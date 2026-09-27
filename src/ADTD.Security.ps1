# ADTD Modern - security and hybrid-identity data collection (read-only LDAP).
# Everything here is readable by an ordinary domain user with default permissions.

$script:UAC = @{
    Disabled = 0x2; PwdNotRequired = 0x20; Reversible = 0x80; ServerTrust = 0x2000; DontExpire = 0x10000
    TrustedForDelegation = 0x80000; NotDelegated = 0x100000; DesOnly = 0x200000; NoPreauth = 0x400000
    TrustedToAuth = 0x1000000; PartialSecrets = 0x4000000
}
$script:StaleDays = 90
$script:MaxEvidence = 500
$script:NonRoutableTlds = @('local', 'lan', 'corp', 'internal', 'intranet', 'home', 'localdomain', 'private', 'ad', 'priv', 'domain', 'test', 'invalid')

function ConvertFrom-AdtdFileTime {
    param($Value)
    if ($null -eq $Value -or "$Value" -eq '') { return $null }
    try { $n = [int64]"$Value" } catch { return $null }
    if ($n -le 0 -or $n -ge [int64]::MaxValue) { return $null }
    try { return [datetime]::FromFileTimeUtc($n) } catch { return $null }
}

function Get-AdtdAgeDays {
    param($Date, [datetime]$Now = (Get-Date).ToUniversalTime())
    if (-not $Date) { return $null }
    return [int][math]::Floor(($Now - $Date).TotalDays)
}

function ConvertTo-AdtdSidString {
    param($Value)
    if ($null -eq $Value) { return $null }
    if ($Value -is [byte[]]) { return (New-Object System.Security.Principal.SecurityIdentifier($Value, 0)).Value }
    return "$Value"
}

function Add-Capped {
    param([System.Collections.ArrayList]$List, $Item)
    if ($List.Count -lt $script:MaxEvidence) { [void]$List.Add($Item) }
}

function Get-AdtdDomainSecurity {
    <# Security data for one domain. #>
    param($Domain, [string]$ConfigNC, [bool]$IsForestRoot, [datetime]$Now = (Get-Date).ToUniversalTime())
    $dn = $Domain.DN; $srv = $Domain.Name
    $S = { param($base, $filter, $props, $scope = 'Subtree', $what) Search-Adtd @{ Server = $srv; SearchBase = $base; Filter = $filter; Properties = $props; Scope = $scope } $what }

    Write-AdtdLog "Security scan of $srv..."
    $head = @(& $S $dn '(objectClass=*)' @('objectSid', 'minPwdLength', 'pwdHistoryLength', 'maxPwdAge', 'lockoutThreshold', 'pwdProperties', 'ms-DS-MachineAccountQuota') 'Base' "password policy of $srv") | Select-Object -First 1
    $sid = ConvertTo-AdtdSidString (Get-A $head 'objectSid')
    $maxAge = Get-A $head 'maxPwdAge'
    $pwdProps = [int](Get-A $head 'pwdProperties')
    $fgpp = @(& $S "CN=Password Settings Container,CN=System,$dn" '(objectClass=msDS-PasswordSettings)' @('name') 'OneLevel' "fine-grained password policies of $srv")
    $maq = Get-A $head 'ms-DS-MachineAccountQuota'

    # Privileged groups by well-known SID / RID.
    $groupDefs = @(
        @{ Key = 'DomainAdmins'; Name = 'Domain Admins'; Sid = "$sid-512" }
        @{ Key = 'Administrators'; Name = 'Administrators'; Sid = 'S-1-5-32-544' }
        @{ Key = 'AccountOperators'; Name = 'Account Operators'; Sid = 'S-1-5-32-548' }
        @{ Key = 'ServerOperators'; Name = 'Server Operators'; Sid = 'S-1-5-32-549' }
        @{ Key = 'PrintOperators'; Name = 'Print Operators'; Sid = 'S-1-5-32-550' }
        @{ Key = 'BackupOperators'; Name = 'Backup Operators'; Sid = 'S-1-5-32-551' }
        @{ Key = 'ProtectedUsers'; Name = 'Protected Users'; Sid = "$sid-525" }
        @{ Key = 'PreWin2000'; Name = 'Pre-Windows 2000 Compatible Access'; Sid = 'S-1-5-32-554' }
    )
    if ($IsForestRoot) {
        $groupDefs += @{ Key = 'EnterpriseAdmins'; Name = 'Enterprise Admins'; Sid = "$sid-519" }
        $groupDefs += @{ Key = 'SchemaAdmins'; Name = 'Schema Admins'; Sid = "$sid-518" }
    }
    $groups = @()
    $privilegedDNs = @{}
    $protectedDNs = @{}
    foreach ($g in $groupDefs) {
        if (-not $sid -and $g.Sid -notlike 'S-1-5-32-*') { continue }
        $obj = @(& $S $dn "(objectSid=$($g.Sid))" @('member', 'name') 'Subtree' "group $($g.Name) in $srv") | Select-Object -First 1
        if (-not $obj) { continue }
        $gdn = Get-A $obj 'distinguishedName'
        $members = @(& $S $dn "(&(objectCategory=person)(objectClass=user)(memberOf:1.2.840.113556.1.4.1941:=$gdn))" @('sAMAccountName', 'userAccountControl') 'Subtree' "members of $($g.Name) in $srv")
        $enabled = @($members | Where-Object { -not ([int](Get-A $_ 'userAccountControl') -band $script:UAC.Disabled) })
        if ($g.Key -in 'DomainAdmins', 'Administrators', 'EnterpriseAdmins', 'SchemaAdmins', 'AccountOperators', 'ServerOperators', 'BackupOperators', 'PrintOperators') {
            foreach ($m in $enabled) { $privilegedDNs[("$(Get-A $m 'distinguishedName')").ToLower()] = $true }
        }
        if ($g.Key -eq 'ProtectedUsers') { foreach ($m in $members) { $protectedDNs[("$(Get-A $m 'distinguishedName')").ToLower()] = $true } }
        $direct = @(Get-AAll $obj 'member')
        $groups += [pscustomobject]@{
            Key = $g.Key; Name = $g.Name; Sid = $g.Sid
            EnabledMembers = $enabled.Count
            Members = @($enabled | ForEach-Object { Get-A $_ 'sAMAccountName' } | Select-Object -First 50)
            HasAnonymousOrEveryone = [bool](@($direct | Where-Object { $_ -match '^CN=(S-1-5-7|S-1-1-0),' }).Count)
            DirectMemberCount = $direct.Count
        }
    }
    $dnsAdmins = @(& $S $dn '(&(objectClass=group)(sAMAccountName=DnsAdmins))' @('member') 'Subtree' "DnsAdmins in $srv") | Select-Object -First 1
    if ($dnsAdmins) {
        $groups += [pscustomobject]@{ Key = 'DnsAdmins'; Name = 'DnsAdmins'; Sid = $null; EnabledMembers = @(Get-AAll $dnsAdmins 'member').Count; Members = @(Get-AAll $dnsAdmins 'member' | ForEach-Object { Get-RdnValue $_ 0 } | Select-Object -First 50); HasAnonymousOrEveryone = $false; DirectMemberCount = @(Get-AAll $dnsAdmins 'member').Count }
    }

    # ---- users (one pass) ----
    $users = @(& $S $dn '(&(objectCategory=person)(objectClass=user))' @('sAMAccountName', 'userAccountControl', 'lastLogonTimestamp', 'pwdLastSet', 'servicePrincipalName', 'adminCount', 'userPrincipalName', 'sIDHistory', 'whenCreated', 'msDS-SupportedEncryptionTypes', 'objectSid', 'description') 'Subtree' "users in $srv")
    $u = [ordered]@{
        Total = $users.Count; Enabled = 0
        Stale = New-Object System.Collections.ArrayList; PwdNeverExpires = New-Object System.Collections.ArrayList
        PwdNotRequired = New-Object System.Collections.ArrayList; Reversible = New-Object System.Collections.ArrayList
        DesOnly = New-Object System.Collections.ArrayList; NoPreauth = New-Object System.Collections.ArrayList
        ServiceAccountsWithSpn = New-Object System.Collections.ArrayList; SidHistory = New-Object System.Collections.ArrayList
        TrustedForDelegation = New-Object System.Collections.ArrayList; TrustedToAuth = New-Object System.Collections.ArrayList
        Rc4Only = New-Object System.Collections.ArrayList; NoUpn = 0; UpnSuffixes = @{}
        Privileged = New-Object System.Collections.ArrayList
    }
    $krbtgtAge = $null; $guestEnabled = $false; $builtinAdmin = $null
    $connect = @()
    foreach ($x in $users) {
        $name = Get-A $x 'sAMAccountName'
        $uac = [int](Get-A $x 'userAccountControl')
        $usid = ConvertTo-AdtdSidString (Get-A $x 'objectSid')
        $pwdSet = ConvertFrom-AdtdFileTime (Get-A $x 'pwdLastSet')
        if ($name -eq 'krbtgt') { $krbtgtAge = Get-AdtdAgeDays $pwdSet $Now; continue }
        if ($usid -and $usid -like '*-501') { $guestEnabled = -not ($uac -band $script:UAC.Disabled) }
        if ($name -like 'MSOL_*' -or $name -like 'ADSyncMSA*' -or $name -like 'Sync_*') {
            $srvName = if ("$(Get-A $x 'description')" -match 'running on computer (\S+?)[\s.,]') { $Matches[1] } else { $null }
            $connect += [pscustomobject]@{ Account = $name; Server = $srvName; Enabled = -not ($uac -band $script:UAC.Disabled) }
        }
        if ($uac -band $script:UAC.Disabled) { continue }
        $u.Enabled++
        $last = ConvertFrom-AdtdFileTime (Get-A $x 'lastLogonTimestamp')
        $created = $null; try { if (Get-A $x 'whenCreated') { $created = ([datetime](Get-A $x 'whenCreated')).ToUniversalTime() } } catch { }
        $stale = if ($last) { (Get-AdtdAgeDays $last $Now) -gt $script:StaleDays } else { -not $created -or (Get-AdtdAgeDays $created $Now) -gt $script:StaleDays }
        $spns = @(Get-AAll $x 'servicePrincipalName')
        $enc = Get-A $x 'msDS-SupportedEncryptionTypes'
        $isPriv = $privilegedDNs.ContainsKey(("$(Get-A $x 'distinguishedName')").ToLower())
        if ($stale) { Add-Capped $u.Stale $name }
        if ($uac -band $script:UAC.DontExpire) { Add-Capped $u.PwdNeverExpires $name }
        if ($uac -band $script:UAC.PwdNotRequired) { Add-Capped $u.PwdNotRequired $name }
        if ($uac -band $script:UAC.Reversible) { Add-Capped $u.Reversible $name }
        if ($uac -band $script:UAC.DesOnly) { Add-Capped $u.DesOnly $name }
        if ($uac -band $script:UAC.NoPreauth) { Add-Capped $u.NoPreauth $name }
        if ($uac -band $script:UAC.TrustedForDelegation) { Add-Capped $u.TrustedForDelegation $name }
        if ($uac -band $script:UAC.TrustedToAuth) { Add-Capped $u.TrustedToAuth $name }
        if ($null -ne $enc -and "$enc" -ne '' -and ([int]$enc -band 0x18) -eq 0 -and ([int]$enc -band 0x7)) { Add-Capped $u.Rc4Only $name }
        if (@(Get-AAll $x 'sIDHistory').Count) { Add-Capped $u.SidHistory $name }
        if ($spns.Count -and -not $isPriv) { Add-Capped $u.ServiceAccountsWithSpn $name }
        $upn = Get-A $x 'userPrincipalName'
        if (-not $upn) { $u.NoUpn++ } else {
            $suffix = ($upn -split '@')[-1].ToLower()
            if ($u.UpnSuffixes.ContainsKey($suffix)) { $u.UpnSuffixes[$suffix]++ } else { $u.UpnSuffixes[$suffix] = 1 }
        }
        if ($isPriv) {
            [void]$u.Privileged.Add([pscustomobject]@{
                    Name = $name
                    HasSpn = [bool]$spns.Count
                    PwdNeverExpires = [bool]($uac -band $script:UAC.DontExpire)
                    PwdAgeDays = Get-AdtdAgeDays $pwdSet $Now
                    Stale = [bool]$stale
                    SensitiveNotDelegated = [bool]($uac -band $script:UAC.NotDelegated)
                    InProtectedUsers = $protectedDNs.ContainsKey(("$(Get-A $x 'distinguishedName')").ToLower())
                    BuiltinAdministrator = [bool]($usid -and $usid -like '*-500')
                })
        }
    }

    # ---- computers (one pass) ----
    $comps = @(& $S $dn '(objectCategory=computer)' @('name', 'userAccountControl', 'lastLogonTimestamp', 'pwdLastSet', 'operatingSystem', 'operatingSystemVersion', 'primaryGroupID', 'msLAPS-PasswordExpirationTime', 'ms-Mcs-AdmPwdExpirationTime', 'msDS-SupportedEncryptionTypes', 'whenCreated') 'Subtree' "computers in $srv")
    $c = [ordered]@{
        Total = $comps.Count; Enabled = 0; Workstations = 0; Servers = 0
        Stale = New-Object System.Collections.ArrayList; TrustedForDelegation = New-Object System.Collections.ArrayList
        TrustedToAuth = New-Object System.Collections.ArrayList; Unsupported = New-Object System.Collections.ArrayList
        EndingSoon = New-Object System.Collections.ArrayList; Rc4Only = New-Object System.Collections.ArrayList
        OsCounts = @{}; LapsEligible = 0; WindowsLapsCovered = 0; LegacyLapsCovered = 0; NoLaps = New-Object System.Collections.ArrayList
    }
    $ssoAge = $null; $ssoRc4 = $false; $entraKerberos = $false
    foreach ($x in $comps) {
        $name = Get-A $x 'name'
        $uac = [int](Get-A $x 'userAccountControl')
        $pg = [int](Get-A $x 'primaryGroupID')
        $isDc = $pg -in 516, 521
        if ($name -eq 'AZUREADSSOACC') {
            $ssoAge = Get-AdtdAgeDays (ConvertFrom-AdtdFileTime (Get-A $x 'pwdLastSet')) $Now
            $enc = Get-A $x 'msDS-SupportedEncryptionTypes'
            $ssoRc4 = ($null -eq $enc -or "$enc" -eq '' -or (([int]$enc -band 0x18) -eq 0))
            continue
        }
        if ($name -eq 'AzureADKerberos') { $entraKerberos = $true; continue }
        if ($uac -band $script:UAC.Disabled) { continue }
        $c.Enabled++
        $os = Get-A $x 'operatingSystem'
        $key = if ($os) { $os } else { '(not set)' }
        if ($c.OsCounts.ContainsKey($key)) { $c.OsCounts[$key]++ } else { $c.OsCounts[$key] = 1 }
        $last = ConvertFrom-AdtdFileTime (Get-A $x 'lastLogonTimestamp')
        $created = $null; try { if (Get-A $x 'whenCreated') { $created = ([datetime](Get-A $x 'whenCreated')).ToUniversalTime() } } catch { }
        $stale = if ($last) { (Get-AdtdAgeDays $last $Now) -gt $script:StaleDays } else { -not $created -or (Get-AdtdAgeDays $created $Now) -gt $script:StaleDays }
        if ($stale) { Add-Capped $c.Stale $name }
        if (-not $isDc -and ($uac -band $script:UAC.TrustedForDelegation)) { Add-Capped $c.TrustedForDelegation $name }
        if (-not $isDc -and ($uac -band $script:UAC.TrustedToAuth)) { Add-Capped $c.TrustedToAuth $name }   # RODC accounts have this flag by design
        $enc = Get-A $x 'msDS-SupportedEncryptionTypes'
        if ($null -ne $enc -and "$enc" -ne '' -and ([int]$enc -band 0x18) -eq 0 -and ([int]$enc -band 0x7)) { Add-Capped $c.Rc4Only $name }
        $info = Get-WindowsOsInfo -OperatingSystem $os -OperatingSystemVersion (Get-A $x 'operatingSystemVersion') -Today $Now
        if ($info -and -not $isDc) {
            if ($os -match 'Server') { $c.Servers++ } else { $c.Workstations++ }
            if ($info.SupportState -eq 'Unsupported') { Add-Capped $c.Unsupported "$name ($($info.Name))" }
            elseif ($info.SupportState -eq 'EndingSoon') { Add-Capped $c.EndingSoon "$name ($($info.Name), ends $($info.EndOfSupport))" }
            $c.LapsEligible++
            $hasWin = [bool](Get-A $x 'msLAPS-PasswordExpirationTime')
            $hasLegacy = [bool](Get-A $x 'ms-Mcs-AdmPwdExpirationTime')
            if ($hasWin) { $c.WindowsLapsCovered++ } elseif ($hasLegacy) { $c.LegacyLapsCovered++ } else { Add-Capped $c.NoLaps $name }
        }
    }

    $gmsa = @(& $S $dn '(objectClass=msDS-GroupManagedServiceAccount)' @('sAMAccountName') 'Subtree' "gMSAs in $srv")
    $cloudSync = @($gmsa | Where-Object { "$(Get-A $_ 'sAMAccountName')" -like 'pGMSA_*' } | ForEach-Object { Get-A $_ 'sAMAccountName' })
    $adfs = @(& $S "CN=ADFS,CN=Microsoft,CN=Program Data,$dn" '(objectClass=*)' @('name') 'Base' "AD FS container in $srv")
    $pwdProt = @(& $S $dn '(&(objectClass=serviceConnectionPoint)(name=AzureADPasswordProtectionDCAgent))' @('name') 'Subtree' "Entra Password Protection agents in $srv")

    $toArr = { param($h) @($h.Keys | Sort-Object | ForEach-Object { [pscustomobject]@{ Name = $_; Count = $h[$_] } }) }
    [pscustomobject]@{
        Domain = $srv
        PasswordPolicy = [pscustomobject]@{
            MinLength = [int](Get-A $head 'minPwdLength')
            History = [int](Get-A $head 'pwdHistoryLength')
            MaxAgeDays = if ($maxAge -and [int64]"$maxAge" -ne [int64]::MinValue) { [int][math]::Abs([int64]"$maxAge" / 864000000000) } else { 0 }
            LockoutThreshold = [int](Get-A $head 'lockoutThreshold')
            Complexity = [bool]($pwdProps -band 1)
            ReversibleEncryption = [bool]($pwdProps -band 16)
            FineGrainedPolicies = $fgpp.Count
        }
        MachineAccountQuota = if ($null -ne $maq -and "$maq" -ne '') { [int]$maq } else { 10 }
        KrbtgtPasswordAgeDays = $krbtgtAge
        GuestEnabled = $guestEnabled
        Groups = @($groups)
        Users = [pscustomobject]@{
            Total = $u.Total; Enabled = $u.Enabled
            Stale = @($u.Stale); PwdNeverExpires = @($u.PwdNeverExpires); PwdNotRequired = @($u.PwdNotRequired)
            Reversible = @($u.Reversible); DesOnly = @($u.DesOnly); NoPreauth = @($u.NoPreauth)
            ServiceAccountsWithSpn = @($u.ServiceAccountsWithSpn); SidHistory = @($u.SidHistory)
            TrustedForDelegation = @($u.TrustedForDelegation); TrustedToAuth = @($u.TrustedToAuth); Rc4Only = @($u.Rc4Only)
            NoUpn = $u.NoUpn; UpnSuffixes = & $toArr $u.UpnSuffixes
            Privileged = @($u.Privileged)
        }
        Computers = [pscustomobject]@{
            Total = $c.Total; Enabled = $c.Enabled; Workstations = $c.Workstations; Servers = $c.Servers
            Stale = @($c.Stale); TrustedForDelegation = @($c.TrustedForDelegation); TrustedToAuth = @($c.TrustedToAuth)
            Unsupported = @($c.Unsupported); EndingSoon = @($c.EndingSoon); Rc4Only = @($c.Rc4Only)
            OsCounts = & $toArr $c.OsCounts
            LapsEligible = $c.LapsEligible; WindowsLapsCovered = $c.WindowsLapsCovered; LegacyLapsCovered = $c.LegacyLapsCovered; NoLaps = @($c.NoLaps)
        }
        GmsaCount = $gmsa.Count
        Hybrid = [pscustomobject]@{
            SeamlessSsoPasswordAgeDays = $ssoAge
            SeamlessSsoRc4 = if ($null -ne $ssoAge) { $ssoRc4 } else { $false }
            EntraKerberos = $entraKerberos
            ConnectSyncAccounts = @($connect)
            CloudSyncAgents = @($cloudSync)
            AdfsDkmContainer = [bool]$adfs.Count
            PasswordProtectionAgents = $pwdProt.Count
        }
    }
}

function Get-AdtdForestSecurity {
    <# Forest-wide items: UPN suffixes, device registration SCP, AD CS, LAPS schema, Exchange hybrid. #>
    param([string]$ConfigNC, [string]$SchemaNC)
    Write-AdtdLog 'Security scan of forest-wide settings (UPN suffixes, Entra device registration, AD CS, LAPS schema)...'
    $parts = @(Search-Adtd @{ SearchBase = "CN=Partitions,$ConfigNC"; Scope = 'Base'; Properties = @('uPNSuffixes') } 'UPN suffixes') | Select-Object -First 1
    $scp = @(Search-Adtd @{ SearchBase = "CN=62a0ff2e-97b9-4513-943f-0d221bd30080,CN=Device Registration Configuration,CN=Services,$ConfigNC"; Scope = 'Base'; Properties = @('keywords') } 'Entra device registration service connection point') | Select-Object -First 1
    $tenantName = $null; $tenantId = $null
    foreach ($k in @(Get-AAll $scp 'keywords')) {
        if ($k -match '^azureADName:(.+)$') { $tenantName = $Matches[1] }
        if ($k -match '^azureADId:(.+)$') { $tenantId = $Matches[1] }
    }
    $winLaps = @(Search-Adtd @{ SearchBase = "CN=ms-LAPS-Password,$SchemaNC"; Scope = 'Base'; Properties = @('name') } 'Windows LAPS schema').Count -gt 0
    $legacyLaps = @(Search-Adtd @{ SearchBase = "CN=ms-Mcs-AdmPwd,$SchemaNC"; Scope = 'Base'; Properties = @('name') } 'legacy LAPS schema').Count -gt 0

    $pks = "CN=Public Key Services,CN=Services,$ConfigNC"
    $cas = @(Search-Adtd @{ SearchBase = "CN=Enrollment Services,$pks"; Filter = '(objectClass=pKIEnrollmentService)'; Scope = 'OneLevel'; Properties = @('name', 'dNSHostName', 'certificateTemplates') } 'certificate authorities')
    $published = @{}
    foreach ($ca in $cas) { foreach ($t in @(Get-AAll $ca 'certificateTemplates')) { $published["$t".ToLower()] = $true } }
    $templates = @(Search-Adtd @{ SearchBase = "CN=Certificate Templates,$pks"; Filter = '(objectClass=pKICertificateTemplate)'; Scope = 'OneLevel'; Properties = @('name', 'displayName', 'msPKI-Certificate-Name-Flag', 'msPKI-Enrollment-Flag', 'msPKI-RA-Signature', 'pKIExtendedKeyUsage') } 'certificate templates')
    $authEkus = @('1.3.6.1.5.5.7.3.2', '1.3.6.1.4.1.311.20.2.2', '1.3.6.1.5.2.3.4', '2.5.29.37.0')
    $risky = @()
    foreach ($t in $templates) {
        $n = Get-A $t 'name'
        if (-not $published.ContainsKey("$n".ToLower())) { continue }
        $supplies = ([int64](Get-A $t 'msPKI-Certificate-Name-Flag')) -band 1
        $approval = ([int](Get-A $t 'msPKI-Enrollment-Flag')) -band 2
        $sigs = [int](Get-A $t 'msPKI-RA-Signature')
        $ekus = @(Get-AAll $t 'pKIExtendedKeyUsage')
        $auth = (-not $ekus.Count) -or @($ekus | Where-Object { $authEkus -contains $_ }).Count
        if ($supplies -and -not $approval -and $sigs -eq 0 -and $auth) {
            $risky += [pscustomobject]@{ Name = $n; DisplayName = Get-A $t 'displayName'; Reason = 'Enrollee supplies subject, usable for authentication, no manager approval' }
        }
    }
    [pscustomobject]@{
        UpnSuffixes = @(Get-AAll $parts 'uPNSuffixes')
        DeviceRegistrationScp = [bool]$scp
        TenantName = $tenantName
        TenantId = $tenantId
        WindowsLapsSchema = $winLaps
        LegacyLapsSchema = $legacyLaps
        CertificateAuthorities = @($cas | ForEach-Object { [pscustomobject]@{ Name = Get-A $_ 'name'; HostName = Get-A $_ 'dNSHostName' } })
        PublishedTemplates = $published.Count
        RiskyTemplates = @($risky)
    }
}

function Test-AdtdNonRoutableSuffix {
    param([string]$Suffix)
    if (-not $Suffix) { return $true }
    if ($Suffix -notmatch '\.') { return $true }
    return $script:NonRoutableTlds -contains ($Suffix.Split('.')[-1].ToLower())
}
