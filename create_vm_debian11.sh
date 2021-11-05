#!/bin/bash

#Script para crear maquina virtal con debian 11

#Nombre de la VM MX5200(host-ip)
MACHINENAME=$1
MEMORY=1024
ADAPTER=ens1f2
CPUS=2
HDD=50000
RUTA="/home/geabox/VirtualBox VMs"
VRDPORT=3397

# Descargar debian.iso
if [ ! -f ./debian11.iso ]; then
    wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.1.0-amd64-netinst.iso -O debian11.iso
fi

#Create VM
VBoxManage createvm --name $MACHINENAME --ostype "Debian_64" --register

#Configurar memoria y network
VBoxManage modifyvm $MACHINENAME --ioapic on
VBoxManage modifyvm $MACHINENAME --memory $MEMORY
VBoxManage modifyvm $MACHINENAME --nic1 bridged
VBoxManage modifyvm $MACHINENAME --bridgeadapter1 $ADAPTER
VBoxManage modifyvm $MACHINENAME --audio none
vboxmanage modifyvm $MACHINENAME --cpus $CPUS

#Create Disk and connect Debian Iso
VBoxManage createhd --filename $RUTA/$MACHINENAME/$MACHINENAME.vdi --size $HDD --format VDI
VBoxManage storagectl $MACHINENAME --name "Sata Controller" --add sata --controller "IntelAHCI"
VBoxManage storageattach $MACHINENAME --storagectl "Sata Controller" --port 0 --device 0 --type hdd --medium  /home/geabox/VirtualBox\ VMs/$MACHINENAME/$MACHINENAME.vdi
VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/debian11.iso
VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

#Enable RDP
VBoxManage modifyvm $MACHINENAME --vrde on
VBoxManage modifyvm $MACHINENAME --vrdeport $VRDPORT

#Start the VM
VBoxManage startvm $MACHINENAME --type headless