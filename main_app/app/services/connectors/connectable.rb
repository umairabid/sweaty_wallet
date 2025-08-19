module Connectors::Connectable
  private

  def set_connector
    @connector = Connector.find_by(user_id: @params[:user_id],
      bank: @params[:bank]) || Connector.build(@params)
    @connector.status = 'connecting'
    @connector.two_factor_key = nil
    if @connector.auth_type == 'transient'
      @connector.username = nil
      @connector.password = nil
    end
    @connector.save!
  end

  def wait_for_node(page, selector, max_tries: 5, current_try: 0, delay: 5)
    raise 'Cannot find node' if current_try > max_tries

    begin
      node = page.at_xpath(selector)
      return node if node.present?
    rescue Ferrum::NodeNotFoundError
    end
    sleep(delay)
    wait_for_node(page, selector, max_tries:, current_try: current_try + 1, delay:)
  end

  def wait_for_connector_prompt(attr, max_tries: 5, current_try: 0, delay: 10)
    raise 'Timedout for prompt' if current_try > max_tries

    @connector.reload
    return @connector.send(attr) if @connector.send(attr).present?

    sleep(delay)
    wait_for_connector_prompt(attr, max_tries:, current_try: current_try + 1, delay:)
  end

  def broadcast(message)
    ActionCable.server.broadcast(channel_name, message)
  end

  def channel_name
    raise 'Not Implemented...'
  end
end
