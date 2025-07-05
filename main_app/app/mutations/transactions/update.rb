class Transactions::Update < BaseMutation
  include Callable

  private

  def mutate
    @model.attributes = params
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
