module UserSelects
  extend ActiveSupport::Concern

  included do
    def bank_options
      return [] if current_user.blank?

      current_user.connectors.map { |c| [Connector::BANK_NAMES[c.bank], c.id] }
    end

    def account_types
      Account::ACCOUNT_TYPE_LABELS.map { |k, v| [v, k] }
    end

    def categories
      return [] if current_user.blank?

      current_user.categories.where.not(parent_category_id: nil).map { |c| [c.name, c.id] }
    end
  end
end
