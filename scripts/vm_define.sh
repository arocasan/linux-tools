
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
    echo "Creating brigde for virsh vms"

 sudo nmcli connection add type bridge con-name br0 ifname br0
 sudo nmcli connection modify br0 ipv4.method auto
 sudo nmcli connection modify br0 ipv4.method manual ipv4.addresses 10.13.37.29/24 ipv4.gateway 10.13.37.1 ipv4.dns 8.8.8.8
 sudo nmcli connection add type ethernet con-name eth0-slave ifname enp0s31f6 master br0
 sudo nmcli connection up br0
 sudo nmcli connection up eth0-slave
 sudo iptables -N DOCKER-USER || true
 sudo iptables -I DOCKER-USER 1 -i docker0 -o docker0 -j RETURN
 sudo iptables -I DOCKER-USER 2 -i br-+ -o br-+ -j RETURN
 sudo iptables -I DOCKER-USER 3 -i br0 -o br0 -j ACCEPT
 sudo iptables -I DOCKER-USER 5 -i vibr0 -o vibr0 -j ACCEPT
 sudo iptables -I DOCKER-USER 6 -i lxcbr0 -o lxcbr0 -j ACCEPT
  
  echo "Verifyin configuration"

  ip addr show br0
  bridge vlan show

 sudo systemctl restart NetworkManager

  cd /var/lib/libvirt/images
 
  for vm in $VM_DEFENITION; do
  sudo virsh define $vm.xml   
  sudo virsh autostart $vm
  sudo virsh start $vm
  done
}

virsh_define
