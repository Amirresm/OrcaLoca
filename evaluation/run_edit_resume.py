"""Resume driver: run ONLY the edit stage on top of already-saved search output.

run.py always runs trace -> search -> edit per instance. If you already have the
expensive trace+search results on disk (output/<id>/searcher_<id>.json), this
loads each one and runs just the edit agent, writing output/<id>/editor_<id>.patch.

It's resume-safe: instances without a searcher_*.json are skipped, and instances
that already have an editor_*.patch are skipped, so you can re-run it freely.

Usage mirrors run.py (same flags: --model, --dataset, --split, --container_name,
--instance_ids/--filter_instance, --cfg_path). Run it from the dir that holds the
`output/` tree (the run-* scripts cd into $ORCA_DATA, which is where it lives).
"""
import os
import sys
import time

# Make `from run import ...` work regardless of CWD.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from run import parse_inputs, stop_container_by_name  # noqa: E402

from Orcar import OrcarAgent  # noqa: E402
from Orcar.environment.benchmark import get_repo_dir  # noqa: E402
from Orcar.gen_config import Config, get_llm  # noqa: E402
from Orcar.load_cache_dataset import load_filter_hf_dataset  # noqa: E402
from Orcar.log_utils import set_log_dir  # noqa: E402
from Orcar.types import SearchOutput  # noqa: E402


def run_edit_only(agent: OrcarAgent, inst: dict, search_json: str) -> None:
    """Set up per-instance state like OrcarAgent.run() does, then run only edit."""
    agent.inst = inst
    agent.inst_id = inst["instance_id"]
    agent.log_dir = f"{agent.base_log_dir}/{agent.inst_id}"
    agent.output_dir = f"./output/{agent.inst_id}"
    agent.repo_name = get_repo_dir(inst["repo"])
    agent.repo_path = os.path.join(agent.base_path, agent.repo_name)
    set_log_dir(agent.log_dir)
    os.makedirs(agent.output_dir, exist_ok=True)

    with open(search_json) as f:
        search_output = SearchOutput.model_validate_json(f.read())

    def _do():
        # Check out the repo for this instance in the container, then edit.
        agent.env.setup(inst)
        agent.run_edit_agent(search_output)

    if agent.redirect_log:
        os.makedirs(agent.log_dir, exist_ok=True)
        log_file = f"{agent.log_dir}/orcar_edit_{agent.inst_id}.log"
        with open(log_file, "w") as fh:
            old_out, old_err = sys.stdout, sys.stderr
            sys.stdout = sys.stderr = fh
            try:
                _do()
            finally:
                sys.stdout, sys.stderr = old_out, old_err
    else:
        _do()


def main():
    args = parse_inputs()
    args.final_stage = "edit"  # this driver only does edit
    cfg = Config(args.cfg_path)
    llm = get_llm(model=args.model, max_tokens=4096, orcar_config=cfg)
    ds = load_filter_hf_dataset(args)

    agent = OrcarAgent(args=args, llm=llm, final_stage="edit")
    agent.set_redirect_log(args.redirect_log)

    n = len(ds)
    done = skipped = failed = 0
    for i, inst in enumerate(ds):
        inst = dict(inst)
        inst_id = inst["instance_id"]
        search_json = f"./output/{inst_id}/searcher_{inst_id}.json"
        patch_file = f"./output/{inst_id}/editor_{inst_id}.patch"

        if not os.path.exists(search_json):
            print(f"({i+1:03d}/{n:03d}) SKIP {inst_id}: no searcher output")
            skipped += 1
            continue
        if os.path.exists(patch_file):
            print(f"({i+1:03d}/{n:03d}) SKIP {inst_id}: patch already exists")
            skipped += 1
            continue

        print(f"({i+1:03d}/{n:03d}) EDIT {inst_id}")
        try:
            # mirror run.py's env health check + container restart
            try:
                agent.env.run_with_handle("ls", err_msg="ls failed")
            except Exception as e:
                print(f"  env unhealthy ({e}); restarting container...")
                del agent
                time.sleep(5)
                stop_container_by_name(args.container_name)
                agent = OrcarAgent(args=args, llm=llm, final_stage="edit")
                agent.set_redirect_log(args.redirect_log)

            run_edit_only(agent, inst, search_json)
            done += 1
        except Exception as e:
            print(f"  EDIT FAILED for {inst_id}: {e}")
            failed += 1

    print(f"\nedit-resume done: {done} written, {skipped} skipped, {failed} failed")


if __name__ == "__main__":
    main()
