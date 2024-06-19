class Connectors::Rbc < Connectors::Base
  def initialize(connector_params)
    @params = connector_params.with_indifferent_access
    connect_by_browser
  end

  def connect_by_browser
    broadcast 'initializing'
    sleep(4)
    broadcast 'another message'
    return
    browser = Ferrum::Browser.new
    page = browser.create_page
    page.go_to("https://secure.royalbank.com/statics/login-service-ui/index#/full/signin")
    #browser.go_to("https://google.com")
    selector = "//input[@id='userName']"
    user_node = wait_for_node(page, selector)
    user_node.focus.type(@username)

    next_button = wait_for_node(page, "//a[@id='signinNext']")
    next_button.click
    password_node = wait_for_node(page, "//input[@id='password']")
    password_node.focus.type(@password)
    next_button = wait_for_node(page, "//button[@id='signinNext']")
    next_button.click
    sleep(10)
    
    page.screenshot(path: "rbc-login.png")
    browser.quit
  end

  def wait_for_node(page, selector, max_tries: 5, current_try: 0, delay: 1)
    puts "current_try: #{current_try}"
    raise 'Cannot find node' if current_try > max_tries

    node = page.at_xpath(selector)
    return node if node.present?

    sleep(delay)
    wait_for_node(page, selector, max_tries: max_tries, current_try: current_try + 1, delay: delay)
  end

  def broadcast(message)
    puts channel_name.inspect
    ActionCable.server.broadcast(channel_name, message)
  end

  def channel_name
    "bank_connector_#{@params[:bank]}_#{@params[:user_id]}"
  end

end
