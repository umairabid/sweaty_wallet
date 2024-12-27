import { Controller } from "@hotwired/stimulus";
import create_modal from "lib/create_modal";
import Dropzone from "dropzone";

export default class extends Controller {
  connect() {
    this.init_dropzone();
    this.get_modal().show();
    this.on_bank_change = this.on_bank_change.bind(this);
    if (this.bank_dropdown())
      this.bank_dropdown().addEventListener("change", this.on_bank_change);
  }

  get_modal() {
    if (!this.modal) {
      this.modal = this.create_modal()
    }
    return this.modal
  }

  close_modal() {
    this.get_modal().hide()
  }

  create_modal() {
    return create_modal("new_connector");
  }

  bank_dropdown() {
    return document.getElementById("new_banks")
  }

  on_bank_change() {  
    const bank_id = this.bank_dropdown().value
    console.log(this)
    console.log(bank_id)
    
    fetch(`/connectors/new?bank=${bank_id}`, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
  }

  init_dropzone() {
    const dropzoneConfig = {
      url: "/connectors/import_csv",
      method: "post",
      clickable: true,
      paramName: "csv",
      maxFilesize: 256,
      parallelUploads: "5",
      addRemoveLinks: true,
      acceptedFiles: ".csv",
      maxFiles: 1,
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
      },
      previewTemplate: '',
      // Specifing an event as an configuration option overwrites the default
      // `addedfile` event handler.
      addedfile: function(file) {
        file.previewElement = Dropzone.createElement(this.options.previewTemplate);
        // Now attach this new element some where in your page
      },
      thumbnail: function(file, dataUrl) {
        // Display the image in your file.previewElement
      },
      uploadprogress: function(file, progress, bytesSent) {
        console.log(file, progress, bytesSent)
      }
    };

    this.dropzone = new Dropzone(this.element, dropzoneConfig);
  }
}
