class ConnectorExtension {
  constructor() {
    // The ID of the extension we want to talk to.
    var editorExtensionId = "pgfanjlkjfhnooneoaakmmhifnccoklm";

    // Make a simple request:
    console.log('sending message')
    chrome.runtime.sendMessage(
      editorExtensionId,
      {  },
      function (response) {
        console.log(response)
      }
    );
  }
}

export default ConnectorExtension;
