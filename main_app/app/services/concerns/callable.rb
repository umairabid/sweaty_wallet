module Callable

  extend ActiveSupport::Concern


  class_methods do
    def call(*args)
      obj = new(*args)
      obj.call
    end
  end

  
end
