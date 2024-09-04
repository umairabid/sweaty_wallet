export default function create_drawer(elem_id) {
  const $targetEl = document.getElementById(elem_id)

  // options with default values
  const options = {
    placement: "right",
    backdrop: true,
    bodyScrolling: false,
    edge: false,
    edgeOffset: "",
    backdropClasses: "drawer-backdrop bg-gray-900/50 dark:bg-gray-900/80 fixed inset-0 z-30",
    onHide: () => {
      console.log("drawer is hidden")
    },
    onShow: () => {
      console.log("drawer is shown")
    },
    onToggle: () => {
      console.log("drawer has been toggled")
    },
  }

  // instance options object
  const instanceOptions = {
    id: elem_id,
    override: true,
  }

  return new Drawer($targetEl, options, instanceOptions)
}
