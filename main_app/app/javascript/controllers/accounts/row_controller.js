import BaseController from "../base_controller"
import create_drawer from "lib/create_drawer"

export default class extends BaseController {
  connect() {
    this.removeBackdrop()
  }

  open_drawer() {
    this.get_drawer().show()
  }

  close_drawer() {
    this.get_drawer().hide()
  }

  get_drawer() {
    if (this.drawer) return this.drawer
    this.drawer = create_drawer(`drawer-account-form-${this.account_id()}`)
    return this.drawer
  }

  account_id() {
    return this.element.dataset.account_id
  }
}
