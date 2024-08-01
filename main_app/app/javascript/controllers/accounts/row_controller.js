import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const backdrop = document.getElementsByClassName('drawer-backdrop')[0]
    if (backdrop) {
      backdrop.remove()
    }
  }

  open_drawer() {
    this.get_drawer().show()
  }

  get_drawer() {
    if (this.drawer) return this.drawer
    const $targetEl = document.getElementById(`drawer-account-form-${this.account_id()}`)

    // options with default values
    const options = {
      placement: "right",
      backdrop: true,
      bodyScrolling: false,
      edge: false,
      edgeOffset: "",
      backdropClasses: "drawer-backdrop bg-gray-900/50 dark:bg-gray-900/80 fixed inset-0 z-30",
      onHide: () => {
        console.log("drawer is hidden")
      },
      onShow: () => {
        console.log("drawer is shown")
      },
      onToggle: () => {
        console.log("drawer has been toggled")
      },
    }

    // instance options object
    const instanceOptions = {
      id: `drawer-account-form-${this.account_id()}`,
      override: true,
    }

    this.drawer = new Drawer($targetEl, options, instanceOptions);
    return this.drawer
  }

  account_id() {
    return this.element.dataset.account_id
  }
}
