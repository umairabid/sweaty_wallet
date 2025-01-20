import BaseController from "controllers/base_controller"
import create_drawer from "lib/create_drawer"

export default class extends BaseController {
  connect() {
    const backdrop = document.getElementsByClassName('drawer-backdrop')[0]
    if (backdrop) {
      backdrop.remove()
      document.getElementsByTagName('body')[0].classList.toggle('overflow-hidden')
    }
  }

  open_drawer() {
    this.get_drawer().show()
  }

  close_edit_drawer() {
    this.get_drawer().hide()
  }

  get_drawer() {
    if (this.drawer) return this.drawer
    this.drawer = create_drawer(`drawer-transaction-form-${this.transaction_id()}`)
    return this.drawer
  }

  transaction_id() {
    return this.element.dataset.transaction_id
  }
}
