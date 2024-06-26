$ErrorActionPreference = 'Stop'
# Load windows environment variable
$adminPassword = $Env:PALADMINPASSWORD # example password
$port = $Env:PALPORT # example 8211
$installPath = $Env:PALPATH # example C:\steamcmd_palworld

# REST API settings
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "admin",$adminPassword)))
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "Basic $base64AuthInfo")

$shutdown_body = @"
{
  `"waittime`": 4,
  `"message`": `"It's Palworld Update Time! Server will shutdown in 10 seconds.`"
}
"@

$metrics = Invoke-RestMethod "http://localhost:8212/v1/api/metrics" -Method 'GET' -Headers $headers
if ($metrics.currentplayernum -eq 0) {

  # Update settings
  $jsonData = Invoke-WebRequest https://api.steamcmd.net/v1/info/2394010
  $parsedData = $jsonData  | ConvertFrom-Json
  $data = $parsedData.data.2394010
  # $public_build_id = $data.depots.branches.public.buildid
  $win = $data.depots.2394011
  $public_win_gid = $win.manifests.public.gid

  $steamcmd = &$installPath\steamcmd +login anonymous +app_status 2394010 +quit
  $line = $steamcmd | Select-String '2394011 :'
  $local_win_gid = [regex]::Match($line, 'manifest (\d+)').Groups[1].Value
  #$local_build_id = [regex]::Match($steamcmd, 'BuildID (\d+)').Groups[1].Value

  if ($local_win_gid -ne $public_win_gid) {

    Invoke-RestMethod "http://localhost:8212/v1/api/shutdown" -Method 'POST' -Headers $headers -Body $shutdown_body
    Start-Sleep -Seconds 10

    # backup
    tar.exe -a -cf "$installPath\steamapps\common\PalServer\Pal\Saved$(get-date -f yyyy-MM-dd).zip" -C $installPath\steamapps\common\PalServer\Pal Saved
    # update
    &$installPath\steamcmd +login anonymous +app_update 2394010 validate +quit

    Start-Process $installPath\steamapps\common\PalServer\PalServer.exe -ArgumentList "-publiclobby","-port=$port"
  }
  else {Write-Host "No updates"}
}
else{Write-Host "Someone is here"}
