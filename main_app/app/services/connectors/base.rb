# frozen_string_literal: true

module Connectors
  class Base
    def self.call(*args)
      obj = new(*args)
      obj.call
    end
  end
end
