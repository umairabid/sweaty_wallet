import { Controller } from "@hotwired/stimulus"

import create_modal from "../../lib/create_modal"
import consumer from "channels/consumer"

export default class extends Controller {
  connect() {
    this.get_modal().show()
    this.channel = this.create_channel()
    console.log(this.channel)
  }

  get_modal() {
    if (!this.modal) {
      this.modal = this.create_modal()
    }
    return this.modal
  }

  create_modal() {
    return create_modal("background_processing_modal")
  }

  create_channel() {
    return consumer.subscriptions.create(
      { 
        channel: "BackgroundProcessChannel",
        job_id: this.element.dataset.job_id
      }, {
      received: (data) => {
        console.log(data)
      }
    })
  }
}
