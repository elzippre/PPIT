#AD Rollout
Import-Module ActiveDirectory

# Set the containers name
$Cshort = "BS"
$Company="BattServ"

$DomainDN=(Get-ADDomain).DistinguishedName
$ParentOU= "DC=4B2-T3,DC=local"

$OUs = @(
"GF",
"Sales",
"Marketing",
"Service"
)

$SOUs= @(
"Users",
"Admins",
"Computers",
"Servers"
)

$base="C:\Abteilungen"

# Create an OU for a new branch office
$newOU=New-ADOrganizationalUnit -Name $Company -path $ParentOU –Description “A container for $Company users”  -PassThru
ForEach ($OU In $OUs) {
    New-ADOrganizationalUnit -Name $OU -Path $newOU
    #Admin Group
    New-ADGroup "$OU Admins" -path ("OU=$OU,OU="+$Company+","+$ParentOU) -GroupScope Global -PassThru –Verbose
    #User Group
    New-ADGroup "$OU Users" -path ("OU=$OU,OU="+$Company+","+$ParentOU) -GroupScope Global -PassThru –Verbose
    #Admin rights
    $acl=Get-Acl "$base\$OU"
    $rule=New-Object System.Security.AccessControl.FileSystemAccessRule("$OU Admins","FullControl","ContainerInherit,ObjectInherit","None","Allow")
    $acl.SetAccessRule($rule)
    #User rights
    Set-Acl "$base\$OU" $acl
    $rule=New-Object System.Security.AccessControl.FileSystemAccessRule("$OU Users","Write","ContainerInherit,ObjectInherit","None","Allow")
    $acl.SetAccessRule($rule)
    Set-Acl "$base\$OU" $acl
}

#Global OUs
ForEach ($SOU In $SOUs) {
    New-ADOrganizationalUnit -Name $SOU -Path $newOU
}


#Create administrative groups   
New-ADGroup "$Cshort admins" -path ("OU=Admins,OU="+$Company+","+$ParentOU) -GroupScope Global -PassThru –Verbose
New-ADGroup "$Cshort account_managers" -path ("OU=Admins,OU="+$Company+","+$ParentOU) -GroupScope Global -PassThru –Verbose
New-ADGroup "$Cshort wks_admins" -path ("OU=Admins,OU="+$Company+","+$ParentOU) -GroupScope Global -PassThru –Verbose

#Admin rights
$acl=Get-Acl "$base"
$rule=New-Object System.Security.AccessControl.FileSystemAccessRule("BS admins","FullControl",1,0,"Allow")
$acl.SetAccessRule($rule)

#Set-ADOrganizationalUnit -Identity "OU=4B2-T3Users,DC=4B2-T3,DC=local" -Description "All Users"
#Set-ADOrganizationalUnit -Identity "OU=GF,DC=4B2-T3,DC=local" -Description "GF Users"
#Set-ADOrganizationalUnit -Identity "OU=Marketing,DC=4B2-T3,DC=local" -Description "Marketing Users"
#Set-ADOrganizationalUnit -Identity "OU=Sales,DC=4B2-T3,DC=local" -Description "Sales Users"
#Set-ADOrganizationalUnit -Identity "OU=Service,DC=4B2-T3,DC=local" -Description "Service Users"


##### An example of assigning password reset permissions for the _account_managers group on the Users OU
$confADRight = "ExtendedRight"
$confDelegatedObjectType = "bf967aba-0de6-11d0-a285-00aa003049e2" # User Object Type GUID
$confExtendedRight = "00299570-246d-11d0-a768-00aa006e0529" # Extended Right PasswordReset GUID
$acl=get-acl ("AD:OU=Users,OU="+$Company+","+$ParentOU)
$adm_accountSID = [System.Security.Principal.SecurityIdentifier]$adm_account.SID
#Build an Access Control Entry (ACE)string
$aceIdentity = [System.Security.Principal.IdentityReference] $adm_accountSID
$aceADRight = [System.DirectoryServices.ActiveDirectoryRights] $confADRight
$aceType = [System.Security.AccessControl.AccessControlType] "Allow"
$aceInheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "Descendents"
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($aceIdentity, $aceADRight, $aceType, $confExtendedRight, $aceInheritanceType,$confDelegatedObjectType)
# Apply ACL
$acl.AddAccessRule($ace)
Set-Acl -Path ("AD:OU=Users,OU="+$Company+","+$ParentOU) -AclObject $acl