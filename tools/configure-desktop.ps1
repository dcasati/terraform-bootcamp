Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y visualstudio2015professional 
choco install -y ssdt15 --params INSTALLALL
