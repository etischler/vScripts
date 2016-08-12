clear
$user = Read-Host 'Enter privledged username (follow @<removed>.org convention)'

$pass = Read-Host 'Enter privledged password'

$vCenter = Read-Host 'Enter vCenter in which you would like to access for this change (Ex: <removed>)'

$pathToFile = Read-Host 'Provide Path for Text File'
Connect-viserver $vCenter -user $user -pass $pass
$reader = [System.IO.File]::OpenText($pathToFile)
try {
    for() {
        $line = $reader.ReadLine()
        if ($line -eq $null) { break }       
        $MyVM = Get-VM -Name $line
        $network = Get-NetworkAdapter -VM $line
        $Network_Adapter = $network.Name[0]
        $Mac_Address = $network.MacAddress[0]
        clear
        echo $Network_Adapter
        echo $Mac_Address
        $proceed = Read-Host 'You are about to delete the nic from $MyVM with the above network adapter and mac address. Remember this is an untested operation. Proceed?(y/n)'
        
        Remove-NetworkAdapter -NetworkAdapter $network[0] -Confirm:$true
       echo "removed."
    }
}
finally {
    $reader.Close()
}
disconnect-viserver -confirm:$false