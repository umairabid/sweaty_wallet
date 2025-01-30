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

  def has?(name)
    self.send(name).present?
  end

  private

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
