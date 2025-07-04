import BaseController from "controllers/base_controller"
import create_drawer from "lib/create_drawer"
import create_modal from "lib/create_modal"
import { blockingJob } from "lib/blocking_job"

export default class extends BaseController {
  connect() {
    this.init_search_drawer()
    this.init_columns_modal()
    this.init_new_transaction_drawer()
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

  init_new_transaction_drawer() {
    this.new_transaction_drawer = create_drawer(`new_transaction_drawer`);
  }

  close_columns_modal() {
    this.columns_modal.hide()
  }

  open_columns_modal() {
    this.columns_modal.show()
  }

  open_add_drawer() {
    this.new_transaction_drawer.show()
  }

  close_add_drawer() {
    this.new_transaction_drawer.hide()
  }

  suggest_categories(event) {
    event.preventDefault()
    const button = event.currentTarget.closest('button')
    const url = button.dataset.action_url
    console.log(url)
    blockingJob({ url })
  }
}
