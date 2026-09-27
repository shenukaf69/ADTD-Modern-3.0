# ADTD Modern - icon set for the drawings.
# Original flat icons (64x64 tiles, white glyph on a colour gradient), embedded in the .drawio file as
# data URIs so they render identically in draw.io desktop, draw.io on the web, the offline report viewer
# and any PNG/SVG/PDF export - no stencil libraries or internet access needed.

$script:IconColors = @{
    server = @('#3B82F6', '#1D4ED8'); rodc = @('#F59E0B', '#B45309'); site = @('#14B8A6', '#0F766E'); subnet = @('#06B6D4', '#0E7490')
    forest = @('#22C55E', '#15803D'); domain = @('#6366F1', '#4338CA'); globe = @('#64748B', '#334155'); link = @('#8B5CF6', '#6D28D9')
    mail = @('#0EA5E9', '#0369A1'); folder = @('#EAB308', '#A16207'); policy = @('#64748B', '#334155'); sync = @('#10B981', '#047857')
    database = @('#A855F7', '#7E22CE'); cloud = @('#0EA5E9', '#1D4ED8'); shield = @('#EF4444', '#B91C1C'); user = @('#6366F1', '#4338CA')
    laptop = @('#3B82F6', '#1E40AF'); app = @('#8B5CF6', '#5B21B6'); cert = @('#F97316', '#C2410C'); key = @('#F59E0B', '#B45309')
    lock = @('#64748B', '#1E293B'); flag = @('#22C55E', '#15803D'); warning = @('#F97316', '#C2410C'); check = @('#22C55E', '#15803D')
    replication = @('#10B981', '#047857'); tier0 = @('#EF4444', '#991B1B'); adtd = @('#3B82F6', '#1E3A8A')
}

$script:IconGlyphs = @{
    server      = '<rect x="17" y="13" width="30" height="15" rx="3"/><rect x="17" y="32" width="30" height="15" rx="3"/><circle cx="23" cy="20.5" r="2" fill="#1E3A8A"/><circle cx="23" cy="39.5" r="2" fill="#1E3A8A"/><rect x="29" y="19" width="13" height="3" rx="1.5" fill="#1E3A8A" opacity=".5"/><rect x="29" y="38" width="13" height="3" rx="1.5" fill="#1E3A8A" opacity=".5"/><rect x="30" y="47" width="4" height="4"/><rect x="21" y="51" width="22" height="3" rx="1.5"/>'
    rodc        = '<rect x="17" y="13" width="30" height="15" rx="3"/><rect x="17" y="32" width="30" height="15" rx="3"/><circle cx="23" cy="20.5" r="2" fill="#92400E"/><circle cx="23" cy="39.5" r="2" fill="#92400E"/><path d="M38 44a6 6 0 1 1 12 0v2h1v9H37v-9h1z" fill="#fff" stroke="#92400E" stroke-width="2"/><rect x="42" y="49" width="4" height="4" rx="1" fill="#92400E"/>'
    site        = '<path d="M14 52V26l12-7v33zM28 52V14l22 9v29z"/><g fill="#0F766E"><rect x="33" y="25" width="4" height="4"/><rect x="41" y="28" width="4" height="4"/><rect x="33" y="33" width="4" height="4"/><rect x="41" y="36" width="4" height="4"/><rect x="33" y="41" width="4" height="4"/><rect x="41" y="44" width="4" height="4"/><rect x="18" y="31" width="4" height="4"/><rect x="18" y="39" width="4" height="4"/></g>'
    subnet      = '<circle cx="32" cy="17" r="6"/><circle cx="16" cy="45" r="6"/><circle cx="48" cy="45" r="6"/><path d="M32 23v8M32 31L16 39M32 31l16 8" stroke="#fff" stroke-width="3" fill="none" stroke-linecap="round"/>'
    forest      = '<path d="M22 12L9 34h8L8 48h28l-9-14h8z"/><path d="M42 16L31 35h7l-8 13h24l-8-13h7z" opacity=".85"/><rect x="20" y="48" width="4" height="7"/><rect x="40" y="48" width="4" height="7"/>'
    domain      = '<rect x="24" y="10" width="16" height="12" rx="2"/><rect x="9" y="40" width="16" height="12" rx="2"/><rect x="39" y="40" width="16" height="12" rx="2"/><path d="M32 22v8M17 40v-6h30v6" stroke="#fff" stroke-width="3" fill="none"/>'
    globe       = '<circle cx="32" cy="32" r="19" fill="none" stroke="#fff" stroke-width="3.5"/><ellipse cx="32" cy="32" rx="8" ry="19" fill="none" stroke="#fff" stroke-width="3"/><path d="M13 32h38M16 22h32M16 42h32" stroke="#fff" stroke-width="3"/>'
    link        = '<rect x="9" y="25" width="26" height="14" rx="7" fill="none" stroke="#fff" stroke-width="4" transform="rotate(-30 22 32)"/><rect x="29" y="25" width="26" height="14" rx="7" fill="none" stroke="#fff" stroke-width="4" transform="rotate(-30 42 32)"/>'
    mail        = '<rect x="11" y="17" width="42" height="30" rx="4"/><path d="M13 20l19 15 19-15" fill="none" stroke="#0369A1" stroke-width="3.5" stroke-linejoin="round"/>'
    folder      = '<path d="M10 20a3 3 0 0 1 3-3h13l5 5h20a3 3 0 0 1 3 3v22a3 3 0 0 1-3 3H13a3 3 0 0 1-3-3z"/><path d="M10 27h44" stroke="#A16207" stroke-width="2.5"/>'
    policy      = '<path d="M16 10h24l10 10v34H16z"/><path d="M40 10v10h10" fill="#CBD5E1"/><circle cx="33" cy="37" r="8" fill="none" stroke="#334155" stroke-width="3.5"/><path d="M33 26v4M33 44v4M22 37h4M40 37h4" stroke="#334155" stroke-width="3.5"/>'
    sync        = '<path d="M47 27A16 16 0 0 0 18 22" fill="none" stroke="#fff" stroke-width="4.5" stroke-linecap="round"/><path d="M17 37a16 16 0 0 0 29 5" fill="none" stroke="#fff" stroke-width="4.5" stroke-linecap="round"/><path d="M13 13v11h11zM51 51V40H40z"/>'
    database    = '<ellipse cx="32" cy="16" rx="17" ry="6"/><path d="M15 16v32c0 3.3 7.6 6 17 6s17-2.7 17-6V16c0 3.3-7.6 6-17 6s-17-2.7-17-6z"/><path d="M15 29c0 3.3 7.6 6 17 6s17-2.7 17-6M15 40c0 3.3 7.6 6 17 6s17-2.7 17-6" fill="none" stroke="#7E22CE" stroke-width="2.5"/>'
    cloud       = '<path d="M20 48a11 11 0 0 1-1-22 15 15 0 0 1 29 3 9.5 9.5 0 0 1-1 19z"/><circle cx="33" cy="37" r="4.5" fill="#1D4ED8"/><path d="M36 37h9v4" stroke="#1D4ED8" stroke-width="3" fill="none"/>'
    shield      = '<path d="M32 9l19 7v14c0 12-8 21-19 25-11-4-19-13-19-25V16z"/><path d="M24 32l6 6 11-12" fill="none" stroke="#B91C1C" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/>'
    user        = '<circle cx="32" cy="22" r="10"/><path d="M13 53c0-11 8.5-18 19-18s19 7 19 18z"/>'
    laptop      = '<rect x="15" y="15" width="34" height="24" rx="3"/><rect x="19" y="19" width="26" height="16" rx="1" fill="#1E40AF"/><path d="M9 44h46l-4 6H13z"/>'
    app         = '<rect x="11" y="13" width="42" height="38" rx="4"/><rect x="11" y="13" width="42" height="9" rx="4" fill="#DDD6FE"/><g fill="#5B21B6"><rect x="17" y="28" width="12" height="8" rx="1.5"/><rect x="35" y="28" width="12" height="8" rx="1.5"/><rect x="17" y="39" width="12" height="7" rx="1.5"/><rect x="35" y="39" width="12" height="7" rx="1.5"/></g>'
    cert        = '<rect x="9" y="12" width="46" height="32" rx="3"/><path d="M15 20h22M15 27h18M15 34h12" stroke="#C2410C" stroke-width="3"/><circle cx="45" cy="34" r="7" fill="#FDBA74" stroke="#C2410C" stroke-width="2"/><path d="M41 40l-2 13 6-4 6 4-2-13" fill="#fff"/>'
    key         = '<circle cx="22" cy="32" r="11" fill="none" stroke="#fff" stroke-width="5"/><path d="M32 32h22M46 32v8M53 32v6" stroke="#fff" stroke-width="5" stroke-linecap="round"/>'
    lock        = '<rect x="15" y="29" width="34" height="25" rx="4"/><path d="M22 29v-7a10 10 0 0 1 20 0v7" fill="none" stroke="#fff" stroke-width="5"/><circle cx="32" cy="40" r="3.5" fill="#1E293B"/><rect x="30.5" y="41" width="3" height="7" fill="#1E293B"/>'
    flag        = '<path d="M17 10v45" stroke="#fff" stroke-width="4" stroke-linecap="round"/><path d="M19 12h28l-6 9 6 9H19z"/>'
    warning     = '<path d="M32 9l24 43H8z"/><path d="M32 24v14" stroke="#C2410C" stroke-width="5" stroke-linecap="round"/><circle cx="32" cy="45" r="3" fill="#C2410C"/>'
    check       = '<circle cx="32" cy="32" r="20" fill="none" stroke="#fff" stroke-width="4.5"/><path d="M22 32l7 7 13-14" fill="none" stroke="#fff" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>'
    replication = '<rect x="9" y="12" width="18" height="24" rx="3"/><rect x="37" y="28" width="18" height="24" rx="3"/><path d="M29 22h11l-3-3M35 42H24l3 3" fill="none" stroke="#fff" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>'
    tier0       = '<path d="M32 9l19 7v14c0 12-8 21-19 25-11-4-19-13-19-25V16z"/><text x="32" y="40" font-family="Segoe UI,Arial" font-size="17" font-weight="700" text-anchor="middle" fill="#991B1B">T0</text>'
    adtd        = '<rect x="24" y="9" width="16" height="12" rx="2"/><rect x="9" y="43" width="16" height="12" rx="2"/><rect x="39" y="43" width="16" height="12" rx="2"/><path d="M32 21v10M17 43v-6h30v6" stroke="#fff" stroke-width="3" fill="none"/><circle cx="32" cy="31" r="4"/>'
}

$script:IconCache = @{}

function Get-AdtdIconSvg {
    param([Parameter(Mandatory)][string]$Name)
    if (-not $script:IconGlyphs.ContainsKey($Name)) { throw "Unknown icon '$Name'." }
    $c = $script:IconColors[$Name]
    return "<svg xmlns=""http://www.w3.org/2000/svg"" viewBox=""0 0 64 64""><defs><linearGradient id=""g"" x1=""0"" y1=""0"" x2=""1"" y2=""1""><stop offset=""0"" stop-color=""$($c[0])""/><stop offset=""1"" stop-color=""$($c[1])""/></linearGradient></defs><rect width=""64"" height=""64"" rx=""14"" fill=""url(#g)""/><g fill=""#fff"">$($script:IconGlyphs[$Name])</g></svg>"
}

function Get-AdtdIconUri {
    <# draw.io-style data URI (base64 without the ';base64' marker, because ';' separates style keys). #>
    param([Parameter(Mandatory)][string]$Name, [switch]$Html)
    $key = "$Name|$Html"
    if (-not $script:IconCache.ContainsKey($key)) {
        $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-AdtdIconSvg $Name)))
        $script:IconCache[$key] = if ($Html) { "data:image/svg+xml;base64,$b64" } else { "data:image/svg+xml,$b64" }
    }
    return $script:IconCache[$key]
}

function Get-AdtdIconImg {
    <# Inline <img> for HTML labels (site headers, titles). #>
    param([string]$Name, [int]$Size = 18)
    return "<img src='$(Get-AdtdIconUri $Name -Html)' width='$Size' height='$Size' style='vertical-align:middle;margin-right:6px'>"
}
