import { Controller } from "@hotwired/stimulus"
import ConnectorExtension from "lib/connector_extension"
import handle_message from "lib/handle_message"
import create_modal from "lib/create_modal"

export default class extends Controller {
  connect() {
    this.handle_success = this.handle_success.bind(this)
    this.handle_error = this.handle_error.bind(this)
    this.get_modal().show()
    this.extension = new ConnectorExtension({
      extension_id: this.element.dataset.extension_id,
      bank: this.element.dataset.bank,
      handle_success: this.handle_success,
      handle_error: this.handle_error,
    })
    this.progress_spinner().classList.remove("hidden")
    this.error_messages_alert().classList.add("hidden")
    this.extension
      .pull_bank(this.element.dataset.bank)
      .then((res) => this.handle_sync(res))
  }

  handle_success(data) {
    handle_message("progress-message", data.status)
  }

  handle_error(data) {
    this.progress_spinner().classList.add("hidden")
    this.error_messages_alert().classList.remove("hidden")
    handle_message("progress-message")
    handle_message("error-message", data.status)
  }

  handle_sync(data) {
    if (data.success) {
      this.close_modal()
    } else {
      this.handle_error(data)
    }
  }

  progress_spinner() {
    return document.getElementById("progress-spinner")
  }

  error_messages_alert() {
    return document.getElementById("error-messages")
  }

  get_modal() {
    if (!this.modal) {
      this.modal = this.create_modal()
    }
    return this.modal
  }

  close_modal() {
    this.get_modal().hide()
  }

  create_modal() {
    return create_modal("new_connector")
  }
}
