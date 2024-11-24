import { Controller } from "@hotwired/stimulus"
import create_drawer from "lib/create_drawer"

export default class extends Controller {
  connect() {
    this.init_search_drawer()
  }

  open_search() {
    this.advance_search_drawer.show()
  }

  init_search_drawer() {
    this.advance_search_drawer = create_drawer(`advance-search-drawer`)
  }
}
