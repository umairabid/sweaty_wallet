import { Controller } from "@hotwired/stimulus"
import create_drawer from "lib/create_drawer"
import create_modal from "lib/create_modal"

export default class extends Controller {
  connect() {
    this.init_search_drawer()
    this.init_columns_modal()
  }

  open_search() {
    this.advance_search_drawer.show()
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
