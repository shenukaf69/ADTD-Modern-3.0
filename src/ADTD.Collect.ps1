# ADTD Modern - reads the Active Directory topology over LDAP.
# Uses System.DirectoryServices only, so it works on any domain-joined Windows machine
# (Windows PowerShell 5.1 or PowerShell 7) without RSAT or the ActiveDirectory module.
# Every read goes through Invoke-AdtdLdapSearch / Get-AdtdRootDse so tests can replace them.

$script:AdtdServer = $null
$script:AdtdCredential = $null
$script:AdtdLogSink = $null

function Write-AdtdLog {
    param([string]$Message, [ValidateSet('Info', 'Warn', 'Error')][string]$Level = 'Info')
    $line = '{0:HH:mm:ss} {1,-5} {2}' -f (Get-Date), $Level.ToUpper(), $Message
    if ($script:AdtdLogSink) { & $script:AdtdLogSink $line }
    switch ($Level) {
        'Warn'  { Write-Warning $Message }
        'Error' { Write-Warning $Message }
        default { Write-Verbose $line }
    }
    $script:AdtdLogLines.Add($line) | Out-Null
}
$script:AdtdLogLines = New-Object System.Collections.ArrayList

function New-AdtdDirectoryEntry {
    param([string]$Path)
    if ($null -ne $IsWindows -and -not $IsWindows) {
        throw 'Reading Active Directory needs Windows. On other systems, re-draw an inventory collected on Windows with -InputFile.'
    }
    if ($script:AdtdCredential) {
        $net = $script:AdtdCredential.GetNetworkCredential()
        $user = if ($net.Domain) { "$($net.Domain)\$($net.UserName)" } else { $net.UserName }
        return New-Object System.DirectoryServices.DirectoryEntry($Path, $user, $net.Password)
    }
    return New-Object System.DirectoryServices.DirectoryEntry($Path)
}

function Get-AdtdRootDse {
    param([string]$Server = $script:AdtdServer)
    $path = if ($Server) { "LDAP://$Server/RootDSE" } else { 'LDAP://RootDSE' }
    $e = New-AdtdDirectoryEntry $path
    $h = @{}
    foreach ($n in 'defaultNamingContext', 'configurationNamingContext', 'schemaNamingContext',
        'rootDomainNamingContext', 'dnsHostName', 'forestFunctionality', 'domainFunctionality') {
        $v = $e.Properties[$n]
        if ($v -and $v.Count -gt 0) { $h[$n.ToLower()] = $v[0] }
    }
    $e.Dispose()
    if (-not $h['configurationnamingcontext']) { throw "Could not read RootDSE from $(if ($Server) { $Server } else { 'the local domain' })." }
    return $h
}

function Invoke-AdtdLdapSearch {
    <# Returns one hashtable per object: lower-case attribute name -> value (array when multi-valued). #>
    param(
        [Parameter(Mandatory)][string]$SearchBase,
        [string]$Filter = '(objectClass=*)',
        [string[]]$Properties = @('distinguishedName'),
        [ValidateSet('Base', 'OneLevel', 'Subtree')][string]$Scope = 'Subtree',
        [string]$Server = $script:AdtdServer,
        [switch]$GlobalCatalog
    )
    $proto = if ($GlobalCatalog) { 'GC' } else { 'LDAP' }
    $path = if ($Server) { "${proto}://$Server/$SearchBase" } else { "${proto}://$SearchBase" }
    $entry = New-AdtdDirectoryEntry $path
    $props = @($Properties) + 'distinguishedName' | Select-Object -Unique
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($entry, $Filter, [string[]]$props, [System.DirectoryServices.SearchScope]$Scope)
    $searcher.PageSize = 1000
    $results = $null
    try {
        $results = $searcher.FindAll()
        foreach ($r in $results) {
            $h = @{}
            foreach ($k in $r.Properties.PropertyNames) {
                $vals = @($r.Properties[$k])
                $h[$k.ToLower()] = if ($vals.Count -eq 1) { $vals[0] } else { , $vals }
            }
            $h
        }
    } finally {
        # Cast to IDisposable: PowerShell's DirectoryEntry adapter binds the object when a member is looked up,
        # which turns "no such object" into "exception while retrieving member Dispose" and hides the real error.
        if ($results) { ([System.IDisposable]$results).Dispose() }
        ([System.IDisposable]$searcher).Dispose()
        ([System.IDisposable]$entry).Dispose()
    }
}

function Search-Adtd {
    <# Wrapper that logs and swallows access errors so one unreachable domain doesn't stop the run. #>
    param([hashtable]$Params, [string]$What)
    try { return @(Invoke-AdtdLdapSearch @Params) }
    catch {
        # 0x80072030 "There is no such object on the server": the item isn't deployed (Exchange, AD FS, LAPS...), not a failure.
        $ex = $_.Exception; while ($ex.InnerException) { $ex = $ex.InnerException }
        if ($ex.HResult -eq -2147016656 -or $ex.Message -match 'no such object on the server') {
            Write-AdtdLog "Not found: $What ($($Params.SearchBase))."
        } else {
            Write-AdtdLog "Could not read $What ($($Params.SearchBase)): $($ex.Message)" -Level Warn
        }
        return @()
    }
}

function Get-A {
    <# First value of an attribute, or $null. #>
    param($Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $v = $Object[$Name.ToLower()]
    if ($null -eq $v) { return $null }
    if ($v -is [array]) { if ($v.Count) { return $v[0] } else { return $null } }
    return $v
}

function Get-AAll {
    param($Object, [string]$Name)
    if ($null -eq $Object) { return @() }
    $v = $Object[$Name.ToLower()]
    if ($null -eq $v) { return @() }
    return @($v)
}

function Split-DistinguishedName {
    param([string]$DN)
    if (-not $DN) { return @() }
    return @([regex]::Split($DN, '(?<!\\),') | ForEach-Object { $_.Trim() })
}

function Get-RdnValue {
    <# Value of the Nth RDN of a DN (0 = leftmost), unescaped. #>
    param([string]$DN, [int]$Index = 0)
    $parts = Split-DistinguishedName $DN
    if ($parts.Count -le $Index) { return $null }
    return ($parts[$Index] -replace '^[^=]+=', '') -replace '\\(.)', '$1'
}

function Get-ParentDN {
    param([string]$DN, [int]$Levels = 1)
    $parts = Split-DistinguishedName $DN
    if ($parts.Count -le $Levels) { return $null }
    return ($parts[$Levels..($parts.Count - 1)] -join ',')
}

function Get-DomainDNFromDN {
    param([string]$DN)
    $dcs = @(Split-DistinguishedName $DN | Where-Object { $_ -match '^DC=' })
    return ($dcs -join ',')
}

function ConvertTo-DnsName {
    param([string]$DomainDN)
    return ((Split-DistinguishedName $DomainDN | Where-Object { $_ -match '^DC=' } | ForEach-Object { $_.Substring(3) }) -join '.')
}

function Get-ServerNameFromNtdsDN {
    <# "CN=NTDS Settings,CN=DC01,CN=Servers,CN=Site,..." -> DC01 #>
    param([string]$DN)
    $parts = Split-DistinguishedName $DN
    if ($parts.Count -ge 2 -and $parts[0] -match '^CN=NTDS Settings$') { return Get-RdnValue $DN 1 }
    return Get-RdnValue $DN 0
}

function Get-SiteNameFromServerDN {
    <# CN=DC01,CN=Servers,CN=SiteName,CN=Sites,... (any depth) -> SiteName #>
    param([string]$DN)
    $parts = Split-DistinguishedName $DN
    for ($i = 0; $i -lt $parts.Count - 1; $i++) {
        if ($parts[$i] -match '^CN=Servers$' -and $parts[$i + 2] -match '^CN=Sites$') {
            return ($parts[$i + 1] -replace '^CN=', '') -replace '\\(.)', '$1'
        }
    }
    return $null
}

function ConvertFrom-GpLink {
    param([string]$GpLink)
    $out = @()
    if (-not $GpLink) { return $out }
    foreach ($m in [regex]::Matches($GpLink, '\[LDAP://([^;\]]+);(\d+)\]', 'IgnoreCase')) {
        $flags = [int]$m.Groups[2].Value
        $out += [pscustomobject]@{
            GpoDN    = $m.Groups[1].Value
            Guid     = if ($m.Groups[1].Value -match '\{[0-9a-fA-F-]+\}') { $Matches[0].ToUpper() } else { $null }
            Disabled = [bool]($flags -band 1)
            Enforced = [bool]($flags -band 2)
        }
    }
    # gPLink lists links lowest precedence first; show highest precedence first.
    [array]::Reverse($out)
    return $out
}

function Get-TrustDescription {
    param([int]$Direction, [int]$Type, [int]$Attributes)
    $dir = switch ($Direction) { 0 { 'Disabled' } 1 { 'Inbound' } 2 { 'Outbound' } 3 { 'Two-way' } default { "Direction $Direction" } }
    $kind = 'External'
    if ($Attributes -band 0x20) { $kind = 'Within forest' }
    elseif ($Attributes -band 0x8) { $kind = 'Forest' }
    elseif ($Type -eq 3) { $kind = 'Realm (Kerberos)' }
    elseif ($Type -eq 1) { $kind = 'Downlevel (NT4)' }
    $flags = @()
    if ($Attributes -band 0x1) { $flags += 'Non-transitive' }
    if ($Attributes -band 0x4) { $flags += 'SID filtering' }
    if ($Attributes -band 0x10) { $flags += 'Selective authentication' }
    if ($Attributes -band 0x40) { $flags += 'Treat as external' }
    if ($Attributes -band 0x400) { $flags += 'PAM trust' }
    if ($Attributes -band 0x800) { $flags += 'No TGT delegation' }
    if ($Attributes -band 0x200) { $flags += 'TGT delegation disabled' }
    [pscustomobject]@{ Direction = $dir; Kind = $kind; Flags = $flags }
}

function Get-AdtdInventory {
    <#
    .SYNOPSIS
    Reads the forest topology and returns one object that the renderers turn into drawings and reports.
    #>
    [CmdletBinding()]
    param(
        [string]$Server,
        [pscredential]$Credential,
        [switch]$IncludeOUs,
        [switch]$IncludeDfsr,
        [switch]$IncludeExchange,
        [switch]$IncludeAppPartitions,
        [switch]$SkipSecurityScan,
        [int]$MaxOUs = 400
    )
    $script:AdtdServer = if ($Server) { $Server } else { $null }
    $script:AdtdCredential = $Credential

    Write-AdtdLog 'Reading RootDSE...'
    $root = Get-AdtdRootDse
    $configNC = $root['configurationnamingcontext']
    $schemaNC = $root['schemanamingcontext']
    $forestDN = $root['rootdomainnamingcontext']

    $inv = [ordered]@{
        Tool           = 'ADTD Modern'
        ToolVersion    = $script:AdtdVersion
        CollectedAt    = (Get-Date).ToString('yyyy-MM-dd HH:mm')
        CollectedFrom  = $root['dnshostname']
        Forest         = $null
        Domains        = @()
        Sites          = @()
        Subnets        = @()
        SiteLinks      = @()
        SiteLinkBridges = @()
        DomainControllers = @()
        Connections    = @()
        Trusts         = @()
        AppPartitions  = @()
        OUs            = @()
        Dfsr           = @()
        Exchange       = $null
        Security       = $null
        Findings       = @()
        Plan           = $null
    }

    # ---------- Forest ----------
    Write-AdtdLog 'Reading forest and schema...'
    $partitions = @(Search-Adtd @{ SearchBase = "CN=Partitions,$configNC"; Scope = 'Base'; Properties = @('msDS-Behavior-Version', 'fsmoRoleOwner', 'msDS-EnabledFeature') } 'forest partitions')
    $schemaHead = @(Search-Adtd @{ SearchBase = $schemaNC; Scope = 'Base'; Properties = @('objectVersion', 'fsmoRoleOwner') } 'schema version')
    $exSchema = @(Search-Adtd @{ SearchBase = "CN=ms-Exch-Schema-Version-Pt,$schemaNC"; Scope = 'Base'; Properties = @('rangeUpper') } 'Exchange schema')
    $dirService = @(Search-Adtd @{ SearchBase = "CN=Directory Service,CN=Windows NT,CN=Services,$configNC"; Scope = 'Base'; Properties = @('tombstoneLifetime', 'msDS-DeletedObjectLifetime') } 'tombstone lifetime')
    $optional = @(Search-Adtd @{ SearchBase = "CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,$configNC"; Filter = '(objectClass=msDS-OptionalFeature)'; Scope = 'OneLevel'; Properties = @('name') } 'optional features')

    $p = $partitions | Select-Object -First 1
    $enabled = @(Get-AAll $p 'msDS-EnabledFeature' | ForEach-Object { "$_".ToLower() })
    $features = foreach ($f in $optional) {
        [pscustomobject]@{ Name = Get-A $f 'name'; Enabled = $enabled -contains ("$(Get-A $f 'distinguishedName')".ToLower()) }
    }
    $ffl = Get-A $p 'msDS-Behavior-Version'
    $schemaVer = Get-A ($schemaHead | Select-Object -First 1) 'objectVersion'
    $exRange = Get-A ($exSchema | Select-Object -First 1) 'rangeUpper'
    $tsl = Get-A ($dirService | Select-Object -First 1) 'tombstoneLifetime'
    $inv.Forest = [pscustomobject]@{
        Name                  = ConvertTo-DnsName $forestDN
        DN                    = $forestDN
        FunctionalLevel       = if ($null -ne $ffl) { [int]$ffl } else { $null }
        FunctionalLevelName   = Get-FunctionalLevelName $ffl
        SchemaVersion         = $schemaVer
        SchemaVersionName     = Get-SchemaVersionName $schemaVer
        ExchangeSchemaVersion = $exRange
        ExchangeSchemaName    = Get-ExchangeSchemaName $exRange
        SchemaMaster          = Get-ServerNameFromNtdsDN (Get-A ($schemaHead | Select-Object -First 1) 'fsmoRoleOwner')
        DomainNamingMaster    = Get-ServerNameFromNtdsDN (Get-A $p 'fsmoRoleOwner')
        TombstoneLifetimeDays = if ($tsl) { [int]$tsl } else { 60 }
        OptionalFeatures      = @($features)
    }

    # ---------- Sites, subnets, links ----------
    Write-AdtdLog 'Reading sites, subnets and site links...'
    $sitesDN = "CN=Sites,$configNC"
    $sites = @(Search-Adtd @{ SearchBase = $sitesDN; Filter = '(objectClass=site)'; Scope = 'OneLevel'; Properties = @('name', 'description', 'location') } 'sites')
    $siteSettings = @(Search-Adtd @{ SearchBase = $sitesDN; Filter = '(objectClass=nTDSSiteSettings)'; Properties = @('options', 'interSiteTopologyGenerator') } 'site settings')
    $settingsBySite = @{}
    foreach ($s in $siteSettings) { $settingsBySite[(Get-RdnValue (Get-A $s 'distinguishedName') 1)] = $s }
    $inv.Sites = @(foreach ($s in $sites | Sort-Object { Get-A $_ 'name' }) {
        $n = Get-A $s 'name'
        $set = $settingsBySite[$n]
        $opt = if ($set) { [int](Get-A $set 'options') } else { 0 }
        [pscustomobject]@{
            Name        = $n
            Description = Get-A $s 'description'
            Location    = Get-A $s 'location'
            ISTG        = if ($set) { Get-ServerNameFromNtdsDN (Get-A $set 'interSiteTopologyGenerator') } else { $null }
            UniversalGroupCaching = [bool]($opt -band 0x20)
            Options     = $opt
        }
    })

    $subnets = @(Search-Adtd @{ SearchBase = "CN=Subnets,$sitesDN"; Filter = '(objectClass=subnet)'; Scope = 'OneLevel'; Properties = @('name', 'siteObject', 'location', 'description') } 'subnets')
    $inv.Subnets = @(foreach ($s in $subnets) {
        $siteDN = Get-A $s 'siteObject'
        [pscustomobject]@{
            Name        = Get-A $s 'name'
            Site        = if ($siteDN) { Get-RdnValue $siteDN 0 } else { $null }
            Location    = Get-A $s 'location'
            Description = Get-A $s 'description'
        }
    })

    $links = @(Search-Adtd @{ SearchBase = "CN=Inter-Site Transports,$sitesDN"; Filter = '(objectClass=siteLink)'; Properties = @('name', 'siteList', 'cost', 'replInterval', 'options') } 'site links')
    $inv.SiteLinks = @(foreach ($l in $links) {
        $opt = [int](Get-A $l 'options')
        [pscustomobject]@{
            Name               = Get-A $l 'name'
            Transport          = Get-RdnValue (Get-A $l 'distinguishedName') 1
            Sites              = @(Get-AAll $l 'siteList' | ForEach-Object { Get-RdnValue $_ 0 })
            Cost               = [int](Get-A $l 'cost')
            ReplIntervalMin    = [int](Get-A $l 'replInterval')
            ChangeNotification = [bool]($opt -band 1)
            TwoWaySync         = [bool]($opt -band 2)
            CompressionDisabled = [bool]($opt -band 4)
        }
    })
    $bridges = @(Search-Adtd @{ SearchBase = "CN=Inter-Site Transports,$sitesDN"; Filter = '(objectClass=siteLinkBridge)'; Properties = @('name', 'siteLinkList') } 'site link bridges')
    $inv.SiteLinkBridges = @(foreach ($b in $bridges) {
        [pscustomobject]@{ Name = Get-A $b 'name'; SiteLinks = @(Get-AAll $b 'siteLinkList' | ForEach-Object { Get-RdnValue $_ 0 }) }
    })

    # ---------- Domains ----------
    Write-AdtdLog 'Reading domains...'
    $crossRefs = @(Search-Adtd @{ SearchBase = "CN=Partitions,$configNC"; Filter = '(objectClass=crossRef)'; Scope = 'OneLevel'; Properties = @('nCName', 'dnsRoot', 'nETBIOSName', 'systemFlags', 'trustParent', 'msDS-NC-Replica-Locations', 'msDS-NC-RO-Replica-Locations') } 'partitions')
    $domainRefs = @($crossRefs | Where-Object { ([int](Get-A $_ 'systemFlags') -band 3) -eq 3 })
    $appRefs = @($crossRefs | Where-Object {
            $f = [int](Get-A $_ 'systemFlags'); $nc = "$(Get-A $_ 'nCName')"
            ($f -band 1) -and -not ($f -band 2) -and $nc -ne $configNC -and $nc -ne $schemaNC
        })

    $domains = @()
    foreach ($ref in $domainRefs) {
        $dn = Get-A $ref 'nCName'
        $dns = Get-A $ref 'dnsRoot'
        $parentDN = if (Get-A $ref 'trustParent') { Get-A (@(Search-Adtd @{ SearchBase = (Get-A $ref 'trustParent'); Scope = 'Base'; Properties = @('nCName') } 'parent domain') | Select-Object -First 1) 'nCName' } else { $null }
        $head = @(Search-Adtd @{ Server = $dns; SearchBase = $dn; Scope = 'Base'; Properties = @('msDS-Behavior-Version', 'fsmoRoleOwner', 'gPLink', 'gPOptions') } "domain $dns")
        $rid = @(Search-Adtd @{ Server = $dns; SearchBase = "CN=RID Manager`$,CN=System,$dn"; Scope = 'Base'; Properties = @('fsmoRoleOwner') } "RID master for $dns")
        $infra = @(Search-Adtd @{ Server = $dns; SearchBase = "CN=Infrastructure,$dn"; Scope = 'Base'; Properties = @('fsmoRoleOwner') } "infrastructure master for $dns")
        $h = $head | Select-Object -First 1
        $dfl = Get-A $h 'msDS-Behavior-Version'
        $domains += [pscustomobject]@{
            Name                = $dns
            NetBIOS             = Get-A $ref 'nETBIOSName'
            DN                  = $dn
            ParentDomain        = if ($parentDN) { ConvertTo-DnsName $parentDN } else { $null }
            IsForestRoot        = ($dn -eq $forestDN)
            FunctionalLevel     = if ($null -ne $dfl) { [int]$dfl } else { $null }
            FunctionalLevelName = Get-FunctionalLevelName $dfl
            PdcEmulator         = Get-ServerNameFromNtdsDN (Get-A $h 'fsmoRoleOwner')
            RidMaster           = Get-ServerNameFromNtdsDN (Get-A ($rid | Select-Object -First 1) 'fsmoRoleOwner')
            InfrastructureMaster = Get-ServerNameFromNtdsDN (Get-A ($infra | Select-Object -First 1) 'fsmoRoleOwner')
            SysvolReplication   = 'Unknown'
            Reachable           = [bool]$h
            GpLink              = Get-A $h 'gPLink'
            GpOptions           = [int](Get-A $h 'gPOptions')
        }
    }
    $inv.Domains = @($domains | Sort-Object @{ E = { -not $_.IsForestRoot } }, Name)

    # ---------- Domain controllers ----------
    Write-AdtdLog 'Reading domain controllers...'
    $servers = @(Search-Adtd @{ SearchBase = $sitesDN; Filter = '(objectClass=server)'; Properties = @('name', 'dNSHostName', 'serverReference') } 'servers')
    $ntds = @(Search-Adtd @{ SearchBase = $sitesDN; Filter = '(|(objectCategory=nTDSDSA)(objectCategory=nTDSDSARO))'; Properties = @('options', 'objectClass', 'msDS-Behavior-Version', 'msDS-HasDomainNCs', 'hasMasterNCs', 'msDS-hasMasterNCs', 'msDS-hasFullReplicaNCs') } 'NTDS settings')
    $ntdsByServerDN = @{}
    foreach ($n in $ntds) { $ntdsByServerDN[(Get-ParentDN (Get-A $n 'distinguishedName')).ToLower()] = $n }

    $computers = @{}
    $dcComputers = @(Search-Adtd @{ SearchBase = $forestDN; GlobalCatalog = $true; Filter = '(&(objectCategory=computer)(|(primaryGroupID=516)(primaryGroupID=521)))'; Properties = @('dNSHostName', 'name', 'operatingSystem', 'operatingSystemVersion') } 'domain controller computer accounts (global catalog)')
    foreach ($c in $dcComputers) {
        $computers[("$(Get-A $c 'distinguishedName')").ToLower()] = $c
        if (Get-A $c 'dNSHostName') { $computers[("$(Get-A $c 'dNSHostName')").ToLower()] = $c }
    }

    $roleMap = @{}
    foreach ($d in $inv.Domains) {
        foreach ($r in @(@('PDC', $d.PdcEmulator), @('RID', $d.RidMaster), @('Infrastructure', $d.InfrastructureMaster))) {
            if ($r[1]) { $key = "$($d.Name)|$($r[1])".ToLower(); if (-not $roleMap[$key]) { $roleMap[$key] = @() }; $roleMap[$key] += $r[0] }
        }
    }

    $dcs = @()
    foreach ($s in $servers) {
        $sdn = "$(Get-A $s 'distinguishedName')"
        $n = $ntdsByServerDN[$sdn.ToLower()]
        if (-not $n) { continue }   # a server object without NTDS Settings is not a DC (or a demoted one)
        $name = Get-A $s 'name'
        $fqdn = Get-A $s 'dNSHostName'
        $ref = Get-A $s 'serverReference'
        $comp = $null
        if ($ref) { $comp = $computers[$ref.ToLower()] }
        if (-not $comp -and $fqdn) { $comp = $computers[$fqdn.ToLower()] }
        # The global catalog may leave operatingSystem out; read the DC's own computer account in its domain instead.
        if ($ref -and -not (Get-A $comp 'operatingSystem')) {
            $direct = @(Search-Adtd @{ SearchBase = $ref; Scope = 'Base'; Filter = '(objectClass=computer)'; Properties = @('dNSHostName', 'name', 'operatingSystem', 'operatingSystemVersion') } "computer account of $name")
            if ($direct.Count) { $comp = $direct[0] }
        }
        $domainDN = if ($ref) { Get-DomainDNFromDN $ref } else { Get-A $n 'msDS-HasDomainNCs' }
        $domainName = if ($domainDN) { ConvertTo-DnsName $domainDN } else { $null }
        $isRodc = @(Get-AAll $n 'objectClass') -contains 'nTDSDSARO'
        $isGc = ([int](Get-A $n 'options')) -band 1
        $os = Get-WindowsServerInfo -OperatingSystem (Get-A $comp 'operatingSystem') -OperatingSystemVersion (Get-A $comp 'operatingSystemVersion')
        $roles = @()
        if ($domainName) { $roles += @($roleMap["$domainName|$name".ToLower()]) | Where-Object { $_ } }
        if ($inv.Forest.SchemaMaster -eq $name) { $roles += 'Schema' }
        if ($inv.Forest.DomainNamingMaster -eq $name) { $roles += 'Domain naming' }
        $dcs += [pscustomobject]@{
            Name            = $name
            HostName        = $fqdn
            Site            = Get-SiteNameFromServerDN $sdn
            Domain          = $domainName
            IsGlobalCatalog = [bool]$isGc
            IsReadOnly      = [bool]$isRodc
            OperatingSystem = $os.Name
            OSBuild         = $os.Build
            OSEndOfSupport  = $os.EndOfSupport
            OSSupportState  = $os.SupportState
            FunctionalLevel = Get-A $n 'msDS-Behavior-Version'
            FsmoRoles       = @($roles)
            NtdsDN          = Get-A $n 'distinguishedName'
        }
    }
    $inv.DomainControllers = @($dcs | Sort-Object Site, Name)

    # ---------- Replication connections ----------
    Write-AdtdLog 'Reading replication connections...'
    $conns = @(Search-Adtd @{ SearchBase = $sitesDN; Filter = '(objectClass=nTDSConnection)'; Properties = @('name', 'fromServer', 'options', 'enabledConnection', 'transportType') } 'replication connections')
    $inv.Connections = @(foreach ($c in $conns) {
        $cdn = Get-A $c 'distinguishedName'
        $en = Get-A $c 'enabledConnection'
        [pscustomobject]@{
            From        = Get-ServerNameFromNtdsDN (Get-A $c 'fromServer')
            To          = Get-RdnValue $cdn 2
            FromSite    = Get-SiteNameFromServerDN (Get-ParentDN (Get-A $c 'fromServer'))
            ToSite      = Get-SiteNameFromServerDN (Get-ParentDN $cdn 2)
            Automatic   = [bool](([int](Get-A $c 'options')) -band 1)
            Enabled     = if ($null -eq $en) { $true } else { [bool]::Parse("$en") }
            Transport   = if (Get-A $c 'transportType') { Get-RdnValue (Get-A $c 'transportType') 0 } else { 'RPC' }
        }
    })

    # ---------- Trusts, SYSVOL, OUs, DFSR per domain ----------
    $trusts = @(); $ous = @(); $dfsr = @()
    foreach ($d in $inv.Domains) {
        if (-not $d.Reachable) { continue }
        Write-AdtdLog "Reading trusts for $($d.Name)..."
        $tds = @(Search-Adtd @{ Server = $d.Name; SearchBase = "CN=System,$($d.DN)"; Filter = '(objectClass=trustedDomain)'; Scope = 'OneLevel'; Properties = @('trustPartner', 'flatName', 'trustType', 'trustDirection', 'trustAttributes', 'whenCreated') } "trusts for $($d.Name)")
        foreach ($t in $tds) {
            $desc = Get-TrustDescription -Direction ([int](Get-A $t 'trustDirection')) -Type ([int](Get-A $t 'trustType')) -Attributes ([int](Get-A $t 'trustAttributes'))
            $trusts += [pscustomobject]@{
                Source     = $d.Name
                Target     = Get-A $t 'trustPartner'
                Direction  = $desc.Direction
                Kind       = $desc.Kind
                Flags      = @($desc.Flags)
                Attributes = [int](Get-A $t 'trustAttributes')
                Created    = if (Get-A $t 'whenCreated') { ([datetime](Get-A $t 'whenCreated')).ToString('yyyy-MM-dd') } else { $null }
            }
        }

        $dfsrSysvol = @(Search-Adtd @{ Server = $d.Name; SearchBase = "CN=DFSR-GlobalSettings,CN=System,$($d.DN)"; Filter = '(&(objectClass=msDFSR-ReplicationGroup)(name=Domain System Volume))'; Scope = 'OneLevel'; Properties = @('name') } "SYSVOL replication for $($d.Name)")
        $d.SysvolReplication = if ($dfsrSysvol.Count) { 'DFSR' } else { 'FRS' }

        if ($IncludeOUs) {
            Write-AdtdLog "Reading OUs and GPO links for $($d.Name)..."
            $gpos = @(Search-Adtd @{ Server = $d.Name; SearchBase = "CN=Policies,CN=System,$($d.DN)"; Filter = '(objectClass=groupPolicyContainer)'; Scope = 'OneLevel'; Properties = @('name', 'displayName') } "GPOs for $($d.Name)")
            $gpoNames = @{}
            foreach ($g in $gpos) { $gpoNames["$(Get-A $g 'name')".ToUpper()] = Get-A $g 'displayName' }
            $resolve = {
                param($link)
                $n = if ($link.Guid -and $gpoNames[$link.Guid]) { $gpoNames[$link.Guid] } elseif ($link.Guid) { "(missing GPO $($link.Guid))" } else { $link.GpoDN }
                [pscustomobject]@{ Name = $n; Enforced = $link.Enforced; Disabled = $link.Disabled }
            }
            $ous += [pscustomobject]@{
                Domain = $d.Name; Name = $d.Name; DN = $d.DN; ParentDN = $null; Depth = 0
                BlockInheritance = [bool]($d.GpOptions -band 1)
                GpoLinks = @(ConvertFrom-GpLink $d.GpLink | ForEach-Object { & $resolve $_ })
            }
            $ouObjs = @(Search-Adtd @{ Server = $d.Name; SearchBase = $d.DN; Filter = '(objectClass=organizationalUnit)'; Properties = @('name', 'gPLink', 'gPOptions') } "OUs for $($d.Name)")
            $sorted = @($ouObjs | Sort-Object { (Split-DistinguishedName (Get-A $_ 'distinguishedName')).Count }, { Get-A $_ 'name' })
            if ($sorted.Count -gt $MaxOUs) {
                Write-AdtdLog "$($d.Name) has $($sorted.Count) OUs; drawing the first $MaxOUs by depth (raise -MaxOUs to draw more)." -Level Warn
                $sorted = $sorted[0..($MaxOUs - 1)]
            }
            $domDepth = (Split-DistinguishedName $d.DN).Count
            foreach ($o in $sorted) {
                $odn = Get-A $o 'distinguishedName'
                $ous += [pscustomobject]@{
                    Domain = $d.Name; Name = Get-A $o 'name'; DN = $odn; ParentDN = Get-ParentDN $odn
                    Depth = (Split-DistinguishedName $odn).Count - $domDepth
                    BlockInheritance = [bool]([int](Get-A $o 'gPOptions') -band 1)
                    GpoLinks = @(ConvertFrom-GpLink (Get-A $o 'gPLink') | ForEach-Object { & $resolve $_ })
                }
            }
        }

        if ($IncludeDfsr) {
            Write-AdtdLog "Reading DFS Replication groups for $($d.Name)..."
            $gs = "CN=DFSR-GlobalSettings,CN=System,$($d.DN)"
            $rgs = @(Search-Adtd @{ Server = $d.Name; SearchBase = $gs; Filter = '(objectClass=msDFSR-ReplicationGroup)'; Scope = 'OneLevel'; Properties = @('name') } "DFSR groups for $($d.Name)")
            foreach ($rg in $rgs) {
                $rgDN = Get-A $rg 'distinguishedName'
                $members = @(Search-Adtd @{ Server = $d.Name; SearchBase = "CN=Topology,$rgDN"; Filter = '(objectClass=msDFSR-Member)'; Scope = 'OneLevel'; Properties = @('name', 'msDFSR-ComputerReference') } "DFSR members of $(Get-A $rg 'name')")
                $memberNames = @{}
                foreach ($m in $members) {
                    $cref = Get-A $m 'msDFSR-ComputerReference'
                    $memberNames[("$(Get-A $m 'distinguishedName')").ToLower()] = if ($cref) { Get-RdnValue $cref 0 } else { Get-A $m 'name' }
                }
                $mconns = @(Search-Adtd @{ Server = $d.Name; SearchBase = "CN=Topology,$rgDN"; Filter = '(objectClass=msDFSR-Connection)'; Properties = @('fromServer', 'msDFSR-Enabled') } "DFSR connections of $(Get-A $rg 'name')")
                $folders = @(Search-Adtd @{ Server = $d.Name; SearchBase = "CN=Content,$rgDN"; Filter = '(objectClass=msDFSR-ContentSet)'; Scope = 'OneLevel'; Properties = @('name') } "DFSR folders of $(Get-A $rg 'name')")
                $dfsr += [pscustomobject]@{
                    Domain      = $d.Name
                    Name        = Get-A $rg 'name'
                    Members     = @($memberNames.Values | Sort-Object)
                    Folders     = @($folders | ForEach-Object { Get-A $_ 'name' })
                    Connections = @(foreach ($c in $mconns) {
                            $en = Get-A $c 'msDFSR-Enabled'
                            [pscustomobject]@{
                                From    = $memberNames[("$(Get-A $c 'fromServer')").ToLower()]
                                To      = $memberNames[(Get-ParentDN (Get-A $c 'distinguishedName')).ToLower()]
                                Enabled = if ($null -eq $en) { $true } else { [bool]::Parse("$en") }
                            }
                        })
                }
            }
        }
    }
    $inv.Trusts = @($trusts)
    $inv.OUs = @($ous)
    $inv.Dfsr = @($dfsr)

    # ---------- Application partitions ----------
    if ($IncludeAppPartitions) {
        Write-AdtdLog 'Reading application partitions...'
        $inv.AppPartitions = @(foreach ($a in $appRefs) {
            [pscustomobject]@{
                Name     = Get-A $a 'dnsRoot'
                DN       = Get-A $a 'nCName'
                Replicas = @(Get-AAll $a 'msDS-NC-Replica-Locations' | ForEach-Object { Get-ServerNameFromNtdsDN $_ } | Sort-Object)
                ReadOnlyReplicas = @(Get-AAll $a 'msDS-NC-RO-Replica-Locations' | ForEach-Object { Get-ServerNameFromNtdsDN $_ } | Sort-Object)
            }
        })
    }

    # ---------- Exchange ----------
    if ($IncludeExchange) {
        Write-AdtdLog 'Reading Exchange organization...'
        $exRoot = "CN=Microsoft Exchange,CN=Services,$configNC"
        $org = @(Search-Adtd @{ SearchBase = $exRoot; Filter = '(objectClass=msExchOrganizationContainer)'; Scope = 'OneLevel'; Properties = @('name') } 'Exchange organization')
        if ($org.Count) {
            $exServers = @(Search-Adtd @{ SearchBase = $exRoot; Filter = '(objectCategory=msExchExchangeServer)'; Properties = @('name', 'serialNumber', 'msExchCurrentServerRoles', 'msExchServerSite', 'networkAddress', 'msExchMDBAvailabilityGroupLink') } 'Exchange servers')
            $dags = @(Search-Adtd @{ SearchBase = $exRoot; Filter = '(objectClass=msExchMDBAvailabilityGroup)'; Properties = @('name') } 'Exchange DAGs')
            $inv.Exchange = [pscustomobject]@{
                Organization = Get-A $org[0] 'name'
                SchemaName   = $inv.Forest.ExchangeSchemaName
                Dags         = @($dags | ForEach-Object { Get-A $_ 'name' })
                Servers      = @(@(foreach ($x in $exServers) {
                        $v = Get-ExchangeServerVersion (Get-A $x 'serialNumber')
                        $fqdn = @(Get-AAll $x 'networkAddress' | Where-Object { $_ -match '^ncacn_ip_tcp:' } | ForEach-Object { $_ -replace '^ncacn_ip_tcp:', '' }) | Select-Object -First 1
                        $dagDN = Get-A $x 'msExchMDBAvailabilityGroupLink'
                        [pscustomobject]@{
                            Name      = Get-A $x 'name'
                            HostName  = $fqdn
                            Product   = $v.Name
                            Version   = $v.Version
                            Supported = $v.Supported
                            Roles     = @(Get-ExchangeRoleNames (Get-A $x 'msExchCurrentServerRoles') $v.Name)
                            Site      = if (Get-A $x 'msExchServerSite') { Get-RdnValue (Get-A $x 'msExchServerSite') 0 } else { $null }
                            Dag       = if ($dagDN) { Get-RdnValue $dagDN 0 } else { $null }
                        }
                    }) | Sort-Object Site, Name)
            }
        } else {
            Write-AdtdLog 'No Exchange organization found in this forest.'
        }
    }

    if (-not $SkipSecurityScan) {
        $secDomains = @(foreach ($d in $inv.Domains) {
                if (-not $d.Reachable) { continue }
                Get-AdtdDomainSecurity -Domain $d -ConfigNC $configNC -IsForestRoot $d.IsForestRoot
            })
        $inv.Security = [pscustomobject]@{
            ScannedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm')
            Forest    = Get-AdtdForestSecurity -ConfigNC $configNC -SchemaNC $schemaNC
            Domains   = $secDomains
        }
    }
    $inv = [pscustomobject]$inv
    $inv.Findings = @(Get-AdtdFindings $inv)
    $inv.Plan = Get-AdtdTopologyPlan $inv
    Write-AdtdLog ("Found {0} domain(s), {1} site(s), {2} domain controller(s), {3} site link(s), {4} trust(s), {5} finding(s)." -f @($inv.Domains).Count, @($inv.Sites).Count, @($inv.DomainControllers).Count, @($inv.SiteLinks).Count, @($inv.Trusts).Count, @($inv.Findings).Count)
    return $inv
}
