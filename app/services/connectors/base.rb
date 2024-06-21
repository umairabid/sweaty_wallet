class Connectors::Base
  def self.call(*args)
    obj = new(*args)
    obj.call
  end
end
