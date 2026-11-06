@echo off
setlocal

echo ==================================================================
echo   Karman Vortex Street Simulation Launcher
echo   GNU Octave / MATLAB DFG 2D-2 Benchmark (Re = 100)
echo ==================================================================
echo.

:: 1. Check if octave is in PATH
where octave >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "OCTAVE_BIN=octave"
    goto :RUN
)

:: 2. Check standard local installation path
set "OCTAVE_LOCAL=%LOCALAPPDATA%\Programs\GNU Octave\Octave-11.3.0\mingw64\bin\octave.exe"
if exist "%OCTAVE_LOCAL%" (
    set "OCTAVE_BIN=%OCTAVE_LOCAL%"
    goto :RUN
)

:: 3. Check Program Files fallback
for /d %%D in ("%ProgramFiles%\GNU Octave\Octave-*") do (
    if exist "%%D\mingw64\bin\octave.exe" (
        set "OCTAVE_BIN=%%D\mingw64\bin\octave.exe"
        goto :RUN
    )
)

echo [ERROR] GNU Octave was not found on PATH or in local programs.
echo Please install GNU Octave or add it to your system PATH.
pause
exit /b 1

:RUN
echo Found GNU Octave at: "%OCTAVE_BIN%"
echo Launching simulation script 'karman_vortex_street.m'...
echo.
"%OCTAVE_BIN%" --no-gui "karman_vortex_street.m"

if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUCCESS] Simulation completed. Outputs:
    echo   - karman_vortex_street.gif
    echo   - karman_vortex_street.mp4
) else (
    echo.
    echo [ERROR] Simulation exited with error code %ERRORLEVEL%.
)

echo.
pause
