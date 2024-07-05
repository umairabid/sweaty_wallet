/**
 * Equivalent of jquery $.ready() but without jquery. Meant for running
 * initialization code on page load.
 */
function docReady(fn) {
  // see if DOM is already available
  if (document.readyState === 'complete' || document.readyState === 'interactive') {
    // call on next available tick
    setTimeout(fn, 1);
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

export default docReady;
