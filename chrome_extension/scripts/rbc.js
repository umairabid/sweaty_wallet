var port = chrome.runtime.connect({ name: "rbc_port" });

function mapRbcAccount(type, account) {
  return {
    type: type,
    external_id: account.accountId,
    encrypted_external_id: account.encryptedAccountNumber,
    account_name: account.product.productName,
    nick_name: account.nickName,
    balance: account.displayCurrentBalance,
    is_active: !account.closedOrBlocked,
    currency: account.accountCurrency.currencyCode,
  };
}

port.onMessage.addListener(function (msg) {
  console.log(msg)
  if (msg.name == "ping") {
    port.postMessage({ name: msg.name, params: { received: true } });
  } else if (msg.name == "pull_accounts") {
    function reqListener() {
      const response = JSON.parse(this.responseText);
      const credit_cards = response.creditCards.accounts.map(
        mapRbcAccount.bind(null, "credit_card")
      );
      const deposit_accounts = response.depositAccounts.accounts.map(
        mapRbcAccount.bind(null, "deposit_account")
      );
      const investments = response.investments.accounts.map(
        mapRbcAccount.bind(null, "investment")
      );
      const credit_lines = response.linesLoans.accounts.map(
        mapRbcAccount.bind(null, "credit_line")
      );
      const mortgages = response.mortgages.accounts.map(
        mapRbcAccount.bind(null, "mortgage")
      );
      const accounts = credit_cards
        .concat(deposit_accounts)
        .concat(investments)
        .concat(credit_lines)
        .concat(mortgages);
      port.postMessage({ name: msg.name, params: accounts });
    }

    const req = new XMLHttpRequest();
    req.addEventListener("load", reqListener);
    req.open(
      "GET",
      `https://www1.royalbank.com/sgw5/omniapi/product-summary-presentation-service-v3/v3/accountListSummary?timestamp=${new Date().getTime()}`
    );
    req.send();
  } else if (msg.name == "pull_tranactions_deposit_account") {
    console.log(msg)
    function reqListener() {
      const response = JSON.parse(this.responseText);
      port.postMessage({ name: msg.name, params: response });
    }

    const req = new XMLHttpRequest();
    req.addEventListener("load", reqListener);
    req.open(
      "GET",
      `https://www1.royalbank.com/sgw5/omniapi/transaction-presentation-service-v3-dbb/v3/transactions/pda/account/${msg.params.encrypted_identifier}?intervalType=DAY&intervalValue=14&type=ALL&txType=pda&useColtOnly=response&timestamp=${new Date().getTime()}`
    );
    req.send();
  }  else if (msg.name == "pull_tranactions_credit_card") {
    console.log(msg)
    function reqListener() {
      const response = JSON.parse(this.responseText);
      port.postMessage({ name: msg.name, params: response });
    }

    const req = new XMLHttpRequest();
    req.addEventListener("load", reqListener);
    req.open(
      "GET",
      `https://www1.royalbank.com/sgw5/omniapi/transaction-presentation-service-v3-dbb/v3/transactions/cc/posted/account/${msg.params.encrypted_identifier}?billingStatus=posted&txType=postedCreditCard&timestamp=${new Date().getTime()}`
    );
    req.send();
  }
});
