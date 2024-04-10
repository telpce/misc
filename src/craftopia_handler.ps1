$ErrorActionPreference = 'Stop'
# Load windows environment variable
$installPath = $Env:CRAFTOPIAPATH # example C:\steamcmd_craftopia

$pinfo = New-Object System.Diagnostics.Process 
$pinfo.StartInfo.FileName ="$installPath\steamapps\common\CraftopiaDedicatedServer\Craftopia.exe"
$pinfo.StartInfo.UseShellExecute = $false
$pinfo.StartInfo.RedirectStandardInput = $true 
[Void]$pinfo.Start() 
$stdin = $pinfo.StandardInput

$udp = New-Object Net.Sockets.UdpClient -ArgumentList 6588
$commander = $null
$line = "start"
while($line -ne "stop")
{
  $buffer = $udp.Receive([ref]$commander)
  $line = [System.Text.Encoding]::UTF8.GetString($buffer)
  $stdin.WriteLine($line)
}
$udp.Close()
[Void]$pinfo.WaitForExit()
$pinfo.Close()
