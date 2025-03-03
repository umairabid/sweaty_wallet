function mapTransaction(account_id, transaction) {
  const is_debit = !!transaction.debit
  const date = transaction.postedDt || transaction.transactionDt
  const type = is_debit ? "debit" : "credit"
  const amount = is_debit ? transaction.debit.amt : transaction.credit.amt
  const description = transaction.transactionDesc
  const balance = transaction.balance.amt
  const secondary_external_id = `${date}-${description}-${type}-${amount}-${balance}`.replace(/ /g, "")

  return {
    external_id: transaction.transactionId,
    secondary_external_id: secondary_external_id,
    external_account_id: account_id,
    description: description,
    date: date,
    type: type,
    amount: amount,
    external_object: transaction,
  }
}

function creditCardTransactionPromise(accountId, cycle) {
  return new Promise((resolve) => {
    function reqCreditCardListener() {
      const response = JSON.parse(this.responseText)
      const mapTransactionFunc = mapTransaction.bind(null, accountId)
      const transactions = (response.transactions.posted || []).map(mapTransactionFunc)
      resolve(transactions)
    }

    const req = new XMLHttpRequest()
    req.open("GET", `https://easyweb.td.com/waw/api/account/creditcard/transactions?accountKey=${accountId}&cycleId=${cycle}`)
    req.addEventListener("load", reqCreditCardListener)
    req.send()
  })
}

export default function pullCreditCardAccount(msg) {
  const promises = [
    creditCardTransactionPromise(msg.params.identifier, 0),
    creditCardTransactionPromise(msg.params.identifier, 1),
    creditCardTransactionPromise(msg.params.identifier, 2),
  ]
  return Promise.all(promises).then((res) => {
    return {
      name: msg.name,
      params: res.flat(),
    }
  })
}
