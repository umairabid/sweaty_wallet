# frozen_string_literal: true

module Connectors
  class Rbc < Connectors::Base
    include Connectors::Connectable

    def initialize(connector_params)
      @params = connector_params.with_indifferent_access
      set_connector
      @browser = Ferrum::Browser.new(headless: true)
      @page = @browser.create_page
    end

    def call
      broadcast({ status: 'logging_in' })
      sleep(5)
      broadcast({ status: 'confirm_two_factor_notification' })
      two_factor_key = wait_for_connector_prompt(:two_factor_key)
      broadcast({ status: 'received_connector_prompt' })
      sleep(5)
      broadcast({ status: 'login_complete' })
    end

    def call_fa
      @page.go_to('https://secure.royalbank.com/statics/login-service-ui/index#/full/signin')
      broadcast({ status: 'logging_in' })

      wait_and_fill_node("//input[@id='userName']", @params[:username])
      sleep(5)
      wait_and_click_node("//a[@id='signinNext']")

      wait_and_fill_node("//input[@id='password']", @params[:password])
      sleep(10)
      wait_and_click_node("//button[@id='signinNext']")

      wait_for_node(@page, '//core-banking-trusted-device-notification')
      broadcast({ status: 'confirm_two_factor_notification' })

      wait_for_connector_prompt(:two_factor_key)
      broadcast({ status: 'received_connector_prompt' })
      @page.go_to('https://www1.royalbank.com/sgw1/olb/index-en/#/summary')

      wait_for_node(@page, '//rbc-account-summary-layout')
      broadcast({ status: 'login_complete' })
      @browser.quit
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
end
