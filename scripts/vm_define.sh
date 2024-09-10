
function info_msg() {
    echo -e "\033[1;3;94m$1\033[0m" 
}

# Function to provide success feedback with  bold, italic, and green text
function success_feedback() {
    echo -e "\n\033[1;3;92m$1\033[0m" 
}

# Function to provide error feedback with bold, italic, and red text
function error_feedback() {
    echo -e "\n\033[1;3;91mError: $1\033[0m"
}

# Virtual machines to restore
VM_DEFENITION="aroca-services aroca-worker-01 aroca-worker-02"

virsh_define(){
  info_msg "Will define and start the following VM's ${VM_DEFENITION}"
  cd /var/lib/libvirt/images
  
  for vm in $VM_DEFENITION; do
  sudo virsh define $vm.xml   
  sudo virsh autostart $vm
  sudo virsh start $vm
  done
}


