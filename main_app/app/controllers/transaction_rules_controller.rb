class TransactionRulesController < ApplicationController
  before_action :set_user_references, only: %i[edit update new]
  before_action :set_rule, only: %i[update edit]

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

  private

  def rule_params
    params.require(:transaction_rule).permit(:name, :category_id, :conditions)
  end

  def set_rule
    @transaction_rule = current_user.transaction_rules.find(params[:id])
  end
end
