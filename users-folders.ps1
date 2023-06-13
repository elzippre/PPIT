# Userrechte Rollout
# 4B2-T3.local
# 4B2-WR

# Userrights for Folders
$base=C:\Abteilungen
$abteilung=GF

$ouPath = "OU=$abateilung,DC=4B2-T3,DC=local"
$folderPath = "$base\$abteilung"

# Get the distinguished name (DN) of the OU
$ou = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'"

if ($ou) {
    $ouDN = $ou.DistinguishedName
    # Get the security identifier (SID) of the OU
    $ouSID = (Get-ADObject -Identity $ouDN).SID
    # Set the folder permissions
    $acl = Get-Acl -Path $folderPath
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ouSID, "Write", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl -Path $folderPath -AclObject $acl

    Write-Host "Access granted to OU: $ouPath"
} else {
    Write-Host "OU not found: $ouPath"
}
