USE SeqKey;
GO
DROP TABLE IF EXISTS dbo.T0;
GO
CREATE TABLE dbo.T0(
	id bigint IDENTITY(1,1) NOT NULL,
	c1 smallint NOT NULL,
	c2 bigint NOT NULL,
	c3 bigint NULL,
	c4 nvarchar(128) NOT NULL,
	c6 int NOT NULL,
	c7 int NOT NULL,
	c8 nvarchar(256) NULL,
	c10 nvarchar(50) NOT NULL,
	c11 varchar(128) NOT NULL,
 CONSTRAINT PK_T0 PRIMARY KEY CLUSTERED (
	id ASC
)WITH (OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)  
)  
GO
DROP TABLE IF EXISTS dbo.T0_Opt;
GO
CREATE TABLE dbo.T0_Opt(
	id bigint IDENTITY(1,1) NOT NULL,
	c1 smallint NOT NULL,
	c2 bigint NOT NULL,
	c3 bigint NULL,
	c4 nvarchar(128) NOT NULL,
	c6 int NOT NULL,
	c7 int NOT NULL,
	c8 nvarchar(256) NULL,
	c10 nvarchar(50) NOT NULL,
	c11 varchar(128) NOT NULL,
 CONSTRAINT PK_T0_Opt PRIMARY KEY CLUSTERED (
	id ASC
)WITH (OPTIMIZE_FOR_SEQUENTIAL_KEY = ON)  
)  
GO
--stored procs
CREATE OR ALTER PROCEDURE dbo.P_T0
AS
INSERT INTO dbo.T0 ( c1, c2, c3, c4, c6, c7, c8, c10, c11)
	VALUES(2,56789,45454545,N'vfrtoglstenoPritzexYswc',3,3,N'wqew.jdkwqjfkewjkejr.ewewewew.DataAccess.tttwewesS.V2.ewwewew.ewew.ppewpeipw', N'kkk',N'xxxxxxxIdId: 2480918')
GO
CREATE OR ALTER PROCEDURE dbo.P_T0_Opt
AS
INSERT INTO dbo.T0_Opt ( c1, c2, c3, c4, c6, c7, c8, c10, c11)
	VALUES(2,56789,45454545,N'vfrtoglstenoPritzexYswc',3,3,N'wqew.jdkwqjfkewjkejr.ewewewew.DataAccess.tttwewesS.V2.ewwewew.ewew.ppewpeipw', N'kkk',N'xxxxxxxIdId: 2480918')
GO

CREATE OR ALTER PROCEDURE dbo.P_T0_Opt2
AS
INSERT INTO dbo.T0_Opt ( c1, c2, c3, c4, c6, c7, c8, c10, c11)
	VALUES(2,56789,45454545,N'vfrtoglstenoPritzexYswc',3,3,N'wqew.jdkwqjfkewjkejr.ewewewew.DataAccess.tttwewesS.V2.ewwewew.ewew.ppewpeipw', N'kkk',N'xxxxxxxIdId: 2480918')
GO