export default function create_modal(elem_id) {
  const $targetEl = document.getElementById(elem_id)

  // options with default values
  const options = {
    placement: "bottom",
    backdrop: "dynamic",
    backdropClasses: "bg-gray-900/50 dark:bg-gray-900/80 fixed inset-0 z-40",
    closable: true,
    onHide: () => {
      console.log("hide")
    },
    onShow: () => {},
    onToggle: () => {},
  }

  // instance options object
  const instanceOptions = {
    id: elem_id,
    override: true,
  }
  
  const current_instance = FlowbiteInstances.getInstance('Modal', elem_id)
  
  if (current_instance) {
    if (document.querySelector('[modal-backdrop]')) {
      current_instance.destroyAndRemoveInstance();
    } else {
      current_instance.removeInstance();
    }
    
  } 
  return new Modal($targetEl, options, instanceOptions)
}
