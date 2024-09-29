import { Controller } from "@hotwired/stimulus"
import create_drawer from "../../lib/create_drawer"

export default class extends Controller {
  connect() {
    this.init_transaction_form_drawer()
  }

  open_drawer() {
    this.form_drawer.show()
  }

  close_edit_drawer() {
    this.form_drawer.hide()
  }

  init_transaction_form_drawer() {
    this.form_drawer = create_drawer(`drawer-transaction-form-${this.element.dataset.transaction_id}`)
  }
}
