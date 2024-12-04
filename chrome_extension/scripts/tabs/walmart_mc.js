const port = chrome.runtime.connect({ name: "walmart_mc_port" })

function getCycleDate(monthsAgo = 0) {
  const today = new Date()
  today.setMonth(today.getMonth() - monthsAgo)

  return today.toISOString().slice(0, 10)
}

function creditCardTransactionPromise(account_id, customer_id, cycle_date) {
  return new Promise((resolve) => {
    function reqCreditCardListener() {
      const response = JSON.parse(this.responseText)
      const transactions = response.activities.map((t) => {
        const amount = parseFloat(t.amount.value)
        const is_debit = amount > 0
        return {
          external_id: t.referenceNumber,
          secondary_external_id: '',
          external_account_id: account_id,
          description: t.merchant.name,
          date: t.date,
          type: is_debit ? "debit" : "credit",
          amount: amount,
          external_object: t
        }
      })
      resolve(transactions)
    }

    const req = new XMLHttpRequest()
    let url = `https://www.walmartrewardsmc.ca/issuing/digital/account/${account_id}/customer/${customer_id}/activity`
    if (cycle_date) {
      url = `${url}?cycleStartDate=${cycle_date}`
    }
    req.open("GET", url)
    req.addEventListener("load", reqCreditCardListener)
    req.send()
  })
}

port.onMessage.addListener((msg) => {
  if (msg.name === "ping") return port.postMessage({ name: msg.name, params: { received: true } })

  if (msg.name === "pull_accounts") {
    const accounts = JSON.parse(sessionStorage.getItem("FAIRSTONE")).user.accounts.map((account) => {
      return {
        type: "credit_card",
        external_id: account.accountId,
        encrypted_external_id: null,
        account_name: account.productName,
        nick_name: "",
        balance: account.currentBalance.value,
        is_active: true,
        currency: account.currentBalance.currency,
      }
    })
    port.postMessage({ name: msg.name, params: accounts })
  }

  if (msg.name === "pull_transactions_credit_card") {
    const account = JSON.parse(sessionStorage.getItem("FAIRSTONE")).user.accounts.find((acc) => acc.accountId === msg.params.identifier)
    const promises = [
      creditCardTransactionPromise(msg.params.identifier, account.customer.customerId),
      creditCardTransactionPromise(msg.params.identifier, account.customer.customerId, account.cycleDates[0]),
      creditCardTransactionPromise(msg.params.identifier, account.customer.customerId, account.cycleDates[1]),
      creditCardTransactionPromise(msg.params.identifier, account.customer.customerId, account.cycleDates[2]),
    ]

    return Promise.all(promises).then((res) => {
      port.postMessage({
        name: msg.name,
        params: res.flat(),
      })
    })
  }
})
