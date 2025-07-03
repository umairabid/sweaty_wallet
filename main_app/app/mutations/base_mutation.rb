class BaseMutation
  include Callable

  class << self
    def default_opts
      @default_opts ||= { safe_params: false }.freeze
    end

    def opts
      @opts ||= default_opts.dup
    end

    def configure(&block)
      current_config = opts
      yield(current_config)
      current_config.freeze
    end
  end
  
  def initialize(user, model, params, opts = nil)
    @user = user
    @model = model
    @params = params
  end

end

