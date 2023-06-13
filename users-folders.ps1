# Userrechte Rollout
# 4B2-T3.local
# 4B2-WR

# Userrights for Folders
$base="C:\Abteilungen"
$abteilungen = @(
"GF",
"Sales",
"Marketing",
"Service"
)

$Company="BattServ"

ForEach ($abteilung In $abteilungen) {

    # Get the distinguished name (DN) of the OU
    $ou = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'"
    $ouPath = "OU=$abteilung,OU=$Company,DC=4B2-T3,DC=local"
    $folderPath = "$base\$abteilung"
    if ($ou) {
        $ouDN = $ou.DistinguishedName
        $ouSID= New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup $abteilung).SID
        $acl = Get-Acl -Path "AD:\$ouDN"
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ouSID, "Write", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule)
        Set-Acl -Path $folderPath -AclObject $acl
        
        Write-Host "Access granted to OU: $ouPath"
    } else {
    Write-Host "OU not found: $ouPath"
    }
}
