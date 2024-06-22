import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

export default class extends Controller {
  connect() {
    this.get_modal().show();
  }

  get_modal() {
    if (!this.modal) {
      this.modal = this.create_modal();
    }
    return this.modal;
  }

  get_subscription() {
    if (this.subscription == null) {
      this.subscription = this.create_subscription();
    }

    return this.subscription;
  }

  disconnect() {
    this.get_subscription().unsubscribe();
  }

  channel_params() {
    return {
      channel: "BankConnectorChannel",
      user_id: this.element.dataset.user_id,
      bank_id: this.element.dataset.bank,
    };
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
      onShow: () => {
        this.get_subscription();
      },
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

  create_subscription() {
    return consumer.subscriptions.create(this.channel_params(), {
      connected() {
        // Called when the subscription is ready for use on the server
        console.log("connected");
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(data) {
        console.log(data["status"]);
        if (data["status"]) {
          const elements = document.getElementsByClassName("progress-message");
          for (let i = 0; i < elements.length; i++) {
            const element = elements[i];
            element.classList.add("hidden");
          }
          const elem = document.getElementById(data["status"]);
          elem.classList.remove("hidden");
        }
      },
    });
  }
}
