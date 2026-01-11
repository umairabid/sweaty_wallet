import docReady from "../../utils/docReady.js";
import { pullAccounts } from "./pull_accounts.js";
import { pullDepositAccount } from "./pull_deposit_account";
import { pullCreditAccount } from "./pull_credit_account";

const ACCOUNTS_URL = "https://app.sweatywallet.ca/example_banks";
const DEPOSIT_ACC_URL = "https://app.sweatywallet.ca/example_banks/debit";
const CREDIT_ACC_URL = "https://app.sweatywallet.ca/example_banks/credit";


function onTabLoad() {
  const port = chrome.runtime.connect({ name: "example_port" });
  const current_url = window.location.href;
  const is_accounst_page = current_url === ACCOUNTS_URL;
  const is_deposit_account_page = current_url === DEPOSIT_ACC_URL;
  const is_credit_account_page = current_url === CREDIT_ACC_URL;

  if (is_accounst_page) {
    port.postMessage({ name: "redirect_to_accounts_page" });
  } else if (is_deposit_account_page) {
    port.postMessage({ name: "redirect_to_deposit_acc_url" });
  } else if (is_credit_account_page) {
    port.postMessage({ name: "redirect_to_credit_card_url" });
  }


  port.onMessage.addListener((msg) => {
    if (msg.name === "ping") {
      port.postMessage({ name: msg.name, params: { received: true } });
    } else if (msg.name === "redirect_to_accounts_page") {
      window.location.href = msg.params.url;
    } else if (msg.name === "pull_accounts") {
      const accounts = pullAccounts();
      port.postMessage({ name: msg.name, params: accounts });
    } else if (msg.name === "redirect_to_deposit_acc_url") {
      window.location.href = msg.params.url;
    } else if (msg.name === "redirect_to_credit_card_url") {
      window.location.href = msg.params.url;
    } else if (msg.name === "pull_transactions_deposit_account") {
      port.postMessage({ name: msg.name, params: pullDepositAccount(msg.params.encrypted_identifier) })
    } else if (msg.name === "pull_transactions_credit_card") {
      port.postMessage({ name: msg.name, params: pullCreditAccount(msg.params.encrypted_identifier) })
    }
  });
}

docReady(onTabLoad);
