class ConnectorExtension {
  constructor(editorExtensionId) {
    this.editorExtensionId = editorExtensionId;
    this.ping = this.ping.bind(this);
  }

  is_connected() {
    return new Promise((resolve, reject) => {
      if (!chrome) {
        return reject({ status: "chrome_unavailable" });
      }

      if (!chrome.runtime) {
        return reject({ status: "no_accessible_extension" });
      }

      return resolve({ status: "runtime_found" });
    })
  }

  ping() {
    return this.send_message_with_response_timeout({message: 'ping'})
      .then((res) => {
        return { status: 'installed' }
      })
      .catch((res) => {
        if (res.status == 'unable_to_reach_extension' || res.status == 'message_failed')
        throw {status: 'not_installed'};
      })
  }

  send_message_with_response_timeout(message, timeout = 20000) {
    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        return reject({ status: "unable_to_reach_extension" });
      }, timeout);
      try {
        chrome.runtime.sendMessage(
          this.editorExtensionId,
          message,
          (response) => {
            clearTimeout(timeoutId);
            if (response.success) {
              return resolve(response);
            } else {
              return reject({ status: "message_failed" });
            }
          }
        );
      } catch (err) {
        return reject({ status: "unable_to_reach_extension" });
      }
    });
  }
}

export default ConnectorExtension;
