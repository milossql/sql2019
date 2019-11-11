# Optimize for sequential key
1. create database OSK
2. execute the Setup.sql
3. copy all files in a local folder (ensure that ostress.exe file is also there)
4. execute c.cmd and check execution statistics (insert into normal table) OFF
5. execute c_opt.cmd and check execution statistics (insert into optimized table) ON
6. execute c_both.cmd and check execution statistics (insert into both tables) ON*
##My results average excution time

option | average execution time
------------ | -------------
OFF | 21.45 ms
ON |  13.25 ms
OFF* |  22.28 ms
ON* |  2.93 ms

