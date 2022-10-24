-- 1. Trả về tên chi nhánh ngân hàng nếu biết mã của nó
	GO
	CREATE FUNCTION fpHW1 (@branchID VARCHAR(5))
	RETURNS NVARCHAR(50)
	AS
	BEGIN
		DECLARE @branchName NVARCHAR(50)
		SET @branchName = (SELECT BR_name FROM dbo.Branch WHERE BR_id = @branchID)
		RETURN @branchName
	END

	PRINT dbo.fHW4('VB001')
-- 2. Trả về tên, địa chỉ, sdt của khách hàng nếu biết mã khách
	GO 
	CREATE PROCEDURE pfHW2 @custID VARCHAR(6), @name NVARCHAR(50) OUT, @address NVARCHAR(150) OUT, @phone VARCHAR(15) OUT
	AS
	BEGIN
	    SET @name = (SELECT Cust_name FROM dbo.customer WHERE Cust_id = @custID)
		SET @address = (SELECT Cust_ad FROM dbo.customer WHERE Cust_id = @custID)
		SET @phone = (SELECT Cust_phone FROM dbo.customer WHERE Cust_id = @custID)
	END
	
	DECLARE @name NVARCHAR(50),
	        @address NVARCHAR(150),
	        @phone VARCHAR(15);
	EXECUTE dbo.pfHW2 @custID = '000002',               -- varchar(6)
	                  @name = @name OUTPUT,       -- nvarchar(50)
	                  @address = @address OUTPUT, -- nvarchar(150)
	                  @phone = @phone OUTPUT      -- varchar(15)

	PRINT @name; PRINT @address; PRINT @phone

-- 3. In ra danh sách khách hàng của một chi nhánh cụ thể nếu biết mã chi nhánh đó
	GO 
	CREATE PROCEDURE pfHW3 @branchID VARCHAR(6), @id VARCHAR(6) OUT, @name NVARCHAR(50) OUT
	AS
	BEGIN
	    DECLARE csHW3 CURSOR FOR (SELECT Cust_id, Cust_name FROM dbo.customer JOIN dbo.Branch ON Branch.BR_id = customer.Br_id WHERE Branch.BR_id = @branchID)
		OPEN csHW3
		FETCH NEXT FROM csHW3  INTO @id, @name

		WHILE @@FETCH_STATUS = 0
			BEGIN
				PRINT @id + REPLICATE(' ', 10) + @name
				FETCH NEXT FROM csHW3  INTO @id, @name
			END
		CLOSE csHW3
		DEALLOCATE csHW3
	END
	DROP PROCEDURE dbo.pfHW3
	DECLARE @id VARCHAR(6),
	        @name NVARCHAR(50);
	EXECUTE dbo.pfHW3 @branchID = 'VT011',      -- varchar(6)
	                  @id = @id OUTPUT,    -- varchar(6)
	                  @name = @name OUTPUT -- nvarchar(50)

-- 4. Kiểm tra thông tin khách hàng đã tồn tại trong hệ thống hay chưa nếu biết họ tên và số điện thoại. Tồn tại trả về 1, không tồn tại trả về 0.
	GO
	CREATE FUNCTION fpHW4 (@name NVARCHAR(50), @phone NUMERIC(15,0))
	RETURNS INT
	AS
	BEGIN
		DECLARE @ret INT
		SET @ret = 1

		IF	NOT EXISTS (SELECT Cust_name, Cust_phone FROM dbo.customer WHERE Cust_name = @name AND Cust_phone = @phone)
		BEGIN
			SET @ret = 0
		END

		RETURN @ret
    END

	PRINT dbo.fHW1('Lê Quang Phong', 01219688656)
 
-- 5. Cập nhật số tiền trong tài khoản nếu biết mã số tài khoản và số tiền mới. Thành công trả về 1, thất bại trả về 0
	GO 
	CREATE PROCEDURE pfHW5 @acc VARCHAR(10), @balance NUMERIC(15,0), @ret INT OUT 
	AS
    BEGIN
		SET @ret = 1
			UPDATE dbo.account SET ac_balance = @balance WHERE Ac_no = @acc
			IF @@ROWCOUNT < 0
				BEGIN
					SET @ret = 0
				END
		RETURN @ret
    END

	DECLARE @ret INT;
	EXECUTE dbo.pfHW5 @acc = '1000000001',         -- varchar(10)
	                  @balance = 10000,   -- numeric(15, 0)
	                  @ret = @ret OUTPUT -- int
	PRINT @ret

-- 6. Cập nhật địa chỉ của khách hàng nếu biết mã số của họ. Thành công trả về 1, thất bại trả về 0 
	GO 
	CREATE PROCEDURE pfHW6 @custID VARCHAR(6), @address NVARCHAR(150), @ret INT OUT
	AS
	BEGIN
		SET @ret = 1
	    UPDATE dbo.customer SET Cust_ad = @address WHERE Cust_id = @custID
		IF @@ROWCOUNT < 0
		BEGIN
		    SET @ret = 0
		END

		RETURN @ret
	END

	DECLARE @ret INT;
	EXECUTE dbo.pfHW6 @custID = '000001',      -- varchar(6)
	                  @address = N'NGUYỄN TIẾN DUẨN - THÔN 3 - XÃ DHÊYANG - EAHLEO - ĐĂKLĂK -- đã cập nhật',    -- nvarchar(150)
	                  @ret = @ret OUTPUT -- int
	PRINT @ret
		
-- 7. Trả về số tiền có trong tài khoản nếu biết mã tài khoản. 
	GO 
	CREATE FUNCTION fpHW6 (@acc VARCHAR(10))
	RETURNS NUMERIC(15,0)
	AS
    BEGIN
        DECLARE @balance NUMERIC(15,0)
		SET @balance = (SELECT ac_balance FROM dbo.account WHERE Ac_no = @acc)
		RETURN @balance
    END

	PRINT dbo.fHW6('1000000002')

-- 8. Trả về số lượng khách hàng, tổng tiền trong các tài khoản nếu biết mã chi nhánh. 
	GO 
	CREATE PROCEDURE pfHW8 @branchID VARCHAR(5), @count INT OUT, @sum INT OUT
	AS
	BEGIN
	    SET @count = (SELECT COUNT(customer.Cust_id) FROM dbo.customer JOIN dbo.account ON account.cust_id = customer.Cust_id WHERE Br_id = @branchID)
		SET @sum = (SELECT SUM(dbo.account.ac_balance) FROM dbo.customer JOIN dbo.account ON account.cust_id = customer.Cust_id WHERE Br_id = @branchID)
	END

	DECLARE @count INT,
	        @sum INT;
	EXECUTE dbo.pfHW8 @branchID = 'VT010',         -- varchar(5)
	                  @count = @count OUTPUT, -- int
	                  @sum = @sum OUTPUT      -- int
	PRINT @count; PRINT @sum

-- 9. Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút tiền diễn ra vào thời điểm 0am - 3am
	GO 
	CREATE FUNCTION fpHW8 (@transID VARCHAR(10))
	RETURNS NVARCHAR(50)
	AS
    BEGIN
		DECLARE @ret NVARCHAR(50)
		SET @ret = N'Giao dịch bình thường'

		IF @transID = (SELECT t_id FROM dbo.transactions WHERE t_id = @transID AND t_type = 1 AND t_time BETWEEN '11:00' AND '13:00' OR t_time BETWEEN '17:00' AND '07:00')
			BEGIN
				SET @ret = N'Giao dịch bất thường'
			END

		ELSE IF @transID = (SELECT t_id FROM dbo.transactions WHERE t_id = @transID AND t_type = 0 AND t_time BETWEEN '00:00' AND '03:00')
			BEGIN
				SET @ret = N'Giao dịch bất thường'
			END

		RETURN @ret
	END
	
	PRINT dbo.fpHW8('0000000226')

-- 10. Trả về mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau: Max(Mã giao dịch đang có) + 1. Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch
	GO
	CREATE FUNCTION fpHW10 ()
	RETURNS VARCHAR(10)
	AS
    BEGIN
		DECLARE @max INT, @temp VARCHAR(10), @newID VARCHAR(10)
		SET @max = (SELECT MAX(CAST(t_id AS INT)) FROM dbo.transactions)
		SET @temp = CAST(@max + 1 AS VARCHAR)
		SET @newID = REPLICATE('0', 10 - LEN(@temp)) + @temp

		RETURN @newID
	END

	PRINT dbo.fpHW10()
-- 13. Kiểm tra thông tin khách hàng đã tồn tại trong hệ thống hay chưa nếu biết họ tên và số điện thoại. Tồn tại trả về 1, không tồn tại trả về 0.
	GO
	CREATE FUNCTION fpHW13 (@name NVARCHAR(50), @phone NUMERIC(15,0))
	RETURNS INT
	AS
	BEGIN
		DECLARE @ret INT
		SET @ret = 1

		IF	NOT EXISTS (SELECT Cust_name, Cust_phone FROM dbo.customer WHERE Cust_name = @name AND Cust_phone = @phone)
		BEGIN
			SET @ret = 0
		END

		RETURN @ret
    END

	PRINT dbo.fpHW13('Lê Quang Phong', 01219688656)

-- 14. Tính mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau: Max(Mã giao dịch đang có) + 1. Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch
	GO
	CREATE FUNCTION fpHW14 ()
	RETURNS VARCHAR(10)
	AS
    BEGIN
		DECLARE @max INT, @temp VARCHAR(10), @newID VARCHAR(10)
		SET @max = (SELECT MAX(CAST(t_id AS INT)) FROM dbo.transactions)
		SET @temp = CAST(@max + 1 AS VARCHAR)
		SET @newID = REPLICATE('0', 10 - LEN(@temp)) + @temp

		RETURN @newID
	END

	PRINT dbo.fpHW14()

-- 15. Tính mã tài khoản mới
	GO
	CREATE FUNCTION fpHW15 ()
	RETURNS VARCHAR(10)
	AS 
	BEGIN
	    DECLARE @max INT, @newAcc VARCHAR(10)
		SET @max = (SELECT MAX(CAST(Ac_no AS int)) FROM dbo.account)
		SET @newAcc = @max + 1
		
		RETURN @newAcc
	END
	
	PRINT dbo.fpHW15()

-- 16. Trả về tên chi nhánh ngân hàng nếu biết mã của nó
	GO
	CREATE FUNCTION fpHW16 (@branchID VARCHAR(5))
	RETURNS NVARCHAR(50)
	AS
	BEGIN
		DECLARE @branchName NVARCHAR(50)
		SET @branchName = (SELECT BR_name FROM dbo.Branch WHERE BR_id = @branchID)
		RETURN @branchName
	END

	PRINT dbo.fpHW16('VB001')

-- 17. Trả về tên của khách hàng nếu biết mã khách
	GO
	CREATE FUNCTION fpHW17 (@custID VARCHAR(6))
	RETURNS NVARCHAR(50)
	AS
    BEGIN
		DECLARE @custName NVARCHAR(50)
		SET @custName = (SELECT Cust_name FROM dbo.customer WHERE Cust_id = @custID)
		RETURN @custName
	END

	PRINT dbo.fpHW17('000001')

-- 18. Trả về số tiền trong tài khoản nếu biết mã tài khoản
	GO 
	CREATE FUNCTION fpHW18 (@acc VARCHAR(10))
	RETURNS NUMERIC(15,0)
	AS
    BEGIN
        DECLARE @balance NUMERIC(15,0)
		SET @balance = (SELECT ac_balance FROM dbo.account WHERE Ac_no = @acc)
		RETURN @balance
    END

	PRINT dbo.fpHW18('1000000001')

-- 19. Trả về số lượng khách hàng nếu biết mã chi nhánh
	GO 
	CREATE FUNCTION fpHW19 (@branchID VARCHAR(5))
	RETURNS INT
	AS
    BEGIN
        DECLARE @count INT
		SET @count = (SELECT COUNT(Cust_id) FROM dbo.customer JOIN dbo.Branch ON Branch.BR_id = customer.Br_id WHERE Branch.BR_id = @branchID)
		RETURN @count
    END

	PRINT dbo.fpHW19('VB001')

-- 20. Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút tiền diễn ra vào thời điểm 0am - 3am
	GO 
	CREATE FUNCTION fpHW20 (@transID VARCHAR(10))
	RETURNS NVARCHAR(50)
	AS
    BEGIN
		DECLARE @ret NVARCHAR(50)
		SET @ret = N'Giao dịch bình thường'

		IF @transID = (SELECT t_id FROM dbo.transactions WHERE t_id = @transID AND t_type = 1 AND t_time BETWEEN '11:00' AND '13:00' OR t_time BETWEEN '17:00' AND '07:00')
			BEGIN
				SET @ret = N'Giao dịch bất thường'
			END

		ELSE IF @transID = (SELECT t_id FROM dbo.transactions WHERE t_id = @transID AND t_type = 0 AND t_time BETWEEN '00:00' AND '03:00')
			BEGIN
				SET @ret = N'Giao dịch bất thường'
			END

		RETURN @ret
	END
	
	PRINT dbo.fpHW20('0000000226')

-- 21. Tạo mã khách hàng tự động. Module có chức năng tạo và trả về mã khách hàng mới bằng cách lấy Max(Mã khách hàng cũ) + 1
	GO 
	CREATE FUNCTION fpHW21 ()
	RETURNS VARCHAR(6)
	AS
    BEGIN
        DECLARE @max INT, @temp VARCHAR(6), @newsID VARCHAR(6)
		SET @max = (SELECT MAX(CAST(Cust_id AS int)) FROM dbo.customer)
		SET @temp = CAST(@max + 1 AS VARCHAR)
		SET @newsID = REPLICATE('0', 6 - LEN(@temp)) + @temp

		RETURN @newsID
    END
	PRINT dbo.fpHW21()

-- 22. Tạo mã chi nhánh tự động (có thuật toán của mmodule)
	GO 
	CREATE FUNCTION fpHW22 (@branchID VARCHAR(5))
	RETURNS VARCHAR(5)
	AS
    BEGIN
        DECLARE @newBranchID VARCHAR(5), @iMax INT, @temp VARCHAR(5)
		IF LEFT(@branchID, 2) LIKE '_[B,T,N]%'
		BEGIN
		    SET @iMax = (SELECT	MAX(CAST(RIGHT(BR_id, 3) AS INT)) FROM dbo.Branch WHERE BR_id = @branchID)
			SET @temp = CAST(@iMax + 1 AS VARCHAR)
			SET @newBranchID = LEFT(@branchID, 2) + REPLICATE('0', 3 - LEN(@temp)) + @temp
		END

		ELSE
		BEGIN
		    SET @newBranchID = LEFT(@branchID, 2) + '001'
		END

		RETURN @newBranchID
    END

	PRINT dbo.fpHW22('VM001')