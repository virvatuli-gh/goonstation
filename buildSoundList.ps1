# Include any directories OR individual files to exclude here (use windows directory separators e.g. sound\foo rather than sound/foo)
# You must include the full path relative to the current script directory
$Excludes = @("sound\vox", "browserassets\sounds", "unversioned\*", "sound\radio_station", "sound\radio_station\adverts", "sound\radio_station\music", "+secret\*")

$oggFiles = Get-ChildItem -Recurse -Filter "*.ogg" -Name | %{
    $allowed = $true
    foreach ($exclude in $Excludes) {
        if ($_ -ilike $exclude -OR (Split-Path $_) -ilike $exclude) {
            $allowed = $false
            break
        }
    }
    if ($allowed) {
        $_
    }
}

$oggVariables = $oggFiles | %{$_ -replace "\\", "/"} | %{$_ -replace "'", "\'"} | %{$_ -replace "((?:[a-zA-Z0-9_/\\'-]|\s)*.ogg)`$", '	"$1" = ''$1'''}
$oggVariables = $oggVariables | %{$_ + ",\
"}

$output = "
// AUTOGENERATED
// USE buildSoundList.ps1 TO UPDATE
// Note: Vox files are excluded from this to save on rsc size

var/global/list/soundCache = list(
$oggVariables
`"NONE`" = null)"

$output | Out-File -encoding ascii code\modules\sound\soundCache.dm
echo "Done!"
