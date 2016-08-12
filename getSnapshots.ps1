clear

$user = Read-Host 'Enter privledged username (follow @<removed> convention)'

$pass = Read-Host 'Enter privledged password'

$vCenter = Read-Host 'Enter vCenter in which you would like to collect logs (Ex: <removed>)'

$fileName = Read-Host 'Enter the name of the file you would like (one word, no spaces, no special characters Ex: <removed>'

$fileLocation = Read-Host 'Specify the drive you would like this in. *Usually J or C given your environment* (J/C/etc)'

echo "wait."

Connect-viserver $vCenter -user $user -pass $pass

get-vm | get-snapshot | format-list  vm,description,name,sizegb,created| out-file c:\$fileName.txt 

disconnect-viserver -confirm:$false

echo "Done. Written to $fileLocation : drive as $fileName.txt"