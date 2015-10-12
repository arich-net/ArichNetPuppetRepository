#This script will add the datastores to a given server $hostt importing the data from a csv
#The CSV hass to have the following structure:
#ip,path,name
#192.168.55.3,/vol/vol_24_356828_Client_Test_France,ds-24-356828-Client-Test-France
#where:
#	ip: nfs ip
#	path: nfs directory path
#	name: datastore name
#
$hostt = Get-VMHost -Name (Read-Host "Enter name of existing server")
$csvFile = "<path_to_csv>"
$vcenterCluster = "Cloud PAR"
Import-Csv $csvFile | foreach-object { Get-Cluster $vcenterCluster | Get-VMHost -Name $hostt | New-Datastore -Nfs -Name $_.name -Path $_.path -NfsHost $_.ip}