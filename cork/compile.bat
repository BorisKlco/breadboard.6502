REM compile Cork
@echo off
echo ca65:
C:\Users\klco\Downloads\cc65\bin\ca65.exe -D cork cork.s -o cork.o
echo ld65:
C:\Users\klco\Downloads\cc65\bin\ld65.exe -C cork.cfg cork.o -o cork.bin -Ln cork.lbl
echo ok
pause > nul