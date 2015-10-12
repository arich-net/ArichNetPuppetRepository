#
# This script will replace a datastore in the given server $hostt
#
#
$hostt = Get-VMHost -Name (Read-Host "Enter name of existing server")


Get-Cluster "Cloud FRA" | Get-VMHost -Name $hostt | Remove-Datastore -Datastore "<old_datastore>" -Confirm:$false 
Get-Cluster "Cloud FRA" | Get-VMHost -Name $hostt | New-Datastore -Nfs -Name <new_ds_name> -Path "<new_ds_path>" -NfsHost <nfs_host>
