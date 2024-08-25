import { Controller } from "@hotwired/stimulus"

import create_modal from "../../lib/create_modal"
import consumer from "channels/consumer"

export default class extends Controller {
  connect() {
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
        if (data.status == 'processing') {
          this.status_message().innerHTML = data.html
        } else if (data.status == 'success') {
          this.progress_message().innerHTML = 'Success!'
          this.progress_spinner().classList.add('hidden')
          this.status_message().innerHTML = data.html
        }
      }
    })
  }

  close_modal() {
    this.get_modal().hide()
  }

  progress_spinner() {
    return document.getElementById("progress-spinner")
  }

  progress_message() {
    return document.getElementById("progress-message")
  }

  status_message() {
    return document.getElementById("status-message")
  }
}
