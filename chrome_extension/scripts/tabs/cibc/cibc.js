import docReady from "../../utils/docReady";
import { pullAccounts } from "./pull_accounts";
import { pullCreditCardTransacttions } from "./pull_credit_card_transactions";
import { pullDepositAccountTransacttions } from "./pull_deposit_account_transactions";

function onTabLoad() {
  const port = chrome.runtime.connect({ name: "cibc_port" });
  const CREDIT_CARD_URL = "http://localhost:8000/credit_card";
  const DEPOSIT_ACC_URL = "http://localhost:8000/deposit_account";

  const current_url = window.location.href;
  const is_credit_card = current_url.startsWith(CREDIT_CARD_URL);
  const is_deposite_acc_url = current_url.startsWith(DEPOSIT_ACC_URL);

  if (is_credit_card) {
    port.postMessage({ name: "redirect_to_credit_card_url" });
  } else if (is_deposite_acc_url) {
    port.postMessage({ name: "redirect_to_deposit_acc_url" });
  }

  port.onMessage.addListener((msg) => {
    console.log("message", msg);
    if (msg.name === "ping")
      return port.postMessage({ name: msg.name, params: { received: true } });
    if (msg.name === "pull_accounts")
      return port.postMessage({ name: msg.name, params: pullAccounts() });
    if (msg.name === "redirect_to_credit_card_url")
      window.location.href = msg.params.url;
    if (msg.name === "redirect_to_deposit_acc_url")
      window.location.href = msg.params.url;
    if (msg.name === "pull_transactions_credit_card")
      return port.postMessage({
        name: msg.name,
        params: pullCreditCardTransacttions(msg.params.identifier),
      });
    if (msg.name === "pull_transactions_deposit_account")
      return port.postMessage({
        name: msg.name,
        params: pullDepositAccountTransacttions(msg.params.identifier),
      });
  });
}

docReady(onTabLoad);
