.\ostress -E -iosk_opt.sql -SAT03W00308\MSSQLSERVER02 -r100 -n300 -q
.\ostress -E -dSeqKey -Q"EXEC dbo.InsertMeasure 'c_opt'" -SAT03W00308\MSSQLSERVER02 -r1 -n1 -q