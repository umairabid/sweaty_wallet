import BaseController from "controllers/base_controller"
import create_drawer from "lib/create_drawer"

export default class extends BaseController {
  connect() {
    this.removeBackdrop()
    this.init_drawer()
  }

  init_drawer() {
    this.drawer = create_drawer("edit_asset_drawer")
  }

  open_drawer() {
    this.drawer.show()
  }

  close_drawer() {
    this.drawer.hide()
  }
}
