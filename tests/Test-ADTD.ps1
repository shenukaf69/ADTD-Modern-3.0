<#
Offline test: replaces the LDAP layer with an in-memory Contoso forest, then runs the full
collect -> findings -> draw.io / HTML / CSV / JSON pipeline and checks the results.
Runs anywhere PowerShell 7 runs (no Active Directory needed):  pwsh ./tests/Test-ADTD.ps1
#>
param([string]$OutputFolder = (Join-Path $PSScriptRoot 'output'))
$ErrorActionPreference = 'Stop'
$mod = Import-Module (Join-Path $PSScriptRoot '..\src\ADTD.psm1') -Force -PassThru

& $mod {
    $cfg = 'CN=Configuration,DC=contoso,DC=com'
    $sch = "CN=Schema,$cfg"
    $root = 'DC=contoso,DC=com'
    $emea = 'DC=emea,DC=contoso,DC=com'
    $script:FakeDir = New-Object System.Collections.ArrayList
    function O([string]$dn, [string[]]$cls, [hashtable]$a = @{}) {
        $h = @{ distinguishedname = $dn; objectclass = $cls; name = ($dn -replace '^[^=]+=', '' -replace '(?<!\\),.*$', '') }
        foreach ($k in $a.Keys) { $h[$k.ToLower()] = $a[$k] }
        [void]$script:FakeDir.Add($h)
    }
    $sites = "CN=Sites,$cfg"
    function Dc($name, $site, $domainDN, $os, $ver, [switch]$Gc, [switch]$Ro) {
        $sdn = "CN=$name,CN=Servers,CN=$site,$sites"
        $fqdn = "$($name.ToLower()).$(($domainDN -replace 'DC=', '' -replace ',', '.'))"
        $comp = "CN=$name,OU=Domain Controllers,$domainDN"
        O $sdn @('top', 'server') @{ dNSHostName = $fqdn; serverReference = $comp }
        $cls = if ($Ro) { @('top', 'applicationSettings', 'nTDSDSA', 'nTDSDSARO') } else { @('top', 'applicationSettings', 'nTDSDSA') }
        O "CN=NTDS Settings,$sdn" $cls @{ options = $(if ($Gc) { 1 } else { 0 }); 'msDS-HasDomainNCs' = $domainDN }
        O $comp @('top', 'computer') @{ dNSHostName = $fqdn; operatingSystem = $os; operatingSystemVersion = $ver; primaryGroupID = $(if ($Ro) { 521 } else { 516 }) }
    }
    function Conn($to, $toSite, $from, $fromSite, [switch]$Manual) {
        O "CN=$([guid]::NewGuid()),CN=NTDS Settings,CN=$to,CN=Servers,CN=$toSite,$sites" @('top', 'nTDSConnection') @{ fromServer = "CN=NTDS Settings,CN=$from,CN=Servers,CN=$fromSite,$sites"; options = $(if ($Manual) { 0 } else { 1 }); enabledConnection = 'TRUE' }
    }

    O "CN=Partitions,$cfg" @('top', 'crossRefContainer') @{ 'msDS-Behavior-Version' = 7; fsmoRoleOwner = "CN=NTDS Settings,CN=DC01,CN=Servers,CN=London,$sites"; 'msDS-EnabledFeature' = "CN=Privileged Access Management Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,$cfg" }
    O $sch @('top', 'dMD') @{ objectVersion = 91; fsmoRoleOwner = "CN=NTDS Settings,CN=DC01,CN=Servers,CN=London,$sites" }
    O "CN=ms-Exch-Schema-Version-Pt,$sch" @('top', 'attributeSchema') @{ rangeUpper = 17003 }
    O "CN=Directory Service,CN=Windows NT,CN=Services,$cfg" @('top', 'nTDSService') @{ tombstoneLifetime = 180 }
    O "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,$cfg" @('top', 'msDS-OptionalFeature')
    O "CN=Privileged Access Management Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,$cfg" @('top', 'msDS-OptionalFeature')
    O "CN=Database 32k pages optional feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,$cfg" @('top', 'msDS-OptionalFeature')

    O "CN=CONTOSO,CN=Partitions,$cfg" @('top', 'crossRef') @{ nCName = $root; dnsRoot = 'contoso.com'; nETBIOSName = 'CONTOSO'; systemFlags = 3 }
    O "CN=EMEA,CN=Partitions,$cfg" @('top', 'crossRef') @{ nCName = $emea; dnsRoot = 'emea.contoso.com'; nETBIOSName = 'EMEA'; systemFlags = 3; trustParent = "CN=CONTOSO,CN=Partitions,$cfg" }
    O "CN=DomainDnsZones,CN=Partitions,$cfg" @('top', 'crossRef') @{ nCName = "DC=DomainDnsZones,$root"; dnsRoot = 'DomainDnsZones.contoso.com'; systemFlags = 5; 'msDS-NC-Replica-Locations' = @("CN=NTDS Settings,CN=DC01,CN=Servers,CN=London,$sites", "CN=NTDS Settings,CN=DC02,CN=Servers,CN=London,$sites", "CN=NTDS Settings,CN=DC03,CN=Servers,CN=Singapore,$sites") }
    O "CN=ForestDnsZones,CN=Partitions,$cfg" @('top', 'crossRef') @{ nCName = "DC=ForestDnsZones,$root"; dnsRoot = 'ForestDnsZones.contoso.com'; systemFlags = 5; 'msDS-NC-Replica-Locations' = @("CN=NTDS Settings,CN=DC01,CN=Servers,CN=London,$sites", "CN=NTDS Settings,CN=EMEADC1,CN=Servers,CN=Frankfurt,$sites") }
    O "CN=Enterprise Configuration,CN=Partitions,$cfg" @('top', 'crossRef') @{ nCName = $cfg; dnsRoot = 'contoso.com'; systemFlags = 1 }

    O $root @('top', 'domainDNS') @{ 'msDS-Behavior-Version' = 7; fsmoRoleOwner = "CN=NTDS Settings,CN=DC01,CN=Servers,CN=London,$sites"; gPLink = '[LDAP://cn={31B2F340-016D-11D2-945F-00C04FB984F9},cn=policies,cn=system,DC=contoso,DC=com;0]' }
    O "CN=RID Manager`$,CN=System,$root" @('top', 'rIDManager') @{ fsmoRoleOwner = "CN=NTDS Settings,CN=DC01,CN=Servers,CN=London,$sites" }
    O "CN=Infrastructure,$root" @('top', 'infrastructureUpdate') @{ fsmoRoleOwner = "CN=NTDS Settings,CN=DC02,CN=Servers,CN=London,$sites" }
    O $emea @('top', 'domainDNS') @{ 'msDS-Behavior-Version' = 6; fsmoRoleOwner = "CN=NTDS Settings,CN=EMEADC1,CN=Servers,CN=Frankfurt,$sites" }
    O "CN=RID Manager`$,CN=System,$emea" @('top', 'rIDManager') @{ fsmoRoleOwner = "CN=NTDS Settings,CN=EMEADC1,CN=Servers,CN=Frankfurt,$sites" }
    O "CN=Infrastructure,$emea" @('top', 'infrastructureUpdate') @{ fsmoRoleOwner = "CN=NTDS Settings,CN=EMEADC1,CN=Servers,CN=Frankfurt,$sites" }

    foreach ($s in 'London', 'Singapore', 'NewYork', 'Frankfurt', 'Auckland') {
        O "CN=$s,$sites" @('top', 'site') @{ location = $(if ($s -eq 'London') { 'UK' } else { $null }) }
        O "CN=NTDS Site Settings,CN=$s,$sites" @('top', 'applicationSiteSettings', 'nTDSSiteSettings') @{ options = $(if ($s -eq 'Singapore') { 0x20 } else { 0 }) }
    }
    O "CN=10.1.0.0/16,CN=Subnets,$sites" @('top', 'subnet') @{ siteObject = "CN=London,$sites" }
    O "CN=10.1.64.0/18,CN=Subnets,$sites" @('top', 'subnet') @{ siteObject = "CN=London,$sites" }
    O "CN=10.20.0.0/16,CN=Subnets,$sites" @('top', 'subnet') @{ siteObject = "CN=Singapore,$sites"; location = 'SG' }
    O "CN=10.30.0.0/16,CN=Subnets,$sites" @('top', 'subnet') @{ siteObject = "CN=NewYork,$sites" }
    O "CN=10.40.0.0/16,CN=Subnets,$sites" @('top', 'subnet') @{ siteObject = "CN=Frankfurt,$sites" }
    O "CN=192.168.99.0/24,CN=Subnets,$sites" @('top', 'subnet')

    $ip = "CN=IP,CN=Inter-Site Transports,$sites"
    O "CN=London-Singapore,$ip" @('top', 'siteLink') @{ siteList = @("CN=London,$sites", "CN=Singapore,$sites"); cost = 200; replInterval = 60 }
    O "CN=London-NewYork,$ip" @('top', 'siteLink') @{ siteList = @("CN=London,$sites", "CN=NewYork,$sites"); cost = 100; replInterval = 15; options = 1 }
    O "CN=Europe-Core,$ip" @('top', 'siteLink') @{ siteList = @("CN=London,$sites", "CN=Frankfurt,$sites", "CN=NewYork,$sites"); cost = 50; replInterval = 180 }
    O "CN=Bridge-All,$ip" @('top', 'siteLinkBridge') @{ siteLinkList = @("CN=London-Singapore,$ip", "CN=Europe-Core,$ip") }

    Dc 'DC01' 'London' $root 'Windows Server 2025 Datacenter' '10.0 (26100)' -Gc
    Dc 'DC02' 'London' $root 'Windows Server 2022 Standard' '10.0 (20348)' -Gc
    Dc 'DC03' 'Singapore' $root 'Windows Server 2019 Standard' '10.0 (17763)' -Gc
    Dc 'SGRODC1' 'Singapore' $root 'Windows Server 2025 Standard' '10.0 (26100)' -Gc -Ro
    Dc 'NYDC1' 'NewYork' $root 'Windows Server 2016 Standard' '10.0 (14393)'
    Dc 'EMEADC1' 'Frankfurt' $emea 'Windows Server 2012 R2 Standard' '6.3 (9600)' -Gc
    Conn 'DC02' 'London' 'DC01' 'London'; Conn 'DC01' 'London' 'DC02' 'London'
    Conn 'DC03' 'Singapore' 'DC01' 'London'; Conn 'DC01' 'London' 'DC03' 'Singapore'
    Conn 'SGRODC1' 'Singapore' 'DC03' 'Singapore'
    Conn 'NYDC1' 'NewYork' 'DC02' 'London' -Manual; Conn 'DC02' 'London' 'NYDC1' 'NewYork'
    Conn 'EMEADC1' 'Frankfurt' 'DC01' 'London'; Conn 'DC01' 'London' 'EMEADC1' 'Frankfurt'

    O "CN=emea.contoso.com,CN=System,$root" @('top', 'leaf', 'trustedDomain') @{ trustPartner = 'emea.contoso.com'; trustDirection = 3; trustType = 2; trustAttributes = 0x20 }
    O "CN=contoso.com,CN=System,$emea" @('top', 'leaf', 'trustedDomain') @{ trustPartner = 'contoso.com'; trustDirection = 3; trustType = 2; trustAttributes = 0x20 }
    O "CN=fabrikam.com,CN=System,$root" @('top', 'leaf', 'trustedDomain') @{ trustPartner = 'fabrikam.com'; trustDirection = 3; trustType = 2; trustAttributes = 0x8 }
    O "CN=tailspin.local,CN=System,$emea" @('top', 'leaf', 'trustedDomain') @{ trustPartner = 'tailspin.local'; trustDirection = 2; trustType = 2; trustAttributes = 0 }

    O "CN=Domain System Volume,CN=DFSR-GlobalSettings,CN=System,$root" @('top', 'msDFSR-ReplicationGroup')
    $rg = "CN=Branch Files,CN=DFSR-GlobalSettings,CN=System,$root"
    O $rg @('top', 'msDFSR-ReplicationGroup')
    O "CN=Files,CN=Content,$rg" @('top', 'msDFSR-ContentSet')
    O "CN=m1,CN=Topology,$rg" @('top', 'msDFSR-Member') @{ 'msDFSR-ComputerReference' = "CN=FS-LON,OU=Servers,$root" }
    O "CN=m2,CN=Topology,$rg" @('top', 'msDFSR-Member') @{ 'msDFSR-ComputerReference' = "CN=FS-SIN,OU=Servers,$root" }
    O "CN=c1,CN=m1,CN=Topology,$rg" @('top', 'msDFSR-Connection') @{ fromServer = "CN=m2,CN=Topology,$rg"; 'msDFSR-Enabled' = 'TRUE' }
    O "CN=c2,CN=m2,CN=Topology,$rg" @('top', 'msDFSR-Connection') @{ fromServer = "CN=m1,CN=Topology,$rg"; 'msDFSR-Enabled' = 'TRUE' }
    # emea has no DFSR SYSVOL -> FRS finding.

    O "CN={31B2F340-016D-11D2-945F-00C04FB984F9},CN=Policies,CN=System,$root" @('top', 'groupPolicyContainer') @{ displayName = 'Default Domain Policy' }
    O "CN={6AC1786C-016F-11D2-945F-00C04FB984F9},CN=Policies,CN=System,$root" @('top', 'groupPolicyContainer') @{ displayName = 'Default Domain Controllers Policy' }
    O "CN={11111111-2222-3333-4444-555555555555},CN=Policies,CN=System,$root" @('top', 'groupPolicyContainer') @{ displayName = 'Workstation Baseline' }
    O "OU=Domain Controllers,$root" @('top', 'organizationalUnit') @{ gPLink = '[LDAP://cn={6AC1786C-016F-11D2-945F-00C04FB984F9},cn=policies,cn=system,DC=contoso,DC=com;0]' }
    O "OU=Corp,$root" @('top', 'organizationalUnit')
    O "OU=Workstations,OU=Corp,$root" @('top', 'organizationalUnit') @{ gPLink = '[LDAP://cn={11111111-2222-3333-4444-555555555555},cn=policies,cn=system,DC=contoso,DC=com;2][LDAP://cn={99999999-2222-3333-4444-555555555555},cn=policies,cn=system,DC=contoso,DC=com;1]' }
    O "OU=Kiosks,OU=Workstations,OU=Corp,$root" @('top', 'organizationalUnit') @{ gPOptions = 1 }
    O "OU=Users,OU=Corp,$root" @('top', 'organizationalUnit')
    O "OU=Servers,$root" @('top', 'organizationalUnit')

    $ex = "CN=Microsoft Exchange,CN=Services,$cfg"
    O "CN=Contoso,$ex" @('top', 'msExchOrganizationContainer')
    $ag = "CN=Exchange Administrative Group (FYDIBOHF23SPDLT),CN=Administrative Groups,CN=Contoso,$ex"
    O "CN=DAG1,CN=Database Availability Groups,$ag" @('top', 'msExchMDBAvailabilityGroup')
    O "CN=EXSE1,CN=Servers,$ag" @('top', 'server', 'msExchExchangeServer') @{ serialNumber = 'Version 15.2 (Build 2562.17)'; msExchCurrentServerRoles = 16439; msExchServerSite = "CN=London,$sites"; networkAddress = @('ncacn_ip_tcp:exse1.contoso.com', 'netbios:EXSE1'); msExchMDBAvailabilityGroupLink = "CN=DAG1,CN=Database Availability Groups,$ag" }
    O "CN=EXSE2,CN=Servers,$ag" @('top', 'server', 'msExchExchangeServer') @{ serialNumber = 'Version 15.2 (Build 2562.17)'; msExchCurrentServerRoles = 16439; msExchServerSite = "CN=Singapore,$sites"; networkAddress = @('ncacn_ip_tcp:exse2.contoso.com'); msExchMDBAvailabilityGroupLink = "CN=DAG1,CN=Database Availability Groups,$ag" }
    O "CN=EX2019,CN=Servers,$ag" @('top', 'server', 'msExchExchangeServer') @{ serialNumber = 'Version 15.2 (Build 1748.10)'; msExchCurrentServerRoles = 16439; msExchServerSite = "CN=NewYork,$sites" }

    # ---- security and hybrid fixture ----
    $now = [datetime]::UtcNow
    function Get-FakeFileTime([int]$daysAgo) { $now.AddDays(-$daysAgo).ToFileTimeUtc() }
    $old = [datetime]'2020-01-01'
    $rootSid = 'S-1-5-21-1-2-3'; $emeaSid = 'S-1-5-21-4-5-6'
    ($script:FakeDir | Where-Object { $_.distinguishedname -eq $root })['objectsid'] = $rootSid
    $rh = $script:FakeDir | Where-Object { $_.distinguishedname -eq $root }
    $rh['minpwdlength'] = 7; $rh['lockoutthreshold'] = 0; $rh['pwdproperties'] = 1; $rh['ms-ds-machineaccountquota'] = 10; $rh['maxpwdage'] = -36288000000000
    $eh = $script:FakeDir | Where-Object { $_.distinguishedname -eq $emea }
    $eh['objectsid'] = $emeaSid; $eh['minpwdlength'] = 14; $eh['lockoutthreshold'] = 10; $eh['pwdproperties'] = 1; $eh['ms-ds-machineaccountquota'] = 0

    $G = @{
        DA = "CN=Domain Admins,CN=Users,$root"; EA = "CN=Enterprise Admins,CN=Users,$root"; SA = "CN=Schema Admins,CN=Users,$root"
        ADM = "CN=Administrators,CN=Builtin,$root"; AO = "CN=Account Operators,CN=Builtin,$root"; PU = "CN=Protected Users,CN=Users,$root"
        PW = "CN=Pre-Windows 2000 Compatible Access,CN=Builtin,$root"; DNS = "CN=DnsAdmins,CN=Users,$root"; EDA = "CN=Domain Admins,CN=Users,$emea"
    }
    O $G.DA @('top', 'group') @{ objectSid = "$rootSid-512" }
    O $G.EA @('top', 'group') @{ objectSid = "$rootSid-519" }
    O $G.SA @('top', 'group') @{ objectSid = "$rootSid-518" }
    O $G.ADM @('top', 'group') @{ objectSid = 'S-1-5-32-544' }
    O $G.AO @('top', 'group') @{ objectSid = 'S-1-5-32-548'; member = "CN=helpdesk1,CN=Users,$root" }
    O $G.PU @('top', 'group') @{ objectSid = "$rootSid-525" }
    O $G.PW @('top', 'group') @{ objectSid = 'S-1-5-32-554'; member = @("CN=S-1-5-11,CN=ForeignSecurityPrincipals,$root", "CN=S-1-5-7,CN=ForeignSecurityPrincipals,$root") }
    O $G.DNS @('top', 'group') @{ sAMAccountName = 'DnsAdmins'; member = "CN=dns.op,CN=Users,$root" }
    O $G.EDA @('top', 'group') @{ objectSid = "$emeaSid-512" }

    function U($name, $domainDN, [int]$uac = 0x200, [int]$lastDays = 5, [int]$pwdDays = 30, $memberOf = @(), $extra = @{}) {
        $a = @{ sAMAccountName = $name; userAccountControl = $uac; lastLogonTimestamp = (Get-FakeFileTime $lastDays); pwdLastSet = (Get-FakeFileTime $pwdDays); whenCreated = $old; memberOf = $memberOf; userPrincipalName = "$name@contoso.com" }
        foreach ($k in $extra.Keys) { $a[$k] = $extra[$k] }
        O "CN=$name,CN=Users,$domainDN" @('top', 'person', 'organizationalPerson', 'user') $a
    }
    U 'krbtgt' $root 0x202 -pwdDays 400 -extra @{ objectSid = "$rootSid-502" }
    U 'Administrator' $root 0x10200 -pwdDays 800 -memberOf @($G.DA, $G.EA, $G.SA) -extra @{ objectSid = "$rootSid-500"; adminCount = 1 }
    U 'Guest' $root 0x200 -extra @{ objectSid = "$rootSid-501" }
    U 'admin.jane' $root -memberOf @($G.DA, $G.PU) -extra @{ adminCount = 1 }
    U 'svc.sql' $root 0x10200 -memberOf @($G.DA) -extra @{ servicePrincipalName = 'MSSQLSvc/sql01.contoso.com:1433'; adminCount = 1 }
    foreach ($n in 1..4) { U "da$n" $root -memberOf @($G.DA) -extra @{ adminCount = 1 } }
    U 'da.stale' $root -lastDays 200 -memberOf @($G.DA) -extra @{ adminCount = 1 }
    U 'helpdesk1' $root -memberOf @($G.AO)
    U 'dns.op' $root
    U 'svc.web' $root -extra @{ servicePrincipalName = 'HTTP/web01.contoso.com'; 'msDS-SupportedEncryptionTypes' = 4 }
    U 'old.user' $root -lastDays 200
    U 'asrep.user' $root (0x200 -bor 0x400000)
    U 'nopwd.user' $root (0x200 -bor 0x20)
    U 'migrated.user' $root -extra @{ sIDHistory = 'S-1-5-21-9-9-9-1105' }
    U 'local.user' $root -extra @{ userPrincipalName = 'local.user@contoso.local' }
    U 'noupn.user' $root -extra @{ userPrincipalName = $null }
    U 'disabled.user' $root 0x202 -lastDays 900
    U 'MSOL_1a2b3c4d5e6f' $root 0x10200 -extra @{ description = 'Account created by Microsoft Azure Active Directory Connect with installation identifier 1a2b running on computer SYNC01 configured to synchronize to tenant contoso.onmicrosoft.com. This account must have directory replication permissions.' }
    U 'krbtgt' $emea 0x202 -pwdDays 20
    U 'emea.admin' $emea -memberOf @($G.EDA) -extra @{ adminCount = 1 }
    U 'emea.user' $emea

    function C($name, $domainDN, $os, $ver, [int]$uac = 0x1000, [int]$lastDays = 3, [switch]$Laps, $extra = @{}) {
        $a = @{ name = $name; userAccountControl = $uac; lastLogonTimestamp = (Get-FakeFileTime $lastDays); pwdLastSet = (Get-FakeFileTime 10); operatingSystem = $os; operatingSystemVersion = $ver; primaryGroupID = 515; whenCreated = $old }
        if ($Laps) { $a['msLAPS-PasswordExpirationTime'] = (Get-FakeFileTime -20) }
        foreach ($k in $extra.Keys) { $a[$k] = $extra[$k] }
        O "CN=$name,OU=Servers,$domainDN" @('top', 'computer') $a
    }
    C 'WS01' $root 'Windows 11 Enterprise' '10.0 (26100)' -Laps
    C 'WS02' $root 'Windows 10 Enterprise' '10.0 (19045)'
    C 'APP01' $root 'Windows Server 2019 Standard' '10.0 (17763)' (0x1000 -bor 0x80000) -Laps
    C 'OLD01' $root 'Windows Server 2012 R2 Standard' '6.3 (9600)' -lastDays 300 -Laps
    C 'NAS01' $root 'OnTap' '9.1' -Laps
    O "CN=AZUREADSSOACC,CN=Computers,$root" @('top', 'computer') @{ name = 'AZUREADSSOACC'; userAccountControl = 0x1000; pwdLastSet = (Get-FakeFileTime 120); primaryGroupID = 515 }
    O "CN=AzureADKerberos,OU=Domain Controllers,$root" @('top', 'computer') @{ name = 'AzureADKerberos'; userAccountControl = 0x5001000; primaryGroupID = 521 }
    C 'EMEAWS1' $emea 'Windows 11 Enterprise' '10.0 (26200)' -Laps

    O "CN=ms-LAPS-Password,$sch" @('top', 'attributeSchema')
    O "CN=gmsa-web,CN=Managed Service Accounts,$root" @('top', 'msDS-GroupManagedServiceAccount') @{ sAMAccountName = 'gmsa-web$' }
    O "CN=Admins-PSO,CN=Password Settings Container,CN=System,$root" @('top', 'msDS-PasswordSettings')
    O "CN=62a0ff2e-97b9-4513-943f-0d221bd30080,CN=Device Registration Configuration,CN=Services,$cfg" @('top', 'serviceConnectionPoint') @{ keywords = @('azureADName:contoso.onmicrosoft.com', 'azureADId:00000000-1111-2222-3333-444444444444') }
    O "CN=ADFS,CN=Microsoft,CN=Program Data,$root" @('top', 'container')
    $pks = "CN=Public Key Services,CN=Services,$cfg"
    O "CN=Contoso-CA,CN=Enrollment Services,$pks" @('top', 'pKIEnrollmentService') @{ dNSHostName = 'ca01.contoso.com'; certificateTemplates = @('User', 'WebServer', 'VulnTemplate') }
    O "CN=VulnTemplate,CN=Certificate Templates,$pks" @('top', 'pKICertificateTemplate') @{ 'msPKI-Certificate-Name-Flag' = 1; 'msPKI-Enrollment-Flag' = 0; 'msPKI-RA-Signature' = 0; pKIExtendedKeyUsage = @('1.3.6.1.5.5.7.3.2') }
    O "CN=WebServer,CN=Certificate Templates,$pks" @('top', 'pKICertificateTemplate') @{ 'msPKI-Certificate-Name-Flag' = 1; 'msPKI-Enrollment-Flag' = 0; 'msPKI-RA-Signature' = 0; pKIExtendedKeyUsage = @('1.3.6.1.5.5.7.3.1') }
    O "CN=User,CN=Certificate Templates,$pks" @('top', 'pKICertificateTemplate') @{ 'msPKI-Certificate-Name-Flag' = 0x82000000; 'msPKI-Enrollment-Flag' = 41; pKIExtendedKeyUsage = @('1.3.6.1.5.5.7.3.2') }

    foreach ($o in @($script:FakeDir | Where-Object { $_.objectclass -contains 'computer' -and $_.primarygroupid -in 516, 521 -and -not $_.lastlogontimestamp })) { $o['lastlogontimestamp'] = (Get-FakeFileTime 1); $o['useraccountcontrol'] = $(if ($o.primarygroupid -eq 521) { 0x5001000 } else { 0x82000 }); $o['name'] = ($o.distinguishedname -replace '^CN=([^,]+),.*$', '$1') }

    # ---- tiny LDAP filter evaluator ----
    function script:Test-Filter([hashtable]$o, [string]$f) {
        $f = $f.Trim()
        if ($f.StartsWith('(') -and $f.EndsWith(')')) { $f = $f.Substring(1, $f.Length - 2) }
        $op = $f[0]
        if ($op -eq '&' -or $op -eq '|' -or $op -eq '!') {
            $parts = @(); $depth = 0; $start = -1
            for ($i = 1; $i -lt $f.Length; $i++) {
                if ($f[$i] -eq '(') { if ($depth -eq 0) { $start = $i }; $depth++ }
                elseif ($f[$i] -eq ')') { $depth--; if ($depth -eq 0) { $parts += $f.Substring($start, $i - $start + 1) } }
            }
            $res = @($parts | ForEach-Object { Test-Filter $o $_ })
            if ($op -eq '&') { return -not ($res -contains $false) }
            if ($op -eq '|') { return $res -contains $true }
            return -not $res[0]
        }
        $attr, $val = $f -split '=', 2
        $attr = ($attr.ToLower() -replace ':.*$', ''); if ($attr -eq 'objectcategory') { $attr = 'objectclass' }
        $vals = @($o[$attr])
        if (-not $vals.Count -or $null -eq $vals[0]) { return $false }
        if ($val -eq '*') { return $true }
        $rx = '^' + ([regex]::Escape($val) -replace '\\\*', '.*') + '$'
        return [bool](@($vals | Where-Object { "$_" -match $rx }).Count)
    }

    Set-Item function:script:Get-AdtdRootDse -Value ({ param([string]$Server) @{ defaultnamingcontext = 'DC=contoso,DC=com'; configurationnamingcontext = 'CN=Configuration,DC=contoso,DC=com'; schemanamingcontext = 'CN=Schema,CN=Configuration,DC=contoso,DC=com'; rootdomainnamingcontext = 'DC=contoso,DC=com'; dnshostname = 'dc01.contoso.com' } })
    Set-Item function:script:Invoke-AdtdLdapSearch -Value ({
            param([string]$SearchBase, [string]$Filter = '(objectClass=*)', [string[]]$Properties, [string]$Scope = 'Subtree', [string]$Server, [switch]$GlobalCatalog)
            $script:LdapCalls++
            $base = $SearchBase.ToLower()
            $baseDepth = ([regex]::Split($SearchBase, '(?<!\\),')).Count
            foreach ($o in $script:FakeDir) {
                $dn = $o.distinguishedname.ToLower()
                $depth = ([regex]::Split($o.distinguishedname, '(?<!\\),')).Count
                $inScope = switch ($Scope) {
                    'Base' { $dn -eq $base }
                    'OneLevel' { $dn.EndsWith(",$base") -and $depth -eq $baseDepth + 1 }
                    default { $dn -eq $base -or $dn.EndsWith(",$base") }
                }
                # A normal LDAP search stays inside one naming context (no referral chasing); a GC search spans the forest.
                if ($inScope -and -not $GlobalCatalog) {
                    $nc = { param($x) (([regex]::Split($x, '(?<!\\),') | Where-Object { $_ -match '^dc=' }) -join ',') }
                    if ((& $nc $dn) -ne (& $nc $base)) { $inScope = $false }
                }
                if ($inScope -and (Test-Filter $o $Filter)) { $o.Clone() }
            }
        })
    $script:LdapCalls = 0
}

$fail = 0
function Check($cond, $msg) { if ($cond) { Write-Host "  PASS  $msg" -ForegroundColor Green } else { Write-Host "  FAIL  $msg" -ForegroundColor Red; $script:fail++ } }

if (Test-Path $OutputFolder) { Remove-Item $OutputFolder -Recurse -Force }
$r = Invoke-ADTD -All -Format DrawIo, Html, HtmlTabs, Markdown, Csv, Json -OutputFolder $OutputFolder
$inv = Get-Content -Raw $r.Files.Json | ConvertFrom-Json

Write-Host 'Inventory'
Check ($inv.Forest.Name -eq 'contoso.com') 'forest name'
Check ($inv.Forest.SchemaVersionName -eq 'Windows Server 2025') 'schema 91 = Windows Server 2025'
Check ($inv.Forest.FunctionalLevelName -eq 'Windows Server 2016') 'forest functional level'
Check ($inv.Forest.ExchangeSchemaName -like 'Exchange 2019*') 'Exchange schema'
Check (@($inv.Domains).Count -eq 2 -and $inv.Domains[0].IsForestRoot) 'two domains, root first'
Check (($inv.Domains | Where-Object Name -eq 'emea.contoso.com').ParentDomain -eq 'contoso.com') 'child domain parent'
Check (($inv.Domains | Where-Object Name -eq 'emea.contoso.com').SysvolReplication -eq 'FRS') 'FRS SYSVOL detected'
Check (@($inv.DomainControllers).Count -eq 6) 'six DCs'
$dc01 = $inv.DomainControllers | Where-Object Name -eq 'DC01'
Check ($dc01.OperatingSystem -eq 'Windows Server 2025' -and $dc01.IsGlobalCatalog) 'DC01 is 2025 GC'
Check (@($dc01.FsmoRoles) -contains 'PDC' -and @($dc01.FsmoRoles) -contains 'Schema' -and @($dc01.FsmoRoles) -contains 'RID') 'DC01 FSMO roles'
Check (($inv.DomainControllers | Where-Object Name -eq 'SGRODC1').IsReadOnly) 'RODC detected'
Check (($inv.DomainControllers | Where-Object Name -eq 'EMEADC1').OSSupportState -eq 'Unsupported') '2012 R2 flagged unsupported'
Check (($inv.DomainControllers | Where-Object Name -eq 'EMEADC1').Domain -eq 'emea.contoso.com') 'DC domain from serverReference'
Check (@($inv.Sites).Count -eq 5 -and @($inv.Subnets).Count -eq 6) 'sites and subnets'
Check ((@($inv.SiteLinks | Where-Object Name -eq 'Europe-Core').Sites).Count -eq 3) 'multi-site link'
Check (($inv.SiteLinks | Where-Object Name -eq 'London-NewYork').ChangeNotification) 'change notification'
Check (@($inv.Connections).Count -eq 9 -and @($inv.Connections | Where-Object { -not $_.Automatic }).Count -eq 1) 'connections'
Check (@($inv.Trusts).Count -eq 4) 'trusts'
Check ((@($inv.AppPartitions).Count -eq 2) -and (@(($inv.AppPartitions | Where-Object Name -like 'Domain*').Replicas).Count -eq 3)) 'application partitions'
$ws = $inv.OUs | Where-Object Name -eq 'Workstations'
Check ($ws.GpoLinks[0].Name -eq '(missing GPO {99999999-2222-3333-4444-555555555555})' -and $ws.GpoLinks[0].Disabled) 'gPLink order, missing and disabled GPO'
Check ($ws.GpoLinks[1].Enforced -and $ws.GpoLinks[1].Name -eq 'Workstation Baseline') 'enforced GPO link'
Check (($inv.OUs | Where-Object Name -eq 'Kiosks').BlockInheritance -and ($inv.OUs | Where-Object Name -eq 'Kiosks').Depth -eq 3) 'block inheritance and depth'
Check (@($inv.Dfsr).Count -eq 2 -and @(($inv.Dfsr | Where-Object Name -eq 'Branch Files').Connections).Count -eq 2) 'DFSR groups'
Check ((($inv.Exchange.Servers | Where-Object Name -eq 'EXSE1').Product) -eq 'Exchange Server SE') 'Exchange SE detected'
Check (-not (($inv.Exchange.Servers | Where-Object Name -eq 'EX2019').Supported)) 'Exchange 2019 unsupported'
Check ((($inv.Exchange.Servers | Where-Object Name -eq 'EXSE1').Dag) -eq 'DAG1') 'DAG membership'
Check ((@(($inv.Exchange.Servers | Where-Object Name -eq 'EXSE1').Roles) -join ',') -eq 'Mailbox') 'Exchange roles are a flat list'

Write-Host 'Security scan'
$sc = $inv.Security.Domains | Where-Object Domain -eq 'contoso.com'
Check ($sc.KrbtgtPasswordAgeDays -ge 399 -and $sc.KrbtgtPasswordAgeDays -le 401) 'krbtgt password age'
Check ((@($sc.Groups | Where-Object Key -eq 'DomainAdmins')[0].EnabledMembers) -eq 8) 'Domain Admins effective members'
Check ($sc.Users.Enabled -eq 19) "enabled users counted ($($sc.Users.Enabled))"
Check (@($sc.Users.NoPreauth) -contains 'asrep.user' -and @($sc.Users.PwdNotRequired) -contains 'nopwd.user') 'UAC flags'
Check (@($sc.Users.ServiceAccountsWithSpn) -contains 'svc.web' -and -not (@($sc.Users.ServiceAccountsWithSpn) -contains 'svc.sql')) 'non-privileged SPN accounts'
Check (@($sc.Users.Stale) -contains 'old.user' -and -not (@($sc.Users.Stale) -contains 'disabled.user')) 'stale users (enabled only)'
Check ((@($sc.Users.Privileged | Where-Object Name -eq 'admin.jane')[0]).InProtectedUsers) 'Protected Users membership'
Check (@($sc.Computers.TrustedForDelegation) -contains 'APP01' -and -not (@($sc.Computers.TrustedForDelegation) -match 'DC0')) 'unconstrained delegation excludes DCs'
Check (@($sc.Computers.Unsupported).Count -eq 2) "unsupported computers ($(@($sc.Computers.Unsupported) -join '; '))"
Check ($sc.Computers.LapsEligible -eq 4 -and $sc.Computers.WindowsLapsCovered -eq 3) 'LAPS coverage (non-Windows excluded)'
Check ($sc.Hybrid.SeamlessSsoPasswordAgeDays -ge 119 -and $sc.Hybrid.EntraKerberos -and $sc.Hybrid.AdfsDkmContainer) 'hybrid objects detected'
Check ((@($sc.Hybrid.ConnectSyncAccounts)[0]).Server -eq 'SYNC01') 'Entra Connect server from MSOL account'
Check ($inv.Security.Forest.TenantName -eq 'contoso.onmicrosoft.com' -and $inv.Security.Forest.WindowsLapsSchema) 'tenant from SCP, Windows LAPS schema'
Check ((@($inv.Security.Forest.RiskyTemplates).Name -join ',') -eq 'VulnTemplate') 'ESC1-style template detected, safe templates ignored'
Check ($inv.Exchange.Organization -eq 'Contoso') 'single search result (Exchange organization) is read correctly'
Check ($sc.GmsaCount -eq 1 -and $sc.PasswordPolicy.FineGrainedPolicies -eq 1) 'single gMSA and single fine-grained policy counted as 1'

Write-Host 'Findings'
$f = @($inv.Findings)
$ids = @($f | ForEach-Object Id)
foreach ($id in 'H01', 'H02', 'H04', 'H06', 'H07', 'H09', 'H11', 'H12', 'H13', 'H16', 'H17', 'S01', 'S02', 'S03', 'S04', 'S05', 'S06', 'S07', 'S08', 'S09', 'S10', 'S11', 'S12', 'S14', 'S17', 'S18', 'S19', 'S21', 'S22', 'S23', 'S26', 'S27', 'S28', 'S29', 'S30', 'S31', 'S32', 'X02', 'X03', 'X04', 'X05', 'X07', 'X08') {
    Check ($ids -contains $id) "finding $id $(($f | Where-Object Id -eq $id).Title)"
}
foreach ($id in 'X01', 'X06', 'S24', 'S25', 'S15', 'S16', 'H05') { Check (-not ($ids -contains $id)) "no false positive $id" }
Check ((@($f | Where-Object Id -eq 'H01')[0].Evidence -join ' ') -match 'EMEADC1') 'H01 evidence names EMEADC1'
Check ((@($f | Where-Object Id -eq 'S01')[0].Finding) -match 'tailspin.local') 'S01 names the trust'
Check ((@($f | Where-Object Id -eq 'S02')[0].Severity) -eq 'High') 'krbtgt older than a year is High'
Check ((@($f | Where-Object Id -eq 'S31')[0].Severity) -eq 'High') 'SSO key older than 90 days is High'
Check ((@($f | Where-Object Id -eq 'S17')[0].Evidence) -contains 'contoso.com\AZUREADSSOACC') 'RC4 check includes AZUREADSSOACC'
Check ((@($f | Where-Object Id -eq 'X07')[0].Evidence) -contains 'emea.contoso.com') 'Entra Kerberos missing in emea only'
Check (@($f | Where-Object { -not $_.Steps.Count -or -not $_.Risk }).Count -eq 0) 'every finding has risk and steps'
Check (@($f | Where-Object { @($_.Evidence | Where-Object { -not "$_" }).Count -or $_.Finding -match ': \.$' }).Count -eq 0) 'no finding has empty evidence'
Check (-not ($ids -contains 'S13')) 'RODCs are not flagged for protocol transition'
Check ($f[0].Severity -eq 'High' -and $f[-1].Severity -eq 'Low') 'findings sorted by severity'

Write-Host 'Hybrid plan'
Check (@($inv.Plan.Phases).Count -eq 4 -and @($inv.Plan.Phases[0].Tasks).Count -gt 5) 'four-phase roadmap'
Check (@($inv.Plan.Gaps | Where-Object { $_.Capability -eq 'Directory sync to Microsoft Entra ID' -and $_.Status -eq 'Present' }).Count -eq 1) 'gap analysis sees sync'
Check (@($inv.Plan.Gaps | Where-Object { $_.Capability -eq 'Cloud authentication (no AD FS)' -and $_.Status -eq 'Missing' }).Count -eq 1) 'gap analysis sees AD FS'
Check (@($inv.Plan.Target | Where-Object Area -eq 'Forest design').Count -eq 1) 'multi-domain consolidation advice'

Write-Host 'Outputs'
[xml]$x = Get-Content -Raw $r.Files.DrawIo
$pages = @($x.mxfile.diagram)
Check ($pages.Count -eq 11) "draw.io has 11 pages ($($pages.name -join ' | '))"
$ids = @{}
$dupe = $false; $dangling = 0
foreach ($p in $pages) {
    $cells = @($p.mxGraphModel.root.ChildNodes)
    $pid_ = @{}
    foreach ($c in $cells) { if ($pid_[$c.id]) { $dupe = $true }; $pid_[$c.id] = $true }
    foreach ($c in $cells) {
        $cell = if ($c.LocalName -eq 'UserObject') { $c.mxCell } else { $c }
        if ($cell.parent -and -not $pid_[$cell.parent]) { $dangling++ }
        if ($cell.edge -eq '1' -and (-not $pid_[$cell.source] -or -not $pid_[$cell.target])) { $dangling++ }
    }
}
Check (-not $dupe) 'no duplicate cell ids per page'
Check ($dangling -eq 0) 'every parent, source and target exists'
$sitesPage = $pages | Where-Object name -eq 'Sites and site links'
Check (@($sitesPage.mxGraphModel.root.mxCell | Where-Object { $_.edge -eq '1' }).Count -eq 5) 'site link edges (2 direct + 3 via hub)'
Check ((Get-Content -Raw $r.Files.Html) -match 'Exchange Server SE') 'HTML report contains Exchange'
Check (@(Get-ChildItem "$($r.Files.Json -replace '\.json$','')-csv" -Filter *.csv).Count -ge 14) 'CSV files'
$html = Get-Content -Raw $r.Files.Html
Check ($html -match 'id="S05"' -and $html -match 'How to fix' -and $html -match 'learn.microsoft.com') 'HTML has a card per finding with steps and references'
Check ($html -match 'window.adtdRender' -and $html -match 'mxGraph' -and $html -notmatch 'viewer.diagrams.net/js') 'HTML has the built-in offline diagram viewer'
$ro = Invoke-ADTD -InputFile $r.Files.Json -Format DrawIo, HtmlTabs -Offline -OutputFolder (Join-Path $OutputFolder 'offline')
$offHtml = Get-Content -Raw $ro.Files.HtmlTabs
Check (-not $ro.Files.DrawIoWebLink -and $offHtml -notmatch 'app.diagrams.net/\?' -and $offHtml -match 'window.adtdRender') 'offline mode: no web links, built-in viewer'
$rw = Invoke-ADTD -InputFile $r.Files.Json -Format DrawIo, Html -DrawIoWebViewer -OutputFolder (Join-Path $OutputFolder 'webviewer')
Check ((Get-Content -Raw $rw.Files.Html) -match 'viewer-static.min.js') 'optional draw.io web viewer'
Check ($html -match 'what on-premises AD is missing') 'HTML has the gap analysis'
$tabs = Get-Content -Raw $r.Files.HtmlTabs
Check ($tabs -match "data-tab='findings'" -and $tabs -match "data-tab='diagrams'" -and $tabs -match "data-tab='plan'" -and $tabs -match "data-tab='inventory'") 'tabbed HTML has all tabs'
Check (([regex]::Matches($tabs, "class='sub' data-page=")).Count -eq 11) 'tabbed HTML has a diagram tab per draw.io page'
$jsonXml = [regex]::Match($tabs, "<script type='application/json' id='dgm-xml'>(.*?)</script>", 'Singleline').Groups[1].Value
Check (($jsonXml | ConvertFrom-Json) -eq [System.IO.File]::ReadAllText($r.Files.DrawIo)) 'tabbed HTML embeds the drawing intact'
$md = @(Get-ChildItem $r.Files.Markdown -Filter *.md)
Check ($md.Count -eq @($inv.Findings).Count + 2) "one Markdown file per finding + index + plan ($($md.Count))"
Check ((Get-Content -Raw (Join-Path $r.Files.Markdown 'hybrid-plan.md')) -match '### Phase 3') 'hybrid-plan.md has the roadmap'
$url = ((Get-Content $r.Files.DrawIoWebLink) | Where-Object { $_ -like 'URL=*' }) -replace '^URL=', ''
$frag = [uri]::UnescapeDataString(($url -split '#R', 2)[1])
$ms = New-Object System.IO.MemoryStream(, [Convert]::FromBase64String($frag))
$ds = New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
$sr = New-Object System.IO.StreamReader($ds)
$roundTrip = [uri]::UnescapeDataString($sr.ReadToEnd())
Check ($url -like 'https://app.diagrams.net/*#R*' -and $roundTrip -eq [System.IO.File]::ReadAllText($r.Files.DrawIo)) 'draw.io web link decodes back to the drawing'

Write-Host 'Re-draw from JSON'
$r2 = Invoke-ADTD -InputFile $r.Files.Json -All -Format DrawIo, Html -OutputFolder (Join-Path $OutputFolder 'redraw')
Check ((Get-Item $r2.Files.DrawIo).Length -gt 10000 -and $r2.Findings -eq $r.Findings) 'redraw from saved inventory'

Write-Host 'App and installer'
$srcDir = Join-Path $PSScriptRoot '..\src'
$exeBytes = [System.IO.File]::ReadAllBytes((Join-Path $srcDir 'ADTD.exe'))
$pe = [BitConverter]::ToInt32($exeBytes, 0x3c)
Check ($exeBytes[0] -eq 0x4D -and $exeBytes[1] -eq 0x5A -and [BitConverter]::ToUInt16($exeBytes, $pe + 24 + 68) -eq 2) 'ADTD.exe is a Windows GUI app (no console window)'
Check ([System.Text.Encoding]::Unicode.GetString($exeBytes) -match 'Shenuka Fernando') 'ADTD.exe carries the author in its version info'
$ico = [System.IO.File]::ReadAllBytes((Join-Path $srcDir 'ADTD.ico'))
Check ([BitConverter]::ToUInt16($ico, 2) -eq 1 -and [BitConverter]::ToUInt16($ico, 4) -ge 6) 'app icon has all sizes'
$wxs = [xml](Get-Content -Raw (Join-Path $PSScriptRoot '..\setup\ADTD.wxs'))
$wxsFiles = @($wxs.GetElementsByTagName('File') | ForEach-Object { Split-Path $_.Source -Leaf })
$needed = @(Get-ChildItem $srcDir -File | Where-Object { $_.Extension -in '.ps1', '.psm1', '.psd1', '.exe', '.ico', '.png' } | ForEach-Object Name)
Check (-not ($needed | Where-Object { $_ -notin $wxsFiles })) "MSI includes every app file ($($needed.Count))"
Check (@($wxs.GetElementsByTagName('Shortcut') | Where-Object { $_.Name -eq 'ADTD Modern' }).Target -eq '[INSTALLDIR]ADTD.exe') 'Start menu shortcut opens ADTD.exe'
Check ($wxs.OuterXml -match 'ARPPRODUCTICON' -and $wxs.OuterXml -match '--welcome') 'MSI sets the Apps icon and opens the welcome screen'
$showCmd = Get-Command Show-ADTD
Check ($showCmd.Parameters.ContainsKey('Welcome') -and $showCmd.Parameters.ContainsKey('HostPath') -and (Get-Command Test-AdtdConnection -ErrorAction SilentlyContinue)) 'window, welcome and connection test commands'
$info = & $mod { Get-AdtdInstallInfo }
Check ($info.Folder -and $info.Exe -like '*ADTD.exe' -and $info.Kind -like 'Not installed*') 'install location is detected'
Check ((& $mod { $script:AdtdAuthor }) -eq 'Shenuka Fernando' -and (Get-Content -Raw (Join-Path $srcDir 'ADTD.Gui.ps1')) -match 'Designed and developed by') 'About shows the author'
# PowerShell variable names ignore case, so $T and $t are the same variable. Catch that in every function.
$clash = foreach ($file in Get-ChildItem $srcDir -Filter *.ps*1) {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$null)
    foreach ($fn in $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)) {
        $names = $fn.Body.FindAll({ $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] }, $true) |
            ForEach-Object { $_.VariablePath.UserPath } | Where-Object { $_ -notmatch ':' } | Sort-Object -Unique -CaseSensitive
        $names | Group-Object { $_.ToLowerInvariant() } | Where-Object Count -gt 1 | ForEach-Object { "$($fn.Name): $($_.Group -join ' / ')" }
    }
}
Check (-not $clash) "no variables that differ only in case $(if ($clash) { '(' + ($clash -join '; ') + ')' })"
$setFile = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'ADTD\settings.json'
$setBackup = if (Test-Path $setFile) { Get-Content -Raw $setFile } else { $null }
try {
    [void](Set-AdtdSettings -WelcomeShown '9.9.9')
    [void](Set-AdtdSettings -DrawIoViewer Web)
    $st = Get-AdtdSettings
    Check ($st.WelcomeShown -eq '9.9.9' -and $st.DrawIoViewer -eq 'Web') 'settings remember the welcome screen and viewer'
} finally { if ($null -ne $setBackup) { Set-Content -Path $setFile -Value $setBackup -NoNewline } else { Remove-Item $setFile -ErrorAction SilentlyContinue } }

Write-Host ''
if ($fail) { Write-Host "$fail check(s) failed" -ForegroundColor Red; exit 1 } else { Write-Host 'All checks passed' -ForegroundColor Green }
