:: encoding="Cp850"
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROGRAM ®head¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::    Outputs first lines of a text file.
::    
:: USAGE:
::    head ®number of lines¯ ®file¯
::
:: DEPENDENCIES: :findOutInstall :parseParameters
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@ECHO OFF
SETLOCAL EnableDelayedExpansion
:::::::::::::::::::::::::::::::::: PREPROCESS ::::::::::::::::::::::::::::::::::
:: This variable will be used to manage the final ERRORLEVEL of the program.
SET errLvl=0

CALL :findOutInstall "%~0" rootDir
CALL :parseParameters %*
SET errLvl=%ERRORLEVEL%
IF "%errLvl%" NEQ "0" (
 	GOTO :exit
)

::TODO: Somehow, verify that param.numberOfLines is numeric.

IF NOT EXIST "%param.file%" (
    ECHO [ERROR]: File "%param.file%" does NOT exist.
    SET errLvl=1
    GOTO :exit
)

IF EXIST "%param.file%\" (
    ECHO [ERROR]: "%param.file%" is NOT a file, is a directory.
    SET errLvl=1
    GOTO :exit
)

:::::::::::::::::::::::::::::::::::: PROCESS :::::::::::::::::::::::::::::::::::
:: Loads the file in a collection of variables that conform an array-like 
:: structure. The array index starts at 1 because it makes everything much 
:: easier.
SET lineNumber=0
FOR /F tokens^=*^ delims^=^ eol^= %%i IN ('FINDSTR /N /R "^" "%param.file%"') DO (
    SET /A "lineNumber += 1"

    SET line=%%i
    IF "!line!" == "!line:ª=!" (
        REM SET lines[!lines.length!].delim=ª
        ::TODO: Refactor this, for the gods shake.
        IF !lineNumber! LSS 10 (
            SET lines[!lineNumber!]=!line:~2!
        ) ELSE IF !lineNumber! LSS 100 (
            SET lines[!lineNumber!]=!line:~3!
        ) ELSE IF !lineNumber! LSS 1000 (
            SET lines[!lineNumber!]=!line:~4!
        )
    )
    REM TODO: Add other delimiters as needed.
)
SET lines.last=!lineNumber!

FOR /L %%i IN (1,1,!param.numberOfLines!) DO (
    CALL :doOutput "!lines[%%i]!"
)

GOTO :exit
:::::::::::::::::::::::::::::::::: POSTPROCESS :::::::::::::::::::::::::::::::::
:exit
EXIT /B %errLvl% & ENDLOCAL

:::::::::::::::::::::::::::::::::: SUBROUTINES :::::::::::::::::::::::::::::::::
:doOutput
IF "%~1" == "" (
    ECHO.
) ELSE (
    ECHO %~1
)

EXIT /B 0
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: BEGINNING: SUBROUTINE ®parseParameters¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::    Turns program actual parameters in environment variables that the program
:: can use.
::
:: USAGE: 
::    CALL :parseParameters %*
::
:: DEPENDENCIES: :showHelp
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:parseParameters
:: Since parameters can contain quotes and other string separators, it is 
:: not reliable to compare them with the empty string. Instead, a variable is 
:: set, and if it is defined afterwards, it means that something has been passed 
:: as parameter.
REM SET param.aux=%*
REM IF NOT DEFINED aux (
REM     ECHO [ERROR]: Missing required parameters.
REM     CALL :showHelp
REM     EXIT /B -1
REM )
REM SET param.aux=

SET param.numberOfLines=%~1
IF NOT DEFINED param.numberOfLines (
    ECHO [ERROR]: Missing {number of lines} parameter.
    CALL :showHelp
    EXIT /B -1
)

SET param.file=%~2
IF NOT DEFINED param.file (
    ECHO [ERROR]: Missing {file} parameter.
    CALL :showHelp
    EXIT /B -1
)

:: Following FOR syntax iterates over every space-delimitied command, allowing
:: to process them one at a time.
REM FOR %%i IN (%*) DO (
REM     IF "%%i" == "${Some parameter you expect}" (
REM         SET param.someFlag=true
REM     ) ELSE (
REM         ECHO [ERROR]: Unknown parameter "%%i".
REM         CALL :showHelp
REM         EXIT /B -1
REM     )
REM )

EXIT /B 0
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: END: SUBROUTINE ®parseParameters¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: BEGINNING: SUBROUTINE ®showHelp¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::    Displays the help file to the user.
::
:: USAGE: 
::    CALL :showHelp
::
:: DEPENDENCIES: NONE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:showHelp
TYPE "%rootDir%\help\help.txt"

EXIT /B 0
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: END: SUBROUTINE ®showHelp¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: BEGINNING: SUBROUTINE ®findOutInstall¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::    Computes the absolute path of the .bat passed as parameter. This 
:: subroutine helps identify the installation directory of .bat script which 
:: invokes it.
:: 
:: USAGE: 
::    CALL :findOutInstall "%~0" ®retVar¯
:: WHERE...
::    ®retVar¯: Name of a variable (existent or not) by means of which the 
::              directory will be returned.
::
:: DEPENDENCIES: :removeFileName
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:findoutInstall
SETLOCAL
SET retVar=%2

SET extension=%~x1
:: If the program is invoked without extension, it won't be found in the PATH. 
:: Adds the extension and recursively invokes :findoutInstall.
IF "%extension%" == "" (
	CALL :findOutInstall "%~1.bat" installDir
	GOTO :findOutInstall.end
) ELSE (
	SET installDir=%~$PATH:1
)

IF "%installDir%" EQU "" (
	SET installDir=%~f1
)

CALL :removeFileName "%installDir%" _removeFileName
SET installDir=%_removeFileName%

:findOutInstall.end
ENDLOCAL & SET %retVar%=%installDir%
EXIT /B 0
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: END: SUBROUTINE ®findOutInstall¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: BEGINNING: SUBROUTINE ®removeFileName¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::    Removes the file name from a path.
::
:: USAGE: 
::    CALL :removeFileName ®["]path["]¯ ®retVar¯
:: WHERE...
::    ®["]path["]¯: Path from which the file name is to be removed. If the path
::                  contains white spaces, it must be enclosed in double quotes.
::                  It is optional otherwise.
::    ®retVar¯:     Name of a variable (existent or not) by means of which the 
::                  directory will be returned.
::
:: DEPENDENCIES: NONE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:removeFileName
SETLOCAL
SET retVar=%2
SET path=%~dp1

PUSHD %path%
SET path=%CD%
POPD

ENDLOCAL & SET %retVar%=%path%
EXIT /B 0
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: END: SUBROUTINE ®removeFileName¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
