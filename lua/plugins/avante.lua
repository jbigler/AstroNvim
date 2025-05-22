return {
  "yetone/avante.nvim",
  opts = {
    auto_suggestions_provider = "copilot",
    provider = "copilot",
    copilot = {
      -- model = "claude-3.7-sonnet",
      model = "o3-mini",
      temperature = 0,
      max_tokens = 8192,
    },
    rag_service = {
      enabled = false,
      host_mount = os.getenv "HOME" .. "/workspace/filial", -- Mount the workspace directory
      runner = "docker",
      provider = "ollama", -- The provider to use for RAG service (e.g. openai or ollama)
      llm_model = "llama3.2", -- The LLM model to use for RAG servicee
      embed_model = "", -- The embedding model to use for RAG service
      endpoint = "http://localhost:11434", -- The API endpoint for RAG service
    },
  },
}
