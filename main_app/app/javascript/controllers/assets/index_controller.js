import BaseController from "controllers/base_controller"
import create_drawer from "lib/create_drawer"

export default class extends BaseController {
  connect() {
    this.init_new_asset_drawer()
  }

  init_new_asset_drawer() {
    this.drawer = create_drawer("new_asset_drawer")
  }

  open_add_drawer() {
    this.drawer.show()
  }

  close_asset_drawer() {
    this.drawer.hide()
  }
}
