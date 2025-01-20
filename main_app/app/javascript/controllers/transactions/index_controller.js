import BaseController from "controllers/base_controller"
import create_drawer from "lib/create_drawer"
import create_modal from "lib/create_modal"

export default class extends BaseController {
  connect() {
    this.init_search_drawer()
    this.init_columns_modal()
  }

  open_search() {
    this.advance_search_drawer.show()
  }

  close_search() {
    this.advance_search_drawer.hide()
  }

  init_search_drawer() {
    this.advance_search_drawer = create_drawer(`advance_search_drawer`)
  }

  init_columns_modal() {
    this.columns_modal = create_modal("select_columns_modal");
  }

  close_columns_modal() {
    this.columns_modal.hide()
  }

  open_columns_modal() {
    this.columns_modal.show()
  }
}
