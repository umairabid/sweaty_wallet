import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  connect() {
    const sub = this.get_subscription()
  }

  get_subscription() {
    if (this.subscription == null) {
      this.subscription = consumer.subscriptions.create(this.channel_params(), {
        connected() {
          // Called when the subscription is ready for use on the server
          
        },

        disconnected() {
          // Called when the subscription has been terminated by the server
        },

        received(data) {
          if (data.status) {
            const elements = document.getElementsByClassName("progress-message")
            for (let i = 0; i < elements.length; i++) {
              const element = elements[i]
              element.classList.add("hidden")
            }
            const elem = document.getElementById(data.status)
            elem.classList.remove("hidden")
          }
        },
      })
    }

    return this.subscription
  }

  disconnect() {
    this.get_subscription().unsubscribe()
  }

  channel_params() {
    return {
      channel: "BankConnectorChannel",
      user_id: this.element.dataset.user_id,
      bank_id: this.element.dataset.bank,
    }
  }

  close_modal() {
    this.dispatch("close_modal")
  }

  send_two_factor() {
    const two_factor_field = document.getElementById("two_factor_field")
    let two_factor_key = "n/a"
    if (two_factor_field) {
      two_factor_key = two_factor_field.value
    }
    this.get_subscription().send({ two_factor_key })
  }
}
