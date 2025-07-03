class Transactions::Create < BaseMutation
  include Callable

  private

  def mutate
    @model.attributes = params
    @model.external_id = SecureRandom.uuid if params[:external_id].blank?
    @model.save!
    @model
  end

  def allowed_params
    %i[
      category_id
      date
      description
      amount
      is_credit
      account_id
      external_id
    ]
  end
end
