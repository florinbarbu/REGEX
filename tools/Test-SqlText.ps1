<#
.SYNOPSIS
Verifică UTF-8 și CRLF pentru fișierele SQL explicit selectate.
.DESCRIPTION
-Fix normalizează numai terminatorii de linie ai textului UTF-8 valid.
Codificările invalide/ambigue sunt refuzate fără rescriere.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]] $Path,
    [switch] $Fix
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = [System.Text.UTF8Encoding]::new($false, $true)
$planned = @()

# Validează toate intrările înainte de orice rescriere.
foreach ($item in $Path) {
    $file = Get-Item -LiteralPath $item -ErrorAction Stop
    if ($file.PSIsContainer -or $file.Extension -ine '.sql') {
        throw "Nu este un fișier SQL: $item"
    }
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    try {
        $content = $utf8.GetString($bytes)
    } catch {
        throw "UTF-8 invalid; fișierul nu a fost modificat: $($file.FullName)"
    }
    if ($content.IndexOf([char]0) -ge 0) {
        throw "Text cu NUL: posibil UTF-16 fără BOM; conversia trebuie stabilită explicit: $($file.FullName)"
    }
    $lfOnly = [regex]::Matches($content, '(?<!\r)\n').Count
    $crOnly = [regex]::Matches($content, '\r(?!\n)').Count
    $planned += [pscustomobject]@{
        File = $file.FullName
        Content = $content
        LFOnly = $lfOnly
        CROnly = $crOnly
    }
}

$failed = $false
foreach ($entry in $planned) {
    $changed = $false
    if ($entry.LFOnly -gt 0 -or $entry.CROnly -gt 0) {
        if ($Fix) {
            $normalized = [regex]::Replace($entry.Content, '\r\n|\r|\n', "`r`n")
            [System.IO.File]::WriteAllBytes($entry.File, $utf8.GetBytes($normalized))
            $verified = $utf8.GetString([System.IO.File]::ReadAllBytes($entry.File))
            if ($verified -cne $normalized -or $verified -match '(?<!\r)\n|\r(?!\n)') {
                throw "Verificarea după rescriere a eșuat: $($entry.File)"
            }
            $changed = $true
        } else {
            $failed = $true
        }
    }
    [pscustomobject]@{
        File = $entry.File
        UTF8 = $true
        LFOnlyFound = $entry.LFOnly
        CROnlyFound = $entry.CROnly
        Normalized = $changed
        Compliant = ($changed -or ($entry.LFOnly -eq 0 -and $entry.CROnly -eq 0))
    }
}
if ($failed) {
    throw 'Există fișiere SQL cu LF/CR izolat. Rulează din nou cu -Fix înainte de livrare.'
}
