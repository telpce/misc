$ErrorActionPreference = 'Stop'
# Load windows environment variable
$udpClient = New-Object Net.Sockets.UdpClient
$byteData = [Text.Encoding]::UTF8.GetBytes("stop")
# Send the UDP datagram
$udpClient.Send($byteData, $byteData.Length, "127.0.0.1", 6588)
$udp.Close()
