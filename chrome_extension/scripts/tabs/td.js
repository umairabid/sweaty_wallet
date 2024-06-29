const port = chrome.runtime.connect({ name: "td_port" });
const current_url = window.location.href;
const is_new_frontend = current_url.startsWith('https://easyweb.td.com/ui');
const is_old_frontend = current_url.startsWith('https://easyweb.td.com/waw');


if (is_new_frontend) {
  port.postMessage({ name: 'redirect_to_new_frontend' });
}

if (is_old_frontend) {
  port.postMessage({ name: 'redirect_to_old_frontend' });
}

function getAccounType(productGroupType) {
  if (productGroupType == "BANKING") return "deposit_account";
  if (productGroupType == "CREDIT") return "credit_card";
  if (productGroupType == "LOAN_MORTGAGE") return "mortgage";
  return "unknow_account";
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
          type: type,
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

port.onMessage.addListener(function (msg) {
  console.log(msg);
  if (msg.name == "ping") {
    port.postMessage({ name: msg.name, params: { received: true } });
  } else if (msg.name == "redirect_to_new_frontend") {
    window.location.href = 'https://easyweb.td.com/ui/ew/fs?fsType=PFS';
  } else if (msg.name == "pull_accounts") {
    function reqListener() {
      const response = JSON.parse(this.responseText);
      const profile_groups =  response.financialSummaries.personalSummary.profileGroups;

      port.postMessage({ name: msg.name, params: extract_accounts_from_profile_groups(profile_groups) });
    }

    const req = new XMLHttpRequest();
    req.open("GET", `https://easyweb.td.com/ms/uainq/v1/accounts/summary`);
    req.setRequestHeader('TraceabilityID', crypto.randomUUID());
    req.setRequestHeader('Messageid', crypto.randomUUID());
    req.setRequestHeader('Originating-App-Name', 'RWUI-uf-fs');
    req.setRequestHeader('Originating-App-Version-Num', '1.5.34');
    req.setRequestHeader('TimeStamp', new Date().getTime());
    req.setRequestHeader('Originating-Channel-Name', 'EWP');
    req.setRequestHeader('Accept-Secondary-Language', 'fr_CA');
    req.addEventListener("load", reqListener);
    req.send();
  }
});
