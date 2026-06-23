import os

import config
from google.oauth2 import service_account
from llama_index.core.llms.llm import LLM
from llama_index.llms.anthropic import Anthropic
from llama_index.llms.openai import OpenAI
from llama_index.llms.vertex import Vertex

from .utils import VertexAnthropicWithCredentials


class Config:
    def __init__(self, file_path=None, provider=None):
        self.file_path = file_path
        if self.file_path and os.path.isfile(self.file_path):
            self.file_config = config.Config(self.file_path)
        else:
            self.file_config = dict()
        self.fallback_config = dict()
        self.fallback_config["OPENAI_API_BASE_URL"] = ""
        self.provider = provider

    def __getitem__(self, index):
        # Values in key.cfg has priority over env variables
        if self.file_config.get(index):
            return self.file_config.get(index)
        if index in os.environ:
            return os.environ[index]
        if index in self.fallback_config:
            return self.fallback_config[index]
        raise KeyError(
            f"Cannot find {index} in either cfg file '{self.file_path}' or env variables"
        )


def get_llm(**kwargs) -> LLM:
    # key.cfg is in the parent directory of this file
    orcar_config: Config = kwargs.get("orcar_config", None)
    model = kwargs.get("model", None)
    if model.startswith("claude"):
        # first check if the provider has been set
        if orcar_config.provider == "vertexanthropic":
            print(f"Using AnthropicVertex model: {model}")
            service_account_path = os.path.expanduser(
                orcar_config["VERTEX_SERVICE_ACCOUNT_PATH"]
            )
            if not os.path.exists(service_account_path):
                raise FileNotFoundError(
                    f"Google Cloud Service Account file not found: {service_account_path}"
                )
            try:
                credentials = service_account.Credentials.from_service_account_file(
                    service_account_path,
                    scopes=["https://www.googleapis.com/auth/cloud-platform"],
                )
                kwargs["credentials"] = credentials
                kwargs["project_id"] = credentials.project_id
                kwargs["region"] = orcar_config["VERTEX_REGION"]
                LLM_func = VertexAnthropicWithCredentials
            except Exception as e:
                raise Exception(f"gen_config: Failed to get vertexanthropic LLM") from e
        else:
            kwargs["api_key"] = orcar_config["ANTHROPIC_API_KEY"]
            LLM_func = Anthropic
    elif model.startswith("gpt"):
        kwargs["api_key"] = orcar_config["OPENAI_API_KEY"]
        LLM_func = OpenAI
    elif orcar_config["OPENAI_API_BASE_URL"]:
        from llama_index.llms.openai_like import OpenAILike

        kwargs["api_key"] = orcar_config["OPENAI_API_KEY"]
        kwargs["api_base"] = orcar_config["OPENAI_API_BASE_URL"]
        kwargs["is_chat_model"] = True
        kwargs["is_function_calling_model"] = True
        try:
            kwargs["context_window"] = int(orcar_config["VLLM_CONTEXT_WINDOW"])
        except (KeyError, ValueError):
            pass
        try:
            kwargs["timeout"] = float(orcar_config["LLM_TIMEOUT"])
        except (KeyError, ValueError):
            kwargs["timeout"] = 600.0
        import httpx

        _http_timeout = httpx.Timeout(kwargs["timeout"])
        kwargs["http_client"] = httpx.Client(timeout=_http_timeout)
        kwargs["async_http_client"] = httpx.AsyncClient(timeout=_http_timeout)
        kwargs["temperature"] = 0.0
        kwargs["additional_kwargs"] = {
            "extra_body": {"chat_template_kwargs": {"enable_thinking": False}}
        }
        LLM_func = OpenAILike
    elif model.startswith("gemini"):
        # Load Google Cloud credentials
        service_account_path = orcar_config["VERTEX_SERVICE_ACCOUNT_PATH"]

        if not os.path.exists(service_account_path):
            raise FileNotFoundError(
                f"Google Cloud Service Account file not found: {service_account_path}"
            )

        credentials = service_account.Credentials.from_service_account_file(
            service_account_path
        )

        kwargs["project"] = credentials.project_id
        kwargs["credentials"] = credentials
        LLM_func = Vertex

    # delete orcar_config from kwargs
    if "orcar_config" in kwargs:
        del kwargs["orcar_config"]

    try:
        llm: LLM = LLM_func(**kwargs)
        _ = llm.complete("Say 'Hi'")
        return llm
    except Exception as e:
        raise Exception(f"Failed to initialize LLM: {e}")
