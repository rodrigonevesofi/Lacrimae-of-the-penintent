@echo off
setlocal
cd /d "%~dp0"
echo Testa a chave do Gemini do Confessionario (faz UMA pergunta real).
echo Selecione o executavel do Godot (de preferencia o *_console.exe).
powershell.exe -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $d = New-Object System.Windows.Forms.OpenFileDialog; $d.Title = 'Selecione o executavel do Godot Standard'; $d.Filter = 'Godot (*.exe)|*.exe'; if ($d.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }; & $d.FileName '--headless' '--path' (Get-Location).Path '--script' 'res://tests/confessor_live_check.gd' 2>&1 | Where-Object { $_ -notmatch '^(Godot Engine|\s*$)' }"
echo.
echo Fonte: gemini  = tudo certo.  SEM CHAVE / chave recusada = confira o ia_local.cfg.
pause
