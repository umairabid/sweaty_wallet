export default function handle_message(type, messageId = null) {
  const elements = document.getElementsByClassName(type);
  for (let i = 0; i < elements.length; i++) {
    const element = elements[i];
    element.classList.add("hidden");
  }
  if (messageId) {
    const elem = document.getElementById(messageId);
    if (elem) elem.classList.remove("hidden");
  }
  
}
