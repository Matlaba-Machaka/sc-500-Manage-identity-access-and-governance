# Grants User.Read.All to the VM Managed Identity
$TenantID = "<tenant_id>"
$VM_ObjectID = "0fc28319-1584-4cf7-bad4-3d30e6dd4eec"
$GraphAppId = "00000003-0000-0000-c000-000000000000" 
$PermissionName = "User.Read.All"

$GraphServicePrincipal = Get-AzADServicePrincipal -Filter "appId eq '$GraphAppId'"

# Extract the ID directly using parentheses around the filter expression
$AppRoleId = ($GraphServicePrincipal.AppRole | Where-Object {$_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application"}).Id

# Execute using the isolated string variable
New-AzADServicePrincipalAppRoleAssignment -ServicePrincipalId $VM_ObjectID -ResourceId $GraphServicePrincipal.Id -AppRoleId $AppRoleId
