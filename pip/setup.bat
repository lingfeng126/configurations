@echo off
REM Replace pip config in Windows environment

REM Set path for the pip config file
set PIP_CONFIG_PATH=%APPDATA%\pip\pip.ini

REM Set path for the new pip config file
set NEW_CONFIG_PATH=.\pip.ini

REM Check if the pip config folder exists
if not exist "%APPDATA%\pip" (
	    echo Creating pip config folder...
		    mkdir "%APPDATA%\pip"
			)

			REM Check if a current pip config file exists, back it up if needed
			if exist "%PIP_CONFIG_PATH%" (
				    echo Backing up existing pip config...
					    move "%PIP_CONFIG_PATH%" "%PIP_CONFIG_PATH%.bak"
						)

						REM Copy new pip config to the target location
						echo Replacing pip config with new file...
						copy "%NEW_CONFIG_PATH%" "%PIP_CONFIG_PATH%"

						REM Confirm operation success
						if exist "%PIP_CONFIG_PATH%" (
							    echo Pip configuration replaced successfully.
								) else (
									    echo Failed to replace pip configuration.
										)

										pause
										
								)
						)
			)
)

REM Open the pip config directory in Windows Explorer
echo Opening pip config directory...
explorer "%APPDATA%\pip"

pause
