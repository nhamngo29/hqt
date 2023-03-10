CREATE DATABASE QL_THUENHA
ON PRIMARY
(
	NAME=QLTN_PRIMARY,
	FILENAME='F:\Desktop\NguyenNhamNgo_2001207130_27_01\QLTN_PRIMARYY.mdf',
	SIZE=5MB,
	MAXSIZE=10MB,
	FILEGROWTH=10%
)
LOG ON
(
	NAME=QLTN_LOG,
	FILENAME='F:\Desktop\NguyenNhamNgo_2001207130_27_01\QLTN_LOGG.ldf',
	SIZE=3MB,
	MAXSIZE=5MB,
	FILEGROWTH=15%
)
CREATE TABLE NHA
(
	MANHA INT IDENTITY PRIMARY KEY,
	SONHA INT,
	DUONG NVARCHAR(50),
	PHUONG NVARCHAR(50),
	QUAN NVARCHAR(50),
	TIENTHUE money,
	MOTA NVARCHAR(50),
	TINHTRANG INT
)
CREATE TABLE KHACHHANG
(
	MAKH INT IDENTITY PRIMARY KEY,
	HOTENKH NVARCHAR(50),
	NGAYSINH DATE,
	PHAI NVARCHAR(3),
	DIACHIA NVARCHAR(50),
	DTHOAI VARCHAR(11),
	KHANANGTHUE money
)
CREATE TABLE HOPDONG
(
	SOHD INT IDENTITY PRIMARY KEY,
	MANHA INT FOREIGN KEY REFERENCES NHA(MANHA),
	MAKH INT FOREIGN KEY REFERENCES KHACHHANG(MAKH),
	NGAYLAP DATE,
	NGAYBD DATE,
	THOIHANTHUE INT,
	TRIGIAHD money
)
alter TRIGGER TG_GIATRIHOPDONG ON HOPDONG
after INSERT
AS
	UPDATE HOPDONG
	SET TRIGIAHD=(select THOIHANTHUE*TIENTHUE from NHA where HOPDONG.MANHA=NHA.MANHA)
	WHERE SOHD=(select SOHD from inserted where HOPDONG.SOHD=inserted.SOHD)
INSERT INTO KHACHHANG
VALUES
(N'Nguyễn Nhâm Ngọ','20020902',N'Nam',N'20 Cộng hòa','0779442612',5000000),
(N'Đồng Minh Phương','20020902',N'Nam',N'69 Cộng hòa','0779442612',5000000),
(N'Nguyễn Đình Huy','20021212',N'Nam',N'20 Trường Chinh','0779442612',5000000)
INSERT INTO NHA
VALUES
(10,N'Cộng hòa',N'Phương 12',N'Tân Bình',90000,N'2 LẦU MỘT TRỆT',0),
(20,N'Cộng hòa',N'Phương 12',N'Tân Bình',100000,N'3 LẦU MỘT TRỆT',1),
(30,N'Cộng hòa',N'Phương 12',N'Tân Bình',200000,N'3 LẦU MỘT TRỆT',1)
INSERT INTO HOPDONG
VALUES
(1,1,GETDATE(),GETDATE(),10,null),
(2,2,GETDATE(),GETDATE(),12,null),
(3,3,GETDATE(),GETDATE(),24,null)
select * from NHA
select * from HOPDONG
delete HOPDONG
INSERT INTO HOPDONG
VALUES
(3,3,GETDATE(),GETDATE(),24,null)


---viết thủ tục nhập vào mã căn nhà,trả về số lượng hợp đồng đã thuê căn nhà đó. viết lệnh gọi thực hiện thủ tục.
CREATE PROC SP_Cau4 @MANHA int
AS
BEGIN 
	SELECT COUNT(*) FROM HOPDONG WHERE MANHA=@MANHA
END
EXECUTE SP_Cau4 
alter FUNCTION FN_Cau4(@MAKH int)
RETURNS @T_KQ TABLE (DiaChia nvarchar(200),TIENTHUE money)
AS
	BEGIN
		DECLARE @GIATHUE MONEY
		SET @GIATHUE=(SELECT KHANANGTHUE FROM KHACHHANG WHERE MAKH=@MAKH)
		insert into @T_KQ  SELECT (N'Số nhà '+CONVERT(varchar(5),SONHA)+N' Tên đường '+DUONG+N' Phường '+PHUONG+N' Quận'+QUAN),TIENTHUE FROM NHA WHERE TIENTHUE<=@GIATHUE
		RETURN
	END
select * from dbo.FN_Cau4(1)
--------tạo nhóm quyen------------
exec sp_addrole 'khachhang'
exec sp_addrole 'nhanvien'

grant select 
on nha(DUONG,PHUONG,QUAN,TIENTHUE)
to khachhang

grant select,insert,delete,update
on KHACHHANG
to nhanvien

grant select,insert,update
on nha
to nhanvien

grant select,insert
on hopdong
to nhanvien
---------tao dang nhap--------------
exec sp_addlogin 'lan','gauyeu'
exec sp_addlogin 'hong','thocon'
exec sp_addlogin 'cuc','cucdep'
---------tạo user tuong ung voi ten dang nhap va thuoc các nhom quyen
exec sp_adduser 'Lan','Lan','nhanvien'
exec sp_adduser 'Hong','Hong','khachhang'
exec sp_adduser 'Cuc','Cuc','khachhang'

--CẤM QUYỀN XÓA

DENY DELETE
ON --BẢNG
TO --USER


-----------------backup
--thời điểm t1: Full Backup
BACKUP DATABASE QL_THUENHA
TO DISK = 'F:\Desktop\NguyenNhamNgo_2001207130_27_01\Backup_Full.bak'
WITH INIT
-- THÊM MỘT BẢN GHI MỚI
INSERT INTO KHACHHANG
VALUES
(N'Đinh Thị Mẫn','19881212',N'Nữ',N'90 Cộng hòa','0779442612',5000000)
--thời điểm t2: Log Backup
BACKUP LOG QL_THUENHA
TO DISK = 'F:\Desktop\NguyenNhamNgo_2001207130_27_01\Backup_LOG1.trn'
WITH INIT
-- THÊM MỘT BẢN GHI MỚI
INSERT INTO KHACHHANG
VALUES
(N'Đăng văn trọng','20201997',N'Nam',N'90 Cộng hòa','0779442612',5000000)
--thời điểm t3: Differential backup
BACKUP database QL_THUENHA
TO DISK = 'F:\Desktop\NguyenNhamNgo_2001207130_27_01\Backup_Diff.bak'
WITH INIT,DIFFERENTIAL
-- THÊM MỘT BẢN GHI MỚI
INSERT INTO KHACHHANG
VALUES
(N'Đăng văn trọng','20201997',N'Nam',N'90 Cộng hòa','0779442612',5000000)
--thời điểm t4: Log Backup
BACKUP LOG QL_THUENHA
TO DISK = 'F:\Desktop\NguyenNhamNgo_2001207130_27_01\Backup_LOG2.trn'
WITH INIT
-- THÊM MỘT BẢN GHI MỚI
INSERT INTO KHACHHANG
VALUES
(N'Đăng văn trọng','20201997',N'Nam',N'90 Cộng hòa','0779442612',5000000)