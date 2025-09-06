class Transactions::Update < BaseMutation
  private

  def mutate
    update_params = params
    update_params[:category_id] = nil if params.dig(:category_id).to_i < 1
    @model.attributes = update_params
    @model.save!
    @model
  end

  def after_mutate
    return unless @model.description_previously_changed?

    Transactions::ResetEmbeddingsJob.perform_later([@model])
  end

  def allowed_params
    %i[
      date
      description
      amount
      is_credit
      category_id
    ]
  end
end
