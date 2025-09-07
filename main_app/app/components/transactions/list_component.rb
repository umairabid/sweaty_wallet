class Transactions::ListComponent < ViewComponent::Base
  include Pagy::Backend

  DEFAULT_OPTIONS = {
    with_suggestions: false,
    show_pagination: true
  }.freeze

  def initialize(user:, columns: nil, filter: nil, page: 1, limit: Pagy::DEFAULT[:limit], options: DEFAULT_OPTIONS)
    @params = params
    @columns = columns || Transaction::DEFAULT_COLUMNS.map { |k| [k, '1'] }.to_h
    @columns['suggested_category'] = '1' if options[:with_suggestions]
    @filter = filter
    @page = page
    @user = user
    @options = options
    @limit = limit
    set_user_references
  end

  private

  def before_render
    set_transactions
  end

  def params
    { page: [@page.to_i || 0, 1].max }
  end

  def set_transactions
    scope = @user.transactions.preload(:account)
    scope = Transactions::ScopeBuilder.call(@filter, scope) if @filter.present?
    @pagy, @transactions = pagy_countless(scope, limit: @limit, request_path: helpers.transactions_path)
  end

  def user_repo
    @user_repo ||= CurrentUserRepository.new(@user)
  end

  def set_user_references
    @user_references = user_repo.select_options
  end
end
