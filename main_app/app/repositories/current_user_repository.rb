class CurrentUserRepository
  delegate :connectors, to: :@base_scope
  delegate :accounts, to: :@base_scope

  def initialize(base_scope)
    @base_scope = base_scope
  end

  def categories
    @base_scope.categories.where.not(parent_category_id: nil).order(name: :asc).preload(:parent_category)
  end

  def parent_categories
    @base_scope.categories.where(parent_category_id: nil)
  end

  def transaction_rules
    @base_scope.transaction_rules.order(name: :asc)
  end

  def select_options
    @select_options ||= UserSelectOptions.call(self)
  end
end
