#AD Users
Import-Module ActiveDirectory


$Cshort = "BS"
$Company="BattServ"
$DomainDN=(Get-ADDomain).DistinguishedName
$ParentOU= "DC=4B2-T3,DC=local"
$base = "C:\Home"
$usersg="Admins"


function create_user {

  New-ADUser -Name "$vn $nn" -Path ("OU=$abteilung,OU="+$Company+","+$ParentOU) -Department "$abteilung" -GivenName "$vn" -Surname "$nn" -SamAccountName "$login" -AccountPassword (ConvertTo-SecureString -AsPlainText “A12345678a!” -Force ) -ChangePasswordAtLogon $True -DisplayName "$vn $nn" -Enabled $True -HomeDirectory "$base\$login" 
  $aduser= Get-ADUser "$login"
  $group=Get-ADGroup "$abteilung $usersg"
  Add-ADGroupMember -Identity $group -Members $aduser
}


$abteilung="GF"
$vn="Sofie"
$nn="Schüssel"
$login="schuessels"
create_user

$abteilung="Admins"
$vn="Valentin"
$nn="Postenvoll"
$login="postenvollv"
create_user

$abteilung="Sales"
$vn="Viktor"
$nn="Sellout"
$login="selloutv"
create_user

$abteilung="Marketing"
$vn="Gernot"
$nn="Kool"
$login="koolg"
create_user

$abteilung="Service"
$vn="Nick"
$nn="Tech"
$login="techn"
create_user

