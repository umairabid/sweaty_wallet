class Transactions::Create < BaseMutation
  include Callable
  
  ALLOWED_PARAMS = %i[
    category_id
    date
    description
    amount
    is_credit
    account_id
    external_id
  ].freeze

  def call
    @model.attributes = params.slice(*ALLOWED_PARAMS)
    @model.external_id = SecureRandom.uuid if params[:external_id].blank?
    @model.save!
    @model
  end

  def params
    return @params if self.class.opts[:safe_params]

    @params.permit(*ALLOWED_PARAMS).to_h.symbolize_keys
  end
end

