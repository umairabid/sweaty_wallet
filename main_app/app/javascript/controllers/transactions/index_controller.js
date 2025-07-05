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
    const ids = this.extractTransactionRowIdsByClass()
    const promise = blockingJob({ url, params: { ids } })
    promise.then(result => {
      const currentUrl = new URL(window.location.href);
      currentUrl.searchParams.append('with_suggestions', 1)
      Turbo.visit(currentUrl.toString())
    })
  }

  extractTransactionRowIdsByClass() {
    const ids = [];
    // Selects all elements that have the class "transaction_row"
    const elements = document.querySelectorAll('.transaction_row');

    elements.forEach(element => {
      const id = element.id; // Get the ID attribute of the element

      // Ensure the ID actually starts with 'transaction_row_' to extract the number
      // (It's good practice to double-check, though elements with this class usually follow the ID pattern)
      if (id.startsWith('transaction_row_')) {
        const numericalPart = id.substring('transaction_row_'.length);
        const numericalId = parseInt(numericalPart, 10);

        if (!isNaN(numericalId)) {
          ids.push(numericalId);
        }
      }
    });

    return ids;
  }
}
