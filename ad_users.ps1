#AD Users Create AdUsers, HomeDrives, Permissions, Assign Groups
Import-Module ActiveDirectory

#
#EINGABEN
#

$Cshort = "BS"
$Company="BattServ"
$DomainDN=(Get-ADDomain).DistinguishedName
$ParentOU= "DC=4B2-T3,DC=local"
$base = "\\DC01\Home"
$p = "A12345678a!"


create_admin -vn "Valentin" -nn "Postenvoll" -abteilung "Admins" -login "postenvollv" -passwd $p

create_user -vn "Sofie" -nn "Seicht" -abteilung "GF" -grp "Admins" -login "seichts" -passwd $p
create_user -vn "Mark" -nn "Teich" -abteilung "GF" -grp "Users" -login "teichm" -passwd $p
create_user -vn "Viktor" -nn "Sellout" -abteilung "Sales" -grp "Admins" -login "selloutv" -passwd $p
create_user -vn "Susi" -nn "Super" -abteilung "Sales" -grp "Users" -login "supers" -passwd $p
create_user -vn "Gernot" -nn "Kool" -abteilung "Marketing" -grp "Admins" -login "koolg" -passwd $p
create_user -vn "Antonia" -nn "Haus" -abteilung "Marketing" -grp "Admins" -login "hausa" -passwd $p
create_user -vn "Nick" -nn "Tech" -abteilung "Service" -grp "Admins" -login "techn" -passwd $p
create_user -vn "Monika" -nn "Turing" -abteilung "Service" -grp "Users" -login "turingm" -passwd $p

#
# ENDE DER EINGABEN
#



# Function for reagular Users
function create_user {
   param(
   [string] $vn,
   [string] $nn,
   [string] $abteilung,
   [string] $grp,
   [string] $login,
   [string] $passwd
   )
  
  $folder= New-Item -Path "$base\$login"  -ItemType "directory"
  $email=""+$login+"@4B2-T3.local"
  $pwd= ConvertTo-SecureString -String $passwd -AsPlainText -Force
  New-ADUser -Name "$vn $nn" -Path ("OU=$abteilung,OU="+$Company+","+$ParentOU) -Department "$abteilung" -GivenName "$vn" -Surname "$nn" -SamAccountName "$login" -AccountPassword $pwd -ChangePasswordAtLogon $True -DisplayName "$vn $nn" -Enabled $True -HomeDirectory "$base\$login" -HomeDrive "H" -EmailAddress $email
 

  $aduser= Get-ADUser $login

  $acl=Get-Acl $folder 
  $rule=New-Object System.Security.AccessControl.FileSystemAccessRule($login,"FullControl","ContainerInherit,ObjectInherit","None","Allow")
  $acl.SetAccessRule($rule)
  Set-Acl "$base\$login" $acl

  $group= Get-ADGroup "$abteilung $grp"
  Add-ADGroupMember -Identity $group -Members $aduser
}

#Function for Global Admin Users
function create_admin {
 param(
   [string] $vn,
   [string] $nn,
   [string] $abteilung,
   [string] $login,
   [string] $passwd
   )
  $pwd= ConvertTo-SecureString -String $passwd -AsPlainText -Force
  New-ADUser -Name "$vn $nn" -Path ("OU=$abteilung,OU="+$Company+","+$ParentOU) -Department "$abteilung" -GivenName "$vn" -Surname "$nn" -SamAccountName "$login" -AccountPassword $pwd -ChangePasswordAtLogon $True -DisplayName "$vn $nn" -Enabled $True -HomeDirectory "$base\$login"  -HomeDrive "H" 
  $aduser= Get-ADUser $login
  $group=Get-ADGroup "BS admins"
  Add-ADGroupMember -Identity $group -Members $aduser
}
