import { Controller } from "@hotwired/stimulus";
import Dropzone from "dropzone";
import consumer from "channels/consumer";
import handle_message from "../../lib/handle_message";

export default class extends Controller {
  connect() {
    this.init_dropzone();
    this.file_input().addEventListener("change", (event) => {
      const files = event.target.files;
      this.dropzone.addFile(files[0]);
    });
  }

  init_dropzone() {
    const dropzoneConfig = {
      url: "/connectors/import_csv?bank=" + this.bank().value,
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
      previewTemplate: "",
      // Specifing an event as an configuration option overwrites the default
      // `addedfile` event handler.
      addedfile: function (file) {
        file.previewElement = Dropzone.createElement(
          this.options.previewTemplate
        );
        // Now attach this new element some where in your page
      },
      thumbnail: function (file, dataUrl) {
        // Display the image in your file.previewElement
      },
      uploadprogress: (file, progress, bytesSent) => {
        this.droppable_area().classList.toggle("hidden")
        this.loading_container().classList.toggle("hidden")
      },
      success: (file, response) => {
        console.log(file, response)
        const sub = this.create_subscription({ channel: "FileImportChannel", file_import_id: response.file_import_id })
      },
    };

    this.dropzone = new Dropzone(this.element, dropzoneConfig);
  }

  file_input() {
    return document.getElementById("dropzone-file");
  }

  bank() {
    return document.getElementById("bank_id");
  }

  loading_container() {
    return document.getElementById("progress-spinner");
  }

  droppable_area() { 
    return document.getElementById("droppable-area")
  }

  create_subscription(params) {
    this.subscription = consumer.subscriptions.create(params, {
      connected() { },

      disconnected() {},

      received(data) {
        console.log(data)
      },
    })

    return this.subscription
  }
}
