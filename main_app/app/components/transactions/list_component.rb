class Transactions::ListComponent < ViewComponent::Base
  include Pagy::Backend

  DEFAULT_OPTIONS = {
    with_suggestions: false,
    show_pagination: true
  }.freeze

  def initialize(**args)
    @options = args[:options] || DEFAULT_OPTIONS
    
    @columns = args[:columns] || Transaction::DEFAULT_COLUMNS.to_h { |k| [k, '1'] }
    @columns['suggested_category'] = '1' if @options[:with_suggestions]
    
    @filter = args[:filter]
    @page = args[:page] || 1
    @user = args[:user]
    @limit = args[:limit] || Pagy::DEFAULT[:limit]
    @sort = args[:sort] || { date: :desc, id: :asc }
    set_user_references
  end

  private

  def before_render
    set_transactions
  end

  def params
    { page: [@page.to_i, 1].max }
  end

  def set_transactions
    scope = @user.transactions.preload(:account)
    scope = Transactions::ScopeBuilder.call(@filter, scope) if @filter.present?
    scope = scope.order(@sort)
    @pagy, @transactions = pagy_countless(scope, limit: @limit,
      request_path: helpers.transactions_path)
  end

  def user_repo
    @user_repo ||= CurrentUserRepository.new(@user)
  end

  def set_user_references
    @user_references = user_repo.select_options
  end
end
