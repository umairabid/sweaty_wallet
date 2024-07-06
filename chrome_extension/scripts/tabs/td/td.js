import docReady from "../../utils/docReady"
import pullAccounts from "./pull_accounts"
import pullDepositAccount from "./pull_deposit_account"
import pullCreditCardAccount from "./pull_credit_card_account"

const TD_NEW_FRONTEND_URL = "https://easyweb.td.com/ui"
const TD_OLD_FRONTEND_URL = "https://easyweb.td.com/waw"
const TD_CREDIT_CARD_URL = "https://easyweb.td.com/waw/webui"
const TD_DEPOSIT_ACC_URL = "https://easyweb.td.com/ui/ew/da"

function onTabLoad() {
  const port = chrome.runtime.connect({ name: "td_port" })
  const current_url = window.location.href

  const is_new_frontend = current_url.startsWith(TD_NEW_FRONTEND_URL)
  const is_old_frontend = current_url.startsWith(TD_OLD_FRONTEND_URL)
  const is_credit_card = current_url.startsWith(TD_CREDIT_CARD_URL)
  const is_deposite_acc_url = current_url.startsWith(TD_DEPOSIT_ACC_URL)

  if (is_credit_card) {
    port.postMessage({ name: "redirect_to_credit_card_url" })
  } else if (is_deposite_acc_url) {
    port.postMessage({ name: "redirect_to_deposit_acc_url" })
  } else if (is_new_frontend) {
    port.postMessage({ name: "redirect_to_new_frontend_url" })
  } else if (is_old_frontend) {
    port.postMessage({ name: "redirect_to_old_frontend_url" })
  }

  port.onMessage.addListener((msg) => {
    if (msg.name === "ping") {
      port.postMessage({ name: msg.name, params: { received: true } })
    } else if (msg.name === "redirect_to_new_frontend_url") {
      window.location.href = msg.params.url
    } else if (msg.name === "redirect_to_old_frontend_url") {
      window.location.href = msg.params.url
    } else if (msg.name === "redirect_to_credit_card_url") {
      window.location.href = msg.params.url
    } else if (msg.name === "redirect_to_deposit_acc_url") {
      window.location.href = msg.params.url
    } else if (msg.name === "pull_accounts") {
      pullAccounts(msg).then((res) => port.postMessage(res))
    } else if (msg.name === "pull_transactions_credit_card") {
      pullCreditCardAccount(msg).then((res) => {
        port.postMessage(res)
      })
    } else if (msg.name === "pull_transactions_deposit_account") {
      pullDepositAccount(msg).then((res) => {
        port.postMessage(res)
      })
    }
  })
}

docReady(onTabLoad)
