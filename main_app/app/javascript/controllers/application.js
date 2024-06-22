import { Application } from "@hotwired/stimulus"
import ConnectorExtension from "lib/connector_extension";
import 'flowbite';

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application
window.ConnectorExtension = new ConnectorExtension();

export { application }
