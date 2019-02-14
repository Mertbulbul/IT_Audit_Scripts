#AD kullanıcı bilgileri icin script

import-module activedirectory
$default_log = $env:userprofile + '\Desktop\User_Password_Age.csv'
 
#enumerate all the domain in a forest
foreach($domain in (get-adforest).domains){
    #Kritik sistem objeleri hariç tüm kullanıcılar için sorgu
    #To list all users change "-LDAPFilter ..." for "-filter *"
    get-aduser -LDAPFilter "(!(IsCriticalSystemObject=TRUE))" `
    -properties enabled,description,whencreated,whenchanged,lastlogontimestamp,PwdLastSet,PasswordExpired,DistinguishedName,servicePrincipalName,memberof `
    -server $domain | Where-Object {($_.Enabled -eq 'True')} |`
    select @{name='Domain';expression={$domain}},`
    @{name='SamAccountName';expression={$_.SamAccountName}},`
    @{name='Description';expression={$_.description}},`
    @{name='Aktive';expression={$_.enabled}},`
    @{name='Expired';expression={$_.PasswordExpired}},`
    @{Name="Last Set";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, `
    @{Name="Total Days";Expression={if($_.PwdLastSet -ne 0){(new-TimeSpan([datetime]::FromFileTimeUTC($_.PwdLastSet)) $(Get-Date)).days}else{0}}}, `
    @{Name="Last Logon";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}}, `
    @{name='Changed.';expression={$_.whenchanged}},`
    @{name='Created';expression={$_.whencreated}},`
    @{Name="Service Principal Name is set";Expression={if($_.servicePrincipalName){$True}else{$False}}}, `
    @{Name="Member of";Expression={$_.memberof -join "`n"}}, `
    @{name='Distinguished name';expression={$_.distinguishedname}}| export-csv $default_log -NoTypeInformation
}
