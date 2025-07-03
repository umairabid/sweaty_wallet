class BaseMutation
  include Callable

  class << self
    def default_opts
      @default_opts ||= { safe_params: false }.freeze
    end

    def opts
      @opts ||= default_opts.dup
    end

    def configure
      current_config = opts
      yield(current_config)
      current_config.freeze
    end
  end

  def initialize(user, model, params)
    @user = user
    @model = model
    @params = params
  end

  def call
    before_mutate
    mutate
    after_mutate
    @model
  end

  private

  def params
    return @params.slice(allowed_params) if self.class.opts[:safe_params]

    @params.permit(allowed_params).to_h.symbolize_keys
  end

  def before_mutate
    nil
  end

  def after_mutate
    nil
  end

  def allowed_params
    []
  end
end
