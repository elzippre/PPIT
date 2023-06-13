#AD Rollout
Import-Module ActiveDirectory

# Set the containers name
$Country="AT"
$City = "VI"
$CityFull="Vienna"

$DomainDN=(Get-ADDomain).DistinguishedName
$ParentOU= "OU=BattServ"
$OUs = @(
"Admins",
"Computers",
"GF",
"Sales",
"Marketing",
"Service",
"Servers"
)


# Create an OU for a new branch office
$newOU=New-ADOrganizationalUnit -Name $CityFull -path $ParentOU –Description “A container for $CityFull users”  -PassThru
ForEach ($OU In $OUs) {
    New-ADOrganizationalUnit -Name $OU -Path $newOU

    $ouDN = $OU.DistinguishedName
    # Get the security identifier (SID) of the OU
    $ouSID = (Get-ADObject -Identity $ouDN).SID
    # Set the folder permissions
    $acl = Get-Acl -Path $folderPath
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ouSID, "Write", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl -Path $folderPath -AclObject $acl


}

#Create administrative groups
$adm_grp=New-ADGroup ($City+ "_admins") -path ("OU=Admins,OU="+$CityFull+","+$ParentOU) -GroupScope Global -PassThru –Verbose
$adm_wks=New-ADGroup ($City+ "_account_managers") -path ("OU=Admins,OU="+$CityFull+","+$ParentOU) -GroupScope Global -PassThru –Verbose
$adm_account=New-ADGroup ($City+ "_wks_admins") -path ("OU=Admins,OU="+$CityFull+","+$ParentOU) -GroupScope Global -PassThru –Verbose


Set-ADOrganizationalUnit -Identity "OU=4B2-T3Users,DC=4B2-T3,DC=local" -Description "All Users"
Set-ADOrganizationalUnit -Identity "OU=GF,DC=4B2-T3,DC=local" -Description "GF Users"
Set-ADOrganizationalUnit -Identity "OU=Marketing,DC=4B2-T3,DC=local" -Description "Marketing Users"
Set-ADOrganizationalUnit -Identity "OU=Sales,DC=4B2-T3,DC=local" -Description "Sales Users"
Set-ADOrganizationalUnit -Identity "OU=Service,DC=4B2-T3,DC=local" -Description "Service Users"


##### An example of assigning password reset permissions for the _account_managers group on the Users OU
$confADRight = "ExtendedRight"
$confDelegatedObjectType = "bf967aba-0de6-11d0-a285-00aa003049e2" # User Object Type GUID
$confExtendedRight = "00299570-246d-11d0-a768-00aa006e0529" # Extended Right PasswordReset GUID
$acl=get-acl ("AD:OU=Users,OU="+$CityFull+","+$ParentOU)
$adm_accountSID = [System.Security.Principal.SecurityIdentifier]$adm_account.SID
#Build an Access Control Entry (ACE)string
$aceIdentity = [System.Security.Principal.IdentityReference] $adm_accountSID
$aceADRight = [System.DirectoryServices.ActiveDirectoryRights] $confADRight
$aceType = [System.Security.AccessControl.AccessControlType] "Allow"
$aceInheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "Descendents"
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($aceIdentity, $aceADRight, $aceType, $confExtendedRight, $aceInheritanceType,$confDelegatedObjectType)
# Apply ACL
$acl.AddAccessRule($ace)
Set-Acl -Path ("AD:OU=Users,OU="+$CityFull+","+$ParentOU) -AclObject $acl
