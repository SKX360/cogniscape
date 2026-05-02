@echo off
setlocal enabledelayedexpansion

set "RootFolder=%~1"
if "%RootFolder%"=="" set "RootFolder=%CD%"

if not exist "%RootFolder%\" (
    echo The specified path "%RootFolder%" does not exist or is not a directory.
    exit /b 1
)

set "OutputFile=%RootFolder%\index.txt"
set "LatexFile=%RootFolder%\index.tex"

pushd "%RootFolder%"

rem Generate index.txt with plain relative paths (including .tex, using \)
(
    for /r %%F in (*.*) do (
        set "FullPath=%%~fF"
        set "RelativePath=!FullPath:%RootFolder%\=!"
        echo !RelativePath!
    )
) > "%OutputFile%"

rem Generate index.tex with \input{} lines (without .tex, using /)
(
    for /r %%F in (*.tex) do (
        set "FullPath=%%~fF"
        set "RelativePath=!FullPath:%RootFolder%\=!"
        set "RelativePath=!RelativePath:.tex=!"
        set "LatexPath=!RelativePath!"
        set "LatexPath=!LatexPath:\=/!"
        if /i not "!RelativePath!"=="index" (
            echo \input{!LatexPath!}
        )
    )
) > "%LatexFile%"

popd

echo Contents of %OutputFile%:
type "%OutputFile%"
echo.
echo Contents of %LatexFile%:
type "%LatexFile%"

endlocal