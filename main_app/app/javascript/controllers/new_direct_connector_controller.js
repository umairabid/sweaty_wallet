import { Controller } from "@hotwired/stimulus";
import { Modal } from "../flowbite_modules";

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
}
