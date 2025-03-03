export default function element_available_width(element) {
  const style = window.getComputedStyle(element);
  const paddingLeft = parseFloat(style.paddingLeft);
  const paddingRight = parseFloat(style.paddingRight);
  const borderLeftWidth = parseFloat(style.borderLeftWidth);
  const borderRightWidth = parseFloat(style.borderRightWidth);

  return (
    element.clientWidth -
    paddingLeft -
    paddingRight -
    borderLeftWidth -
    borderRightWidth
  );
}
