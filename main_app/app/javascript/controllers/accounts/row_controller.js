import BaseController from "controllers/base_controller";
import create_drawer from "lib/create_drawer";

export default class extends BaseController {
  connect() {
    this.removeBackdrop();
    this.drawer = create_drawer(`drawer-account-form-${this.account_id()}`)
    this.merge_drawer = create_drawer(`drawer-account-merge-form-${this.account_id()}`)
  }

  open_drawer() {
    this.drawer.show();
  }

  close_drawer() {
    this.drawer.hide();
  }

  open_merge_drawer() {
    this.merge_drawer.show();
  }

  close_merge_drawer() {
    this.merge_drawer.hide();
  }

  account_id() {
    return this.element.dataset.account_id;
  }
}
