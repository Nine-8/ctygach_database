create database SanXuat
--drop database SanXuat
go
use SanXuat 
go
create table Loai_VT(
	MaLoai char(5) not null,
	TenLoai nvarchar(20)
	primary key( MaLoai)
)
go
create table Vat_Tu(
Ma_VT char(5),
SoLuongTon int,
LoaiVT char(5) not null,
GiaNhap money
primary key(Ma_VT)
)
go
create table ThanhPham(
	Ma_ThanhPham VARCHAR(50),
	TenThanhPham nvarchar(30),
	DonGia money,
	SoLuongTon int
	primary key(Ma_ThanhPham)
	)
go
create table SanPham_NguyenLieu
(
	Ma_ThanhPham VARCHAR(50),--char(5),
	STT int,
	VatTuCan char(5) not null,
	SoLuong_NL int
	primary key(Ma_ThanhPham,STT)
)
go
--create table Loai_NhaMay
--(
--	MaLoai char(5),
--	Ten_NhaMay nvarchar(50)
--	primary key(MaLoai)
--)
go
create table NhaMay
(
	Ma_NhaMay VARCHAR(50),--char(5),
	Ten_NhaMay nvarchar(30),
	Loai_NhaMay nvarchar(30),
	DiaChi nvarchar(50),
	primary key(Ma_NhaMay)
)
go
create table KeHoach_SX
(
	Ma_KH char(5),
	ThanhPham char(5),
	NgaySanXuat date,
	NhaMay char(5),
	SoLuong_KHSX int
	primary key(Ma_KH)
)
go
create table DonHang_SanXuat
(
	Ma_DHSX char(5),
	Ma_KhachHang char(5),
	MatHang VARCHAR(50),--char(5),
	SoLuong_Dat int,
	NgayDat date,
	NgayGiao date
	primary key(Ma_DHSX)
)
go

ALTER TABLE NhaMay
	ALTER COLUMN Loai_NhaMay VARCHAR(20) NOT NULL;
--ALTER TABLE KeHoach_SX
--	ALTER COLUMN Ma_KH VARCHAR(50) NOT NULL;
ALTER TABLE KeHoach_SX
	ALTER COLUMN ThanhPham VARCHAR(50) NOT NULL;
ALTER TABLE KeHoach_SX
	ALTER COLUMN NhaMay VARCHAR(50) NOT NULL;

alter table DonHang_SanXuat add
	constraint FK_DonHang_SanXuat_ThanhPham foreign key(MatHang) references ThanhPham(Ma_ThanhPham)

alter table  SanPham_NguyenLieu add
	constraint FK_SanPham_NguyenLieu_Vat_Tu foreign key(VatTuCan) references Vat_Tu(Ma_VT),
	constraint FK_SanPham_NguyenLieu_Thanh_Pham foreign key(Ma_ThanhPham) references ThanhPham(Ma_ThanhPham)

alter table Vat_Tu add
	constraint FK_Vat_Tu_Loai_VT foreign key(LoaiVT) references Loai_VT(MaLoai)
--alter table NhaMay add	constraint FK_NhaMay_Loai_NhaMay foreign key(Loai_NhaMay) references Loai_NhaMay(MaLoai)
alter table KeHoach_SX add
	constraint FK_KeHoach_SX_ThanhPham foreign key(ThanhPham) references ThanhPham(Ma_ThanhPham),
	constraint FK_KeHoach_SX_NhaMay foreign key(NhaMay) references NhaMay(Ma_NhaMay)
go

--IF (OBJECT_ID('sp_KiemTraSanXuatTheoNgay') IS NOT NULL) DROP PROC sp_KiemTraSanXuatTheoNgay

create proc sp_KiemTraSanXuatTheoNgay @Date date
as
begin tran
begin try
	if(@Date is null)
	begin 
		rollback tran
		return -1
	end
	select * from KeHoach_SX as KH where KH.NgaySanXuat=@Date
	end try
	begin catch
		rollback tran
		return -1
	end catch
commit tran
go

--IF (OBJECT_ID('sp_KiemTraSanXuatTheoTungNgay') IS NOT NULL) DROP PROC sp_KiemTraSanXuatTheoTungNgay
create proc sp_KiemTraSanXuatTheoTungNgay
as
begin tran
	select * from KeHoach_SX as KH order by KH.NgaySanXuat DESC-- sắp xếp theo ngày sản xuất giảm dần
commit tran
go

--IF (OBJECT_ID('sp_KiemTraSanXuatTheoMatHang') IS NOT NULL) DROP PROC sp_KiemTraSanXuatTheoMatHang
create proc sp_KiemTraSanXuatTheoMatHang @MatHang nvarchar(30)
as
begin tran
	begin try
		if(@MatHang is null)
		begin 
			rollback tran
			return -1
		end
		declare @MaSP char(5)
		if(not exists( select * from ThanhPham where ThanhPham.TenThanhPham =@MatHang))
		begin
			rollback tran
			return -1
		end
		select @MaSP=ThanhPham.Ma_ThanhPham from ThanhPham where ThanhPham.TenThanhPham =@MatHang
		select * from KeHoach_SX as KH where KH.ThanhPham=@MaSP order by KH.NgaySanXuat DESC-- sắp xếp theo ngày sản xuất giảm dần
	end try
	begin catch
		rollback tran
		return -1
	end catch
commit tran
go

--IF (OBJECT_ID('sp_KiemTraSanXuatTheoTungMatHang') IS NOT NULL) DROP PROC sp_KiemTraSanXuatTheoTungMatHang
create proc sp_KiemTraSanXuatTheoTungMatHang
as
begin tran
	Select * 
	from KeHoach_SX as KH 
	order by KH.ThanhPham ASC, KH.NgaySanXuat DESC-- sắp xếp theo thứ tự tăng dần của mặt hàng và ngày sản xuất giảm dần
commit tran
go

--IF (OBJECT_ID('sp_KiemTraSanXuatTheoKy') IS NOT NULL) DROP PROC sp_KiemTraSanXuatTheoKy
--create proc sp_KiemTraSanXuatTheoKy @Start_Date date,@End_Date date
--as
--begin tran
--	begin try
--	if(@Start_Date is null)
--	begin 
--		rollback tran
--		return -1
--	end
--	select * from KeHoach_SX as KH where KH.NgaySanXuat between @Start_Date and @End_Date
--	end try
--	begin catch
--		rollback tran
--		return -1
--	end catch
--commit tran
--go

--IF (OBJECT_ID('sp_NoiDungMatHangTonKho') IS NOT NULL) DROP PROC sp_NoiDungMatHangTonKho
--create proc sp_NoiDungMatHangTonKho @MaMatHang char(5)
--as
--begin tran
--	begin try
--	if(@MaMatHang is null)
--	begin
--		rollback tran
--		return -1
--	end
--	Select * from ThanhPham as TP where TP.Ma_ThanhPham=@MaMatHang
--	end try
--	begin catch
--		rollback tran
--		return -1
--	end catch
--commit tran 

--them du lieu bang loai vat tu
insert into Loai_VT(MaLoai,TenLoai) values('L_01','cat')
insert into Loai_VT(MaLoai,TenLoai) values('L_02','da mat')
insert into Loai_VT(MaLoai,TenLoai) values('L_03','xi mang')
insert into Loai_VT(MaLoai,TenLoai) values('L_04','nuoc')
insert into Loai_VT(MaLoai,TenLoai) values('L_05','dat set')

--them du lieu ban vat tu
insert into Vat_Tu(Ma_VT,SoLuongTon,LoaiVT,GiaNhap) values('C01','5','L_01','220000')
insert into Vat_Tu(Ma_VT,SoLuongTon,LoaiVT,GiaNhap) values('C02','4','L_02','140000')
insert into Vat_Tu(Ma_VT,SoLuongTon,LoaiVT,GiaNhap) values('C03','10','L_03','78000')
insert into Vat_Tu(Ma_VT,SoLuongTon,LoaiVT,GiaNhap) values('C05','5','L_05','')

--them du lieu bang thanh pham
insert into ThanhPham(Ma_ThanhPham,TenThanhPham,DonGia,SoLuongTon) values ('TP_01','Gach block so 8','9000','10000')
insert into ThanhPham(Ma_ThanhPham,TenThanhPham,DonGia,SoLuongTon) values ('TP_02','Gach block 8 lo','6800','20000')
insert into ThanhPham(Ma_ThanhPham,TenThanhPham,DonGia,SoLuongTon) values ('TP_03','Gach 2 lo','1100','10000')
insert into ThanhPham(Ma_ThanhPham,TenThanhPham,DonGia,SoLuongTon) values ('TP_04','Gach 6 lo','2900','50000')

--them du lieu bang san pham nguyen lieu
insert into SanPham_NguyenLieu(Ma_ThanhPham,STT,VatTuCan,SoLuong_NL) values('TP_04',1,'C05',2)
--select * from SanPham_NguyenLieu
--them du lieu bang nha may
insert into NhaMay(Ma_NhaMay,Ten_NhaMay,Loai_NhaMay,DiaChi) values('NM_1','Nha may 1','gach block so 8','212 to ky q12 TP.HCM')
insert into NhaMay(Ma_NhaMay,Ten_NhaMay,Loai_NhaMay,DiaChi) values('NM_2','Nha may 2','gach block 8 lo','111 le van viet q9 TP.HCM')
insert into NhaMay(Ma_NhaMay,Ten_NhaMay,Loai_NhaMay,DiaChi) values('NM_3','Nha may 3','gach 2 lo','80 au co tan phu TP.HCM')
insert into NhaMay(Ma_NhaMay,Ten_NhaMay,Loai_NhaMay,DiaChi) values('NM_4','Nha may 4','gach 6 lo','12 le van chi thu duc TP.HCM')

--them du lieu ban ke hoach san xuat
insert into KeHoach_SX(Ma_KH,ThanhPham,NgaySanXuat,NhaMay,SoLuong_KHSX) values('KH_1','TP_03','5/6/2019','NM_3','10000')
insert into KeHoach_SX(Ma_KH,ThanhPham,NgaySanXuat,NhaMay,SoLuong_KHSX) values('KH_2','TP_01','7/22/2019','NM_1','6000')

--them du lieu bang don hang san xuat
insert into DonHang_SanXuat(Ma_DHSX,Ma_KhachHang,MatHang,SoLuong_Dat,NgayDat,NgayGiao) values('DH_01','KH_01','TP_03','20000','5/6/2019','5/14/2019')
insert into DonHang_SanXuat(Ma_DHSX,Ma_KhachHang,MatHang,SoLuong_Dat,NgayDat,NgayGiao) values('DH_02','KH_02','TP_01','16000','7/22/2019','7/30/2019')


go
create proc sp_thanhpham (@ma_TP char(10),
					  @tentp nvarchar(30),
					  @dongia money,
					  @soluongton int,
					  @sql nvarchar(20)='')
as
begin
	--thuc thi insert
	if(@sql = 'insert')
	begin
	insert into ThanhPham(Ma_ThanhPham,TenThanhPham,DonGia,SoLuongTon) values(@ma_TP,@tentp,@dongia,@soluongton)
	end

	--thuc thi update
	if(@sql = 'update')
	begin
	update ThanhPham set
	TenThanhPham = @tentp,
	DonGia = @dongia,
	SoLuongTon = @soluongton
	where Ma_ThanhPham = @ma_TP
	end

	--thuc thi delete
	if(@sql ='delete')
	begin
		delete from ThanhPham where Ma_ThanhPham = @ma_TP
	end
end

go
--PROCEDURE THÊM SẢN PHẨM NGUYÊN LIỆU
--drop proc sp_ThemSanPham_NguyenLieu
create proc sp_ThemSanPham_NguyenLieu (@MaThanhPham varchar(50),@VatTuCan char(5),@SoLuong int)
as
begin 
	begin tran
	begin try
		if(@MaThanhPham is null or @VatTuCan is null or @SoLuong is null)
		begin
			print N'Thong Tin null'
			rollback tran
			return
		end
		if(not exists(select * from ThanhPham tp where tp.Ma_ThanhPham=@MaThanhPham))--Kiểm tra MaThanhPham tồn tại
		begin
		print N'Thành phẩm không tồn tại'
			rollback tran
			return
		end
		if(not exists(select * from Vat_Tu vt where vt.Ma_VT=@VatTuCan))--Kiểm tra VatTuCan tồn tại
		begin
		print N'Vật tư không tồn tại'
			rollback tran
			return
		end
		declare @STT int-- Lấy tự động STT tiếp theo theo STT lớn nhất hiện có của Ma_ThanhPham
		if(not exists(select * from SanPham_NguyenLieu as NL where NL.Ma_ThanhPham=@MaThanhPham))
		begin
			set @STT=1
		end
		else
		begin
		select @STT=(max(nl.STT)+1) from SanPham_NguyenLieu as nl where nl.Ma_ThanhPham=@MaThanhPham
		end
		print @STT
		insert into SanPham_NguyenLieu
		values(@MaThanhPham,@STT,@VatTuCan,@SoLuong)
	end try
	begin catch
		rollback tran
		return
	end catch
	commit tran
end
go
--PROCEDURE Cập nhật SẢN PHẨM_NGUYÊN LIỆU
create proc sp_CapNhatSanPham_NguyenLieu (@MaThanhPham varchar(50),@STT int,@VatTuCan char(5),@SoLuong int)
as
begin 
	begin tran
	begin try
		if(@MaThanhPham is null or @STT is null or @VatTuCan is null or @SoLuong is null)
		begin
			print N'Thông tin null'
			rollback tran
			return
		end
		--Kiểm tra SanPham_NguyenLieu cần thay đổi có tồn tại
		if(not exists(select * from SanPham_NguyenLieu nl where nl.Ma_ThanhPham=@MaThanhPham and nl.STT=@STT))
		begin
			print N'SanPhamNguyenLieu đã nhập không tồn tại'
			rollback tran
			return
		end
		if(not exists(select * from Vat_Tu vt where vt.Ma_VT=@VatTuCan))--Kiểm tra VatTuCan tồn tại
		begin
			print N'Vật tư thay đổi không tồn tại'
			rollback tran
			return
		end
		update SanPham_NguyenLieu set VatTuCan=@VatTuCan,SoLuong_NL=@SoLuong where Ma_ThanhPham=@MaThanhPham and STT=@STT
	end try
	begin catch
		rollback tran
		return
	end catch
	commit tran
end

go
--select * from SanPham_NguyenLieu
--select * from Vat_Tu
--exec sp_ThemSanPham_NguyenLieu 'TP_04','C03',2
--exec sp_CapNhatSanPham_NguyenLieu 'TP_04',1,'C03',3
go
--PROCEDURE Thêm Vât tư
create proc sp_ThemVatTu @MaVT char(5),@Soluongton int, @loaiVT char(5), @GiaNhap money
as
begin
	begin tran
		begin try
			if(@MaVT is null or @loaiVT is null or @GiaNhap is null)
			begin
				print N'Gia tri Null'
				rollback tran
				return
			end
			if(exists(select * from Vat_Tu where Vat_Tu.Ma_VT=@MaVT))
			begin
				print N'MaVT đã có'
				rollback tran
				return
			end
			if(not exists(select * from Loai_VT L where L.MaLoai=@loaiVT))
			begin
				print N'Loại VT không tồn tại'
				rollback tran
				return
			end
			insert into Vat_Tu
			values(@MaVT,@Soluongton,@loaiVT,@GiaNhap)
		end try
		begin catch
			rollback tran
			return
		end catch
	commit tran
end
go
--select * from Vat_Tu
--exec sp_ThemVatTu 'C04',3,'L_01',3
go
-----------------------------TRIGGER-------------------------------------------
--update hang trong kho
create trigger trg_dathang on DonHang_SanXuat for insert,update
as
	begin
		SET XACT_ABORT ON
			begin tran
			update ThanhPham
				SET SoLuongTon = SoLuongTon - SoLuong_Dat
				from THANHPHAM a, DonHang_SanXuat b
				where a.Ma_ThanhPham = b.MatHang
			commit tran
		SET XACT_ABORT off
	end
go
--Ràng buộc số lượng tồn của vật tư không âm
create trigger trg_VatTu_Soluongton on Vat_Tu for insert,update
as
begin
	if((select SoLuongTon from inserted)<0)
	begin
		rollback tran
	end
end
go
--Ràng buộc số lượng Nguyên liệu cần trong SanPham_NguyenLieu >0
create trigger trg_SP_NguyenLieu_SoluongNL on SanPham_NguyenLieu for insert,update
as
begin
	if((select SoLuong_NL from inserted)<=0)
	begin
		rollback tran
	end
end
go
--Ràng buộc tên Nhà máy là duy nhất
create trigger trg_NhaMay on NhaMay for insert,update
as
begin
	if(exists(select * from NhaMay NM 
				where NM.Ten_NhaMay in(
				select Ten_NhaMay from inserted))
	begin
		print N'Tên Nhà Máy đã có'
		rollback tran
	end
end

GO
--select * from Vat_Tu
--select * from Loai_VT
--select * from SanPham_NguyenLieu
--select * from ThanhPham
--select * from DonHang_SanXuat
--select * from KeHoach_SX
--select * from NhaMay
go
---------------------------Function-------------------------------
create function fuThanhPham (@MaTP  varchar(50))
--Lấy ra tên của thành phẩm
returns nvarchar(30)
as
begin
	declare @ThanhPham_name nvarchar(30);
	select @ThanhPham_name=TenThanhPham from ThanhPham where Ma_ThanhPham=@MaTP
	return @ThanhPham_name;
end;
go
select * from ThanhPham
select dbo.fuThanhPham('TP_01')
go

---------------------------VIEW------------------------------------
CREATE VIEW VatTu_view AS
SELECT LoaiVT, GiaNhap
FROM Vat_Tu
go
--SELECT * FROM VatTu_view
go
Create view NhaMay_view as
select Ten_NhaMay,Loai_NhaMay,DiaChi
from NhaMay
where Ten_NhaMay='Nha may 1'
go
--SELECT * FROM NhaMay_view
go
Create view ThanhPham_view as
select TenThanhPham, DonGia, SoLuongTon
from ThanhPham
where DonGia >2000 
and SoLuongTon> 10000
go
--SELECT * FROM ThanhPham_view

go
Create view KHSX_view as
select Ma_KH, NgaySanXuat,SoLuong_KHSX
from KeHoach_SX
where SoLuong_KHSX >2000
go
--SELECT * FROM KHSX_view
-------------------------------Role------------------------
create login NV01 --drop login  NV01
	with password='nhanvien01'must_change,
	default_database=SanXuat,
	check_expiration=on,
	check_policy=on
create login NV02 --drop login  NV02
	with password='nhanvien03'must_change,
	default_database=SanXuat,
	check_expiration=on,
	check_policy=on
create login NV03 --drop login  NV03
	with password='nhanvien03'must_change,
	default_database=SanXuat,
	check_expiration=on,
	check_policy=on
create login NV04 --drop login  NV04
	with password='nhanvien04'must_change,
	default_database=SanXuat,
	check_expiration=on,
	check_policy=on
create login NV05 --drop login  NV05
	with password='nhanvien05'must_change,
	default_database=SanXuat,
	check_expiration=on,
	check_policy=on

create user NV01 for login NV01 -- drop user NV01
create user NV02 for login NV02 -- drop user NV02
create user NV03 for login NV03-- drop user NV03
create user NV04 for login NV04-- drop user NV04
create user NV05 for login NV05-- drop user NV05
go
create role employee
-- drop role employee
create role users
-- drop role users
go

--exec sp_droprolemember 'employee', 'NV01'
exec sp_addrolemember 'employee', 'NV01'
--exec sp_droprolemember 'employee', 'NV02'
exec sp_addrolemember 'employee', 'NV02'
--exec sp_droprolemember 'users', 'NV03'
exec sp_addrolemember 'users', 'NV03'
go