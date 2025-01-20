import BaseController from "../base_controller"
import ConnectorExtension from "lib/connector_extension"
import handle_message from "lib/handle_message"

export default class extends BaseController {
  connect() {
    this.handle_success = this.handle_success.bind(this)
    this.handle_error = this.handle_error.bind(this)
    this.extension = new ConnectorExtension({
      extension_id: this.element.dataset.extension_id,
      bank: this.element.dataset.bank,
      handle_success: this.handle_success,
      handle_error: this.handle_error,
    })
  }

  start_import() {
    document.getElementById("instructions").classList.toggle("hidden")
    document.getElementById("process").classList.toggle("hidden")
    document.getElementById("next_button").classList.toggle("hidden")
    document.getElementById("done_button").classList.toggle("hidden")
    this.import()
  }

  import() {
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
      this.handle_success(data)
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
}
