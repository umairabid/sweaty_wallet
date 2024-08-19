class TransactionRulesController < ApplicationController
  before_action :set_user_references, only: %i[edit update new]
  before_action :set_rule, only: %i[update edit conditions]

  def index
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
