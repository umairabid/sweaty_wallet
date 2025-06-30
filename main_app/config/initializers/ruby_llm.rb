require 'ruby_llm'

RubyLLM.configure do |config|
  config.gemini_api_key = Rails.application.credentials.dig(:google, :gemini_api_key)
  config.default_model = 'gemini-2.5-flash-preview-05-20'
  config.default_embedding_model = 'text-embedding-004'
end
