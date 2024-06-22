console.log('hello')

chrome.runtime.onMessageExternal.addListener(function (
  request,
  sender,
  sendResponse
) {
  console.log(request)
});
