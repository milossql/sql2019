# Optimize for sequential key
1. execute the code from the 00Setup.sql file
2. ensure that Query Store is turned on
3. execute c1.cmd (insert into normal table) OFF
4. execute c2.cmd (insert into optimized table) ON
5. execute c3.cmd (insert into both tables) ON*
6. check the results in Query Store


##My results average excution time

option | average execution time
------------ | -------------
OFF | 16.478 ms
ON |  11.933 ms
OFF* |  17.123 ms
ON* |  2.684 ms
 
