class TransactionRulesController < ApplicationController
  before_action :set_user_references, only: %i[edit update new conditions]
  before_action :set_rule, only: %i[update edit conditions]

  def index
    @transaction_rules = current_user.transaction_rules.preload(:category)
  end

  def new
  end

  def create
    rule = current_user.transaction_rules.create!(rule_params)

    redirect_to edit_transaction_rule_path(id: rule.id)
  end

  def edit
  end

  def update
  end

  def conditions
    TransactionRules::PersistCondition.call(@transaction_rule, condition_params)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          :transaction_rules_conditions,
          partial: "transaction_rules/rules_conditions",
          locals: { group: @transaction_rule.conditions, references: @user_references },
        )
      end

      format.html { render :new_extension }
    end
  end

  private

  def condition_params
    params.require(:condition).permit(:type, :category_id, :transaction_type, :tags, :group_id, :join_by)
  end

  def rule_params
    params.require(:transaction_rule).permit(:name, :category_id, :conditions)
  end

  def set_rule
    @transaction_rule = current_user.transaction_rules.find(params[:id])
  end
end
