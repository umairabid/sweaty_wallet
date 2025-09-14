class Transactions::Model
  ATTRIBUTES = %i[query categories time_range start_date end_date account_type bank type account_id selects
                  show_duplicates transaction_rule_id exclude_transfers].freeze

  attr_reader(*ATTRIBUTES)

  FILTERABLE_ACCOUNT_TYPES = %i[credit_card deposit_account].freeze

  def initialize(user, params = {})
    @user = user
    ATTRIBUTES.each do |attr|
      if attr == :show_duplicates || attr == :exclude_transfers
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
      time_ranges: [
        ['Select Duration', ''],
        ['This Month', 'this_month'],
        ['Last Month', 'last_month'],
        ['Last 30 days', 'thirty_days'],
        ['Last 60 days', 'sixty_days'],
        ['Last 90 days', 'ninety_days']
      ],
      types: [
        ['Select Type', ''],
        %w[Credit credit],
        %w[Debit debit]
      ]
    }
  end

  def current_user_repo
    @current_user_repo ||= CurrentUserRepository.new(@user)
  end
end
