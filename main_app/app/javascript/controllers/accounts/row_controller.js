import { Controller } from "@hotwired/stimulus"
import create_drawer from "lib/create_drawer"

export default class extends Controller {
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
