import BaseController from "../base_controller"
import create_drawer from "lib/create_drawer"

export default class extends BaseController {
  connect() {
    this.open_drawer()
  }

  open_drawer() {
    this.get_drawer().show()
  }

  close_drawer() {
    this.get_drawer().hide()
  }

  get_drawer() {
    if (!this.drawer) {
      this.drawer = create_drawer(`new_category_form`)
    }
    return this.drawer
  }
}
