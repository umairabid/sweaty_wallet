class Connectors::Rbc < Connectors::Base
  include Connectors::Connectable

  def initialize(connector_params)
    @params = connector_params.with_indifferent_access
    set_connector
    @browser = Ferrum::Browser.new(headless: false)
    @page = @browser.create_page
  end

  def call_fa
    broadcast({ status: "logging_in" })
    sleep(5)
    broadcast({ status: "confirm_two_factor_notification" })
    two_factor_key = wait_for_connector_prompt(:two_factor_key)
    broadcast({ status: "received_connector_prompt" })
    puts two_factor_key
  end

  def call
    @page.go_to("https://secure.royalbank.com/statics/login-service-ui/index#/full/signin")
    broadcast({ status: "logging_in" })
    return
    
    wait_and_fill_node("//input[@id='userName']", @params[:username])
    sleep(10)
    wait_and_click_node("//a[@id='signinNext']")
    
    wait_and_fill_node("//input[@id='password']", @params[:password])
    sleep(10)
    wait_and_click_node("//button[@id='signinNext']")

    sleep(20)

    @page.screenshot(path: "rbc-login.png")
    wait_for_node(@page, "//core-banking-trusted-device-notification")
    broadcast({ status: "confirm_two_factor_notification" })

    wait_for_connector_prompt(:two_factor_key)
    broadcast({ status: "received_connector_prompt" })
    @page.screenshot(path: "rbc-login-3.png")
    @page.go_to("https://www1.royalbank.com/sgw1/olb/index-en/#/summary")
    
    wait_for_node(@page, "//rbc-account-summary-layout")
    @page.screenshot(path: "rbc-login-4.png")
    broadcast({ status: "login_complete" })
    @page.screenshot(path: "rbc-login-2.png")
    browser.quit
  end

  private

  def wait_and_click_node(selector)
    node = wait_for_node(@page, selector)
    node.click
  end

  def wait_and_fill_node(selector, fill_value)
    node = wait_for_node(@page, selector)
    node.focus.type(fill_value)
  end

  def channel_name
    "bank_connector_#{@params[:bank]}_#{@params[:user_id]}"
  end
end
