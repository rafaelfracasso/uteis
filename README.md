# uteis

Script para Windows que encontra uma câmera IP na rede local e abre a transmissão ao vivo no VLC.

O IP da câmera pode mudar quando o roteador reinicia. Por isso o script procura a câmera pelo **endereço MAC**, que não muda, e monta o link RTSP com o IP atual.

## Como funciona

1. Faz ping em todos os endereços da rede (ex.: `192.168.1.1` a `192.168.1.254`) para preencher a tabela ARP.
2. Procura o MAC da câmera na tabela (`arp -a`).
3. Encontrou: salva o IP em `ip-camera.txt` e abre o stream no VLC, sempre por cima das outras janelas e com zoom de 25%.
4. Não encontrou: tenta de novo, até 3 vezes.

## Requisitos

- Windows com PowerShell
- [VLC](https://www.videolan.org/vlc/) instalado em `C:\Program Files\VideoLAN\VLC\vlc.exe`
- Câmera com RTSP na porta 554. O caminho `/cam/realmonitor?channel=1&subtype=0` é o padrão de câmeras Dahua/Intelbras. Para outras marcas, ajuste a URL em `abrir-camera.ps1`.
- Computador na mesma rede da câmera

## Configuração

1. Copie `config.example.json` para `config.json`.
2. Preencha com os dados da sua câmera:

   ```json
   {
     "mac": "aa-bb-cc-dd-ee-ff",
     "rede": "192.168.1.",
     "user": "admin",
     "senha": "SUA_SENHA_AQUI"
   }
   ```

   - `mac`: endereço MAC da câmera, com hífens e letras minúsculas (o formato que o `arp -a` mostra)
   - `rede`: os três primeiros números do IP da sua rede, terminando com ponto
   - `user` / `senha`: login da câmera

> `config.json` está no `.gitignore` e não vai para o repositório. Nunca coloque a senha direto no script.

## Uso

Dê dois cliques em **`Abrir Camera.bat`**.

Ou, pelo PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\abrir-camera.ps1
```

## Arquivos

| Arquivo | Para que serve |
|---|---|
| `Abrir Camera.bat` | Atalho para rodar o script com dois cliques |
| `abrir-camera.ps1` | Script principal |
| `config.example.json` | Modelo de configuração |
| `config.json` | Sua configuração, com a senha (não vai para o git) |
| `ip-camera.txt` | Último IP encontrado, gerado pelo script (não vai para o git) |
