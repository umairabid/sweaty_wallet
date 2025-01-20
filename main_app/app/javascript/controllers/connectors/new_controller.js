import BaseController from "../base_controller"
import create_modal from "lib/create_modal";

export default class extends BaseController {
  connect() {
    this.get_modal().show();
    this.on_bank_change = this.on_bank_change.bind(this);
    if (this.bank_dropdown())
      this.bank_dropdown().addEventListener("change", this.on_bank_change);
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
    return create_modal("new_connector");
  }

  bank_dropdown() {
    return document.getElementById("new_banks")
  }

  on_bank_change() {  
    const bank_id = this.bank_dropdown().value
    
    fetch(`/connectors/new?bank=${bank_id}`, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}
