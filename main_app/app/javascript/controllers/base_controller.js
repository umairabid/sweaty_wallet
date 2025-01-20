import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  removeBackdrop() {
    const backdrop = document.getElementsByClassName('drawer-backdrop')[0]
    if (backdrop) {
      backdrop.remove()
      document.getElementsByTagName('body')[0].classList.toggle('overflow-hidden')
    }
  }
}