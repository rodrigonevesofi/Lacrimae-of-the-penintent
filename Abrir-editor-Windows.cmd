@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $d = New-Object System.Windows.Forms.OpenFileDialog; $d.Title = 'Selecione o executavel do Godot Standard'; $d.Filter = 'Godot (*.exe)|*.exe'; if ($d.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }; $root = (Get-Location).Path; $log = Join-Path $root 'godot-inicializacao.log'; Write-Host ('Executavel: ' + $d.FileName); Write-Host ('Projeto: ' + $root); & $d.FileName '--headless' '--path' $root '--editor' '--import' '--quit' 2>&1 | Tee-Object -FilePath (Join-Path $root 'godot-importacao.log'); if ($LASTEXITCODE -ne 0) { Write-Host 'Falha na importacao. Consulte godot-importacao.log'; exit 1 }; & $d.FileName '--path' $root '--editor' '--rendering-method' 'gl_compatibility' '--verbose' 2>&1 | Tee-Object -FilePath $log; $result = $LASTEXITCODE; Write-Host ('Log salvo em: ' + $log); exit $result"
echo.
echo Se houve erro, envie o conteudo de godot-inicializacao.log.
pause
