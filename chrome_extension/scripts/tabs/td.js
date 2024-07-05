import docReady from '../utils/docReady';

const TD_NEW_FRONTEND_URL = 'https://easyweb.td.com/ui';
const TD_OLD_FRONTEND_URL = 'https://easyweb.td.com/waw';
const TD_CREDIT_CARD_URL = 'https://easyweb.td.com/waw/webui';

function onTabLoad() {
  const port = chrome.runtime.connect({ name: 'td_port' });
  const current_url = window.location.href;

  const is_new_frontend = current_url.startsWith(TD_NEW_FRONTEND_URL);
  const is_old_frontend = current_url.startsWith(TD_OLD_FRONTEND_URL);
  const is_credit_card = current_url.startsWith(TD_CREDIT_CARD_URL);

  if (is_credit_card) {
    port.postMessage({ name: 'redirect_to_credit_card_url' });
  } else if (is_new_frontend) {
    port.postMessage({ name: 'redirect_to_new_frontend_url' });
  } else if (is_old_frontend) {
    port.postMessage({ name: 'redirect_to_old_frontend_url' });
  }

  function getAccounType(productGroupType) {
    if (productGroupType === 'BANKING') return 'deposit_account';
    if (productGroupType === 'CREDIT') return 'credit_card';
    if (productGroupType === 'LOAN_MORTGAGE') return 'mortgage';
    return 'unknow_account';
  }

  function extract_accounts_from_profile_groups(profile_groups) {
    const accounts = [];
    profile_groups.forEach((profile_group) => {
      const product_groups = profile_group.productGroups;
      product_groups.forEach((product_group) => {
        const type = getAccounType(product_group.productGroupType);
        const td_accounts = product_group.accounts || [];
        td_accounts.forEach((account) => {
          accounts.push({
            type,
            external_id: account.accountKey,
            encrypted_external_id: account.accountIdentifier,
            account_name: account.accountDesc,
            nick_name: null,
            balance: account.balanceAmt.amount,
            is_active: true,
            currency: account.balanceAmt.currencyCd,
          });
        });
      });
    });
    return accounts;
  }

  function mapTransaction(account_id, transaction) {
    const is_debit = !!transaction.debit;
    return {
      external_id: transaction.transactionId,
      external_account_id: account_id,
      description: transaction.transactionDesc,
      date: transaction.transactionDt,
      type: is_debit ? 'debit' : 'credit',
      amount: is_debit ? transaction.debit.amt : transaction.credit.amt,
    };
  }

  function reqCreditCardListener(accountId) {
    const response = JSON.parse(this.responseText);
    const mapTransactionFunc = mapTransaction.bind(null, accountId);
    const transactions = response.transactions.posted.map(mapTransactionFunc);
    return transactions;
  }

  function creditCardTransactionPromise(accountId, cycle) {
    return new Promise((resolve) => {
      const req = new XMLHttpRequest();
      req.open('GET', `https://easyweb.td.com/waw/api/account/creditcard/transactions?accountKey=${accountId}&cycleId=${cycle}`);

      req.addEventListener('load', () => {
        const result = reqCreditCardListener(accountId);
        resolve(result);
      });

      req.send();
    });
  }

  function parse_description(text) {
    if (text.indexOf('\nView more') !== -1) {
      return text.split('\nView more')[0].replace('View more', '').trim();
    }
    return text;
  }

  function parse_transaction(row, external_account_id) {
    const tds = row.querySelectorAll('td');
    if (tds.length === 0) return null;

    const date = tds[0] && tds[0].innerText.trim();
    const description = tds[1] && tds[1].innerText.trim();
    const debit = tds[2] && tds[2].innerText.trim();
    const credit = tds[3] && tds[3].innerText.trim();
    const balance = tds[4] && tds[4].innerText.trim();

    if (!date || (!debit && !credit && !balance)) return null;

    const type = debit ? 'debit' : 'credit';
    const amount = debit || credit;
    const parsed_description = parse_description(description);

    return {
      external_id: `${date}-${parsed_description}-${type}-${amount}-${balance}`.replace(/ /g, ''),
      external_account_id,
      description: parsed_description,
      date,
      type,
      amount,
    };
  }

  function parse_transactions(transaction_rows, external_account_id) {
    const transactions = [];
    for (let i = 0; i < transaction_rows.length; i++) {
      const row = transaction_rows[i];
      const transaction = parse_transaction(row, external_account_id);
      if (transaction) transactions.push(transaction);
    }
    return transactions;
  }

  function reqListener(msg) {
    const response = JSON.parse(this.responseText);
    const profile_groups = response.financialSummaries.personalSummary.profileGroups;

    port.postMessage({
      name: msg.name,
      params: extract_accounts_from_profile_groups(profile_groups),
    });
  }

  port.onMessage.addListener((msg) => {
    if (msg.name === 'ping') {
      port.postMessage({ name: msg.name, params: { received: true } });
    } else if (msg.name === 'redirect_to_new_frontend_url') {
      window.location.href = msg.params.url;
    } else if (msg.name === 'redirect_to_old_frontend_url') {
      window.location.href = msg.params.url;
    } else if (msg.name === 'redirect_to_credit_card_url') {
      window.location.href = msg.params.url;
    } else if (msg.name === 'pull_accounts') {
      const req = new XMLHttpRequest();
      req.open('GET', 'https://easyweb.td.com/ms/uainq/v1/accounts/summary');
      req.setRequestHeader('TraceabilityID', crypto.randomUUID());
      req.setRequestHeader('Messageid', crypto.randomUUID());
      req.setRequestHeader('Originating-App-Name', 'RWUI-uf-fs');
      req.setRequestHeader('Originating-App-Version-Num', '1.5.34');
      req.setRequestHeader('TimeStamp', new Date().getTime());
      req.setRequestHeader('Originating-Channel-Name', 'EWP');
      req.setRequestHeader('Accept-Secondary-Language', 'fr_CA');
      req.addEventListener('load', reqListener(msg));
      req.send();
    } else if (msg.name === 'pull_transactions_credit_card') {
      const promises = [
        creditCardTransactionPromise(msg.params.identifier, 0),
        creditCardTransactionPromise(msg.params.identifier, 1),
        creditCardTransactionPromise(msg.params.identifier, 2),
      ];
      Promise.all(promises).then((res) => {
        port.postMessage({
          name: msg.name,
          params: res.flat(),
        });
      });
    } else if (msg.name === 'pull_transactions_deposit_account') {
      const transaction_rows = document.querySelectorAll('#tabcontent1 #content1 table tr');
      port.postMessage({
        name: msg.name,
        params: parse_transactions(transaction_rows, msg.params.identifier),
      });
    }
  });
}

docReady(onTabLoad);
