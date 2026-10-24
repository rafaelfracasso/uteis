# Encontra a camera pelo MAC (nao muda) e abre no VLC
$configPath = "$PSScriptRoot\config.json"
if (-not (Test-Path $configPath)) {
    Write-Host "Arquivo config.json nao encontrado. Copie config.example.json para config.json e preencha." -ForegroundColor Red
    Read-Host "Pressione Enter para fechar"
    exit 1
}
$config = Get-Content $configPath -Raw | ConvertFrom-Json

$mac   = $config.mac
$rede  = $config.rede
$user  = $config.user
$senha = $config.senha
$vlc   = "C:\Program Files\VideoLAN\VLC\vlc.exe"

Write-Host "Procurando a camera na rede..."

for ($tentativa = 1; $tentativa -le 3; $tentativa++) {
    Write-Host "Tentativa $tentativa de 3..."

    $pings = 1..254 | ForEach-Object {
        (New-Object System.Net.NetworkInformation.Ping).SendPingAsync("$rede$_", 800)
    }

    try { [Threading.Tasks.Task]::WaitAll($pings) } catch {}

    $linha = arp -a | Select-String $mac

    if ($linha) {
        $ip = ($linha.Line.Trim() -split '\s+')[0]
        Write-Host "Camera encontrada em $ip" -ForegroundColor Green
        Set-Content -Path "$PSScriptRoot\ip-camera.txt" -Value $ip

        $url = "rtsp://${user}:${senha}@${ip}:554/cam/realmonitor?channel=1&subtype=0"
        Start-Process $vlc -ArgumentList "--video-on-top", "--zoom=0.25", "`"$url`""

        break
    }

    if ($tentativa -lt 3) {
        Write-Host "Camera nao encontrada. Tentando novamente em 3 segundos..."
        Start-Sleep -Seconds 3
    } else {
        Write-Host "Camera nao encontrada apos 3 tentativas. Ela esta ligada e na mesma rede?" -ForegroundColor Red
        Read-Host "Pressione Enter para fechar"
    }
}