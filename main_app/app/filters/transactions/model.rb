class Transactions::Model
  ATTRIBUTES = %i[query categories time_range account_type bank type account_id selects
                  show_duplicates].freeze

  attr_reader(*ATTRIBUTES)

  FILTERABLE_ACCOUNT_TYPES = %i[credit_card deposit_account].freeze

  def initialize(user, params = {})
    @user = user

    ATTRIBUTES.each do |attr|
      if attr == :show_duplicates
        instance_variable_set("@#{attr}", params[attr] == '1')
      elsif attr == :categories
        instance_variable_set("@#{attr}", params[attr] || [])
      else
        instance_variable_set("@#{attr}", params[attr] || '')
      end
    end

    set_select_options
  end

  def has?(name)
    send(name).present?
  end

  private

  def set_select_options
    @selects = {
      **current_user_repo.select_options,
      time_ranges: [['Select Duration', ''], ['Last Month', 1], ['Last Two Months', 2],
                    ['Last Three Months', 3]],
      types: [['Select Type', ''], %w[Credit credit], %w[Debit debit]]
    }
  end

  def current_user_repo
    @current_user_repo ||= CurrentUserRepository.new(@user)
  end
end
