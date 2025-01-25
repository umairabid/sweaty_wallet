const port = chrome.runtime.connect({ name: "rbc_port" })

function getCookie(cookieKey) {
  const allCookies = document.cookie
  const cookieName = `${cookieKey}=` // Add '=' to match the format

  // Look for the cookie with the specified key
  const startIndex = allCookies.indexOf(cookieName)

  if (startIndex === -1) {
    return null // Cookie not found
  }

  const endIndex = allCookies.indexOf(";", startIndex + cookieName.length)

  // Extract the value between the '=' and next ';'
  return endIndex !== -1
    ? decodeURIComponent(allCookies.substring(startIndex + cookieName.length, endIndex))
    : decodeURIComponent(allCookies.substring(startIndex + cookieName.length))
}

function mapRbcAccount(type, account) {
  return {
    type,
    external_id: type == "investment" ? account.accountNumber : account.accountId,
    encrypted_external_id: account.encryptedAccountNumber,
    account_name: account.product.productName,
    nick_name: account.nickName,
    balance: account.displayCurrentBalance,
    is_active: !account.closedOrBlocked,
    currency: account.accountCurrency.currencyCode,
  }
}

function mapTransaction(account_id, transaction) {
  const date = transaction.bookingDate || transaction.postedDate
  const description = transaction.description.join(" | ")
  const secondary_external_id = `${date}-${description}-${transaction.amount}-${transaction.creditDebitIndicator}
    -${transaction.runningBalance || transaction.transactionCode}`.replace(/ /g, "")

  return {
    external_id: transaction.transactionId || secondary_external_id,
    secondary_external_id: secondary_external_id,
    external_account_id: account_id,
    description: transaction.description.join(" | "),
    date: transaction.bookingDate || transaction.postedDate,
    type: transaction.creditDebitIndicator,
    amount: transaction.amount,
    external_object: transaction
  }
}

function toDate() {
  const today = new Date()
  return today.toISOString().slice(0, 10)
}

function fromDate() {
  const today = new Date()
  const monthsAgo = 3
  today.setMonth(today.getMonth() - monthsAgo)

  return today.toISOString().slice(0, 10)
}

port.onMessage.addListener((msg) => {
  if (msg.name === "ping") return port.postMessage({ name: msg.name, params: { received: true } })

  if (msg.name === "pull_accounts") {
    function reqAccountsListener() {
      const response = JSON.parse(this.responseText)
      const credit_cards = response.creditCards.accounts.map(mapRbcAccount.bind(null, "credit_card"))
      const deposit_accounts = response.depositAccounts.accounts.map(mapRbcAccount.bind(null, "deposit_account"))
      const investments = response.investments.accounts.map(mapRbcAccount.bind(null, "investment"))
      const credit_lines = response.linesLoans.accounts.map(mapRbcAccount.bind(null, "credit_line"))
      const mortgages = response.mortgages.accounts.map(mapRbcAccount.bind(null, "mortgage"))
      const accounts = credit_cards.concat(deposit_accounts).concat(investments).concat(credit_lines).concat(mortgages)
      port.postMessage({ name: msg.name, params: accounts })
    }
    const req = new XMLHttpRequest()
    req.addEventListener("load", reqAccountsListener)
    req.open(
      "GET",
      `https://www1.royalbank.com/sgw5/digital/product-summary-presentation-service-v3/v3/accountListSummary?timestamp=${new Date().getTime()}`,
    )

    return req.send()
  }

  if (msg.name === "pull_transactions_deposit_account") {
    function reqTransactionListener() {
      const response = JSON.parse(this.responseText)
      const transactions = response.transactionList.map(mapTransaction.bind(null, msg.params.identifier))
      port.postMessage({ name: msg.name, params: transactions })
    }
    const req = new XMLHttpRequest()
    const url = `https://www1.royalbank.com/sgw5/digital/transaction-presentation-service-v3-dbb/v3/search/pda/account/${msg.params.encrypted_identifier}`
    req.open("POST", url)
    req.setRequestHeader("X-Xsrf-Token", getCookie("XSRF-TOKEN"))
    req.setRequestHeader("Content-Type", "application/json;charset=UTF-8")
    req.addEventListener("load", reqTransactionListener)

    return req.send(
      JSON.stringify({
        limit: 1000,
        transactionFromDate: fromDate(),
        transactionToDate: toDate(),
      }),
    )
  }

  if (msg.name === "pull_transactions_credit_card") {
    function reqTransactionListener() {
      const response = JSON.parse(this.responseText)
      const transactions = response.transactionList.map(mapTransaction.bind(null, msg.params.identifier))
      port.postMessage({ name: msg.name, params: transactions })
    }
    const req = new XMLHttpRequest()
    const url = `https://www1.royalbank.com/sgw5/digital/transaction-presentation-service-v3-dbb/v3/search/cc/posted/account/${msg.params.encrypted_identifier}`
    req.open("POST", url)
    req.setRequestHeader("X-Xsrf-Token", getCookie("XSRF-TOKEN"))
    req.setRequestHeader("Content-Type", "application/json;charset=UTF-8")
    req.addEventListener("load", reqTransactionListener)

    return req.send(
      JSON.stringify({
        limit: 1000,
        transactionFromDate: fromDate(),
        transactionToDate: toDate(),
      }),
    )
  }
})
