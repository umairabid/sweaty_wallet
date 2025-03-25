function getRows(firstTransactionRow) {
  const tbody = firstTransactionRow.closest("tbody");
  return tbody.querySelectorAll("tr.transaction-row");
}

function parseTransaction(row, external_account_id) {
  const dateSpan = row.querySelector("td.transactionDate span");
  if (!dateSpan) return null;

  const date = dateSpan.innerText.trim();
  const descriptionSpan = row.querySelector(
    "td.transactions span.transactionDescription"
  );
  const description = descriptionSpan && descriptionSpan.innerText.trim();
  console.log(row);
  let amountTd = row.querySelector("td.amount.debit");
  let type = "debit";
  if (!amountTd) {
    amountTd = row.querySelector("td.amount.credit");
    type = "credit";
  }
  console.log(amountTd);
  const isPending = amountTd.querySelector(".pending-indicator") != null;
  if (isPending) return null;

  const amountStr = row.querySelector("span").innerText.trim();
  const amount = amountStr.replace(/[^0-9.-]/g, "");
  const descript_str = `${date}-${description}-${type}-${amount}`;
  const secondary_external_id = descript_str.replace(/ /g, "");
  const external_id = secondary_external_id;

  return {
    external_id,
    secondary_external_id,
    external_account_id,
    description,
    date,
    type,
    amount,
    external_object: {},
  };
}

function scrapTransactions(external_account_id) {
  const firstTransactionRow = document.querySelector(".transaction-row");
  const rows = getRows(firstTransactionRow);
  const transactions = [];
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const transaction = parseTransaction(row, external_account_id);
    if (transaction) transactions.push(transaction);
  }
  return transactions;
}

export function pullCreditCardTransacttions(external_account_id) {
  return scrapTransactions(external_account_id);
}
