clear
$user = Read-Host 'Enter privledged username (follow @<removed>.org convention)'

$pass = Read-Host 'Enter privledged password'

$vCenter = Read-Host 'Enter vCenter in which you would like to access for this change (Ex: <removed>)'
$netName = Read-Host 'Provide me the name of the network please. For example :<removed>'
Connect-viserver $vCenter -user $user -pass $pass
echo "Please wait while I query"
echo ""
$VMs = Get-VM | where {$_.NetworkAdapters.NetworkName -eq $netName}
echo "These will be the VMs that receive a new nic:"
echo $VMs.Name
echo ""
$proceed = Read-Host 'Proceed? (y/n)'
if($proceed -eq 'y'){
    echo "Proceeding..."
    echo ""
    foreach($VM in $VMs){
        Get-VM $VM.Name | New-NetworkAdapter  -NetworkName $netName -StartConnected -Type VMXNET3
        echo ""
        echo "$VM has received a nic"
        echo ""
        #Read-Host 'Proceed? (y/n)'
    }
}
else{
echo "User aborted."
}

disconnect-viserver -confirm:$false
