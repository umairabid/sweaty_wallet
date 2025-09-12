module Callable
  extend ActiveSupport::Concern

  class_methods do
    def call(*args, **kwargs)
      obj = new(*args, **kwargs)
      obj.call
    end
  end
end
