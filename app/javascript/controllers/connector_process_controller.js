import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  connect() {
    const form = document.getElementById('new_connector_form');
    form.classList.add('hidden');
    consumer.subscriptions.create(this.channel_params(), {
      connected() {
        // Called when the subscription is ready for use on the server
        console.log('connected')
      },
    
      disconnected() {
        // Called when the subscription has been terminated by the server
      },
    
      received(data) {
        console.log(data)
      }
    });
  }

  channel_params() {
    return {
      channel: "BankConnectorChannel", 
      user_id: this.element.dataset.user_id,
      bank_id: this.element.dataset.bank_id
    }
  }

  close_modal() {
    this.dispatch('close_modal')
  }
}
