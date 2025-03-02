class TransactionFilter
  attr_reader :query,
              :categories,
              :time_range,
              :account_type,
              :bank,
              :type,
              :account_id,
              :selects,
              :show_duplicates

  FILTERABLE_ACCOUT_TYPES = [:credit_card, :deposit_account]

  def initialize(user, params = {})
    @user = user
    @query = params[:query] || ""
    @categories = params[:categories] || ""
    @time_range = params[:time_range] || ""
    @bank = params[:bank] || ""
    @account_type = params[:account_type] || ""
    @type = params[:type] || ""
    @account_id = params[:account_id] || ""
    @show_duplicates = params[:show_duplicates] == "1"
    set_select_options
  end

  def apply(scope)
    scope = scope.joins(account: :connector).preload(:category)
    if has? :query
      scope = scope.where("description ilike ?", "%#{query}%")
    end

    if has? :bank
      scope = scope.where(accounts: { connectors: { bank: bank } })
    end

    if has? :time_range
      end_date = Time.now.to_date
      start_date = end_date - time_range.to_i.months
      scope = scope.where(date: start_date..end_date)
    end

    if has? :type
      scope = scope.where(is_credit: type == "credit")
    end

    if has? :account_id
      scope = scope.where(account_id: account_id)
    end

    if has? :account_type
      scope = scope.where(account: { account_type: account_type })
    end

    if has? :categories
      cats = categories.select { |id| id.to_i > 0 }
      if categories.any? { |id| id == "-1" }
        cats << nil
      end
      scope = scope.where(category_id: cats) unless cats.empty?
    end

    if has? :show_duplicates
      duplicate_scope = scope
        .select(:date, :description, :amount, :is_credit, :account_id)
        .group(:date, :description, :amount, :is_credit, :account_id)
        .having("count(*) > 1")
        .pluck(:date, :description, :amount, :is_credit, :account_id)

      scope = scope.where(date: duplicate_scope.map { |d| d[0] })
        .where(description: duplicate_scope.map { |d| d[1] })
        .where(amount: duplicate_scope.map { |d| d[2] })
        .where(is_credit: duplicate_scope.map { |d| d[3] })
        .where(account_id: duplicate_scope.map { |d| d[4] })
    end

    scope = scope.order(date: :desc).preload(account: :connector)
  end

  private

  def has?(name)
    self.send(name).present?
  end

  def set_select_options
    @selects = {
      **current_user_repo.fetch_referencables,
      time_ranges: [["Select Duration", ""], ["Last Month", 1], ["Last Two Months", 2], ["Last Three Months", 3]],
      types: [["Select Type", ""], ["Credit", "credit"], ["Debit", "debit"]],
    }
  end

  def current_user_repo
    @users_repo ||= CurrentUserRepository.new(@user)
  end
end
