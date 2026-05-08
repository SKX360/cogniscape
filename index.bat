@echo off
setlocal enabledelayedexpansion

set "RootFolder=%~1"
if "%RootFolder%"=="" set "RootFolder=%CD%"

if not exist "%RootFolder%\" (
    echo The specified path "%RootFolder%" does not exist or is not a directory.
    exit /b 1
)

set "OutputFile=%RootFolder%\index.html"
set "TempFile=%RootFolder%\~temp_pdfs.txt"

pushd "%RootFolder%"

rem === HTML Header ===
(
    echo ^<!DOCTYPE html^>
    echo ^<html lang="en"^>
    echo ^<head^>
    echo     ^<meta charset="UTF-8"^>
    echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
    echo     ^<title^>Document Index^</title^>
    echo     ^<style^>
    echo         body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
    echo         h2, h3, h4, h5, h6 { margin-top: 30px; color: #333; }
    echo         a { text-decoration: none; color: #0066cc; }
    echo         a:hover { text-decoration: underline; }
    echo         ul { list-style-type: none; padding-left: 20px; }
    echo     ^</style^>
    echo ^</head^>
    echo ^<body^>
    echo ^<h1^>Document Index^</h1^>
) > "%OutputFile%"

rem === Collect all PDFs ===
(
    for /r %%F in (*.pdf) do (
        set "Full=%%~fF"
        set "Rel=!Full:%RootFolder%\=!"
        echo !Rel!
    )
) > "%TempFile%" 2>nul

sort "%TempFile%" /o "%TempFile%"

set "LastFolder="

for /f "usebackq delims=" %%L in ("%TempFile%") do (
    set "RelPath=%%L"
    echo !RelPath! | findstr /i "\\\.git\\" >nul && continue

    rem Relative folder path (from current folder)
    for %%A in ("!RelPath!") do set "Folder=%%~dpA"
    set "Folder=!Folder:~0,-1!"
    set "FileName=%%~nL"

    rem Folder Title (full relative path, nice formatting)
    set "FolderTitle=!Folder!"
    set "FolderTitle=!FolderTitle:_= !"
    call :TitleCase FolderTitle

    rem Heading level
    if "!Folder!"=="" (
        set "Level=2"
        set "FolderTitle=Root"
    ) else (
        set "Level=2"
        set "Temp=!Folder!"
        set "BS=0"
        :Count
        set "Temp=!Temp:\= !"
        for %%x in (!Temp!) do set /a BS+=1
        set /a Level=2 + BS
    )

    rem Write new heading when folder changes
    if not "!Folder!"=="!LastFolder!" (
        if not "!LastFolder!"=="" echo ^</ul^> >> "%OutputFile%"
        echo ^<h!Level!^>!FolderTitle!^</h!Level!^> >> "%OutputFile%"
        echo ^<ul^> >> "%OutputFile%"
        set "LastFolder=!Folder!"
    )

    rem File display name
    set "Display=!FileName!"
    set "Display=!Display:_= !"
    call :TitleCase Display

    rem Link with relative path
    echo     ^<li^>^<a href="!RelPath!"^>!Display!^</a^>^</li^> >> "%OutputFile%"
)

if not "!LastFolder!"=="" echo ^</ul^> >> "%OutputFile%"

(
    echo ^</body^>
    echo ^</html^>
) >> "%OutputFile%"

del "%TempFile%" 2>nul
popd

echo.
echo Done! Generated: %OutputFile%
pause
endlocal
goto :EOF

:TitleCase
set "str=!%1!"
set "result="
for %%w in (!str!) do (
    set "word=%%w"
    set "first=!word:~0,1!"
    set "rest=!word:~1!"
    set "result=!result! !first!!rest!"
)
set "result=!result:~1!"
set "%1=!result!"
goto :EOF