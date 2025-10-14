import docReady from "../../utils/docReady.js";
import { pullAccounts } from "./pull_accounts.js";

const ACCOUNTS_URL = "https://app.sweatywallet.ca/example_banks";


function onTabLoad() {
  const port = chrome.runtime.connect({ name: "example_port" });
  const current_url = window.location.href;
  const is_accounst_page = current_url === ACCOUNTS_URL;

  if (is_accounst_page) {
    port.postMessage({ name: "redirect_to_accounts_page"});
  }

  port.onMessage.addListener((msg) => {
    if (msg.name === "ping") {
      port.postMessage({ name: msg.name, params: { received: true } });
    } else if (msg.name === "redirect_to_accounts_page") {
      console.log("Redirect to accounts page command received");
      window.location.href = msg.params.url;
    } else if (msg.name === "pull_accounts") {
      console.log("Pull accounts command received");
      const accounts = pullAccounts();
      console.log(accounts);
      port.postMessage({ name: msg.name, params: accounts });
    }
  });
}

docReady(onTabLoad);
