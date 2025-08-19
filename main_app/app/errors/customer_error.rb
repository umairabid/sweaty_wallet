class CustomerError < ArgumentError
  def initialize(message = 'Incorrect Input')
    super(message)
  end
end
