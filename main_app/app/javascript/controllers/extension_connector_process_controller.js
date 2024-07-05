import { Controller } from "@hotwired/stimulus"
import ConnectorExtension from "lib/connector_extension"
import handle_message from "lib/handle_message"

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
      .pull_bank()
      .then((data) => {
        console.log(data)
        return fetch("/accounts/import", {
          method: "POST",
          body: JSON.stringify({
            bank: this.element.dataset.bank,
            accounts: data,
          }),
          headers: {
            "Content-Type": "application/json",
          },
        })
      })
      .then((res) => {
        new Response(res.body).json().then((body) => {
          console.log(body)
        })
        return { status: "pulled_transactions" }
      })
      .then(this.handle_success)
  }

  handle_success(data) {
    return new Promise((resolve) => {
      setTimeout(() => {
        handle_message("progress-message", data.status)
        return resolve(data)
      }, 1000)
    })
  }

  handle_error(data) {
    this.progress_spinner().classList.add("hidden")
    this.error_messages_alert().classList.remove("hidden")
    handle_message("progress-message")
    handle_message("error-message", data.status)
    throw data
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
    const $targetEl = document.getElementById("new_connector")

    // options with default values
    const options = {
      placement: "bottom-right",
      backdrop: "dynamic",
      backdropClasses: "bg-gray-900/50 dark:bg-gray-900/80 fixed inset-0 z-40",
      closable: true,
      onHide: () => {},
      onShow: () => {},
      onToggle: () => {},
    }

    // instance options object
    const instanceOptions = {
      id: "connector-modal",
      override: true,
    }

    return new Modal($targetEl, options, instanceOptions)
  }
}
