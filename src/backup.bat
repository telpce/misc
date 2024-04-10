set time2=%time: =0%
tar.exe -a -cf World%date:/=%%time2:~0,2%%time2:~3,2%%time2:~6,2%.zip World
timeout /t 2 > nul
