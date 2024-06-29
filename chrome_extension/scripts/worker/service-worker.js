import MessageController from './message_controller.js';


chrome.webRequest.onBeforeSendHeaders.addListener(function (details) {
  console.log(details)
}, { urls: ['https://easyweb.td.com/ms/uainq/v1/accounts/summary'] }, ['requestHeaders']);

new MessageController();

