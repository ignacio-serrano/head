:: encoding="Cp850"
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PROGRAM ®test¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::    Builds and runs automatic tests in the project directory.
::
:: USAGE:
::    test
::
:: DEPENDENCIES: :findOutInstall :runTest
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@ECHO OFF
SETLOCAL EnableDelayedExpansion
:::::::::::::::::::::::::::::::::: PREPROCESS ::::::::::::::::::::::::::::::::::
:: This variable will be used to manage the final ERRORLEVEL of the program.
SET errLvl=0

CALL :findOutInstall "%~0" rootDir

:::::::::::::::::::::::::::::::::::: PROCESS :::::::::::::::::::::::::::::::::::
IF NOT EXIST "%rootDir%\target" (
    MD "%rootDir%\target"
)
IF NOT EXIST "%rootDir%\target\test" (
    MD "%rootDir%\target\test"
)


FOR /F %%i IN ('DIR /B /A:D "%rootDir%\src\test"') DO (
    CALL :runTest %%i
    SET testErrLvl=!ERRORLEVEL!
    IF !testErrLvl! GTR 0 (
        SET errLvl=!testErrLvl!
        ECHO %%i FAILED
    ) ELSE (
        ECHO %%i ok
    )
)
:::::::::::::::::::::::::::::::::: POSTPROCESS :::::::::::::::::::::::::::::::::
:exit

EXIT /B %errLvl% & ENDLOCAL

:::::::::::::::::::::::::::::::::: SUBROUTINES :::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: BEGINNING: SUBROUTINE ®runTest¯
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::    Runs a test located under src\test. First calls the prepare-test.bat to
:: set the number of lines to display. Then runs head. Then compares
:: the output with the content of the expected-output.txt file.
:: 
:: USAGE: 
::    CALL :runTest ®testDir¯
:: WHERE...
::    ®testDir¯: Name of a directory under src\test.
::
:: DEPENDENCIES: NONE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:runTest
SETLOCAL EnableDelayedExpansion

::TODO: It wouldn't harm to check that the directory actually contains a 
:: prepare-test.bat and expected-output.txt files.

::TODO: It would be better to completely avoid setting variables within this 
:: subroutine. They may conflict with the environment changes made by 
:: prepare-test.bat and with other variables used by the program being tested.

:: The directory name is used to compose the names of temporary files in the 
:: target directory.
SET testName=%~1

:: Sets the number of lines to "behead" for this test.
CALL "%rootDir%\src\test\%testName%\prepare-test.bat"

:: Runs head, capturing its output in a file.
>"%rootDir%\target\test\%testName%.output.txt" CALL "%rootDir%\src\main\head.bat" %numberOfLines% "%rootDir%\src\test\%testName%\test-file.txt"
SET errLvl=%ERRORLEVEL%
IF %errLvl% NEQ 0 (
    ECHO Error running head.bat %numberOfLines% "%testName%\test-file.txt"
    EXIT /B %errLvl% & ENDLOCAL
)

:: Compares the contents of that file with those of expected-output.txt. If 
:: the contents aren't identical, FC will set an ERRORLEVEL. The output of FC 
:: is written to a file so in case the test fails, give some more information 
:: as of why.
>"%rootDir%\target\test\%testName%.comparison.txt" FC "%rootDir%\src\test\%testName%\expected-output.txt" "%rootDir%\target\test\%testName%.output.txt"
SET errLvl=%ERRORLEVEL%
IF %errLvl% GTR 0 (
    TYPE "%rootDir%\target\test\%testName%.comparison.txt"
)

:: Returns FCs ERRORLEVEL to signal the calling code that the test ended in 
:: failure.
EXIT /B %errLvl% & ENDLOCAL
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: END: SUBROUTINE ®runTest¯
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
