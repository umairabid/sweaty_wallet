import MessageController from './message_controller.js';

new MessageController();


(function (
  request,
  sender,
  sendResponse
) {
  if (request.message == "ping_rbc") {
    const rbc_port = ports.get_rbc_port();
    if (!rbc_port) {
      sendResponse({ status: "rbc_not_found" });
      return;
    }
    rbc_port.execute_command(
      "ping",
      { message: "are you alive" },
      (response) => {
        if (response.received) {
          sendResponse({ success: true, status: "found_rbc" });
          return;
        }
      }
    );
  } else if (request.message == "pull_accounts_rbc") {
    const rbc_port = ports.get_rbc_port();
    rbc_port.execute_command("pull_accounts", {}, (response) => {
      sendResponse({
        success: true,
        status: 'pulled_accounts',
        accounts: response,
      });
    });
  } else if (request.message == "pull_transactions_rbc") {
    const rbc_port = ports.get_rbc_port();
    rbc_port.execute_command(
      `pull_tranactions_${request.type}`,
      { encrypted_identifier: request.encrypted_identifier, identifier: request.identifier },
      (response) => {
        sendResponse({
          success: true,
          status: `pulled_transactions_for_${request.type}`,
          external_id: request.identifier,
          transactions: response,
        });
      }
    );
  }
});
