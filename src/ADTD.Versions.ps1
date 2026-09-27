# ADTD Modern - version tables for Active Directory, Windows Server and Exchange.
# Update these tables when Microsoft ships a new release; nothing else needs to change.

# msDS-Behavior-Version on CN=Partitions (forest), the domain head (domain) and NTDS Settings (DC).
# Windows Server 2019 and 2022 did not add a level: they run at the 2016 level (7).
$script:FunctionalLevels = @{
    0  = 'Windows 2000'
    1  = 'Windows Server 2003 interim'
    2  = 'Windows Server 2003'
    3  = 'Windows Server 2008'
    4  = 'Windows Server 2008 R2'
    5  = 'Windows Server 2012'
    6  = 'Windows Server 2012 R2'
    7  = 'Windows Server 2016'
    10 = 'Windows Server 2025'
}
$script:LatestFunctionalLevel = 10
$script:RecommendedMinimumLevel = 7

# objectVersion on the schema naming context head.
$script:SchemaVersions = @{
    13 = 'Windows 2000'
    30 = 'Windows Server 2003'
    31 = 'Windows Server 2003 R2'
    44 = 'Windows Server 2008'
    47 = 'Windows Server 2008 R2'
    52 = 'Windows Server 2012 beta'
    56 = 'Windows Server 2012'
    69 = 'Windows Server 2012 R2'
    72 = 'Windows Server 2016 TP4'
    81 = 'Windows Server 2016 TP5'
    87 = 'Windows Server 2016'
    88 = 'Windows Server 2019 / 2022'
    90 = 'Windows Server 2025 preview'
    91 = 'Windows Server 2025'
}

# Windows Server builds (operatingSystemVersion "10.0 (20348)") and end of extended support.
$script:WindowsServerBuilds = @(
    [pscustomobject]@{ Build = 2195;  Name = 'Windows 2000 Server';       EndOfSupport = '2010-07-13' }
    [pscustomobject]@{ Build = 3790;  Name = 'Windows Server 2003 / R2';  EndOfSupport = '2015-07-14' }
    [pscustomobject]@{ Build = 6001;  Name = 'Windows Server 2008';       EndOfSupport = '2020-01-14' }
    [pscustomobject]@{ Build = 6002;  Name = 'Windows Server 2008';       EndOfSupport = '2020-01-14' }
    [pscustomobject]@{ Build = 6003;  Name = 'Windows Server 2008';       EndOfSupport = '2020-01-14' }
    [pscustomobject]@{ Build = 7600;  Name = 'Windows Server 2008 R2';    EndOfSupport = '2020-01-14' }
    [pscustomobject]@{ Build = 7601;  Name = 'Windows Server 2008 R2';    EndOfSupport = '2020-01-14' }
    [pscustomobject]@{ Build = 9200;  Name = 'Windows Server 2012';       EndOfSupport = '2023-10-10' }
    [pscustomobject]@{ Build = 9600;  Name = 'Windows Server 2012 R2';    EndOfSupport = '2023-10-10' }
    [pscustomobject]@{ Build = 14393; Name = 'Windows Server 2016';       EndOfSupport = '2027-01-12' }
    [pscustomobject]@{ Build = 17763; Name = 'Windows Server 2019';       EndOfSupport = '2029-01-09' }
    [pscustomobject]@{ Build = 20348; Name = 'Windows Server 2022';       EndOfSupport = '2031-10-14' }
    [pscustomobject]@{ Build = 26100; Name = 'Windows Server 2025';       EndOfSupport = '2034-10-10' }
)

# rangeUpper of CN=ms-Exch-Schema-Version-Pt in the schema.
$script:ExchangeSchemaVersions = @(
    [pscustomobject]@{ Min = 4397;  Max = 4406;  Name = 'Exchange 2000' }
    [pscustomobject]@{ Min = 6870;  Max = 6936;  Name = 'Exchange 2003' }
    [pscustomobject]@{ Min = 10637; Max = 11116; Name = 'Exchange 2007' }
    [pscustomobject]@{ Min = 14622; Max = 14622; Name = 'Exchange 2007 SP3 / 2010' }
    [pscustomobject]@{ Min = 14625; Max = 14734; Name = 'Exchange 2010' }
    [pscustomobject]@{ Min = 15137; Max = 15312; Name = 'Exchange 2013' }
    [pscustomobject]@{ Min = 15317; Max = 15334; Name = 'Exchange 2016' }
    [pscustomobject]@{ Min = 17000; Max = 17999; Name = 'Exchange 2019 / Subscription Edition' }
)

# Exchange Server SE RTM is 15.2.2562; earlier 15.2 builds are Exchange 2019.
$script:ExchangeSeFirstBuild = 2562

function Get-FunctionalLevelName {
    param($Level)
    if ($null -eq $Level -or "$Level" -eq '') { return 'Unknown' }
    $n = [int]$Level
    if ($script:FunctionalLevels.ContainsKey($n)) { return $script:FunctionalLevels[$n] }
    return "Unknown level $n (newer than this version of ADTD)"
}

function Get-SchemaVersionName {
    param($Version)
    if ($null -eq $Version -or "$Version" -eq '') { return 'Unknown' }
    $n = [int]$Version
    if ($script:SchemaVersions.ContainsKey($n)) { return $script:SchemaVersions[$n] }
    if ($n -gt 91) { return "Schema $n (newer than Windows Server 2025)" }
    return "Schema $n"
}

function Get-ExchangeSchemaName {
    param($RangeUpper)
    if ($null -eq $RangeUpper -or "$RangeUpper" -eq '') { return $null }
    $n = [int]$RangeUpper
    foreach ($v in $script:ExchangeSchemaVersions) {
        if ($n -ge $v.Min -and $n -le $v.Max) { return $v.Name }
    }
    return "Exchange schema $n"
}

function Get-WindowsServerInfo {
    <# Maps operatingSystem / operatingSystemVersion to a product name and support state. #>
    param([string]$OperatingSystem, [string]$OperatingSystemVersion, [datetime]$Today = (Get-Date))
    $build = $null
    if ($OperatingSystemVersion -match '\((\d+)\)') { $build = [int]$Matches[1] }
    elseif ($OperatingSystemVersion -match '^\d+\.\d+\.(\d+)') { $build = [int]$Matches[1] }

    $entry = $null
    if ($build) { $entry = $script:WindowsServerBuilds | Where-Object { $_.Build -eq $build } | Select-Object -First 1 }
    if (-not $entry -and $build) {
        # Unknown build: take the newest known release at or below it (insider / future builds).
        $entry = $script:WindowsServerBuilds | Where-Object { $_.Build -le $build } | Select-Object -Last 1
        if ($entry -and $build -gt ($script:WindowsServerBuilds[-1].Build)) {
            $entry = [pscustomobject]@{ Build = $build; Name = "Windows Server (build $build)"; EndOfSupport = $null }
        }
    }
    $name = if ($entry) { $entry.Name } elseif ($OperatingSystem) { $OperatingSystem } else { 'Unknown Windows version' }
    $state = 'Unknown'
    $eos = $null
    if ($entry -and $entry.EndOfSupport) {
        $eos = [datetime]::ParseExact($entry.EndOfSupport, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)
        if ($eos -lt $Today) { $state = 'Unsupported' }
        elseif ($eos -lt $Today.AddMonths(12)) { $state = 'EndingSoon' }
        else { $state = 'Supported' }
    } elseif ($entry) { $state = 'Supported' }
    [pscustomobject]@{
        Name         = $name
        Build        = $build
        EndOfSupport = if ($eos) { $eos.ToString('yyyy-MM-dd') } else { $null }
        SupportState = $state
    }
}

function Get-ExchangeServerVersion {
    <# serialNumber looks like "Version 15.2 (Build 2562.17)". #>
    param([string]$SerialNumber)
    $major = $null; $minor = $null; $build = $null
    if ($SerialNumber -match 'Version\s+(\d+)\.(\d+)\s*\(Build\s+(\d+)') {
        $major = [int]$Matches[1]; $minor = [int]$Matches[2]; $build = [int]$Matches[3]
    }
    $name = 'Unknown Exchange version'
    $supported = $false
    if ($null -ne $major) {
        switch ($major) {
            6  { $name = if ($minor -ge 5) { 'Exchange 2003' } else { 'Exchange 2000' } }
            8  { $name = 'Exchange 2007' }
            14 { $name = 'Exchange 2010' }
            15 {
                switch ($minor) {
                    0 { $name = 'Exchange 2013' }
                    1 { $name = 'Exchange 2016' }
                    2 {
                        if ($build -ge $script:ExchangeSeFirstBuild) { $name = 'Exchange Server SE'; $supported = $true }
                        else { $name = 'Exchange 2019' }
                    }
                    default { $name = "Exchange 15.$minor"; $supported = $true }
                }
            }
            default { if ($major -gt 15) { $name = "Exchange $major.$minor"; $supported = $true } }
        }
    }
    $ver = if ($null -ne $major) { "$major.$minor.$build" } else { $null }
    [pscustomobject]@{ Name = $name; Version = $ver; Supported = $supported }
}

function Get-ExchangeRoleNames {
    param($Roles, [string]$ProductName)
    if ($null -eq $Roles -or "$Roles" -eq '') { return @() }
    $r = [int64]$Roles
    $names = New-Object System.Collections.Generic.List[string]
    if ($r -band 64) { $names.Add('Edge Transport') }
    if ($r -band 2)  { $names.Add('Mailbox') }
    if ($ProductName -notmatch '2016|2019|SE') {
        if ($r -band 4)  { $names.Add('Client Access') }
        if ($r -band 32) { $names.Add('Hub Transport') }
        if ($r -band 16) { $names.Add('Unified Messaging') }
    }
    return $names.ToArray()
}

# Windows client releases (Enterprise/Education servicing dates; Home/Pro end earlier).
# Windows 10 (non-LTSC) ended 2025-10-14; paid Extended Security Updates don't change that here.
$script:WindowsClientBuilds = @(
    [pscustomobject]@{ Match = 'Windows 11'; Build = 22000; Name = 'Windows 11 21H2'; EndOfSupport = '2024-10-08' }
    [pscustomobject]@{ Match = 'Windows 11'; Build = 22621; Name = 'Windows 11 22H2'; EndOfSupport = '2025-10-14' }
    [pscustomobject]@{ Match = 'Windows 11'; Build = 22631; Name = 'Windows 11 23H2'; EndOfSupport = '2026-11-10' }
    [pscustomobject]@{ Match = 'Windows 11'; Build = 26100; Name = 'Windows 11 24H2'; EndOfSupport = '2027-10-12' }
    [pscustomobject]@{ Match = 'Windows 11'; Build = 26200; Name = 'Windows 11 25H2'; EndOfSupport = '2028-10-10' }
    [pscustomobject]@{ Match = 'LTS';        Build = 14393; Name = 'Windows 10 LTSB 2016'; EndOfSupport = '2026-10-13' }
    [pscustomobject]@{ Match = 'LTS';        Build = 17763; Name = 'Windows 10 LTSC 2019'; EndOfSupport = '2029-01-09' }
    [pscustomobject]@{ Match = 'LTS';        Build = 19044; Name = 'Windows 10 LTSC 2021'; EndOfSupport = '2027-01-12' }
    [pscustomobject]@{ Match = 'LTS';        Build = 26100; Name = 'Windows 11 LTSC 2024'; EndOfSupport = '2029-10-09' }
)
$script:Windows10EndOfSupport = '2025-10-14'

function Get-WindowsOsInfo {
    <# Support state for any Windows computer (server or client). Returns $null for non-Windows systems. #>
    param([string]$OperatingSystem, [string]$OperatingSystemVersion, [datetime]$Today = (Get-Date))
    if (-not $OperatingSystem -or $OperatingSystem -notmatch 'Windows') { return $null }
    if ($OperatingSystem -match 'Server') { return Get-WindowsServerInfo -OperatingSystem $OperatingSystem -OperatingSystemVersion $OperatingSystemVersion -Today $Today }
    $build = $null
    if ($OperatingSystemVersion -match '\((\d+)\)') { $build = [int]$Matches[1] }
    $name = $OperatingSystem; $eos = $null
    if ($OperatingSystem -match 'Windows (XP|Vista|7|8)\b' -or $OperatingSystem -match 'Windows 8\.1|Windows 2000') {
        $eos = '2023-01-10'; $name = $OperatingSystem
    } elseif ($OperatingSystem -match 'LTS[BC]') {
        $e = $script:WindowsClientBuilds | Where-Object { $_.Match -eq 'LTS' -and $_.Build -eq $build } | Select-Object -First 1
        if ($e) { $name = $e.Name; $eos = $e.EndOfSupport }
    } elseif ($OperatingSystem -match 'Windows 11') {
        $e = $script:WindowsClientBuilds | Where-Object { $_.Match -eq 'Windows 11' -and $_.Build -eq $build } | Select-Object -First 1
        if ($e) { $name = $e.Name; $eos = $e.EndOfSupport }
    } elseif ($OperatingSystem -match 'Windows 10') {
        $name = 'Windows 10'; $eos = $script:Windows10EndOfSupport
    }
    $state = 'Unknown'
    if ($eos) {
        $d = [datetime]::ParseExact($eos, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)
        $state = if ($d -lt $Today) { 'Unsupported' } elseif ($d -lt $Today.AddMonths(12)) { 'EndingSoon' } else { 'Supported' }
    }
    [pscustomobject]@{ Name = $name; Build = $build; EndOfSupport = $eos; SupportState = $state }
}
