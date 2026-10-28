# Windows GUI smoke test evidence

## User journey

A user opens `TriadDesktop.exe`, confirms the Triad icon and window, runs
`Stato`, and sees the CLI status output in the application window.

## RED/GREEN evidence

- RED command:
  `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\cli\windows-gui\tests\smoke.ps1`
- RED result before implementation:
  `Desktop executable not found: ...\cli\dist\TriadDesktop.exe`
- Build command:
  `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\cli\windows-gui\build.ps1`
- GREEN command: the same smoke command above.
- GREEN result:
  `PASS: app opens with the Triad logo and the Status action works.`

The smoke test checks the executable icon, window title, enabled status action,
and visible status output. It uses UI Automation to locate controls and native
Windows messages to activate/read them because this .NET Framework runtime
exposes WinForms controls without UIA action/text patterns.

## Coverage and gaps

This is an end-to-end smoke test; no line or branch coverage instrumentation is
configured for the WinForms application. It does not automate the folder picker
or the other CLI commands.
