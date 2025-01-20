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
      
    },
    onShow: () => {
      
    },
    onToggle: () => {
      
    },
  }

  // instance options object
  const instanceOptions = {
    id: elem_id,
    override: true,
  }

  const current_instance = FlowbiteInstances.getInstance('Drawer', elem_id)
  
  if (current_instance) {
    current_instance.removeInstance();
  } 

  return new Drawer($targetEl, options, instanceOptions)
}
