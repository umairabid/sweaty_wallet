class Transactions::Update < BaseMutation
  include Callable
  
  ALLOWED_PARAMS = %i[
    date
    description
    amount
    is_credit
  ].freeze

  def call
    @model.attributes = params.slice(*ALLOWED_PARAMS)
    @model.save!
    @model
  end

  def params
    return @params if self.class.opts[:safe_params]

    @params.permit(*ALLOWED_PARAMS).to_h.symbolize_keys
  end
end

