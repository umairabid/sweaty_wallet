class Transactions::ListComponent < ViewComponent::Base
  include Pagy::Backend

  def initialize(user:, columns: nil, filter: nil, page: 1)
    @params = params
    @columns = columns || Transaction::DEFAULT_COLUMNS.map { |k| [k, '1'] }.to_h
    @filter = filter
    @page = page
    @user = user
    set_user_references
    set_transactions
  end

  private

  def params
    { page: [@page.to_i || 0, 1].max }
  end

  def set_transactions
    scope = @user.transactions
    scope = Transactions::ScopeBuilder.call(@filter, scope) if @filter.present?
    @pagy, @transactions = pagy_countless(scope)
  end

  def user_repo
    @user_repo ||= CurrentUserRepository.new(@user)
  end

  def set_user_references
    @user_references = user_repo.select_options
  end
end
