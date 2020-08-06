@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION



:PROCESS_CMD
    SET "utility_folder=%~dp0"
    CALL "%utility_folder%..\win-utils\setup.cmd" cecho vswhere

    SET help_val=false
    :LOOP
        SET current_arg=%1
        IF [%current_arg%] EQU [-h] (
            SET help_val=true
        )
        IF [%current_arg%] EQU [--help] (
            SET help_val=true
        )
        SHIFT
    IF NOT "%~1"=="" GOTO :LOOP

    IF [%help_val%] EQU [true] (
        CALL :SHOW_HELP
    ) ELSE (
        CALL :MAIN
        IF !ERRORLEVEL! NEQ 0 (
            EXIT /B !ERRORLEVEL!
        )
    )

    REM All changes to variables within this script, will have local scope. Only
    REM variables specified in the following block can propagates to the outside
    REM world (For example, a calling script of this script).
    ENDLOCAL & (
        SET "TOOLSET_MSBUILD_PATH=%msbuild_folder%"
        SET "PATH=%PATH%"
    )
EXIT /B 0



:MAIN
    FOR /f "usebackq tokens=*" %%i IN (`vswhere -latest -requires Microsoft.Component.MSBuild -property installationPath`) DO (
        SET installation_base_path=%%i
    )

    SET "msbuild_folder=%installation_base_path%\MSBuild\Current\Bin"
    IF EXIST "%msbuild_folder%" (
        IF "!PATH:%msbuild_folder%=!" EQU "%PATH%" (
            SET "PATH=%msbuild_folder%;%PATH%"
            CALL :SHOW_INFO "Utility added to system path."
        )
    ) ELSE (
        CALL :SHOW_ERROR "Unable to find the 'MSBuild' folder."
        CALL :SHOW_DETAIL "%msbuild_folder%"
        EXIT /B -1
    )
EXIT /B 0



:SHOW_INFO
    cecho {olive}[TOOLSET - UTILS - MSBUILD]{default} INFO: %~1{\n}
EXIT /B 0

:SHOW_DETAIL
    cecho {white}[TOOLSET - UTILS - MSBUILD]{default} DETAIL: %~1{\n}
EXIT /B 0

:SHOW_ERROR
    cecho {olive}[TOOLSET - UTILS - MSBUILD]{red} ERROR: %~1 {default} {\n}
EXIT /B 0



:SHOW_HELP
    SET "script_name=%~n0%~x0"
    ECHO #######################################################################
    ECHO #                                                                     #
    ECHO #                      T O O L   S E T U P                            #
    ECHO #                                                                     #
    ECHO #          Microsoft Build Engine, better known as 'MSBuild'.         #
    ECHO #                                                                     #
    ECHO # TOOL: MSBuild                                                       #
    ECHO #                                                                     #
    ECHO # USAGE:                                                              #
    ECHO #     %SCRIPT_NAME% [-h^|--help]                                           #
    ECHO #                                                                     #
    ECHO # EXAMPLES:                                                           #
    ECHO #     %script_name% --help                                                #
    ECHO #                                                                     #
    ECHO # ARGUMENTS:                                                          #
    ECHO #     -h^|--help    Print this help and exit.                          #
    ECHO #                                                                     #
    ECHO # EXPORTED ENVIRONMENT VARIABLES:                                     #
    ECHO #     TOOLSET_MSBUILD_PATH    The path where the msbuild is located.  #
    ECHO #                                                                     #
    ECHO #     PATH    This tool will export all local changes that it made to #
    ECHO #         the path's environment variable.                            #
    ECHO #                                                                     #
    ECHO #     The environment variables will be exported only if this tools   #
    ECHO #     executes without any error.                                     #
    ECHO #                                                                     #
    ECHO #######################################################################
EXIT /B 0