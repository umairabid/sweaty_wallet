import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";
import ConnectorExtension from "lib/connector_extension";
import handle_message from "lib/handle_message";

export default class extends Controller {
  connect() {
    this.handle_success = this.handle_success.bind(this);
    this.handle_error = this.handle_error.bind(this);
    this.connect_with_bank = this.connect_with_bank.bind(this);
    this.pull_accounts = this.pull_accounts.bind(this);
    this.pull_transactions = this.pull_transactions.bind(this);
    this.get_modal().show();
    this.extension = new ConnectorExtension(this.element.dataset.extension_id);
    this.connect_with_extension();
  }

  connect_with_extension() {
    this.progress_spinner().classList.remove("hidden");
    this.error_messages_alert().classList.add("hidden");
    this.extension
      .is_connected()
      .then(this.extension.ping)
      .then(this.handle_success)
      .then(this.connect_with_bank)
      .then(this.handle_success)
      .then(this.pull_accounts)
      .then(this.handle_success)
      .then(this.pull_transactions)
      .then(this.handle_success)
      .catch(this.handle_error);
  }

  handle_success(data) {
    console.log(data);
    return new Promise((resolve) => {
      setTimeout(() => {
        handle_message("progress-message", data.status);
        return resolve(data);
      }, 1000);
    });
  }

  handle_error(data) {
    console.log(data);
    this.progress_spinner().classList.add("hidden");
    this.error_messages_alert().classList.remove("hidden");
    handle_message("progress-message");
    handle_message("error-message", data.status);
  }

  connect_with_bank() {
    return this.extension
      .send_message_with_response_timeout({
        message: `ping_${this.element.dataset.bank}`,
      })
      .catch((data) => {
        if (data.status == "message_failed") {
          throw { status: "rbc_not_found" };
        }
      });
  }

  pull_accounts() {
    return this.extension.send_message_with_response_timeout({
      message: `pull_accounts_${this.element.dataset.bank}`,
    });
  }

  pull_transactions(response) {
    const transactions = {};
    const accounts_with_transactions = response.accounts.filter((a) =>
      ["credit_card", "deposit_account"].includes(a.type)
    );
    const promises = accounts_with_transactions.map((a) => {
      const message = {
        message: `pull_transactions_${this.element.dataset.bank}`,
        type: a.type,
        identifier: a.external_id,
        encrypted_identifier: a.encrypted_external_id
      };
      return this.extension.send_message_with_response_timeout.bind(
        this.extension,
        message
      );
    });
    let promiseChain = Promise.resolve(); // Start with a resolved promise
    promises.forEach((promise) => {
      promiseChain = promiseChain.then(() =>
        this.wrap_promise_in_delay(promise, 5000)
        .then(res => {
          transactions[res.external_id] = res.transactions;
        })

      )
    });

    return promiseChain.then(() => {
      console.log(transactions);
      return { status: 'pulled_transactions' };
    });
  }

  wrap_promise_in_delay(promise, delayTime) {
    return new Promise((resolve, reject) => {
      promise()
        .then((result) => {
          this.delay(delayTime).then(() => resolve(result)); // Schedule next execution after delay
        })
        .catch((error) => reject(error)); // Propagate errors
    });
  }

  delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  progress_spinner() {
    return document.getElementById("progress-spinner");
  }

  error_messages_alert() {
    return document.getElementById("error-messages");
  }

  get_modal() {
    if (!this.modal) {
      this.modal = this.create_modal();
    }
    return this.modal;
  }

  close_modal() {
    this.get_modal().hide();
  }

  create_modal() {
    const $targetEl = document.getElementById("new_connector");

    // options with default values
    const options = {
      placement: "bottom-right",
      backdrop: "dynamic",
      backdropClasses: "bg-gray-900/50 dark:bg-gray-900/80 fixed inset-0 z-40",
      closable: true,
      onHide: () => {
        console.log("modal is hidden");
      },
      onShow: () => {},
      onToggle: () => {
        console.log("modal has been toggled");
      },
    };

    // instance options object
    const instanceOptions = {
      id: "connector-modal",
      override: true,
    };

    return new Modal($targetEl, options, instanceOptions);
  }
}
