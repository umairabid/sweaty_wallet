function parse_transaction(row, external_account_id) {
  const tds = row.querySelectorAll("td");
  if (tds.length === 0) return null;

  const date = tds[0].innerText.trim();
  const description = tds[1].innerText.trim();
  const amountStr = tds[2].innerText.trim();
  const type = tds[2].classList.contains('debit') ? "debit" : "credit";
  const amount = amountStr.replace(/[^0-9.-]/g, "");
  const secondary_external_id = `${date}-${description}-${type}-${amount}`;

  return {
    external_id: secondary_external_id.replace(/ /g, ""),
    secondary_external_id: secondary_external_id.replace(/ /g, ""),
    external_object: { },
    external_account_id,
    description,
    date,
    type,
    amount,
  };
}

function scrapeDepositAccountTransactions(account_id) {
  const transaction_rows = document.querySelectorAll("table tbody tr")
  const transactions = []
  for (let i = 0; i < transaction_rows.length; i++) {
    const transaction = parse_transaction(transaction_rows[i], account_id)
    transactions.push(transaction)
  }
  return transactions;
}

export function pullDepositAccount(account_id) {
  return scrapeDepositAccountTransactions(account_id);
}
