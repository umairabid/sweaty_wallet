import BaseController from "controllers/base_controller"
import create_drawer from "lib/create_drawer"

export default class extends BaseController {
  connect() {

  }

  open_drawer() {
    this.get_drawer().show()
  }

  close_drawer() {
    this.get_drawer().hide()
  }

  get_drawer() {
    if (!this.drawer) {
      this.drawer = create_drawer(`category_form_${this.element.dataset.category_id}`)
    }
    return this.drawer
  }
}
