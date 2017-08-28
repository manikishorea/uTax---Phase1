USE [master]
GO
/****** Object:  Database [EMPDB_uTax_13072017]    Script Date: 28-08-2017 19:13:11 ******/
CREATE DATABASE [EMPDB_uTax_13072017] ON  PRIMARY 
( NAME = N'EMPDB_uTax_13072017', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\DATA\EMPDB_uTax_13072017.mdf' , SIZE = 187392KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'EMPDB_uTax_13072017_log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\DATA\EMPDB_uTax_13072017_log.ldf' , SIZE = 2560KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [EMPDB_uTax_13072017].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET ARITHABORT OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET  DISABLE_BROKER 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET  MULTI_USER 
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET DB_CHAINING OFF 
GO
USE [EMPDB_uTax_13072017]
GO
/****** Object:  StoredProcedure [dbo].[ActivateAdditionalEFIN]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ActivateAdditionalEFIN]
	@ParentId uniqueidentifier=null,
	--@EntityId int = 0,
	@SalesYearId uniqueidentifier = null
AS

BEGIN

--IF (@EntityId=3 OR @EntityId=7 OR @EntityId=13 OR @EntityId=15) --AND @IsActivationCompleted=1 --IsEnrolled=1
BEGIN
	
	--Update OfficeManagement SET IsActivationCompleted=1 ,StatusCode='ACT',AccountStatus='Active' Where ParentId = @ParentId and EntityId in (4,8,14,16)
	
	Update emp_CustomerInformation SET IsActivationCompleted=1, StatusCode='ACT',AccountStatus='Active' Where ParentId = @ParentId and EntityId in (4,8,14,16)
	

	DECLARE @myId uniqueidentifier=null;

    DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT CustomerId
    FROM OfficeManagement Where ParentId = @ParentId and EntityId in (4,8,14,16);

    OPEN intListCursor;

    -- Initial fetch attempt
    FETCH NEXT FROM intListCursor INTO @myId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
       -- Here we do some kind of action that requires us to 
       -- process the table variable row-by-row. This example simply
       -- uses a PRINT statement as that action (not a very good
       -- example).
      -- PRINT 'Int var is : ' + CONVERT(VARCHAR(max),@myInt);

       -- Attempt to fetch next row from cursor

	   EXEC [OfficeManagementGridSP] @myId,@SalesYearId,@ParentId 

       FETCH NEXT FROM intListCursor INTO @myId;
    END;

    CLOSE intListCursor;
    DEALLOCATE intListCursor;

	--EXEC [OfficeManagementGridSP] @xCustomerId varchar(100),@xSalesYear varchar(100),@xRootParentId varchar(100) = null 

END

END 

















GO
/****** Object:  StoredProcedure [dbo].[ArchiveData_InsertSP]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[ArchiveData_InsertSP]
	@UserId uniqueidentifier,
	@EntityType int,
	@SalesYear uniqueidentifier,
	@Token uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @EntityId int=0;
	DECLARE @ParentId uniqueidentifier=null;
	DECLARE @OldSalesYear uniqueidentifier=null;

	SELECT @EntityId=EntityId, @ParentId=ParentId,@OldSalesYear=SalesYearId FROM dbo.emp_CustomerInformation WHERE Id=@UserId

	 IF NOT EXISTS (SELECT * FROM EMPDB_uTax_Arch.dbo.emp_CustomerInformation WHERE Id=@UserId and SalesYearId=@SalesYear)
	  BEGIN
	   INSERT INTO EMPDB_uTax_Arch.dbo.EntityHierarchy select * from  dbo.EntityHierarchy where CustomerId in (@UserId);
	    INSERT INTO EMPDB_uTax_Arch.dbo.emp_CustomerInformation select * from  dbo.emp_CustomerInformation where Id in (@UserId);
		INSERT INTO EMPDB_uTax_Arch.dbo.emp_CustomerLoginInformation select * from  dbo.emp_CustomerLoginInformation where CustomerOfficeId in (@UserId);
		INSERT INTO EMPDB_uTax_Arch.dbo.OfficeManagement select * from  dbo.OfficeManagement where CustomerId in (@UserId);

	--	INSERT INTO EMPDB_uTax_Arch.dbo.SecurityAnswerUserMap select * from dbo.SecurityAnswerUserMap where UserId in (@UserId);
	  IF @EntityType=1 
	  BEGIN
  			
		--Main Office Config
		INSERT INTO EMPDB_uTax_Arch.dbo.MainOfficeConfiguration select * from dbo.MainOfficeConfiguration where emp_CustomerInformation_ID in (@UserId);
	
		--Main Site - Sub Site Configuration
		INSERT INTO EMPDB_uTax_Arch.dbo.SubSiteConfiguration select * from dbo.SubSiteConfiguration where emp_CustomerInformation_ID in (@UserId);
		INSERT INTO EMPDB_uTax_Arch.dbo.SubSiteAffiliateProgramConfig select * from dbo.SubSiteAffiliateProgramConfig where emp_CustomerInformation_ID in (@UserId);
		INSERT INTO EMPDB_uTax_Arch.dbo.SubSiteBankConfig select * from dbo.SubSiteBankConfig where emp_CustomerInformation_ID in (@UserId);

		--Main Site Fee Setup
		INSERT INTO EMPDB_uTax_Arch.dbo.CustomerAssociatedFees select * from dbo.CustomerAssociatedFees where emp_CustomerInformation_ID in (@UserId);
		INSERT INTO EMPDB_uTax_Arch.dbo.SubSiteFeeConfig select * from dbo.SubSiteFeeConfig where emp_CustomerInformation_ID in (@UserId);
		INSERT INTO EMPDB_uTax_Arch.dbo.SubSiteBankFeesConfig select * from dbo.SubSiteBankFeesConfig where emp_CustomerInformation_ID in (@UserId);

		--Main Site Fee Reim
		INSERT INTO EMPDB_uTax_Arch.dbo.FeeReimbursementConfig select * from dbo.FeeReimbursementConfig where emp_CustomerInformation_ID in (@UserId);
	 END
	 ELSE
		BEGIN
			INSERT INTO EMPDB_uTax_Arch.dbo.SubSiteOfficeConfig select * from  dbo.SubSiteOfficeConfig where RefId in (@UserId);
			INSERT INTO EMPDB_uTax_Arch.dbo.SubSiteBankFeesConfig select * from  dbo.SubSiteBankFeesConfig where emp_CustomerInformation_ID in (@UserId);
		END
	

	-- Configuration Status
		INSERT INTO EMPDB_uTax_Arch.dbo.CustomerConfigurationStatus select * from dbo.CustomerConfigurationStatus where CustomerId in (@UserId);
	
		-- IF EXISTS (SELECT * FROM dbo.emp_CustomerInformation WHERE Id=@UserId and IsEnrolled=1)
		-- BEGIN
			INSERT INTO EMPDB_uTax_Arch.dbo.EnrollmentOfficeConfiguration select * from dbo.EnrollmentOfficeConfiguration where CustomerId in (@UserId);
			INSERT INTO EMPDB_uTax_Arch.dbo.EnrollmentAffiliateConfiguration select * from dbo.EnrollmentAffiliateConfiguration where CustomerId in (@UserId);

			INSERT INTO EMPDB_uTax_Arch.dbo.EnrollmentBankSelection select * from dbo.EnrollmentBankSelection where CustomerId in (@UserId);
			INSERT INTO EMPDB_uTax_Arch.dbo.BankEnrollment select * from dbo.BankEnrollment where CustomerId in (@UserId);
			INSERT INTO EMPDB_uTax_Arch.dbo.EnrollmentFeeReimbursementConfig select * from dbo.EnrollmentFeeReimbursementConfig where emp_CustomerInformation_ID in (@UserId);
			INSERT INTO EMPDB_uTax_Arch.dbo.BankEnrollmentHistory select * from dbo.BankEnrollmentHistory where CustomerId in (@UserId);
			INSERT INTO EMPDB_uTax_Arch.dbo.BankEnrollmentForTPG select * from dbo.BankEnrollmentForTPG where CustomerId in (@UserId);
			INSERT INTO EMPDB_uTax_Arch.dbo.BankEnrollmentForRB select * from dbo.BankEnrollmentForRB where CustomerId in (@UserId);
			INSERT INTO EMPDB_uTax_Arch.dbo.BankEnrollmentForRA select * from dbo.BankEnrollmentForRA where CustomerId in (@UserId);
			INSERT INTO EMPDB_uTax_Arch.dbo.BankEnrollmentEFINOwnersForRA select * from dbo.BankEnrollmentEFINOwnersForRA where  BankEnrollmentRAId in (select Id from dbo.BankEnrollmentForRA where CustomerId in (@UserId));
		
		INSERT INTO EMPDB_uTax_Arch.dbo.CustomerPaymentOptions select * from dbo.CustomerPaymentOptions where CustomerId in (@UserId);
		INSERT INTO EMPDB_uTax_Arch.dbo.CustomerPaymentViaACH select * from dbo.CustomerPaymentViaACH where PaymentOptionId in (select Id from dbo.CustomerPaymentOptions where CustomerId in (@UserId));
		INSERT INTO EMPDB_uTax_Arch.dbo.CustomerPaymentViaCreditCard select * from dbo.CustomerPaymentViaCreditCard where  PaymentOptionId in (select Id from dbo.CustomerPaymentOptions where CustomerId in (@UserId));
		--END
	
	-- update statements for procedure here

	IF @EntityId<>2 and @EntityId<>3 and @EntityId<>4 
	BEGIN
		Update dbo.emp_CustomerInformation set IsArchived =1, StatusCode='PEA',AccountStatus='Not Active', IsActivationCompleted=0,IsEnrolled=0, SalesYearID = (select Id from SalesYearMaster where ApplicableToDate IS NULL)  Where Id in (@UserId);
	END
	ELSE
	BEGIN
		Update dbo.emp_CustomerInformation set IsArchived = 1,  IsEnrolled=0, SalesYearID = (select Id from SalesYearMaster where ApplicableToDate IS NULL)  Where Id in (@UserId);
	END;

		delete from dbo.CustomerConfigurationStatus Where CustomerId in (@UserId);
		update BankEnrollment set IsActive=0 Where CustomerId in (@UserId);
		--Update dbo.CustomerConfigurationStatus set StatusCode='NEW' Where CustomerId in (@UserId);
	
		UPDATE TempArchiveCustomerInfo SET Status='DONE' WHERE CustomerId=@UserId and TokenId = @Token
		
		update EnrollmentBankSelection SET StatusCode='INA' Where CustomerId=@UserId
		update BankEnrollment SET StatusCode='INA',IsActive=0 Where CustomerId=@UserId
		update EnrollmentFeeReimbursementConfig SET StatusCode='INA' Where emp_CustomerInformation_ID=@UserId
		delete from BankEnrollmentHistory Where CustomerId=@UserId
		update BankEnrollmentForTPG SET StatusCode='INA' Where CustomerId=@UserId
		update BankEnrollmentForRB SET StatusCode='INA' Where CustomerId=@UserId
		update BankEnrollmentForRA SET StatusCode='INA' Where CustomerId=@UserId
		delete from BankEnrollmentEFINOwnersForRA where  BankEnrollmentRAId in (select Id from dbo.BankEnrollmentForRA where CustomerId in (@UserId));
		
		EXEC OfficeManagementGridSP @UserId,@OldSalesYear,@ParentId
	
	END 

END
















GO
/****** Object:  StoredProcedure [dbo].[NewCustomerSignupGrid_SP]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[NewCustomerSignupGrid_SP]
  @PageIndex int=0,
  @PageSize int=0
AS

  BEGIN

	  select * from emp_CustomerInformation 
	  where
		  StatusCode = 'NEW'
		  AND 
		 EntityId<>1

END













GO
/****** Object:  StoredProcedure [dbo].[NewSalesYear_Update]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[NewSalesYear_Update]
	@SalesYear uniqueidentifier=null
AS
BEGIN
	Update dbo.emp_CustomerInformation set SalesYearGroupId = Id, SalesYearID = (select Id from SalesYearMaster where ApplicableToDate IS NULL);
END 

















GO
/****** Object:  StoredProcedure [dbo].[OfficeManagementGridFilter]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OfficeManagementGridFilter]
	-- Add the parameters for the stored procedure here
	@StautusFilter varchar(250)='',
	@SiteTypeFilter varchar(250)='',
	@EnrollmentStatusFilter varchar(250)='',
	@BankPartnerFilter varchar(250)='',
	@OnboardingStatusFilter varchar(250)='',
	@UserType int,
	@xCustomerId varchar(250)
AS
	BEGIN
		declare @CustomerId uniqueidentifier
		Select @CustomerId = CONVERT(uniqueidentifier, @xCustomerId);
		declare @activestatus varchar(100);
		declare @holdstatus bit;
		set @activestatus ='';
		set @holdstatus = 0;

		IF OBJECT_ID(N'dbo.tmpHierarchy', N'U') IS NOT NULL
			BEGIN
				drop table tmpHierarchy;
			END;

		if CHARINDEX('ACT,',@StautusFilter) > 0 and CHARINDEX('INA,',@StautusFilter) > 0 and CHARINDEX('REV,',@StautusFilter) > 0 and CHARINDEX('HLD,',@StautusFilter) > 0 
			begin
				select @StautusFilter = replace(@StautusFilter,'ACT,', '');
				select @StautusFilter = replace(@StautusFilter,'INA,', '');
				select @StautusFilter = replace(@StautusFilter,'REV,', '');
				select @StautusFilter = replace(@StautusFilter,'HLD,', '');
				set @activestatus = 'Active,Not Active,Review,Hold';
			end;
		else 
			begin
				if CHARINDEX('ACT,',@StautusFilter) > 0
					begin						
						select @StautusFilter = replace(@StautusFilter,'ACT,', '');
						set @activestatus = 'Active';						
					end;
				if CHARINDEX('INA,',@StautusFilter) > 0
					begin
						select @StautusFilter = replace(@StautusFilter,'INA,', '');
						set @activestatus = @activestatus+ ',Not Active';
					end;
				if CHARINDEX('REV,',@StautusFilter) > 0
					begin
						select @StautusFilter = replace(@StautusFilter,'REV,', '');
						set @activestatus =@activestatus+ ',Review';
					end;
				if CHARINDEX('HLD,',@StautusFilter) > 0
					begin
						select @StautusFilter = replace(@StautusFilter,'HLD,', '');
						set @activestatus =@activestatus+ ',Hold';
					end;
			end;

		--if CHARINDEX('HLD',@StautusFilter) > 0
		--	begin
		--		set @holdstatus = 1;
		--		set @StautusFilter ='None';
		--	end;


		IF @StautusFilter ='' and @activestatus !='' --and @holdstatus = 0
		BEGIN
			set @StautusFilter = 'None';
		END;

		--IF @StautusFilter ='None' and @holdstatus = 1 and @activestatus = ''
		--BEGIN
		--	set @activestatus = 'None';
		--END;

		WITH RecursiveCte AS
		(
			SELECT H1.Id, H1.CustomerId FROM officeManagement H1
			WHERE CustomerId = @CustomerId
			UNION ALL
			SELECT  H2.Id, H2.CustomerId FROM officeManagement H2
			INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.CustomerId
		)
		select CustomerId into tmpHierarchy from RecursiveCte
		OPTION(MAXRECURSION 32767)


		print @activestatus;
		print @StautusFilter;
		print @holdstatus;

		IF OBJECT_ID(N'dbo.tmpHierarchyFilter', N'U') IS NOT NULL
			BEGIN
				drop table tmpHierarchyFilter;
			END;

		select CustomerId,ParentId into tmpHierarchyFilter from officeManagement
		where ((@UserType = 0 and CustomerId in (select distinct(CustomerId) from officeManagement)) or (CustomerId in (select CustomerId from tmpHierarchy)))		
		and (((@StautusFilter = '' and ISNULL(StatusCode,'') in (select distinct(StatusCode) from officeManagement)) or (ISNULL(StatusCode,'') in (SELECT Item FROM dbo.SplitString(@StautusFilter, ','))))		
		or ((@activestatus = '' and AccountStatus in ('Active','Not Active','Review','Hold')) or AccountStatus in ((SELECT Item FROM dbo.SplitString(@activestatus, ',')))))
		--or ((@holdstatus=0 and ISNULL(IsHold,0) in (0,1)) or (IsHold = 1)))
		and ((@SiteTypeFilter = '' and ISNULL(EntityId,'') in (select distinct(EntityId) from officeManagement)) or (ISNULL(EntityId,'') in (SELECT CAST(Item AS INTEGER) FROM dbo.SplitString(@SiteTypeFilter, ','))))
		and ((@EnrollmentStatusFilter = '' and ISNULL(EnrollmentStatus,'') in (select distinct(ISNULL(EnrollmentStatus,'')) from officeManagement)) or (ISNULL(EnrollmentStatus,'') in (SELECT Item FROM dbo.SplitString(@EnrollmentStatusFilter, ','))))
		and ((@BankPartnerFilter = '' and ISNULL(ActiveBankName,'') in (select distinct(ISNULL(ActiveBankName,'')) from officeManagement)) or (ISNULL(ActiveBankName,'') in (SELECT Item FROM dbo.SplitString(@BankPartnerFilter, ','))))
		and ((@OnboardingStatusFilter = '' and ISNULL(OnboardingStatus,'') in (select distinct(ISNULL(OnboardingStatus,'')) from officeManagement)) or (ISNULL(OnboardingStatus,'') in (SELECT Item FROM dbo.SplitString(@OnboardingStatusFilter, ','))))
		and StatusCode!='NEW';

		IF OBJECT_ID(N'dbo.tmpHierarchyFilters', N'U') IS NOT NULL
			BEGIN
				drop table tmpHierarchyFilters;
			END;

		--WITH RecursiveCte AS
		--(
		--	SELECT H1.Id, H1.CustomerId FROM officeManagement H1
		--	WHERE CustomerId in (select ParentId From tmpHierarchyFilter Where ParentId IS NOT NULL)
		--	UNION ALL
		--	SELECT  H2.Id, H2.CustomerId FROM officeManagement H2
		--	INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.CustomerId
		--)
		--select CustomerId into tmpHierarchyFilters from RecursiveCte
		--OPTION(MAXRECURSION 32767)

		WITH Hierarchy(ParentId,CustomerId)
		AS
		(
			SELECT ParentId,CustomerId
				FROM OfficeManagement AS LastGeneration
				WHERE CustomerId IN (select ParentId From tmpHierarchyFilter Where ParentId IS NOT NULL)
			UNION ALL
			SELECT PrevGeneration.ParentId, PrevGeneration.CustomerId
				FROM OfficeManagement AS PrevGeneration
				INNER JOIN Hierarchy AS Child ON PrevGeneration.CustomerId = Child.ParentId    
		)
		SELECT CustomerId into tmpHierarchyFilters from Hierarchy
		OPTION(MAXRECURSION 32767)

		--------------------------

		--IF OBJECT_ID(N'dbo.tmpHierarchyMaster', N'U') IS NOT NULL
		--	BEGIN
		--		drop table tmpHierarchyMaster;
		--	END;

		--WITH RecursiveCte AS
		--(
		--	SELECT H1.Id, H1.CustomerId FROM officeManagement H1
		--	WHERE CustomerId in (select CustomerId From tmpHierarchyFilter Where ParentId IS NULL)
		--	UNION ALL
		--	SELECT  H2.Id, H2.CustomerId FROM officeManagement H2
		--	INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.CustomerId
		--)
		--select CustomerId into tmpHierarchyMaster from RecursiveCte
		--OPTION(MAXRECURSION 32767)

		
		select * from OfficeManagement where CustomerId in (select DISTINCT CustomerId From tmpHierarchyFilter) OR  CustomerId in (select DISTINCT CustomerId From tmpHierarchyFilters)
		--OR  CustomerId in (select DISTINCT CustomerId From tmpHierarchyMaster)
		 
END












GO
/****** Object:  StoredProcedure [dbo].[OfficeManagementGridRecord]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[OfficeManagementGridRecord]
	@UserType int = 0,
	@xCustomerId varchar(250) = null,
	@xStart int=0,
	@xMaxSize int=0
AS
	--IF @SearchTypeId = 1 
	--SET NONCOUNT 
	BEGIN
		Declare @CustomerIds varchar(MAX)
		Declare @CustomerId uniqueidentifier
		Select @CustomerId = CONVERT(uniqueidentifier, @xCustomerId);

		
		IF @UserType = 0
		BEGIN
	drop table tmpHierarchy3;
	WITH RecursiveCte AS
                    (
                        SELECT H1.Id, H1.CustomerId FROM officeManagement H1
                        WHERE CustomerId in (select CustomerId from  (SELECT *, ROW_NUMBER() OVER (ORDER BY CompanyName) as row FROM OfficeManagement Where ParentId  is null  and  StatusCode <> 'NEW')  a where a.row > @xStart and a.row<=(@xStart+@xMaxSize)
		)
                        UNION ALL
                        SELECT  H2.Id, H2.CustomerId FROM officeManagement H2
                        INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.CustomerId
                    )
                    select CustomerId into tmpHierarchy3 from RecursiveCte
                    OPTION(MAXRECURSION 32767);

					select * from  OfficeManagement Where CustomerId in (select CustomerId from  tmpHierarchy3) and StatusCode<>'NEW'
		END
		ELSE 
		BEGIN
		drop table tmpHierarchy4;
		WITH RecursiveCte AS
                    (
                        SELECT H1.Id, H1.CustomerId FROM officeManagement H1
                        WHERE CustomerId in (@CustomerId)
                        UNION ALL
                        SELECT  H2.Id, H2.CustomerId FROM officeManagement H2
                        INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.CustomerId
                    )
                    select CustomerId into tmpHierarchy4 from RecursiveCte
                    OPTION(MAXRECURSION 32767);


				select * from  OfficeManagement Where CustomerId in (select CustomerId from  tmpHierarchy4) and StatusCode<>'NEW'
		END

		END













GO
/****** Object:  StoredProcedure [dbo].[OfficeManagementGridSearch]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[OfficeManagementGridSearch]
  @SearchTypeId int,
  @SearchText varchar(250),
  @UserType int = 0,  --- 0 For Utax and 1 For Main Site
  @xCustomerId varchar(250) = null,
  @PageIndex int=0,
  @PageSize int=0
AS

SET @SearchText=RTRIM(LTRIM(@SearchText));
PRINT @SearchText;
  --IF @SearchTypeId = 1 
  BEGIN
  DECLARE @CustomerIds varchar(250);
  DECLARE @ParentIds varchar(250);

	  Declare @CustomerId uniqueidentifier
	  Select @CustomerId = CONVERT(uniqueidentifier, @xCustomerId);

	  IF @UserType = 1   ---- For Main Site 
	  BEGIN
		
	  drop table tmpHierarchy0;
	  WITH RecursiveCte AS
									  (
											  SELECT H1.Id, H1.CustomerId FROM officeManagement H1
											  WHERE CustomerId in (@CustomerId)
											  UNION ALL
											  SELECT  H2.Id, H2.CustomerId FROM officeManagement H2
											  INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.CustomerId
									  )
									  select CustomerId into tmpHierarchy0 from RecursiveCte
									  OPTION(MAXRECURSION 32767);

				  -- select CustomerId from  tmpHierarchy1;

				  --select * from OfficeManagement where CustomerId in (select CustomerId from  tmpHierarchy1)



	  drop table tmpHierarchy5;
	  select CustomerId,ParentId into tmpHierarchy5   from 
	  OfficeManagement
	  where
		  StatusCode <> 'NEW'

		  AND
		  CompanyName Like CASE WHEN @SearchTypeId=1 THEN
			   '%'+@SearchText+'%'
		  ELSE
		  CompanyName
		  END
			
		 AND
		  ISNULL(EMPUserId,'') Like CASE WHEN @SearchTypeId=2 THEN
			   '%'+@SearchText +'%'
		  ELSE
		  ISNULL(EMPUserId,'')
		  END

		 AND
		  ISNULL(EFIN,'') = CASE WHEN @SearchTypeId=3 THEN
		
		  (case when IsNumeric(@SearchText) = 1
				 then cast(@SearchText as int)
       else EFIN end)

			   --@SearchText
		  ELSE
		  ISNULL(EFIN,'')
		  END
		AND
		  BusinessOwnerFirstName Like CASE WHEN @SearchTypeId=4 THEN
			   '%'+@SearchText +'%'
		  ELSE
		  BusinessOwnerFirstName

		  END
			
		AND
		  Replace(Replace(Replace(OfficePhone,'-',''),')',''),'','(') Like CASE WHEN @SearchTypeId=5 THEN
			   '%'+Replace(Replace(Replace(@SearchText,'-',''),')',''),'','(') +'%'
		  ELSE
		  Replace(Replace(Replace(OfficePhone,'-',''),')',''),'','(')
		  END
		AND
		  MasterIdentifier Like CASE WHEN @SearchTypeId=6 THEN
			   '%'+@SearchText +'%'
		  ELSE
		  MasterIdentifier
		  END
		AND		  
		   CustomerId IN (select CustomerId from  tmpHierarchy0)
					
	  --select * from OfficeManagement where CustomerId in (@CustomerIds)


	    BEGIN
  drop table tmpHierarchy1;
 
  WITH Hierarchy(ParentId,CustomerId)
		AS
		(
			SELECT ParentId,CustomerId
				FROM OfficeManagement AS LastGeneration
				WHERE CustomerId IN (select CustomerId From tmpHierarchy5 Where ParentId IS NULL)
			UNION ALL
			SELECT PrevGeneration.ParentId, PrevGeneration.CustomerId
				FROM OfficeManagement AS PrevGeneration
				INNER JOIN Hierarchy AS Child ON PrevGeneration.ParentId = Child.CustomerId    
		)
		SELECT CustomerId into tmpHierarchy1 from Hierarchy
		OPTION(MAXRECURSION 32767)



		-----------------

		drop table tmpHierarchy12;
 
  WITH Hierarchy(ParentId,CustomerId)
		AS
		(
			SELECT ParentId,CustomerId
				FROM OfficeManagement AS LastGeneration
				WHERE CustomerId IN (select ParentId From tmpHierarchy5 Where ParentId IS NOT NULL)
			UNION ALL
			SELECT PrevGeneration.ParentId, PrevGeneration.CustomerId
				FROM OfficeManagement AS PrevGeneration
				INNER JOIN Hierarchy AS Child ON PrevGeneration.CustomerId = Child.ParentId    
		)
		SELECT CustomerId into tmpHierarchy12 from Hierarchy
		OPTION(MAXRECURSION 32767)

				  --select DISTINCT CustomerId From tmpHierarchy1;
				  --select CustomerId From tmpHierarchy5;
END

select * from OfficeManagement where CustomerId in (select DISTINCT CustomerId From tmpHierarchy1) OR  CustomerId in (select DISTINCT CustomerId From tmpHierarchy5 
     ) OR  CustomerId in (select DISTINCT CustomerId From tmpHierarchy12)


	  END
	  ELSE
	  BEGIN

	  drop table tmpHierarchy5;
	  select CustomerId,ParentId into tmpHierarchy5  from 
		
	  --(SELECT *, ROW_NUMBER() OVER (ORDER BY CompanyName) as row FROM OfficeManagement Where ParentId  is null)  a where 
		 
	  -- a.row > @xStart and a.row<=(@xStart+@xMaxSize) 

	  --and
	  OfficeManagement Where
	
		  StatusCode <> 'NEW'
		  AND
		  CompanyName Like CASE WHEN @SearchTypeId=1 THEN
			   '%'+@SearchText+'%'
		  ELSE
		  CompanyName
		  END
			
	  AND
		  ISNULL(EMPUserId,'') Like CASE WHEN @SearchTypeId=2 THEN
			   '%'+@SearchText +'%'
		  ELSE
		  ISNULL(EMPUserId,'')
		  END

		 AND
		  ISNULL(EFIN,'') = CASE WHEN @SearchTypeId=3 THEN
		
		  (case when IsNumeric(@SearchText) = 1
				 then cast(@SearchText as int)
       else EFIN end)

			   --@SearchText
		  ELSE
		  ISNULL(EFIN,'')
		  END

			
		  AND
			
		  BusinessOwnerFirstName Like CASE WHEN @SearchTypeId=4 THEN
			   '%'+@SearchText +'%'
		  ELSE
		  BusinessOwnerFirstName

		  END
			
		   AND
		   Replace(Replace(Replace(OfficePhone,'-',''),')',''),'','(') Like CASE WHEN @SearchTypeId=5 THEN
			   '%'+Replace(Replace(Replace(@SearchText,'-',''),')',''),'','(') +'%'
		  ELSE
		   Replace(Replace(Replace(OfficePhone,'-',''),')',''),'','(')
		  END
		  AND
		  MasterIdentifier Like CASE WHEN @SearchTypeId=6 THEN
			   '%'+@SearchText +'%'
		  ELSE
		  MasterIdentifier
		  END

	  --AND ParentId is null

  	--select * From tmpHierarchy5
		
	  BEGIN
  drop table tmpHierarchy1;
 
  WITH Hierarchy(ParentId,CustomerId)
		AS
		(
			SELECT ParentId,CustomerId
				FROM OfficeManagement AS LastGeneration
				WHERE CustomerId IN (select CustomerId From tmpHierarchy5 Where ParentId IS NULL)
			UNION ALL
			SELECT PrevGeneration.ParentId, PrevGeneration.CustomerId
				FROM OfficeManagement AS PrevGeneration
				INNER JOIN Hierarchy AS Child ON PrevGeneration.ParentId = Child.CustomerId    
		)
		SELECT CustomerId into tmpHierarchy1 from Hierarchy
		OPTION(MAXRECURSION 32767)



		-----------------

		drop table tmpHierarchy12;
 
  WITH Hierarchy(ParentId,CustomerId)
		AS
		(
			SELECT ParentId,CustomerId
				FROM OfficeManagement AS LastGeneration
				WHERE CustomerId IN (select ParentId From tmpHierarchy5 Where ParentId IS NOT NULL)
			UNION ALL
			SELECT PrevGeneration.ParentId, PrevGeneration.CustomerId
				FROM OfficeManagement AS PrevGeneration
				INNER JOIN Hierarchy AS Child ON PrevGeneration.CustomerId = Child.ParentId    
		)
		SELECT CustomerId into tmpHierarchy12 from Hierarchy
		OPTION(MAXRECURSION 32767)

				  --select DISTINCT CustomerId From tmpHierarchy1;
				  --select CustomerId From tmpHierarchy5;
END

select * from OfficeManagement where CustomerId in (select DISTINCT CustomerId From tmpHierarchy1) OR  CustomerId in (select DISTINCT CustomerId From tmpHierarchy5 
     ) OR  CustomerId in (select DISTINCT CustomerId From tmpHierarchy12)
	 -- Where ParentId Is Null)
--select  ROW_NUMBER() OVER
--      (
--            ORDER BY [CustomerID] ASC
--      )AS RowNumber
--      , * into #Results from OfficeManagement where CustomerId in (select DISTINCT CustomerId From tmpHierarchy1) OR  CustomerId in (select DISTINCT CustomerId From tmpHierarchy5 
--      Where ParentId Is Null)
--      -- and RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1

--select * from #Results 
--      where RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
      
	  END
	
END














GO
/****** Object:  StoredProcedure [dbo].[OfficeManagementGridSP]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OfficeManagementGridSP]
	-- Add the parameters for the stored procedure here
	@xCustomerId varchar(100),
	@xSalesYear varchar(100),
	@xRootParentId varchar(100) = null 
AS
BEGIN

	declare @BankEnrollId uniqueidentifier =null;
	declare @BankId uniqueidentifier =null;
	declare @CustomerId uniqueidentifier;
	declare @ismsouser int;
	declare @EntityId int;
	declare @EFIN int;

	declare @SalesYear uniqueidentifier;
	declare @RootParentId uniqueidentifier;
	declare @IsEnrollmentCompleted bit;

	Select @CustomerId = CONVERT(uniqueidentifier, @xCustomerId)
	if @xSalesYear <>''
	Set @SalesYear  = CONVERT(uniqueidentifier, @xSalesYear) 

	if @xRootParentId is not null 
	  Set @RootParentId  = CONVERT(uniqueidentifier, @xRootParentId) 
	else 
    Set @RootParentId = null 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 IF NOT EXISTS (SELECT * FROM OfficeManagement WHERE CustomerId = @CustomerId) -- and SalesYearId=@SalesYear
	 BEGIN
	   INSERT INTO OfficeManagement
	   
(--Id,
CustomerId,
ParentId,
EntityId,
BaseEntityId,
CompanyName,
BusinessOwnerFirstName,
BusinessOwnerLastName,
OfficePhone,
EMPUserId,
EMPPassword,
EFIN,
EFINStatus,
MasterIdentifier,
IsActivationCompleted,
IsVerified,
--IsEnrollmentCompleted,
ActiveBankId,
EnrollmentPrimaryKey,
OnBoardPrimaryKey,
AccountStatus,
StatusCode,
SalesYearId,
IsArchived,
IsHold,
CreatedDate)


SELECT ci.Id,
--ci.CustomerId,
ci.ParentId,
ci.EntityId,
ent.BaseEntityId,
ci.CompanyName,
ci.BusinessOwnerFirstName,
ci.BusinesOwnerLastName,
ci.OfficePhone,
cl.EMPUserId,
cl.EMPPassword,
ci.EFIN,
ci.EFINStatus,
cl.MasterIdentifier,
ci.IsActivationCompleted,
ci.IsVerified,
--ci.IsEnrolled,
ci.EnrolledBankId,
ci.EnrollmentPrimaryKey,
ci.OnBoardPrimaryKey,
ISNULL(ci.AccountStatus,'Not Active'),
ci.StatusCode,
ci.SalesYearId,
ci.IsArchived,
ci.IsHold,
GETDATE()
 from emp_CustomerInformation ci
	   join emp_CustomerLoginInformation cl on ci.Id = cl.CustomerOfficeId
	   join EntityMaster ent on ent.Id= ci.EntityId
	   Where ci.Id=@CustomerId
	   
	 END

	 ELSE
	 BEGIN
	 
update OfficeManagement
SET 
EntityId=ci.EntityId,
BaseEntityId=ent.BaseEntityId,
CompanyName=ci.CompanyName,
BusinessOwnerFirstName=ci.BusinessOwnerFirstName,
BusinessOwnerLastName=ci.BusinesOwnerLastName,
OfficePhone=ci.OfficePhone,
EMPUserId=cl.EMPUserId,
EMPPassword=cl.EMPPassword,
EFIN=ci.EFIN,
EFINStatus=ci.EFINStatus,
MasterIdentifier=cl.MasterIdentifier,
IsActivationCompleted=ci.IsActivationCompleted,
IsVerified=ci.IsVerified,
--IsEnrollmentCompleted=ci.IsEnrolled,
ActiveBankId=ci.EnrolledBankId,
EnrollmentPrimaryKey=ci.EnrollmentPrimaryKey,
OnBoardPrimaryKey=ci.OnBoardPrimaryKey,
AccountStatus= CASE WHEN ci.IsActivationCompleted=1 THEN 'Active' ELSE 'Not Active' END,
StatusCode=ci.StatusCode,
SalesYearId=ci.SalesYearId,
UpdatedDate=GETDATE(),
IsArchived=ci.IsArchived,
IsHold=ci.IsHold
from emp_CustomerInformation ci
join emp_CustomerLoginInformation cl on ci.Id=cl.CustomerOfficeId
join EntityMaster ent on ent.Id =ci.EntityId
Where CustomerId=@CustomerId and ci.Id=@CustomerId

END

-- Commented by Mani
DECLARE @SiteOwnThisEFIN bit=0;
DECLARE @EFINListedOtherOffice bit=0;
DECLARE @EFINOwnerSite varchar(50)='';
declare @IsActivationCompleted int=0;

select @SalesYear= SalesYearId,  @IsActivationCompleted=ISNULL(@IsActivationCompleted,0), @EFIN=ISNULL(EFIN,0), @ismsouser= ISNULL(IsMSOUser,0),@EntityId=EntityId, @IsEnrollmentCompleted = ISNULL(IsEnrolled,0), @BankId = ISNULL(EnrolledBankId,null) from emp_customerInformation where Id = @CustomerId; --GD Added ISNULL

IF @RootParentId IS NOT NULL OR @EntityId=3 OR @EntityId=2
BEGIN

SELECT @SiteOwnThisEFIN=SiteOwnThisEFIN, @EFINListedOtherOffice=EFINListedOtherOffice,@EFINOwnerSite=EFINOwnerSite, @ismsouser = ISNULL(SiteanMSOLocation,0) from SubSiteOfficeConfig Where RefId=@CustomerId 

END


-- Commented by Mani


-- For Account status "Review" starts

declare @xAcctStatus varchar(50)='';
declare @xActSts varchar(50);

select @xAcctStatus = AccountStatus,@xActSts=StatusCode from OfficeManagement where CustomerId = @CustomerId

IF @xAcctStatus = 'Active' and @xActSts='CRT'
BEGIN
	Declare @xlinkUserId int;
	Declare @xlinkPassword varchar(50);
	select @xlinkUserId = EMPUserId,@xlinkPassword=EMPPassword from emp_CustomerLoginInformation where CustomerOfficeId=@CustomerId
	If (@xlinkUserId is not null and @xlinkUserId <>'') and (@xlinkPassword is null or @xlinkPassword='')
	BEGIN
		update OfficeManagement 
		SET AccountStatus = 'Review'
		Where CustomerId = @CustomerId
	END
END

IF @xAcctStatus = 'Not Active'
BEGIN	
	If @EntityId = 5 or @EntityId = 9
	BEGIN
		update OfficeManagement 
		SET AccountStatus = 'Review'
		FROM CustomerConfigurationStatus custconfigstatus
		Where OfficeManagement.CustomerId = @CustomerId and  custconfigstatus.CustomerId = @CustomerId and custconfigstatus.SitemapId in (
		 '98A706D7-031F-4C5D-8CC4-D32CC7658B63'  --Dashboard
		,'7C8AA474-2535-4F69-A2AE-C3794887F92D' -- Verify
		,'0EDA5D25-591C-4E01-A845-FB580572ADE8' --Main Office Configuration
		,'68882C05-5914-4FDB-B284-E33D6C029F5A' --Sub-Site Configuration
		,'C81DDDC4-4654-4775-A5CD-74EFA99DFC90' --Fee Setup & Configuration
		,'60025459-7568-4A77-B152-F81904AAAA63') --Service Bureau And Transmission Fee Add-On
	END
	ELSE
	BEGIN
		update OfficeManagement 
		SET AccountStatus = 'Review'
		FROM CustomerConfigurationStatus custconfigstatus
		Where OfficeManagement.CustomerId = @CustomerId and  custconfigstatus.CustomerId = @CustomerId and custconfigstatus.SitemapId in (
		 '1F2A6418-F9BC-4878-AB0B-2FA004C01C01'  --Dashboard
		,'2639FB0A-0CAA-47CF-B315-587E7CE86AEF' -- Office Configuration
		,'D8D06578-1923-4792-BDAD-153603B57068' --Fee Configuration
		,'7C8AA474-2535-4F69-A2AE-C3794887F92D') -- Enroll Verify for self
	END
END


-- For Account status "Review" end

-- For Account Status "Hold"

update OfficeManagement SET AccountStatus = 'Hold' Where IsHold = 1 and CustomerId = @CustomerId and IsActivationCompleted = 1

-- For Account Status "Hold" end


update OfficeManagement 
SET 
uTaxSVBFee= 0,
CrosslinkTransFee= 0,
SVBAddonFee= 0,
TransAddonFee= 0,
SVBEnrollAddonFee= 0,
TransEnrollAddonFee =0
Where OfficeManagement.CustomerId=@CustomerId



update OfficeManagement 
SET CanEnrollmentAllowed = 0,
 CanEnrollmentAllowedForMain = 0
where OfficeManagement.CustomerId=@CustomerId


IF @RootParentId IS NULL
BEGIN

update OfficeManagement 
SET CanEnrollmentAllowed = 1,
 CanEnrollmentAllowedForMain = 1
where OfficeManagement.CustomerId=@CustomerId and OfficeManagement.IsActivationCompleted = 1 and (OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19)


-- Added for SO and SOME sharing efin
IF @EntityId=3 OR @EntityId=2
BEGIN
	IF @EFINListedOtherOffice=1 AND @EFIN>0 
	BEGIN
	update OfficeManagement 
	SET CanEnrollmentAllowed = ISNULL(@SiteOwnThisEFIN,0),
		CanEnrollmentAllowedForMain= ISNULL(@SiteOwnThisEFIN,0)
	where OfficeManagement.CustomerId=@CustomerId and  (OfficeManagement.EFINStatus=21 OR OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19) and OfficeManagement.IsActivationCompleted = 1 
	END

END
-- Added for SO and SOME sharing efin

END
ELSE
BEGIN

DECLARE @IsuTaxManageingEnrolling bit=0;
Select @IsuTaxManageingEnrolling=ISNULL(IsuTaxManageingEnrolling,1) from SubSiteConfiguration where emp_CustomerInformation_ID=@RootParentId;

--select @IsuTaxManageingEnrolling;

IF @EntityId=4  -- For SOME-SS
BEGIN
DECLARE @RootEnrollmentCompleted bit=0;
SELECT @RootEnrollmentCompleted=IsEnrollmentCompleted From  OfficeManagement Where CustomerId=@RootParentId 

IF @RootEnrollmentCompleted=1 
	BEGIN
		update OfficeManagement 
		SET CanEnrollmentAllowed = 1,
		CanEnrollmentAllowedForMain=1
		where OfficeManagement.CustomerId=@CustomerId and OfficeManagement.IsActivationCompleted = 1 and (OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19)
	END

END

ELSE


--BEGIN
----Commented by Ghanshyam 11242016
----update OfficeManagement 
----SET CanEnrollmentAllowed = ISNULL(@IsuTaxManageingEnrolling,1),
----CanEnrollmentAllowedForMain = 1
----where OfficeManagement.CustomerId=@CustomerId and OfficeManagement.IsActivationCompleted = 1 and (OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19)

--END


IF @EntityId > 5 and @EntityId <> 9
update OfficeManagement 
SET CanEnrollmentAllowed = 1,
CanEnrollmentAllowedForMain = 1
where OfficeManagement.CustomerId=@CustomerId and OfficeManagement.IsActivationCompleted = 1 and (OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19)


IF @EFINListedOtherOffice=1 AND @EFIN >0 -- and @SiteOwnThisEFIN=1
BEGIN
	IF @RootEnrollmentCompleted=1 and @EntityId = 4
	BEGIN
		update OfficeManagement 
		SET CanEnrollmentAllowedForMain = ISNULL(@SiteOwnThisEFIN,0)
		where OfficeManagement.CustomerId=@CustomerId and  (OfficeManagement.EFINStatus=21 OR OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19) and OfficeManagement.IsActivationCompleted = 1 
	END
	IF @EntityId <> 4
	BEGIN
		update OfficeManagement 
		SET CanEnrollmentAllowedForMain = ISNULL(@SiteOwnThisEFIN,0)
		where OfficeManagement.CustomerId=@CustomerId and  (OfficeManagement.EFINStatus=21 OR OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19) and OfficeManagement.IsActivationCompleted = 1 
	END
END

IF @EntityId =4 or @EntityId =8 or @EntityId = 14
Begin
update OfficeManagement set CanEnrollmentAllowedForMain = 0,CanEnrollmentAllowed=0 where OfficeManagement.CustomerId=@CustomerId and OfficeManagement.EFINStatus=21 
end

--Commented by Ghanshyam 11242016
--IF @IsuTaxManageingEnrolling=1
--BEGIN
--IF @EFINListedOtherOffice=1 AND @EFIN>0
--BEGIN
--update OfficeManagement 
--SET CanEnrollmentAllowed = ISNULL(@SiteOwnThisEFIN,0)
--where OfficeManagement.CustomerId=@CustomerId and  (OfficeManagement.EFINStatus=21 OR OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19) and OfficeManagement.IsActivationCompleted = 1 
--END
--END

END


update OfficeManagement 
	SET ActiveBankId=null,
		ActiveBankName = null,
		EnrollmentPrimaryKey = NULL,
		EnrollmentStatus = null,
		IsEnrollmentCompleted=0
Where OfficeManagement.CustomerId =@CustomerId



--MK 12122016 for active bnk

--update OfficeManagement 
--SET 
--ActiveBankId=bankenroll.BankId,
--ActiveBankName=bank.BankName,
--EnrollmentPrimaryKey=bankenroll.Id,
--EnrollmentStatus=bankenroll.StatusCode,
--@BankEnrollId=bankenroll.Id
--FROM BankEnrollment bankenroll
--join BankMaster bank on bankenroll.BankId = bank.Id
--Where OfficeManagement.CustomerId=@CustomerId and bankenroll.CustomerId=@CustomerId  and bankenroll.IsActive=1

--MK 12122016 for active bnk


declare @ActiveBankId uniqueidentifier =null;
declare @ActiveBankName varchar(100) ='';
declare @EnrollmentPrimaryKey uniqueidentifier =null;
declare @ActiveEnrollmentStatus varchar(100) ='';

select top(1)
@ActiveBankId=bank.Id,
@ActiveBankName=bank.BankName,
@EnrollmentPrimaryKey=bankenroll.Id,
@ActiveEnrollmentStatus=bankenroll.StatusCode,
@BankEnrollId=bankenroll.Id
FROM BankEnrollment bankenroll
join BankMaster bank on bankenroll.BankId = bank.Id
join EnrollmentBankSelection banksel on bankenroll.BankId = banksel.BankId
join OfficeManagement om on bankenroll.CustomerId = om.CustomerId
Where om.CustomerId=@CustomerId and bankenroll.CustomerId=@CustomerId  and bankenroll.IsActive=1
and banksel.CustomerId = @CustomerId and banksel.StatusCode ='ACT' and (bankenroll.StatusCode='SUB' or bankenroll.StatusCode='PEN' or bankenroll.StatusCode='APR') --and banksel.BankSubmissionStatus =1
and om.IsActivationCompleted=1 
order by banksel.BankSubmissionStatus desc, banksel.LastUpdatedDate desc

update OfficeManagement set
ActiveBankId=@ActiveBankId,
ActiveBankName=@ActiveBankName,
EnrollmentPrimaryKey=@EnrollmentPrimaryKey,
EnrollmentStatus=@ActiveEnrollmentStatus
where CustomerId=@CustomerId and IsActivationCompleted=1 

declare @enr_status varchar(100)='';

IF @BankEnrollId IS NULL
BEGIN

	update OfficeManagement 
	SET EnrollmentStatus = bankenroll.StatusCode,
	@enr_status = bankenroll.StatusCode
	FROM BankEnrollment bankenroll
	Where OfficeManagement.CustomerId =@CustomerId and bankenroll.CustomerId = @CustomerId and bankenroll.IsActive=1 and OfficeManagement.IsActivationCompleted=1
	--and (bankenroll.StatusCode='SUB' or bankenroll.StatusCode='PEN') --bankenroll.StatusCode='RDY' or 

	IF @enr_status IS NULL or @enr_status=''
	BEGIN

	update OfficeManagement 
	SET EnrollmentStatus = 'INP'
	FROM CustomerConfigurationStatus custconfigstatus
	Where OfficeManagement.CustomerId =@CustomerId and OfficeManagement.IsActivationCompleted=1 and  custconfigstatus.CustomerId = @CustomerId and custconfigstatus.SitemapId in (
	 '7c8aa474-2535-4f69-a2ae-c3794887f92d'  --office Info
	,'fc32db13-6aec-488e-bafe-19acb3399e57' --office Config
	,'2f7d1b90-78aa-4a93-85ec-81cd8b10a545' --Affiliate
	,'067c03a3-34f1-4143-beae-35327a8fca44' --Bank Sele
	,'0feeb0fe-d0e7-4370-8733-dd5f7d2041fc' --Bank Enro
	,'98a706d7-031f-4c5d-8cc4-d32cc7658b69' -- Enroll Sum
	,'a55334d1-3960-44c4-8cf1-e3ba9901f2be') --Fee Reim

	END


	--update OfficeManagement 
	--SET ActiveBankId=banksele.BankId,
	--ActiveBankName = bank.BankName,
	--EnrollmentPrimaryKey = NULL
	----EnrollmentStatus =''
	--FROM EnrollmentBankSelection banksele
	--join BankMaster bank on banksele.BankId = bank.Id
	--Where OfficeManagement.CustomerId =@CustomerId and banksele.CustomerId = @CustomerId and banksele.StatusCode='ACT' 
	--and (OfficeManagement.IsEnrollmentCompleted=1) and OfficeManagement.EnrollmentStatus <>'INP' 

END

--Added CAN(cancel) status 27/06/2017

update OfficeManagement 
SET IsEnrollmentCompleted = 1
FROM BankEnrollment bankenroll
where OfficeManagement.CustomerId=@CustomerId and bankenroll.StatusCode in ('APR','SUB','DEN','REJ','RDY','PEN','CAN') and bankenroll.CustomerId=@CustomerId and bankenroll.IsActive=1

update OfficeManagement 
SET EnrollmentSubmittionDate = null where OfficeManagement.CustomerId=@CustomerId and (OfficeManagement.EnrollmentStatus in ('INP','RDY') Or EnrollmentStatus Is Null)

IF @BankEnrollId IS NOT NULL
BEGIN
	update OfficeManagement 
	SET EnrollmentSubmittionDate =  (select top(1) bankenrollstatus.CreatedDate
	FROM BankEnrollmentStatus bankenrollstatus where
	bankenrollstatus.[Status] = 'Submitted the Application' and bankenrollstatus.EnrollmentId=@BankEnrollId
	--and bankenrollstatus.IsUnlocked = 0
	order by bankenrollstatus.CreatedDate desc)
	where OfficeManagement.CustomerId=@CustomerId --and bankenrollstatus.EnrollmentId=@BankEnrollId
END


--update OfficeManagement 
--SET 
-- RejectedBanks= bank.BankName
--FROM BankEnrollmentHistory bankenrhis
--join BankMaster bank on bankenrhis.BankId = bank.Id
--Where OfficeManagement.CustomerId=@CustomerId and bankenrhis.CustomerId=@CustomerId and (bankenrhis.[Message] = 'Bank App Rejected' OR bankenrhis.[Message] = 'Bank App Denied')
--order by bankenrollstatus.CreatedDate desc

update OfficeManagement 
SET 
RejectedBanks= (SELECT  STUFF((SELECT  ',' + bm.BankName
				FROM BankEnrollment be
				join BankMaster bm on be.BankId = bm.Id
				WHERE  be.CustomerId=@CustomerId and (be.StatusCode = 'REJ' OR be.StatusCode = 'DEN' or be.StatusCode = 'CAN') and be.IsActive = 1
				--ORDER BY be.CreatedDate DESC
				FOR XML PATH('')), 1, 1, '') AS listStr) where OfficeManagement.CustomerId=@CustomerId



--and bankenrhis.UpdatedDate = (SELECT MAX(CreatedDate) as max_date
--FROM BankEnrollmentHistory
--WHERE EnrollmentId in (@BankEnrollId))


update OfficeManagement 
SET 
ApprovedBank= (SELECT  STUFF((SELECT ',' + bm.BankName
				FROM BankEnrollment be
				join BankMaster bm on be.BankId = bm.Id
				WHERE  be.CustomerId=@CustomerId and be.StatusCode = 'APR' and be.IsActive = 1
				--ORDER BY be.CreatedDate DESC
				FOR XML PATH('')), 1, 1, '') AS listStr) where OfficeManagement.CustomerId=@CustomerId

--(select top(1) bank.BankName
--FROM BankEnrollmentHistory bankenrhis
--join BankMaster bank on bankenrhis.BankId = bank.Id 
--Where bankenrhis.CustomerId=@CustomerId and (bankenrhis.[Message] = 'Bank App Approved') order by bankenrhis.CreatedDate) where OfficeManagement.CustomerId=@CustomerId

update OfficeManagement 
SET 
SubmittedBanks = (SELECT  STUFF((SELECT ',' + bm.BankName
				FROM BankEnrollment be
				join BankMaster bm on be.BankId = bm.Id
				WHERE  be.CustomerId=@CustomerId and (be.StatusCode = 'PEN' or be.StatusCode = 'SUB') and be.IsActive = 1
				ORDER BY be.CreatedDate DESC
				FOR XML PATH('')), 1, 1, '') AS listStr) where OfficeManagement.CustomerId=@CustomerId

--and bankenrhis.CustomerId =@CustomerId

--and bankenrhis.UpdatedDate = (SELECT MAX(CreatedDate) as max_date
--FROM BankEnrollmentHistory
--WHERE EnrollmentId in (@BankEnrollId))



--update OfficeManagement 
--SET 
--UnlockedBanks= bank.BankName
--FROM BankEnrollmentStatus bankenrstatus
--join BankEnrollment bankenroll on bankenrstatus.EnrollmentId = bankenroll.Id
--join BankMaster bank on bankenroll.BankId = bank.Id
--Where OfficeManagement.CustomerId=@CustomerId and bankenroll.CustomerId=@CustomerId  and bankenrstatus.IsUnlocked = 1 and bankenroll.IsActive = 1


update OfficeManagement 
SET 
UnlockedBanks= '' where OfficeManagement.CustomerId=@CustomerId

--(SELECT  STUFF((SELECT  ',' + bm.BankName
--				From BankEnrollmentStatus bs 
--				join BankEnrollment be on bs.EnrollmentId = be.Id
--				join BankMaster bm on be.BankId = bm.Id
--				WHERE  be.CustomerId=@CustomerId and bs.IsUnlocked = 1 and be.IsActive = 1
--				ORDER BY bs.CreatedDate DESC
--				FOR XML PATH('')), 1, 1, '') AS listStr) where OfficeManagement.CustomerId=@CustomerId


--and bankenrstatus.UpdatedDate = (SELECT MAX(CreatedDate) as max_date
--FROM BankEnrollmentHistory
--WHERE EnrollmentId in (@BankEnrollId))


--IsEnrollmentCompleted
--ActiveBankId
--ActiveBankName
--EnrollmentSubmittionDate
--EnrollmentPrimaryKey
--EnrollmentStatus
--ApprovedBank
--RejectedBank
--UnlockedBank


IF @RootParentId IS NULL
BEGIN
	IF @EntityId=2 OR @EntityId=3
		BEGIN
		update OfficeManagement 
		SET 
		IsTaxReturn= 1
		Where OfficeManagement.CustomerId=@CustomerId
		END
	ELSE 
		BEGIN
		update OfficeManagement 
		SET 
		IsTaxReturn= ISNULL(mainoffconfig.IsSiteTransmitTaxReturns,1)
		FROM MainOfficeConfiguration mainoffconfig
		Where OfficeManagement.CustomerId=@CustomerId and mainoffconfig.emp_CustomerInformation_ID=@CustomerId
		END
END
ELSE 
BEGIN
update OfficeManagement 
SET 
IsTaxReturn= 1
Where OfficeManagement.CustomerId=@CustomerId
END

   --var taxreturn = db.MainOfficeConfigurations.Where(x => x.emp_CustomerInformation_ID == itm.e.CustomerId).Select(x => x).FirstOrDefault();
   --                 ocustomer.IsTaxReturn = taxreturn == null ? true : taxreturn.IsSiteTransmitTaxReturns;
   --                 ocustomer.StatusCode = itm.e.StatusCode;



----Fee Related Stuff

update OfficeManagement 
SET 
SVBCanAddon= 0,
SVBCanEnroll= 0,
TRANCanAddon= 0,
TRANCanEnroll= 0
Where OfficeManagement.CustomerId=@CustomerId


IF (@EntityId<>2 AND  @EntityId<>3 AND  @EntityId<>4) AND @IsEnrollmentCompleted=1
BEGIN
	IF @RootParentId IS NULL
	BEGIN 
	update OfficeManagement 
	SET 
	SVBCanAddon= ssfee.IsAddOnFeeCharge,
	SVBCanEnroll= ssfee.IsSubSiteAddonFee
	FROM SubSiteFeeConfig ssfee
	Where OfficeManagement.CustomerId=@CustomerId and ssfee.emp_CustomerInformation_ID=@CustomerId and ssfee.ServiceorTransmission=1  and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')

	update OfficeManagement 
	SET 
	TRANCanAddon= ssfee.IsAddOnFeeCharge,
	TRANCanEnroll= ssfee.IsSubSiteAddonFee
	FROM SubSiteFeeConfig ssfee
	Where OfficeManagement.CustomerId=@CustomerId and ssfee.emp_CustomerInformation_ID=@CustomerId and ssfee.ServiceorTransmission=2 and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')

	-- Commented by Mani
	END
	ELSE 
	BEGIN 

		update OfficeManagement 
		SET 
		SVBCanAddon= ssfee.IsAddOnFeeCharge,
		SVBCanEnroll= ssfee.IsSubSiteAddonFee
		FROM SubSiteFeeConfig ssfee
		Where OfficeManagement.CustomerId=@CustomerId and ssfee.emp_CustomerInformation_ID=@RootParentId and ssfee.ServiceorTransmission=1 and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')

		update OfficeManagement 
		SET 
		TRANCanAddon= ssfee.IsAddOnFeeCharge,
		TRANCanEnroll= ssfee.IsSubSiteAddonFee
		FROM SubSiteFeeConfig ssfee
		Where OfficeManagement.CustomerId=@CustomerId and ssfee.emp_CustomerInformation_ID=@RootParentId and ssfee.ServiceorTransmission=2 and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')
	END
END

ELSE IF (@EntityId=2 OR  @EntityId=3 OR  @EntityId=4) AND @IsEnrollmentCompleted=1
BEGIN
update OfficeManagement 
SET 
SVBCanAddon= 1,
SVBCanEnroll= 1,
TRANCanAddon= 1,
TRANCanEnroll= 1
Where OfficeManagement.CustomerId=@CustomerId and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')

END
ELSE
BEGIN
update OfficeManagement 
SET 
SVBCanAddon= 0,
SVBCanEnroll= 0,
TRANCanAddon= 0,
TRANCanEnroll= 0
Where OfficeManagement.CustomerId=@CustomerId
END


update OfficeManagement 
SET 
uTaxSVBFee= fee.Amount
FROM FeeMaster fee
Where OfficeManagement.CustomerId=@CustomerId and fee.FeesFor=2 and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')

update OfficeManagement 
SET 
CrosslinkTransFee= fee.Amount
FROM FeeMaster fee
Where OfficeManagement.CustomerId=@CustomerId and fee.FeesFor=3 and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')


IF @ismsouser = 0
BEGIN

update OfficeManagement 
SET 
SVBAddonFee= ssbfee.BankMaxFees
FROM SubSiteBankFeesConfig ssbfee
Where OfficeManagement.CustomerId=@CustomerId 
and ssbfee.emp_CustomerInformation_ID=@CustomerId 
and ssbfee.ServiceOrTransmitter=1 
and ssbfee.BankMaster_ID = @BankId
and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')


update OfficeManagement 
SET 
TransAddonFee= ssbfee.BankMaxFees
FROM SubSiteBankFeesConfig ssbfee
Where OfficeManagement.CustomerId=@CustomerId and ssbfee.emp_CustomerInformation_ID=@CustomerId and ssbfee.ServiceOrTransmitter=2 and ssbfee.BankMaster_ID = @BankId
and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')

END
ELSE
BEGIN

update OfficeManagement 
SET 
SVBAddonFee= ssbfee.BankMaxFees_MSO
FROM SubSiteBankFeesConfig ssbfee
Where OfficeManagement.CustomerId=@CustomerId and ssbfee.emp_CustomerInformation_ID=@CustomerId and ssbfee.ServiceOrTransmitter=1 and ssbfee.BankMaster_ID = @BankId
and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')


update OfficeManagement 
SET 
TransAddonFee= ssbfee.BankMaxFees_MSO
FROM SubSiteBankFeesConfig ssbfee
Where OfficeManagement.CustomerId=@CustomerId and ssbfee.emp_CustomerInformation_ID=@CustomerId and ssbfee.ServiceOrTransmitter=2 and ssbfee.BankMaster_ID = @BankId
and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')

END

update OfficeManagement 
SET 
SVBEnrollAddonFee= enrollbanksel.ServiceBureauBankAmount
FROM EnrollmentBankSelection enrollbanksel
Where OfficeManagement.CustomerId=@CustomerId and enrollbanksel.CustomerId=@CustomerId and enrollbanksel.IsServiceBureauFee=1 and enrollbanksel.StatusCode ='ACT'
and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')

update OfficeManagement 
SET 
TransEnrollAddonFee= enrollbanksel.TransmissionBankAmount
FROM EnrollmentBankSelection enrollbanksel
Where OfficeManagement.CustomerId=@CustomerId and enrollbanksel.CustomerId=@CustomerId and enrollbanksel.IsTransmissionFee=1 and enrollbanksel.StatusCode ='ACT'
and OfficeManagement.EnrollmentStatus NOT IN ('INP','RDY')





--DECLARE @IsEnrollmentCompleted int =0;

--SELECT @IsEnrollmentCompleted = IsEnrollmentCompleted From OfficeManagement Where CustomerId=@CustomerId;

-- IF @EntityId=3
--BEGIN
--update OfficeManagement 
--SET CanEnrollmentAllowed = 0,
-- CanEnrollmentAllowedForMain = 0
--where OfficeManagement.ParentId=@CustomerId

--IF @IsEnrollmentCompleted = 1 
--BEGIN
--	update OfficeManagement 
--	SET CanEnrollmentAllowed = 1,
--	CanEnrollmentAllowedForMain=1
--	where OfficeManagement.ParentId=@CustomerId and OfficeManagement.IsActivationCompleted = 1 and (OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19)
--END
--END



IF @EntityId=3 --OR @EntityId=2
BEGIN
DECLARE @EnrollmentCompleted bit=0;
DECLARE @EnrollmentStatus varchar(10)='';
SELECT @EnrollmentCompleted=IsEnrollmentCompleted,@EnrollmentStatus=EnrollmentStatus From  OfficeManagement Where CustomerId=@CustomerId  and OfficeManagement.EnrollmentStatus in ('APR','REJ','RDY','SUB','PEN','DEN','CAN') 

update OfficeManagement 
		SET CanEnrollmentAllowed = 0,
		CanEnrollmentAllowedForMain=0
		where OfficeManagement.ParentId=@CustomerId--  and (OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19 OR OfficeManagement.EFINStatus=21)
	
IF @EnrollmentCompleted=1
	BEGIN
		update OfficeManagement 
		SET CanEnrollmentAllowed = 1,
		CanEnrollmentAllowedForMain=1
		where OfficeManagement.CustomerId in (select RefId from subsiteofficeconfig where RefId in (select CustomerId from OfficeManagement where Parentid=@CustomerId) and ((EFINListedOtherOffice=0) OR (EFINListedOtherOffice =1 and SiteOwnthisEFIN = 1)))
		 and OfficeManagement.IsActivationCompleted = 1 and (OfficeManagement.EFINStatus=16 OR OfficeManagement.EFINStatus=19 OR OfficeManagement.EFINStatus=21) and EFIN>0
	END
END



IF (@EntityId=3 OR @EntityId=7 OR @EntityId=13 OR @EntityId=15) --AND @IsActivationCompleted=1 --IsEnrolled=1
	BEGIN
		--Update OfficeManagement SET IsActivationCompleted=1,IsEnrollmentCompleted=1 ,StatusCode='ACT',AccountStatus='Active' Where ParentId = @CustomerId and EntityId in (4,8,14,16)
		--Update emp_CustomerInformation SET IsActivationCompleted=1, IsEnrolled=1 ,StatusCode='ACT',AccountStatus='Active' Where ParentId = @CustomerId and EntityId in (4,8,14,16)
		EXEC [ActivateAdditionalEFIN]  @CustomerId,@SalesYear
	END;

update OfficeManagement set CanEnrollmentAllowed = 0, CanEnrollmentAllowedForMain = 0 where CustomerId = @CustomerId and (IsHold = 1 or AccountStatus = 'Hold') 
and EntityId not in (2,5,9) -- added after mail Hold Status write up - for approval by Mani

END












GO
/****** Object:  StoredProcedure [dbo].[SetDefaultBankSP]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SetDefaultBankSP]
	-- Add the parameters for the stored procedure here
	@xCustomerId varchar(250)=null,
	@xUserId varchar(250)=null,
	@xBankId varchar(250)=null
	
AS
BEGIN
	DECLARE @CustomerId uniqueidentifier;
	DECLARE @UserId uniqueidentifier;
	DECLARE @BankId uniqueidentifier;

	SELECT  @CustomerId = CONVERT(uniqueidentifier, @xCustomerId)
	SELECT  @UserId = CONVERT(uniqueidentifier, @xUserId)
	SELECT  @BankId = CONVERT(uniqueidentifier, @xBankId)


	INSERT INTO AudtiLog_DefaultBank (NewValue,OldValue,ActionType,CustomerId,UpdatedBy,UpdatedDate) 
	select @BankId,BankId,'U',@CustomerId,@UserId,GETDATE() From EnrollmentBankSelection Where BankSubmissionStatus=1 and CustomerId=@CustomerId


	Update EnrollmentBankSelection SET BankSubmissionStatus=0 Where CustomerId=@CustomerId

	Update EnrollmentBankSelection SET BankSubmissionStatus=1 Where BankId=@BankId and CustomerId=@CustomerId
		

END;







GO
/****** Object:  StoredProcedure [dbo].[SF_SOSOME_Update]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SF_SOSOME_Update]
	-- Add the parameters for the stored procedure here
	@xCustomerId varchar(250)=null,
	@xUserId varchar(250)=null,
	@EFINListedOtherOffice bit = true,
	@SiteOwnthisEFIN bit = 1,
	@SubSiteSendTaxReturn bit = 1
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @CustomerId uniqueidentifier;
	DECLARE @UserId uniqueidentifier;
	SELECT  @CustomerId = CONVERT(uniqueidentifier, @xCustomerId)
	SELECT  @UserId = CONVERT(uniqueidentifier, @xUserId)


DECLARE @SalesYearId uniqueidentifier;

DECLARE @CrossLinkUserId varchar(100)=null;
DECLARE @CrossLinkPassword varchar(1000)=null;
DECLARE @IsMSOUser bit = 1;
DECLARE @Feeder bit=0

select @CrossLinkUserId=CrossLinkUserId,@CrossLinkPassword=CrossLinkPassword from emp_CustomerLoginInformation Where CustomerOfficeId = @CustomerId

SELECT 
@IsMSOUser=ISNULL(IsMSOUser,0),
@SalesYearId=SalesYearId,
@Feeder=ISNULL(Feeder,0),
@SubSiteSendTaxReturn=ISNULL(Feeder,0)
 FROM emp_CustomerInformation Where Id=@CustomerId
 
--DELETE FROM CustomerConfigurationStatus where CustomerId = @CustomerId

--- INSERT CONFIGURATION
IF NOT EXISTS (select *  FROM SubSiteOfficeConfig Where RefId = @CustomerId) --AND @Feeder=1
BEGIN
INSERT INTO [dbo].[SubSiteOfficeConfig]
 (
 Id,
 RefId,
 EFINListedOtherOffice,
 SiteOwnthisEFIN,
 SOorSSorEFIN,
 SubSiteSendTaxReturn,
 SiteanMSOLocation,
 StatusCode,
 CreatedBy,
 CreatedDate,
 LastUpdatedBy,
 LastUpdatedDate)
 VALUES (newid(),@CustomerId,@EFINListedOtherOffice,@SiteOwnthisEFIN,1,@SubSiteSendTaxReturn,@IsMSOUser,'ACT',@UserId,GETDATE(),@UserId,GETDATE())

 
 IF NOT EXISTS (select *  FROM CustomerConfigurationStatus Where CustomerId = @CustomerId AND SitemapId = (SELECT Id FROM SitemapMaster WHERE SitemapTypeID = 3 AND DisplayOrder IN (2) ))
 BEGIN
INSERT INTO [dbo].[CustomerConfigurationStatus] 
(SitemapId,
CustomerId,
StatusCode,
UpdatedBy,
UpdatedDate)
(SELECT Id,@CustomerId,'done',@UserId, GETDATE() FROM SitemapMaster WHERE (SitemapTypeID = 3) AND (DisplayOrder IN (2)))
END;
 END;

--- INSERT SUB SITE FEE CONFIG
IF NOT EXISTS (select * FROM SubSiteBankFeesConfig Where emp_CustomerInformation_ID = @CustomerId) -- AND @Feeder=1
BEGIN
INSERT INTO [dbo].[SubSiteBankFeesConfig] (
ID,
emp_CustomerInformation_ID,
BankMaster_ID,
BankMaxFees,
BankMaxFees_MSO,
ServiceOrTransmitter,
StatusCode,
CreatedBy,
CreatedDate,
LastUpdatedBy,
LastUpdatedDate
)
(select newid(), @CustomerId as CustomerId,  ban.Id,  CASE WHEN fee.FeesFor = 2 THEN  fee.Amount
            ELSE 0 END AS Amount,
			CASE WHEN @IsMSOUser = 1 AND fee.FeesFor = 2 THEN  fee.Amount
				 WHEN @IsMSOUser = 1 AND fee.FeesFor = 3 THEN  0
				 ELSE 0 END AS MSO_Amount,
					
			CASE WHEN fee.FeesFor = 2 THEN  1
            ELSE 2 END AS ServiceOrTrans,'ACT',@UserId,GETDATE(),@UserId,GETDATE()
 from BankMaster ban ,FeeMaster fee Where fee.FeesFor in (2,3))
 
  IF NOT EXISTS (select *  FROM CustomerConfigurationStatus Where CustomerId = @CustomerId AND SitemapId = (SELECT Id FROM SitemapMaster WHERE SitemapTypeID = 3 AND DisplayOrder IN (3) ))
 BEGIN
INSERT INTO [dbo].[CustomerConfigurationStatus] 
(SitemapId,
CustomerId,
StatusCode,
UpdatedBy,
UpdatedDate)
(SELECT Id,@CustomerId,'done',@UserId, GETDATE() FROM SitemapMaster WHERE (SitemapTypeID = 3) AND (DisplayOrder IN (3)))
END;
END;


 IF EXISTS (select * from emp_CustomerInformation where  Id =@CustomerId and  EFIN> 0 and 
CompanyName IS NOT null and 
BusinessOwnerFirstName IS NOT null and 
BusinesOwnerLastName IS NOT null and 
TitleId  IS NOT null and 
OfficePhone IS NOT null and 
PrimaryEmail IS NOT null and 
PhysicalAddress1 IS NOT null and 
PhysicalCity IS NOT null and 
PhysicalState IS NOT null and (Feeder = 1 OR IsVerified=1 )) AND  (@CrossLinkUserId IS NOT null and  @CrossLinkPassword IS NOT null)
BEGIN

 IF NOT EXISTS (select *  FROM CustomerConfigurationStatus Where CustomerId = @CustomerId AND SitemapId = (SELECT Id FROM SitemapMaster WHERE SitemapTypeID = 3 AND DisplayOrder IN (1) ))
 BEGIN
INSERT INTO [dbo].[CustomerConfigurationStatus] 
(SitemapId,
CustomerId,
StatusCode,
UpdatedBy,
UpdatedDate)
(SELECT Id,@CustomerId,'done',@UserId, GETDATE() FROM SitemapMaster WHERE (SitemapTypeID = 3) AND (DisplayOrder IN (1)))
END;

--[dbo].[SubSiteBankFeesConfig]

--Update  emp_CustomerInformation set StatusCode='ACT', IsActivationCompleted=1 Where Id = @CustomerId





END

DECLARE @menucount int = 0;

select @menucount=Count(Id)  FROM CustomerConfigurationStatus Where CustomerId = @CustomerId AND SitemapId in (SELECT Id FROM SitemapMaster WHERE SitemapTypeID = 3 AND DisplayOrder IN (1,2,3))

 IF @menucount =3 
 BEGIN

 Update  emp_CustomerInformation set StatusCode='ACT', IsActivationCompleted=1 Where Id = @CustomerId
 
 IF NOT EXISTS (select *  FROM CustomerConfigurationStatus Where CustomerId = @CustomerId AND SitemapId = (SELECT Id FROM SitemapMaster WHERE SitemapTypeID = 3 AND DisplayOrder IN (5) ))
 BEGIN
 INSERT INTO [dbo].[CustomerConfigurationStatus] 
(SitemapId,
CustomerId,
StatusCode,
UpdatedBy,
UpdatedDate)
(SELECT Id,@CustomerId,'done',@UserId, GETDATE() FROM SitemapMaster WHERE (SitemapTypeID = 3) AND (DisplayOrder IN (5)))

EXEC [dbo].[OfficeManagementGridSP] @CustomerId, @SalesYearId

END;

 END;




END;








GO
/****** Object:  StoredProcedure [dbo].[UpdateBankEnrollStatusAfterApprove]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[UpdateBankEnrollStatusAfterApprove]
  @xCustomerId varchar(250) = null,
  @xUserId varchar(250) = null
AS
BEGIN
declare @CustomerId uniqueidentifier;
declare @UserId uniqueidentifier;
Select @CustomerId = CONVERT(uniqueidentifier, @xCustomerId)
Select @UserId = CONVERT(uniqueidentifier, @xUserId)

IF EXISTS (select * from BankEnrollment Where CustomerId = @CustomerId and StatusCode='APR')
BEGIN

update BankEnrollment SET UpdatedBy=@UserId Where CustomerId = @CustomerId  and StatusCode='APR'

--INSERT INTO AuditLog_EnrollmentReset (NewValue,OldValue,=,'',ActionType,UserId=@UserId,UpdatedBy=@UserId,UpdatedDate=GetDate() Where CustomerId = @CustomerId

--update 
END;
END













GO
/****** Object:  StoredProcedure [dbo].[UpdateEFINAfterApprove]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[UpdateEFINAfterApprove]
  @xCustomerId varchar(250) = null,
  @xUserId varchar(250) = null,
  @OldEFIN int
AS
BEGIN
declare @CustomerId uniqueidentifier;
declare @UserId uniqueidentifier;
Select @CustomerId = CONVERT(uniqueidentifier, @xCustomerId)
Select @UserId = CONVERT(uniqueidentifier, @xUserId)

declare @NewEFIN int;

select @NewEFIN = EFIN from emp_CustomerInformation where Id=@CustomerId


IF EXISTS (select * from BankEnrollment Where CustomerId = @CustomerId and StatusCode='APR') and @NewEFIN != @OldEFIN
BEGIN
update BankEnrollment SET UpdatedBy=@UserId,IsActive=0,UpdatedDate=GETDATE() Where CustomerId = @CustomerId  and StatusCode='APR'
update EnrollmentBankSelection SET StatusCode='INA', LastUpdatedBy=@UserId,LastUpdatedDate=GETDATE(),BankSubmissionStatus=0,IsPreferredBank=0 Where CustomerId = @CustomerId  and StatusCode='ACT'
--INSERT INTO AuditLog_EnrollmentReset (NewValue,OldValue,=,'',ActionType,UserId=@UserId,UpdatedBy=@UserId,UpdatedDate=GetDate() Where CustomerId = @CustomerId

END;
END













GO
/****** Object:  StoredProcedure [dbo].[UpdateFeeAfterApprove]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[UpdateFeeAfterApprove]
  @xCustomerId varchar(250) = null,
  @xUserId varchar(250) = null
AS
BEGIN
declare @CustomerId uniqueidentifier;
declare @UserId uniqueidentifier;
Select @CustomerId = CONVERT(uniqueidentifier, @xCustomerId)
Select @UserId = CONVERT(uniqueidentifier, @xUserId)


Declare @entityid int=0;
Select @entityid = EntityId From OfficeManagement Where CustomerId=@CustomerId;

IF EXISTS (select * from BankEnrollment Where CustomerId = @CustomerId and StatusCode='APR') and (@entityid<>2 and @entityid<>3 and @entityid<>4)
BEGIN

update BankEnrollment SET UpdatedBy=@UserId,IsActive=0 Where CustomerId = @CustomerId  and StatusCode='APR'
update EnrollmentBankSelection SET  StatusCode='INA', LastUpdatedBy=@UserId,LastUpdatedDate=GETDATE(),BankSubmissionStatus=0,IsPreferredBank=0 Where CustomerId = @CustomerId  and StatusCode='ACT'
--INSERT INTO AuditLog_EnrollmentReset (NewValue,OldValue,=,'',ActionType,UserId=@UserId,UpdatedBy=@UserId,UpdatedDate=GetDate() Where CustomerId = @CustomerId

--update 
END;
END













GO
/****** Object:  UserDefinedFunction [dbo].[SplitString]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitString]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS @Output TABLE (
      Item NVARCHAR(1000)
)
AS
BEGIN
      DECLARE @StartIndex INT, @EndIndex INT
 
      SET @StartIndex = 1
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
      BEGIN
            SET @Input = @Input + @Character
      END
 
      WHILE CHARINDEX(@Character, @Input) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Input)
           
            INSERT INTO @Output(Item)
            SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)
           
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
      END
 
      RETURN
END












GO
/****** Object:  Table [dbo].[AccessTypeMaster]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccessTypeMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_AccessTypeMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AffiliateProgramMaster]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AffiliateProgramMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Cost] [decimal](18, 2) NULL,
	[ActivationDate] [datetime] NULL,
	[DeactivationDate] [datetime] NULL,
	[DocumentPath] [nvarchar](250) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](50) NULL,
 CONSTRAINT [PK_AffiliateProgram] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AffiliationProgramEntityMap]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AffiliationProgramEntityMap](
	[Id] [uniqueidentifier] NOT NULL,
	[AffiliateProgramId] [uniqueidentifier] NULL,
	[EntityId] [int] NULL,
 CONSTRAINT [PK_AffiliationProgramCustomerMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[APIIntegrations]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[APIIntegrations](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](150) NULL,
	[URL] [nvarchar](250) NULL,
	[UserName] [nvarchar](150) NULL,
	[Password] [nvarchar](150) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_Integration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AuditLog]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AuditLog](
	[AuditLogID] [bigint] IDENTITY(1,1) NOT NULL,
	[TableName] [nvarchar](250) NULL,
	[PrimaryKey] [varchar](500) NULL,
	[AuditStatus] [varchar](10) NULL,
	[FieldName] [varchar](500) NULL,
	[NewValue] [text] NULL,
	[OldValue] [text] NULL,
	[TokenId] [uniqueidentifier] NULL,
	[UserId] [uniqueidentifier] NULL,
	[DateStamp] [datetime] NULL,
 CONSTRAINT [PK_AuditLog] PRIMARY KEY CLUSTERED 
(
	[AuditLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AuditLog_EFIN]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AuditLog_EFIN](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[NewEFIN] [int] NULL,
	[OldEFIN] [int] NULL,
	[ActionType] [varchar](10) NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_AuditLog_EFIN] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AuditLog_EnrollmentReset]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AuditLog_EnrollmentReset](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[NewValue] [varchar](50) NULL,
	[OldValue] [varchar](50) NULL,
	[ActionType] [varchar](10) NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_AuditLog_EnrollmentReset] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AudtiLog_DefaultBank]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AudtiLog_DefaultBank](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[NewValue] [varchar](50) NULL,
	[OldValue] [varchar](50) NULL,
	[ActionType] [varchar](10) NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_AudtiLog_DefaultBank] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankAssociatedCutofDate]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankAssociatedCutofDate](
	[Id] [uniqueidentifier] NOT NULL,
	[BankID] [uniqueidentifier] NOT NULL,
	[SalesYearID] [uniqueidentifier] NOT NULL,
	[CutofDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BankEnrollment]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BankEnrollment](
	[Id] [uniqueidentifier] NOT NULL,
	[BankId] [uniqueidentifier] NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[EntityId] [int] NULL,
	[SalesYearId] [uniqueidentifier] NULL,
	[StatusCode] [varchar](10) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[ArchiveStatusCode] [varchar](10) NULL,
 CONSTRAINT [PK_BankEnrollment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankEnrollmentEFINOwnersForRA]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BankEnrollmentEFINOwnersForRA](
	[Id] [uniqueidentifier] NOT NULL,
	[BankEnrollmentRAId] [uniqueidentifier] NOT NULL,
	[FirstName] [nvarchar](150) NULL,
	[LastName] [nvarchar](150) NULL,
	[EmailId] [nvarchar](150) NULL,
	[DateofBirth] [varchar](50) NULL,
	[SSN] [varchar](50) NULL,
	[HomePhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[Address] [varchar](150) NULL,
	[City] [varchar](50) NULL,
	[StateId] [varchar](50) NULL,
	[ZipCode] [varchar](50) NULL,
	[IDNumber] [varchar](50) NULL,
	[IDState] [varchar](50) NULL,
	[PercentageOwned] [decimal](18, 2) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[StatusCode] [varchar](10) NULL,
 CONSTRAINT [PK_BankEnrollmentEFINOwnersForRA] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankEnrollmentForRA]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BankEnrollmentForRA](
	[Id] [uniqueidentifier] NOT NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[EfinID] [varchar](50) NULL,
	[OwnerEmail] [varchar](150) NULL,
	[OwnerFirstName] [varchar](50) NULL,
	[OwnerLastName] [varchar](50) NULL,
	[OwnerSSN] [varchar](50) NULL,
	[OwnerDOB] [datetime] NULL,
	[OwnerCellPhone] [varchar](10) NULL,
	[OwnerHomePhone] [varchar](10) NULL,
	[OwnerAddress] [varchar](100) NULL,
	[OwnerCity] [varchar](50) NULL,
	[OwnerState] [varchar](50) NULL,
	[OwnerZipCode] [varchar](10) NULL,
	[OwnerStateIssuedIdNumber] [varchar](50) NULL,
	[OwnerIssuingState] [varchar](50) NULL,
	[EROOfficeName] [varchar](100) NULL,
	[EROOfficeAddress] [varchar](500) NULL,
	[EROOfficeCity] [varchar](50) NULL,
	[EROOfficeState] [varchar](50) NULL,
	[EROOfficeZipCoce] [varchar](20) NULL,
	[EROOfficePhone] [varchar](20) NULL,
	[EROMaillingAddress] [varchar](500) NULL,
	[EROMailingCity] [varchar](50) NULL,
	[EROMailingState] [varchar](50) NULL,
	[EROMailingZipcode] [varchar](20) NULL,
	[EROShippingAddress] [varchar](500) NULL,
	[EROShippingCity] [varchar](50) NULL,
	[EROShippingState] [varchar](50) NULL,
	[EROShippingZip] [varchar](50) NULL,
	[IRSAddress] [varchar](50) NULL,
	[IRSCity] [varchar](50) NULL,
	[IRSState] [varchar](50) NULL,
	[IRSZipcode] [varchar](10) NULL,
	[PreviousYearVolume] [int] NULL,
	[ExpectedCurrentYearVolume] [int] NULL,
	[PreviousBankName] [varchar](50) NULL,
	[CorporationType] [varchar](50) NULL,
	[CollectionofBusinessOwners] [varchar](50) NULL,
	[CollectionOfOtherOwners] [varchar](50) NULL,
	[NoofYearsExperience] [int] NULL,
	[HasAssociatedWithVictims] [varchar](50) NULL,
	[BusinessFederalIDNumber] [varchar](10) NULL,
	[BusinessEIN] [varchar](50) NULL,
	[EFINOwnersSite] [varchar](50) NULL,
	[IsLastYearClient] [varchar](50) NULL,
	[BankRoutingNumber] [varchar](10) NULL,
	[BankAccountNumber] [varchar](50) NULL,
	[BankAccountType] [varchar](50) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[StatusCode] [varchar](50) NULL,
	[OwnerTitle] [varchar](50) NULL,
	[SbFeeall] [varchar](50) NULL,
	[TransmissionAddon] [varchar](50) NULL,
	[SbFee] [varchar](50) NULL,
	[ElectronicFee] [varchar](50) NULL,
	[AgreeTandC] [bit] NULL,
	[BankName] [varchar](50) NULL,
	[AccountName] [varchar](50) NULL,
	[MainContactFirstName] [varchar](50) NULL,
	[MainContactLastName] [varchar](50) NULL,
	[MainContactPhone] [varchar](50) NULL,
	[TextMessages] [bit] NULL,
	[LegalIssues] [bit] NULL,
	[StateOfIncorporation] [varchar](50) NULL,
	[IsEnrtyCompleted] [bit] NULL,
	[EntryLevel] [int] NULL,
	[IsUpdated] [bit] NULL,
 CONSTRAINT [PK_BankEnrollmentForRA] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankEnrollmentForRB]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BankEnrollmentForRB](
	[Id] [uniqueidentifier] NOT NULL,
	[OfficeName] [varchar](50) NULL,
	[OfficePhysicalAddress] [varchar](50) NULL,
	[OfficePhysicalCity] [varchar](50) NULL,
	[OfficePhysicalState] [varchar](50) NULL,
	[OfficePhysicalZip] [varchar](10) NULL,
	[OfficeContactFirstName] [varchar](50) NULL,
	[OfficeContactLastName] [varchar](50) NULL,
	[OfficeContactSSN] [varchar](10) NULL,
	[OfficePhoneNumber] [varchar](15) NULL,
	[CellPhoneNumber] [varchar](15) NULL,
	[OfficeContactDOB] [datetime] NULL,
	[FAXNumber] [varchar](10) NULL,
	[EmailAddress] [varchar](150) NULL,
	[OfficeManagerFirstName] [varchar](50) NULL,
	[OfficeManageLastName] [varchar](50) NULL,
	[OfficeManagerSSN] [varchar](10) NULL,
	[OfficeManagerDOB] [datetime] NULL,
	[OfficeManagerPhone] [varchar](15) NULL,
	[OfficeManagerCellNo] [varchar](15) NULL,
	[OfficeManagerEmail] [varchar](150) NULL,
	[AltOfficeContact1FirstName] [varchar](50) NULL,
	[AltOfficeContact1LastName] [varchar](50) NULL,
	[AltOfficeContact1Email] [varchar](150) NULL,
	[AltOfficeContact1SSn] [varchar](5) NULL,
	[AltOfficeContact2FirstName] [varchar](50) NULL,
	[AltOfficeContact2LastName] [varchar](50) NULL,
	[AltOfficeContact2Email] [varchar](150) NULL,
	[AltOfficeContact2SSn] [varchar](5) NULL,
	[AltOfficePhysicalAddress] [varchar](150) NULL,
	[AltOfficePhysicalAddress2] [varchar](150) NULL,
	[AltOfficePhysicalCity] [varchar](50) NULL,
	[AltOfficePhysicalState] [varchar](50) NULL,
	[AltOfficePhysicalZipcode] [varchar](50) NULL,
	[MailingAddress] [varchar](50) NULL,
	[MailingCity] [varchar](50) NULL,
	[MailingState] [varchar](50) NULL,
	[MailingZip] [varchar](10) NULL,
	[FulfillmentShippingAddress] [varchar](50) NULL,
	[FulfillmentShippingCity] [varchar](50) NULL,
	[FulfillmentShippingState] [varchar](50) NULL,
	[FulfillmentShippingZip] [varchar](10) NULL,
	[WebsiteAddress] [varchar](150) NULL,
	[YearsinBusiness] [int] NULL,
	[NoofBankProductsLastYear] [int] NULL,
	[PreviousBankProductFacilitator] [varchar](10) NULL,
	[ActualNoofBankProductsLastYear] [int] NULL,
	[OwnerFirstName] [varchar](50) NULL,
	[OwnerLastName] [varchar](50) NULL,
	[OwnerSSN] [varchar](10) NULL,
	[OnwerDOB] [datetime] NULL,
	[OwnerHomePhone] [varchar](15) NULL,
	[OwnerAddress] [varchar](50) NULL,
	[OwnerCity] [varchar](50) NULL,
	[OwnerState] [varchar](50) NULL,
	[OwnerZip] [varchar](10) NULL,
	[LegarEntityStatus] [varchar](1) NULL,
	[LLCMembershipRegistration] [varchar](1) NULL,
	[BusinessName] [varchar](50) NULL,
	[BusinessEIN] [varchar](10) NULL,
	[BusinessIncorporation] [datetime] NULL,
	[EFINOwnerFirstName] [varchar](50) NULL,
	[EFINOwnerLastName] [varchar](50) NULL,
	[EFINOwnerSSN] [varchar](10) NULL,
	[EFINOwnerDOB] [datetime] NULL,
	[IsMultiOffice] [varchar](50) NULL,
	[ProductsOffering] [int] NULL,
	[IsOfficeTransmit] [varchar](50) NULL,
	[IsPTIN] [varchar](50) NULL,
	[IsAsPerProcessLaw] [varchar](50) NULL,
	[IsAsPerComplainceLaw] [varchar](50) NULL,
	[ConsumerLending] [varchar](50) NULL,
	[NoofPersoneel] [int] NULL,
	[AdvertisingApproval] [varchar](50) NULL,
	[EROParticipation] [varchar](50) NULL,
	[SPAAmount] [decimal](18, 2) NULL,
	[SPADate] [datetime] NULL,
	[RetailPricingMethod] [varchar](1) NULL,
	[IsLockedStore_Documents] [varchar](50) NULL,
	[IsLockedStore_Checks] [varchar](50) NULL,
	[IsLocked_Office] [varchar](50) NULL,
	[IsLimitAccess] [varchar](50) NULL,
	[PlantoDispose] [varchar](50) NULL,
	[LoginAccesstoEmployees] [varchar](50) NULL,
	[AntivirusRequired] [varchar](50) NULL,
	[HasFirewall] [varchar](50) NULL,
	[OnlineTraining] [varchar](50) NULL,
	[PasswordRequired] [varchar](50) NULL,
	[EROApplicattionDate] [datetime] NULL,
	[EROReadTAndC] [varchar](50) NULL,
	[CheckingAccountName] [varchar](50) NULL,
	[BankRoutingNumber] [varchar](50) NULL,
	[BankAccountNumber] [varchar](50) NULL,
	[BankAccountType] [varchar](50) NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[StatusCode] [varchar](50) NULL,
	[EFINOwnerTitle] [varchar](50) NULL,
	[EFINOwnerAddress] [varchar](50) NULL,
	[EFINOwnerCity] [varchar](50) NULL,
	[EFINOwnerState] [varchar](50) NULL,
	[EFINOwnerZip] [varchar](50) NULL,
	[EFINOwnerPhone] [varchar](50) NULL,
	[EFINOwnerMobile] [varchar](50) NULL,
	[EFINOwnerEmail] [varchar](50) NULL,
	[EFINOwnerIDNumber] [varchar](50) NULL,
	[EFINOwnerIDState] [varchar](50) NULL,
	[EFINOwnerEIN] [varchar](50) NULL,
	[SupportOS] [varchar](50) NULL,
	[BankName] [varchar](50) NULL,
	[SBFeeonAll] [varchar](50) NULL,
	[SBFee] [varchar](50) NULL,
	[TransimissionAddon] [varchar](50) NULL,
	[PrepaidCardProgram] [varchar](50) NULL,
	[TandC] [bit] NULL,
	[IsEnrtyCompleted] [bit] NULL,
	[EntryLevel] [int] NULL,
	[IsUpdated] [bit] NULL,
 CONSTRAINT [PK_BankEnrollmentForRB] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankEnrollmentForTPG]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BankEnrollmentForTPG](
	[Id] [uniqueidentifier] NOT NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[CompanyName] [varchar](100) NULL,
	[ManagerFirstName] [varchar](50) NULL,
	[ManagerLastName] [varchar](50) NULL,
	[OfficeAddress] [varchar](150) NULL,
	[OfficeCity] [varchar](50) NULL,
	[OfficeState] [varchar](10) NULL,
	[OfficeZip] [varchar](12) NULL,
	[OfficeTelephone] [varchar](15) NULL,
	[OfficeFAX] [varchar](50) NULL,
	[ShippingAddress] [varchar](150) NULL,
	[ShippingCity] [varchar](50) NULL,
	[ShippingState] [varchar](10) NULL,
	[ShippingZip] [varchar](12) NULL,
	[ManagerEmail] [varchar](150) NULL,
	[EFINOwnerEIN] [varchar](50) NULL,
	[EFINOwnerSSN] [varchar](50) NULL,
	[EFINOwnerFirstName] [varchar](50) NULL,
	[EFINOwnerLastName] [varchar](50) NULL,
	[EFINOwnerAddress] [varchar](150) NULL,
	[EFINOwnerCity] [varchar](50) NULL,
	[EFINOwnerState] [varchar](10) NULL,
	[EFINOwnerZip] [varchar](12) NULL,
	[EFINOwnerTelephone] [varchar](15) NULL,
	[EFINOwnerDOB] [datetime] NULL,
	[EFINOwnerEmail] [varchar](150) NULL,
	[BankUsedLastYear] [varchar](3) NULL,
	[PriorYearEFIN] [varchar](50) NULL,
	[PriorYearVolume] [varchar](50) NULL,
	[PriorYearFund] [varchar](50) NULL,
	[OfficeRTN] [varchar](50) NULL,
	[OfficeDAN] [varchar](50) NULL,
	[OfficeAccountType] [varchar](3) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[OwnerTitle] [varchar](50) NULL,
	[OwnerMobile] [varchar](50) NULL,
	[OwnerIdNumber] [varchar](50) NULL,
	[OwnerIdState] [varchar](50) NULL,
	[DocPrepFee] [varchar](50) NULL,
	[BankName] [varchar](50) NULL,
	[AccountName] [varchar](50) NULL,
	[AddonFee] [varchar](50) NULL,
	[ServiceBureauFee] [varchar](50) NULL,
	[AgreeBank] [bit] NULL,
	[FeeOnAll] [varchar](50) NULL,
	[CheckPrint] [varchar](50) NULL,
	[StatusCode] [varchar](50) NULL,
	[IsEnrtyCompleted] [bit] NULL,
	[EntryLevel] [int] NULL,
	[IsUpdated] [bit] NULL,
 CONSTRAINT [PK_BankEnrollmentForTPG] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankEnrollmentHistory]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BankEnrollmentHistory](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[BankId] [uniqueidentifier] NULL,
	[EnrollmentId] [uniqueidentifier] NULL,
	[Status] [bit] NULL,
	[Message] [varchar](max) NULL,
	[Paramaeters] [varchar](max) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_BankEnrollmentHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankEnrollmentInvalid]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankEnrollmentInvalid](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[IsValid] [bit] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_BankEnrollmentInvalid] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BankEnrollmentStatus]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BankEnrollmentStatus](
	[Id] [uniqueidentifier] NOT NULL,
	[EnrollmentId] [uniqueidentifier] NULL,
	[Status] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[IsUnlocked] [bit] NULL,
	[Reason] [varchar](max) NULL,
	[UnlockedBy] [uniqueidentifier] NULL,
	[UnlockedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_BankEnrollmentStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankEntityMap]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankEntityMap](
	[Id] [uniqueidentifier] NOT NULL,
	[BankId] [uniqueidentifier] NOT NULL,
	[EntityId] [int] NULL,
 CONSTRAINT [PK_BankEntityMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BankMaster]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BankMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[BankName] [nvarchar](100) NULL,
	[BankCode] [varchar](5) NULL,
	[BankServiceFees] [decimal](18, 2) NULL,
	[MaxFeeLimitDeskTop] [decimal](18, 2) NULL,
	[MaxTranFeeDeskTop] [decimal](18, 2) NULL,
	[MaxFeeLimitMSO] [decimal](18, 2) NULL,
	[MaxTranFeeMSO] [decimal](18, 2) NULL,
	[ActivatedDate] [datetime] NULL,
	[BankProductDocument] [nvarchar](500) NULL,
	[DeActivatedDate] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
	[Description] [nvarchar](500) NULL,
 CONSTRAINT [PK_BankMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankSubQuestions]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankSubQuestions](
	[Id] [uniqueidentifier] NOT NULL,
	[BankId] [uniqueidentifier] NOT NULL,
	[Questions] [nvarchar](250) NOT NULL,
	[ActivatedDate] [datetime] NULL,
	[DeActivatedDate] [datetime] NULL,
	[Description] [nvarchar](500) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
	[Options] [int] NULL,
 CONSTRAINT [PK_BankSubQuestions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ContactPersonTitleCustomerMap]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactPersonTitleCustomerMap](
	[Id] [uniqueidentifier] NOT NULL,
	[ContactPersonTitleId] [uniqueidentifier] NULL,
	[CustomerId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_ContactPersonTitleCustomerMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ContactPersonTitleMaster]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactPersonTitleMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[ContactPersonTitle] [nvarchar](30) NOT NULL,
	[ActivatedDate] [datetime] NOT NULL,
	[Description] [nvarchar](150) NULL,
	[TypeId] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_ContactPersonTitle] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerAssociatedFees]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerAssociatedFees](
	[ID] [uniqueidentifier] NOT NULL,
	[emp_CustomerInformation_ID] [uniqueidentifier] NOT NULL,
	[FeeMaster_ID] [uniqueidentifier] NOT NULL,
	[Amount] [decimal](10, 2) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsEdit] [bit] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [uniqueidentifier] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK__Transmit__3214EC275BAD9CC8] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerConfigurationStatus]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerConfigurationStatus](
	[Id] [uniqueidentifier] NOT NULL,
	[SitemapId] [uniqueidentifier] NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[StatusCode] [varchar](10) NULL,
	[bankid] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_CustomerConfigurationStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerMaster]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[EntityId] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_CustomerMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerNotes]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerNotes](
	[Id] [uniqueidentifier] NOT NULL,
	[RefId] [uniqueidentifier] NOT NULL,
	[Note] [varchar](max) NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__Customer__3214EC073BFFE745] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerPaymentOptions]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerPaymentOptions](
	[Id] [uniqueidentifier] NOT NULL,
	[CustomerId] [uniqueidentifier] NOT NULL,
	[BankId] [uniqueidentifier] NULL,
	[PaymentType] [int] NULL,
	[IsSameasBankAccount] [int] NULL,
	[SiteType] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_CustomerPaymentOptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerPaymentViaACH]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerPaymentViaACH](
	[Id] [uniqueidentifier] NOT NULL,
	[PaymentOptionId] [uniqueidentifier] NOT NULL,
	[AccountName] [varchar](50) NULL,
	[BankName] [varchar](50) NULL,
	[RTN] [varchar](50) NULL,
	[AccountNumber] [varchar](50) NULL,
	[AccountType] [int] NULL,
	[CreatdedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_CustomerPaymentViaACH] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerPaymentViaCreditCard]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerPaymentViaCreditCard](
	[Id] [uniqueidentifier] NOT NULL,
	[PaymentOptionId] [uniqueidentifier] NOT NULL,
	[CardHolderName] [varchar](50) NULL,
	[Cardtype] [int] NULL,
	[BillingAddress] [varchar](250) NULL,
	[CardNumber] [varchar](16) NULL,
	[Expiration] [varchar](10) NULL,
	[City] [varchar](50) NULL,
	[State] [int] NULL,
	[ZipCode] [varchar](50) NULL,
	[CreatdedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_CustomerPaymentViaCreditCard] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerUnlock]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerUnlock](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerId] [uniqueidentifier] NOT NULL,
	[IsUnlocked] [bit] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [uniqueidentifier] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CustomerUnlock] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DocumentMaster]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DocumentMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[FileName] [varchar](50) NOT NULL,
	[FileType] [varchar](50) NOT NULL,
	[FileData] [varbinary](max) NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DocumentMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmailNotification]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmailNotification](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[EmailType] [int] NULL,
	[EmailTo] [varchar](250) NULL,
	[EmailCC] [varchar](max) NULL,
	[EmailSubject] [varchar](500) NULL,
	[EmailContent] [varchar](max) NULL,
	[Parameters] [varchar](max) NULL,
	[IsSent] [bit] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[SentDate] [datetime] NULL,
 CONSTRAINT [PK_EmailNotification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EMP_ActionMaser]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EMP_ActionMaser](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentId] [bigint] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[ForActive] [int] NOT NULL,
	[Status] [varchar](10) NULL,
	[DisplayOrder] [int] NULL,
	[EntityId] [int] NULL,
 CONSTRAINT [PK_EMP_ActionMaser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[emp_CustomerInformation]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[emp_CustomerInformation](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyName] [varchar](100) NULL,
	[ParentId] [uniqueidentifier] NULL,
	[AccountStatus] [varchar](20) NULL,
	[EntityId] [int] NULL,
	[Feeder] [bit] NULL,
	[BusinessOwnerFirstName] [nvarchar](100) NULL,
	[BusinesOwnerLastName] [varchar](100) NULL,
	[OfficePhone] [nvarchar](30) NULL,
	[AlternatePhone] [nvarchar](15) NULL,
	[PrimaryEmail] [nvarchar](100) NULL,
	[SupportNotificationEmail] [nvarchar](100) NULL,
	[EROType] [varchar](50) NULL,
	[AlternativeContact] [nvarchar](50) NULL,
	[AlternativeType] [uniqueidentifier] NULL,
	[EFIN] [int] NULL,
	[PhysicalAddress1] [nvarchar](200) NULL,
	[PhysicalAddress2] [nvarchar](200) NULL,
	[PhysicalZipCode] [varchar](50) NULL,
	[PhysicalCity] [varchar](50) NULL,
	[PhysicalState] [varchar](50) NULL,
	[ShippingAddressSameAsPhysicalAddress] [bit] NOT NULL,
	[ShippingAddress1] [nvarchar](200) NULL,
	[ShippingAddress2] [nvarchar](200) NULL,
	[ShippingZipCode] [varchar](50) NULL,
	[ShippingCity] [varchar](50) NULL,
	[ShippingState] [varchar](50) NULL,
	[PhoneTypeId] [uniqueidentifier] NULL,
	[TitleId] [uniqueidentifier] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
	[SalesforceAccountID] [nchar](18) NULL,
	[SalesforceOpportunityID] [nchar](18) NULL,
	[SalesYearID] [uniqueidentifier] NULL,
	[SalesforceParentID] [nvarchar](100) NULL,
	[Type] [varchar](50) NULL,
	[QuoteSoftwarePackage] [varchar](50) NULL,
	[CoBranding] [bit] NULL,
	[TPGCheckpointSoftware] [bit] NULL,
	[MSOUser] [bit] NULL,
	[uTaxNotCollectingSBFee] [bit] NULL,
	[IsAdditionalEFINAllowed] [bit] NULL,
	[MasterIdentifier] [nvarchar](100) NULL,
	[IsActivationCompleted] [int] NULL,
	[IsCSRUpdated] [bit] NOT NULL,
	[CSRUpdatedDt] [datetime] NULL,
	[EnrollmentPrimaryKey] [uniqueidentifier] NULL,
	[OnBoardPrimaryKey] [uniqueidentifier] NULL,
	[IsVerified] [bit] NULL,
	[IsMSOUser] [bit] NULL,
	[IsEnrolled] [bit] NULL,
	[EnrolledBankId] [uniqueidentifier] NULL,
	[SalesYearGroupId] [uniqueidentifier] NULL,
	[Tax_Season__c] [varchar](10) NULL,
	[Cash_Saver__c] [varchar](10) NULL,
	[pymt__Balance__c] [decimal](18, 4) NULL,
	[LOC_Program_Participant__c] [varchar](10) NULL,
	[Total_Amount_Loaned__c] [decimal](18, 4) NULL,
	[A_R_Amount_Due_Credit__c] [decimal](18, 4) NULL,
	[Federal_EF_Fee_New__c] [decimal](18, 4) NULL,
	[State_EF_Fee_New__c] [decimal](18, 4) NULL,
	[EFINStatus] [int] NULL,
	[IsArchived] [int] NULL,
	[IsHold] [bit] NULL,
	[Quote_Rebate__c] [bit] NOT NULL,
	[HoldDescription] [varchar](200) NULL,
	[AlternatePhoneTypeId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_emp_CustomerInformation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[emp_CustomerLoginInformation]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emp_CustomerLoginInformation](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterIdentifier] [nvarchar](50) NULL,
	[CrossLinkUserId] [nvarchar](50) NULL,
	[CrossLinkPassword] [nvarchar](500) NULL,
	[EMPUserId] [nvarchar](50) NULL,
	[EMPPassword] [nvarchar](500) NULL,
	[OfficePortalUrl] [nvarchar](150) NULL,
	[TaxOfficeUsername] [nvarchar](100) NULL,
	[TaxOfficePassword] [nvarchar](500) NULL,
	[CustomerOfficeId] [uniqueidentifier] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
	[CLAccountId] [nvarchar](50) NULL,
	[CLLogin] [nvarchar](50) NULL,
	[CLAccountPassword] [nvarchar](500) NULL,
 CONSTRAINT [PK_emp_CustomerLoginInformation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EnrollmentAddonStaging]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnrollmentAddonStaging](
	[Id] [uniqueidentifier] NOT NULL,
	[IsSvbFee] [bit] NOT NULL,
	[SvbAddonAmount] [decimal](18, 4) NOT NULL,
	[IsTransmissionFee] [bit] NOT NULL,
	[TransmissionAddonAmount] [decimal](18, 4) NOT NULL,
	[BankSelectionId] [uniqueidentifier] NOT NULL,
	[BankId] [uniqueidentifier] NOT NULL,
	[CustomerId] [uniqueidentifier] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_EnrollmentAddonStaging] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EnrollmentAffiliateConfiguration]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EnrollmentAffiliateConfiguration](
	[Id] [uniqueidentifier] NOT NULL,
	[CustomerId] [uniqueidentifier] NOT NULL,
	[AffiliateProgramId] [uniqueidentifier] NOT NULL,
	[AffiliateProgramCharge] [decimal](18, 2) NULL,
	[StatusCode] [varchar](10) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[LastUpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_EnrollmentAffiliateConfiguration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EnrollmentBankSelection]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EnrollmentBankSelection](
	[Id] [uniqueidentifier] NOT NULL,
	[CustomerId] [uniqueidentifier] NOT NULL,
	[BankId] [uniqueidentifier] NOT NULL,
	[QuestionId] [uniqueidentifier] NOT NULL,
	[IsServiceBureauFee] [bit] NULL,
	[ServiceBureauBankAmount] [decimal](9, 2) NULL,
	[IsTransmissionFee] [bit] NULL,
	[TransmissionBankAmount] [decimal](9, 2) NULL,
	[BankSubmissionStatus] [int] NULL,
	[IsPreferredBank] [bit] NULL,
	[StatusCode] [varchar](10) NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_SubSiteOfficeBankSelection] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EnrollmentFeeReimbursementConfig]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EnrollmentFeeReimbursementConfig](
	[ID] [uniqueidentifier] NOT NULL,
	[emp_CustomerInformation_ID] [uniqueidentifier] NOT NULL,
	[BankId] [uniqueidentifier] NULL,
	[AccountName] [varchar](50) NOT NULL,
	[BankName] [varchar](50) NOT NULL,
	[AccountType] [int] NOT NULL,
	[RTN] [varchar](15) NOT NULL,
	[BankAccountNo] [varchar](50) NOT NULL,
	[IsAuthorize] [bit] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [uniqueidentifier] NOT NULL,
	[StatusCode] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_EnrollmentFeeReimbursementConfig] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EnrollmentOfficeConfiguration]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EnrollmentOfficeConfiguration](
	[Id] [uniqueidentifier] NOT NULL,
	[CustomerId] [uniqueidentifier] NOT NULL,
	[IsMainSiteTransmitTaxReturn] [bit] NULL,
	[NoofTaxProfessionals] [int] NULL,
	[IsSoftwareOnNetwork] [bit] NULL,
	[NoofComputers] [int] NULL,
	[PreferredLanguage] [int] NULL,
	[StatusCode] [varchar](10) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_EnrollmentOfficeConfiguration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EntityActionPermissions]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EntityActionPermissions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EntityId] [int] NULL,
	[ActionId] [bigint] NULL,
	[Status] [varchar](10) NULL,
 CONSTRAINT [PK_EntityActionPermissions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EntityHierarchy]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EntityHierarchy](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[RelationId] [uniqueidentifier] NULL,
	[Customer_Level] [int] NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[EntityId] [int] NULL,
	[Status] [varchar](10) NULL,
 CONSTRAINT [PK_EntityHierarchy] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EntityMaster]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EntityMaster](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ParentId] [int] NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](150) NULL,
	[AccessTypeId] [uniqueidentifier] NULL,
	[DisplayOrder] [int] NULL,
	[FeeSourceEntityId] [int] NULL,
	[BaseEntityId] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
	[IsAdditionalEFINAllowed] [bit] NOT NULL,
 CONSTRAINT [PK_EntityMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Error]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Error](
	[ErrorId] [bigint] IDENTITY(1,1) NOT NULL,
	[Query] [varchar](max) NULL,
	[Parameter] [varchar](max) NULL,
	[CommandType] [varchar](max) NULL,
	[TotalSeconds] [decimal](18, 2) NULL,
	[Exception] [varchar](max) NULL,
	[InnerException] [varchar](max) NULL,
	[RequestId] [int] NULL,
	[FileName] [varchar](500) NULL,
	[CreateDate] [datetime] NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_Error] PRIMARY KEY CLUSTERED 
(
	[ErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ExceptionLog]    Script Date: 28-08-2017 19:13:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExceptionLog](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ExceptionMessage] [varchar](max) NULL,
	[UserId] [uniqueidentifier] NULL,
	[MethodName] [varchar](max) NULL,
	[CreatedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_ExceptionLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FeeEntityMap]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeeEntityMap](
	[Id] [uniqueidentifier] NOT NULL,
	[FeeId] [uniqueidentifier] NULL,
	[EntityId] [int] NULL,
 CONSTRAINT [PK_FeeEntityMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeeMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FeeMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[FeeType] [nvarchar](50) NULL,
	[FeeTypeId] [smallint] NULL,
	[Amount] [decimal](10, 2) NULL,
	[FeeNature] [nvarchar](50) NULL,
	[FeeNatureId] [smallint] NULL,
	[ActivatedDate] [datetime] NULL,
	[DeActivatedDate] [datetime] NULL,
	[NoteForUser] [nvarchar](150) NULL,
	[Note] [nvarchar](150) NULL,
	[FeeCategoryID] [int] NOT NULL,
	[IsIncludedMaxAmtCalculation] [bit] NOT NULL,
	[SalesforceFeesFieldID] [varchar](50) NOT NULL,
	[FeesFor] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_FeeMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FeeReimbursementConfig]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FeeReimbursementConfig](
	[ID] [uniqueidentifier] NOT NULL,
	[emp_CustomerInformation_ID] [uniqueidentifier] NOT NULL,
	[AccountName] [varchar](50) NOT NULL,
	[BankName] [varchar](50) NOT NULL,
	[AccountType] [int] NOT NULL,
	[RTN] [varchar](15) NOT NULL,
	[BankAccountNo] [varchar](50) NOT NULL,
	[IsAuthorize] [bit] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [uniqueidentifier] NOT NULL,
	[StatusCode] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK__FeeReimb__3214EC27503BEA1C] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GroupMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](150) NULL,
	[Description] [nvarchar](250) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_Groups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GroupRoleMap]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupRoleMap](
	[Id] [uniqueidentifier] NOT NULL,
	[GroupId] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_GroupRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MainOfficeConfiguration]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MainOfficeConfiguration](
	[Id] [uniqueidentifier] NOT NULL,
	[emp_CustomerInformation_ID] [uniqueidentifier] NOT NULL,
	[IsSiteTransmitTaxReturns] [bit] NOT NULL,
	[IsSiteOfferBankProducts] [bit] NOT NULL,
	[TaxProfessionals] [int] NOT NULL,
	[IsSoftwarebeInstalledNetwork] [bit] NOT NULL,
	[ComputerswillruninSoftware] [int] NOT NULL,
	[PreferredSupportLanguage] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [uniqueidentifier] NOT NULL,
	[StatusCode] [nvarchar](10) NOT NULL,
	[HasBusinessSoftware] [bit] NOT NULL,
	[IsSharingEfin] [bit] NOT NULL,
 CONSTRAINT [PK__MainOffi__3214EC0747A6A41B] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NotificationMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Data] [nvarchar](max) NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_NotificationMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OfficeManagement]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OfficeManagement](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[ParentId] [uniqueidentifier] NULL,
	[EntityId] [int] NULL,
	[BaseEntityId] [int] NULL,
	[CompanyName] [nvarchar](500) NULL,
	[BusinessOwnerFirstName] [nvarchar](100) NULL,
	[BusinessOwnerLastName] [nvarchar](100) NULL,
	[OfficePhone] [nvarchar](30) NULL,
	[EMPUserId] [nvarchar](50) NULL,
	[EMPPassword] [nvarchar](500) NULL,
	[EFIN] [int] NULL,
	[MasterIdentifier] [nvarchar](100) NULL,
	[IsActivationCompleted] [int] NULL,
	[IsVerified] [bit] NULL,
	[AccountStatus] [varchar](20) NULL,
	[StatusCode] [varchar](20) NULL,
	[SVBFee] [decimal](10, 2) NULL,
	[uTaxSVBFee] [decimal](10, 2) NULL,
	[SVBAddonFee] [decimal](10, 2) NULL,
	[SVBEnrollAddonFee] [decimal](10, 2) NULL,
	[TransmissionFee] [decimal](10, 2) NULL,
	[CrosslinkTransFee] [decimal](10, 2) NULL,
	[TransAddonFee] [decimal](10, 2) NULL,
	[TransEnrollAddonFee] [decimal](10, 2) NULL,
	[SalesYearId] [uniqueidentifier] NULL,
	[SVBCanAddon] [bit] NULL,
	[SVBCanEnroll] [bit] NULL,
	[TRANCanAddon] [bit] NULL,
	[TRANCanEnroll] [bit] NULL,
	[CanEnrollmentAllowed] [bit] NULL,
	[IsEnrollmentCompleted] [bit] NULL,
	[ActiveBankId] [uniqueidentifier] NULL,
	[ActiveBankName] [varchar](150) NULL,
	[EnrollmentSubmittionDate] [datetime] NULL,
	[EnrollmentPrimaryKey] [uniqueidentifier] NULL,
	[EnrollmentStatus] [varchar](50) NULL,
	[ApprovedBank] [varchar](250) NULL,
	[SubmittedBanks] [varchar](250) NULL,
	[RejectedBanks] [varchar](250) NULL,
	[UnlockedBanks] [varchar](250) NULL,
	[OnBoardPrimaryKey] [uniqueidentifier] NULL,
	[OnboardingStatus] [varchar](20) NULL,
	[IsAdditionalEFINAllowed] [bit] NULL,
	[IsTaxReturn] [bit] NULL,
	[EFINStatus] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[CanEnrollmentAllowedForMain] [bit] NULL,
	[IsArchived] [int] NULL,
	[IsHold] [bit] NULL,
	[OnboardStatusTooltip] [varchar](max) NULL,
 CONSTRAINT [PK_OfficeManagement_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PermissionMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PermissionMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_PermissionMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PhoneTypeCustomerMap]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhoneTypeCustomerMap](
	[Id] [uniqueidentifier] NOT NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[PhoneTypeId] [uniqueidentifier] NULL,
	[PoneNumber] [nvarchar](20) NULL,
 CONSTRAINT [PK_CustomerPhoneTypeMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PhoneTypeMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhoneTypeMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[PhoneType] [nvarchar](30) NOT NULL,
	[ActivatedDate] [datetime] NOT NULL,
	[Description] [nvarchar](150) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_PhoneTypeMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RoleMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsVisible] [bit] NOT NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_RoleMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RolePermissionMap]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RolePermissionMap](
	[Id] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NULL,
	[PermissionId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_RolePermissionMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Salesforce_Account]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Salesforce_Account](
	[SFDC_AccountSyncID] [bigint] IDENTITY(1,1) NOT NULL,
	[AccountID] [nchar](18) NULL,
	[Master_Identifier__c] [nvarchar](8) NULL,
	[EFIN__c] [nvarchar](6) NULL,
	[Transmission_Password__c] [nvarchar](8) NULL,
	[ParentID] [nchar](18) NULL,
	[Feeder_Sites__c] [varchar](5) NULL,
	[Name] [nvarchar](255) NULL,
	[ERO_Type__c] [nvarchar](255) NULL,
	[BillingStreet] [nvarchar](255) NULL,
	[BillingCity] [nvarchar](40) NULL,
	[BillingState] [nvarchar](80) NULL,
	[BillingPostalCode] [nvarchar](20) NULL,
	[ShippingStreet] [nvarchar](255) NULL,
	[ShippingCIty] [nvarchar](40) NULL,
	[ShippingState] [nvarchar](80) NULL,
	[ShippingPostalCode] [nvarchar](20) NULL,
	[MSO_User__c] [varchar](5) NULL,
	[Co_Branding__c] [varchar](5) NULL,
	[TPG_Check_Print_Software__c] [varchar](5) NULL,
	[LastActivityDate] [datetime2](7) NULL,
	[LastModifiedDate] [datetime2](7) NULL,
	[User_ID__c] [nvarchar](6) NULL,
	[EFIN_Status__c] [nvarchar](50) NULL,
 CONSTRAINT [PK_Salesforce_Account] PRIMARY KEY CLUSTERED 
(
	[SFDC_AccountSyncID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Salesforce_Contact]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Salesforce_Contact](
	[SFDC_ContactSyncID] [bigint] IDENTITY(1,1) NOT NULL,
	[ContactID] [nchar](18) NOT NULL,
	[AccountID] [nchar](18) NOT NULL,
	[FirstName] [nvarchar](40) NULL,
	[LastName] [nvarchar](40) NULL,
	[Email] [nvarchar](40) NULL,
	[Primary_Contact__c] [varchar](5) NULL,
	[Phone] [nvarchar](40) NULL,
	[Title] [nvarchar](128) NULL,
	[LastActivityDate] [datetime2](7) NULL,
	[LastModifiedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Salesforce_Contact] PRIMARY KEY CLUSTERED 
(
	[SFDC_ContactSyncID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Salesforce_Opportunity]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Salesforce_Opportunity](
	[SFDC_OpportunitySyncID] [bigint] IDENTITY(1,1) NOT NULL,
	[OpportunityID] [nchar](18) NOT NULL,
	[AccountID] [nchar](18) NOT NULL,
	[OpportunityOwnerID] [nchar](18) NOT NULL,
	[AccountOwnerID] [nchar](18) NULL,
	[Tax_Season__c] [nvarchar](255) NULL,
	[Quote_Software_Package__c] [nvarchar](255) NULL,
	[uTax_Not_Collecting_SB_Fees__c] [varchar](5) NULL,
	[Transmitter_Fee__c] [decimal](18, 2) NULL,
	[Technology_Fee__c] [decimal](18, 2) NULL,
	[Quote_Bank_Product_uTax_Fee__c] [decimal](18, 2) NULL,
	[Quote_Federal_EF_Fee__c] [decimal](18, 2) NULL,
	[Quote_State_EF_Fee__c] [decimal](18, 2) NULL,
	[OpportunityType] [nvarchar](40) NULL,
	[StageName] [nvarchar](40) NULL,
	[OpportunityLastModifiedDate] [datetime2](7) NULL,
	[OpportunityLastActivityDate] [datetime2](7) NULL,
	[IsEMPCustomerCreated] [bit] NULL,
	[EMPCustomerID] [nvarchar](255) NULL,
	[EmpCustomerCreatedDtTm] [datetime] NULL,
	[User_ID__c] [nvarchar](6) NULL,
	[A_R_Amount_Due_Credit__c] [decimal](18, 2) NULL,
	[Cash_Saver__c] [varchar](5) NULL,
	[pymt__Balance__c] [decimal](18, 2) NULL,
	[LOC_Program_Participant__c] [varchar](5) NULL,
	[Total_Amount_Loaned__c] [decimal](18, 0) NULL,
	[Federal_EF_Fee_New__c] [decimal](18, 2) NULL,
	[State_EF_Fee_New__c] [decimal](18, 2) NULL,
 CONSTRAINT [PK_Salesforce_Opportunity] PRIMARY KEY CLUSTERED 
(
	[SFDC_OpportunitySyncID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[salesforce_sync_summary]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[salesforce_sync_summary](
	[salesforce_sync_summary_id] [bigint] IDENTITY(1,1) NOT NULL,
	[sync_timestamp] [datetime] NOT NULL,
	[salesforceOpportunityID] [varchar](200) NULL,
	[salesforceAccountID] [varchar](200) NULL,
	[EROType] [varchar](100) NULL,
	[OpportunityLastActivityDate] [datetime] NULL,
	[OpportunityLastModifiedDate] [datetime] NULL,
	[AccountLastActivityDate1] [datetime] NULL,
	[AccountLastModifiedDate1] [datetime] NULL,
	[emp_CustomerID] [varchar](100) NULL,
	[SalesYear] [varchar](50) NULL,
	[Lastsync_timestamp] [datetime] NULL,
	[Emp_LastUpdatedDate] [datetime] NULL,
	[IsEMPtoSFDC] [bit] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SalesYearEntityMap]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesYearEntityMap](
	[Id] [uniqueidentifier] NOT NULL,
	[SalesYearId] [uniqueidentifier] NULL,
	[EntityId] [int] NULL,
 CONSTRAINT [PK_SalesYearEntityMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SalesYearMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesYearMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[SalesYear] [int] NULL,
	[ApplicableFromDate] [datetime] NULL,
	[ApplicableToDate] [datetime] NULL,
	[Description] [nvarchar](500) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
	[DateType] [bit] NULL,
 CONSTRAINT [PK_SalesYear] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SecurityAnswerUserMap]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SecurityAnswerUserMap](
	[Id] [uniqueidentifier] NOT NULL,
	[Answer] [nvarchar](150) NOT NULL,
	[QuestionId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[DisplayOrder] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_UserSecurityAnswerMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SecurityQuestionMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SecurityQuestionMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[Question] [nvarchar](150) NULL,
	[Description] [nvarchar](250) NULL,
	[DisplayOrder] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_SecurityQuestionMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SitemapEntity]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SitemapEntity](
	[Id] [int] NOT NULL,
	[SitemapId] [uniqueidentifier] NULL,
	[EntityId] [int] NULL,
	[StatusCode] [varchar](10) NULL,
	[DisplayOrder] [int] NULL,
	[DisplayPartial] [bit] NULL,
	[DisplayClass] [varchar](50) NULL,
 CONSTRAINT [PK_SitemapEntity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SitemapMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SitemapMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[ParentId] [uniqueidentifier] NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](250) NULL,
	[URL] [nvarchar](200) NULL,
	[DisplayOrder] [int] NULL,
	[SitemapTypeID] [int] NULL,
	[IsVisible] [bit] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
	[IsDisplayAfterActivation] [int] NULL,
	[IsDisplayBeforeActvation] [int] NULL,
	[DisplayOrderAfterAct] [int] NULL,
	[DisplayOrderBeforeAct] [int] NULL,
	[DisplayBeforeVerify] [int] NULL,
 CONSTRAINT [PK_Sitemap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SitemapPermissionMap]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SitemapPermissionMap](
	[Id] [uniqueidentifier] NOT NULL,
	[SiteMapId] [uniqueidentifier] NULL,
	[PermissionId] [uniqueidentifier] NULL,
	[IsVisisble] [bit] NULL,
 CONSTRAINT [PK_SitemapPermissionMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SiteMapRolePermission]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SiteMapRolePermission](
	[Id] [uniqueidentifier] NOT NULL,
	[SiteMapId] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[PermissionId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_SiteMapRolePermission] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[StateMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StateMaster](
	[StateID] [int] IDENTITY(1,1) NOT NULL,
	[StateName] [varchar](20) NULL,
	[StateCode] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[StateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StatusCode]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StatusCode](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](15) NULL,
	[DisplayText] [varchar](50) NULL,
	[IsActive] [bit] NULL,
	[RefType] [varchar](25) NULL,
	[RefTypeId] [int] NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_StatusCode] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SubSiteAffiliateProgramConfig]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubSiteAffiliateProgramConfig](
	[ID] [uniqueidentifier] NOT NULL,
	[emp_CustomerInformation_ID] [uniqueidentifier] NOT NULL,
	[AffiliateProgramMaster_ID] [uniqueidentifier] NOT NULL,
	[SubSiteConfiguration_ID] [uniqueidentifier] NOT NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SubSiteBankConfig]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubSiteBankConfig](
	[ID] [uniqueidentifier] NOT NULL,
	[emp_CustomerInformation_ID] [uniqueidentifier] NOT NULL,
	[BankMaster_ID] [uniqueidentifier] NOT NULL,
	[SubSiteConfiguration_ID] [uniqueidentifier] NOT NULL,
	[SubQuestion_ID] [uniqueidentifier] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK__SubSiteB__3214EC2757DD0BE4] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SubSiteBankFeesConfig]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubSiteBankFeesConfig](
	[ID] [uniqueidentifier] NOT NULL,
	[emp_CustomerInformation_ID] [uniqueidentifier] NOT NULL,
	[BankMaster_ID] [uniqueidentifier] NOT NULL,
	[SubSiteFeeConfig_ID] [uniqueidentifier] NULL,
	[BankMaxFees] [decimal](10, 2) NOT NULL,
	[BankMaxFees_MSO] [decimal](10, 2) NULL,
	[ServiceOrTransmitter] [int] NULL,
	[QuestionID] [uniqueidentifier] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK__SubSiteB__3214EC2766603565] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SubSiteConfiguration]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SubSiteConfiguration](
	[ID] [uniqueidentifier] NOT NULL,
	[emp_CustomerInformation_ID] [uniqueidentifier] NOT NULL,
	[IsuTaxManageingEnrolling] [bit] NULL,
	[IsuTaxPortalEnrollment] [bit] NULL,
	[IsuTaxManageOnboarding] [bit] NULL,
	[IsuTaxCustomerSupport] [bit] NULL,
	[CanSubSiteLoginToEmp] [bit] NOT NULL,
	[NoofSupportStaff] [int] NULL,
	[NoofDays] [varchar](20) NULL,
	[OpenHours] [time](7) NULL,
	[CloseHours] [time](7) NULL,
	[TimeZone] [varchar](50) NULL,
	[IsAutoEnrollAffiliateProgram] [bit] NULL,
	[SubSiteTaxReturn] [int] NULL,
	[IsSubSiteEFINAllow] [bit] NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [uniqueidentifier] NOT NULL,
	[StatusCode] [nvarchar](10) NOT NULL,
	[EnrollmentEmails] [bit] NULL,
 CONSTRAINT [PK__SubSiteC__3214EC274C6B5938] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SubSiteFeeConfig]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubSiteFeeConfig](
	[ID] [uniqueidentifier] NOT NULL,
	[emp_CustomerInformation_ID] [uniqueidentifier] NOT NULL,
	[IsAddOnFeeCharge] [bit] NOT NULL,
	[IsSameforAll] [bit] NOT NULL,
	[IsSubSiteAddonFee] [bit] NOT NULL,
	[ServiceorTransmission] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [uniqueidentifier] NOT NULL,
	[StatusCode] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK__SubSiteF__3214EC275F7E2DAC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SubSiteOfficeBankFeeConfig]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SubSiteOfficeBankFeeConfig](
	[Id] [uniqueidentifier] NOT NULL,
	[RefId] [uniqueidentifier] NOT NULL,
	[BankID] [uniqueidentifier] NOT NULL,
	[ServiceorTransmitter] [int] NOT NULL,
	[Amount] [decimal](9, 2) NOT NULL,
	[AmountType] [int] NOT NULL,
	[QuestionID] [uniqueidentifier] NOT NULL,
	[StatusCode] [varchar](10) NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__SubSiteF__3214EC0743A1090D] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SubSiteOfficeConfig]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SubSiteOfficeConfig](
	[Id] [uniqueidentifier] NOT NULL,
	[RefId] [uniqueidentifier] NOT NULL,
	[EFINListedOtherOffice] [bit] NOT NULL,
	[SiteOwnthisEFIN] [bit] NOT NULL,
	[EFINOwnerSite] [varchar](50) NULL,
	[SOorSSorEFIN] [int] NOT NULL,
	[SubSiteSendTaxReturn] [bit] NOT NULL,
	[SiteanMSOLocation] [bit] NOT NULL,
	[IsMainSiteTransmitTaxReturn] [bit] NULL,
	[NoofTaxProfessionals] [int] NULL,
	[IsSoftwareOnNetwork] [bit] NULL,
	[NoofComputers] [int] NULL,
	[PreferredLanguage] [int] NULL,
	[CanSubSiteLoginToEmp] [bit] NULL,
	[StatusCode] [varchar](10) NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [uniqueidentifier] NOT NULL,
	[HasBusinessSoftware] [bit] NOT NULL,
	[IsSharingEFIN] [bit] NOT NULL,
 CONSTRAINT [PK__SubSiteO__3214EC073FD07829] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[temp3]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[temp3](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[ParentId] [uniqueidentifier] NULL,
	[EntityId] [int] NULL,
	[BaseEntityId] [int] NULL,
	[CompanyName] [nvarchar](500) NULL,
	[BusinessOwnerFirstName] [nvarchar](100) NULL,
	[BusinessOwnerLastName] [nvarchar](100) NULL,
	[OfficePhone] [nvarchar](30) NULL,
	[EMPUserId] [nvarchar](50) NULL,
	[EMPPassword] [nvarchar](500) NULL,
	[EFIN] [int] NULL,
	[MasterIdentifier] [nvarchar](100) NULL,
	[IsActivationCompleted] [int] NULL,
	[IsVerified] [bit] NULL,
	[AccountStatus] [varchar](20) NULL,
	[StatusCode] [varchar](20) NULL,
	[SVBFee] [decimal](18, 0) NULL,
	[uTaxSVBFee] [decimal](18, 0) NULL,
	[SVBAddonFee] [decimal](18, 0) NULL,
	[SVBEnrollAddonFee] [decimal](18, 0) NULL,
	[TransmissionFee] [decimal](18, 0) NULL,
	[CrosslinkTransFee] [decimal](18, 0) NULL,
	[TransAddonFee] [decimal](18, 0) NULL,
	[TransEnrollAddonFee] [decimal](18, 0) NULL,
	[SalesYearId] [uniqueidentifier] NULL,
	[SVBCanAddon] [bit] NULL,
	[SVBCanEnroll] [bit] NULL,
	[TRANCanAddon] [bit] NULL,
	[TRANCanEnroll] [bit] NULL,
	[CanEnrollmentAllowed] [bit] NULL,
	[IsEnrollmentCompleted] [bit] NULL,
	[ActiveBankId] [uniqueidentifier] NULL,
	[ActiveBankName] [varchar](150) NULL,
	[EnrollmentSubmittionDate] [datetime] NULL,
	[EnrollmentPrimaryKey] [uniqueidentifier] NULL,
	[EnrollmentStatus] [varchar](50) NULL,
	[ApprovedBank] [varchar](250) NULL,
	[RejectedBanks] [varchar](250) NULL,
	[UnlockedBanks] [varchar](250) NULL,
	[OnBoardPrimaryKey] [uniqueidentifier] NULL,
	[OnboardingStatus] [varchar](20) NULL,
	[IsAdditionalEFINAllowed] [bit] NULL,
	[IsTaxReturn] [bit] NULL,
	[row] [bigint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TempArchiveCustomerInfo]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempArchiveCustomerInfo](
	[CustomerId] [uniqueidentifier] NOT NULL,
	[Status] [varchar](50) NULL,
	[TokenId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TempArchiveCustomerInfo] PRIMARY KEY CLUSTERED 
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tmpHierarchy]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchy](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchy0]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchy0](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchy1]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchy1](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchy12]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchy12](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchy123]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchy123](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchy2]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchy2](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchy3]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchy3](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchy4]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchy4](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchy5]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchy5](
	[CustomerId] [uniqueidentifier] NULL,
	[ParentId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchyFilter]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchyFilter](
	[CustomerId] [uniqueidentifier] NULL,
	[ParentId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchyFilters]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchyFilters](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchyFilters2]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchyFilters2](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpHierarchyMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpHierarchyMaster](
	[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TokenMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TokenMaster](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[AuthToken] [nvarchar](500) NOT NULL,
	[IssuedOn] [datetime] NOT NULL,
	[ExpiredOn] [datetime] NOT NULL,
	[StatusCode] [nvarchar](5) NULL,
	[IPAddress] [varchar](250) NULL,
 CONSTRAINT [PK_TokenMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TooltipMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TooltipMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[Field] [varchar](1000) NULL,
	[ToolTipText] [nvarchar](1000) NULL,
	[Description] [nvarchar](max) NULL,
	[SitemapId] [uniqueidentifier] NULL,
	[IsUIVisible] [bit] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_TooltipMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UpdateBankEnrollmentStatus_AuditLog]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UpdateBankEnrollmentStatus_AuditLog](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[NewValue] [varchar](50) NULL,
	[OldValue] [varchar](50) NULL,
	[ActionType] [varchar](10) NULL,
	[UserId] [uniqueidentifier] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_UpdateBankEnrollmentStatus_AuditLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserGroupMap]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserGroupMap](
	[Id] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[GroupId] [uniqueidentifier] NOT NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_UserGroupsMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [int] NULL,
	[CustomerId] [uniqueidentifier] NULL,
	[FirstName] [nvarchar](32) NOT NULL,
	[LastName] [nvarchar](32) NOT NULL,
	[UserName] [nvarchar](32) NOT NULL,
	[Password] [nvarchar](128) NOT NULL,
	[EmailAddress] [nvarchar](256) NOT NULL,
	[IsEmailConfirmed] [bit] NOT NULL,
	[EmailConfirmationCode] [nvarchar](128) NULL,
	[PasswordResetCode] [nvarchar](328) NULL,
	[LastLoginDate] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[IsActiveDate] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[StatusCode] [nvarchar](10) NULL,
	[IsFirstLogin] [bit] NULL,
 CONSTRAINT [PK_UserMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserNotificationsMap]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserNotificationsMap](
	[Id] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[NotificationId] [uniqueidentifier] NOT NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_UserNotificationsMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserRolesMap]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRolesMap](
	[Id] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[StatusCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_UserRolesMap] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UtaxCrosslinkDetails]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UtaxCrosslinkDetails](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](50) NULL,
	[Password] [varchar](500) NULL,
	[StatusCode] [varchar](50) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[CLAccountId] [nvarchar](50) NULL,
	[CLLogin] [nvarchar](50) NULL,
	[CLAccountPassword] [nvarchar](500) NULL,
 CONSTRAINT [PK_UtaxCrosslinkDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[uTaxSettings]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[uTaxSettings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AccountCreation] [bit] NULL,
	[StatusCode] [varchar](50) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedBy] [uniqueidentifier] NULL,
	[LastUpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_uTaxSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ZipCodeMaster]    Script Date: 28-08-2017 19:13:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ZipCodeMaster](
	[ZIPID] [int] IDENTITY(1,1) NOT NULL,
	[ZipCode] [varchar](12) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Latitude] [varchar](20) NULL,
	[Longitude] [varchar](20) NULL,
	[TimeZone] [varchar](20) NULL,
	[dst] [varchar](20) NULL,
 CONSTRAINT [PK_ZIPID] PRIMARY KEY CLUSTERED 
(
	[ZIPID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[AccessTypeMaster] ADD  CONSTRAINT [DF_AccessTypeMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[AffiliateProgramMaster] ADD  CONSTRAINT [DF_AffiliateProgramMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[AffiliationProgramEntityMap] ADD  CONSTRAINT [DF_AffiliationProgramCustomerMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[APIIntegrations] ADD  CONSTRAINT [DF_APIIntegrations_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[AuditLog_EFIN] ADD  CONSTRAINT [DF_AuditLog_EFIN_UpdatedDate]  DEFAULT (getdate()) FOR [UpdatedDate]
GO
ALTER TABLE [dbo].[AuditLog_EnrollmentReset] ADD  CONSTRAINT [DF_AuditLog_EnrollmentReset_UpdatedDate]  DEFAULT (getdate()) FOR [UpdatedDate]
GO
ALTER TABLE [dbo].[AudtiLog_DefaultBank] ADD  CONSTRAINT [DF_AudtiLog_DefaultBank_UpdatedDate]  DEFAULT (getdate()) FOR [UpdatedDate]
GO
ALTER TABLE [dbo].[BankAssociatedCutofDate] ADD  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[BankEnrollment] ADD  CONSTRAINT [DF_BankEnrollment_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[BankEnrollmentEFINOwnersForRA] ADD  CONSTRAINT [DF_BankEnrollmentEFINOwnersForRA_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[BankEnrollmentForRA] ADD  CONSTRAINT [DF_BankEnrollmentForRA_IsUpdated]  DEFAULT ((0)) FOR [IsUpdated]
GO
ALTER TABLE [dbo].[BankEnrollmentForRB] ADD  CONSTRAINT [DF_BankEnrollmentForRB_IsUpdated]  DEFAULT ((0)) FOR [IsUpdated]
GO
ALTER TABLE [dbo].[BankEnrollmentForTPG] ADD  CONSTRAINT [DF_BankEnrollmentForTPG_IsEnrtyCompleted]  DEFAULT ((0)) FOR [IsEnrtyCompleted]
GO
ALTER TABLE [dbo].[BankEntityMap] ADD  CONSTRAINT [DF_BankEntityMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[BankMaster] ADD  CONSTRAINT [DF_BankMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[BankSubQuestions] ADD  CONSTRAINT [DF_BankSubQuestions_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[ContactPersonTitleCustomerMap] ADD  CONSTRAINT [DF_ContactPersonTitleCustomerMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[ContactPersonTitleMaster] ADD  CONSTRAINT [DF_ContactPersonTitle_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[ContactPersonTitleMaster] ADD  CONSTRAINT [DF_ContactPersonTitleMaster_TypeId]  DEFAULT ((0)) FOR [TypeId]
GO
ALTER TABLE [dbo].[CustomerAssociatedFees] ADD  CONSTRAINT [DF_CustomerAssociatedFees_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[CustomerConfigurationStatus] ADD  CONSTRAINT [DF_CustomerConfigurationStatus_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[CustomerMaster] ADD  CONSTRAINT [DF_CustomerMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[CustomerUnlock] ADD  CONSTRAINT [DF_CustomerUnlock_IsUnlocked]  DEFAULT ((0)) FOR [IsUnlocked]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  CONSTRAINT [DF_emp_CustomerInformation_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  CONSTRAINT [DF_emp_CustomerInformation_EFIN]  DEFAULT ((0)) FOR [EFIN]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  CONSTRAINT [DF_emp_CustomerInformation_ShippingAddressSameAsPhysicalAddress]  DEFAULT ((0)) FOR [ShippingAddressSameAsPhysicalAddress]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  CONSTRAINT [DF_emp_CustomerInformation_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  CONSTRAINT [DF__emp_Custo__Sales__0B91BA14]  DEFAULT ('') FOR [SalesforceParentID]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  CONSTRAINT [DF_emp_CustomerInformation_IsActivationCompleted]  DEFAULT ((0)) FOR [IsActivationCompleted]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  CONSTRAINT [DF_emp_CustomerInformation_IsCSRUpdated]  DEFAULT ((0)) FOR [IsCSRUpdated]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  CONSTRAINT [DF_emp_CustomerInformation_IsVerified]  DEFAULT ((0)) FOR [IsVerified]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  CONSTRAINT [DF_emp_CustomerInformation_IsArchived]  DEFAULT ((0)) FOR [IsArchived]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  CONSTRAINT [DF_emp_CustomerInformation_IsHold]  DEFAULT ((0)) FOR [IsHold]
GO
ALTER TABLE [dbo].[emp_CustomerInformation] ADD  DEFAULT ((0)) FOR [Quote_Rebate__c]
GO
ALTER TABLE [dbo].[emp_CustomerLoginInformation] ADD  CONSTRAINT [DF_emp_CustomerLoginInformation_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[EnrollmentAddonStaging] ADD  CONSTRAINT [DF_EnrollmentAddonStaging_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[EnrollmentAddonStaging] ADD  CONSTRAINT [DF_EnrollmentAddonStaging_IsSvbFee]  DEFAULT ((0)) FOR [IsSvbFee]
GO
ALTER TABLE [dbo].[EnrollmentAddonStaging] ADD  CONSTRAINT [DF_EnrollmentAddonStaging_SvbAddonAmount]  DEFAULT ((0)) FOR [SvbAddonAmount]
GO
ALTER TABLE [dbo].[EnrollmentAddonStaging] ADD  CONSTRAINT [DF_EnrollmentAddonStaging_IsTransmissionFee]  DEFAULT ((0)) FOR [IsTransmissionFee]
GO
ALTER TABLE [dbo].[EnrollmentAddonStaging] ADD  CONSTRAINT [DF_Table_1_AddonAmount]  DEFAULT ((0)) FOR [TransmissionAddonAmount]
GO
ALTER TABLE [dbo].[EnrollmentAddonStaging] ADD  CONSTRAINT [DF_EnrollmentAddonStaging_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[EnrollmentAffiliateConfiguration] ADD  CONSTRAINT [DF_EnrollmentAffiliateConfiguration_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[EnrollmentBankSelection] ADD  CONSTRAINT [DF_SubSiteOfficeBankSelection_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[EnrollmentBankSelection] ADD  CONSTRAINT [DF_EnrollmentBankSelection_BankSubmissionStatus]  DEFAULT ((0)) FOR [BankSubmissionStatus]
GO
ALTER TABLE [dbo].[EnrollmentBankSelection] ADD  CONSTRAINT [DF_EnrollmentBankSelection_IsPreferredBank]  DEFAULT ((0)) FOR [IsPreferredBank]
GO
ALTER TABLE [dbo].[EnrollmentOfficeConfiguration] ADD  CONSTRAINT [DF_EnrollmentOfficeConfiguration_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[EntityMaster] ADD  CONSTRAINT [DF_EntityMaster_IsAdditionalEFINAllowed]  DEFAULT ((0)) FOR [IsAdditionalEFINAllowed]
GO
ALTER TABLE [dbo].[ExceptionLog] ADD  CONSTRAINT [DF_ExceptionLog_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[FeeEntityMap] ADD  CONSTRAINT [DF_FeeEntityMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[FeeMaster] ADD  CONSTRAINT [DF_FeeMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[FeeMaster] ADD  CONSTRAINT [DF__FeeMaster__FeeCa__10216507]  DEFAULT ((0)) FOR [FeeCategoryID]
GO
ALTER TABLE [dbo].[FeeMaster] ADD  CONSTRAINT [DF__FeeMaster__IsInc__11158940]  DEFAULT ((0)) FOR [IsIncludedMaxAmtCalculation]
GO
ALTER TABLE [dbo].[FeeMaster] ADD  CONSTRAINT [DF__FeeMaster__Sales__1209AD79]  DEFAULT ('') FOR [SalesforceFeesFieldID]
GO
ALTER TABLE [dbo].[GroupMaster] ADD  CONSTRAINT [DF_GroupMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[GroupRoleMap] ADD  CONSTRAINT [DF_GroupRoleMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[MainOfficeConfiguration] ADD  CONSTRAINT [DF_MainOfficeConfiguration_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[MainOfficeConfiguration] ADD  DEFAULT ((0)) FOR [HasBusinessSoftware]
GO
ALTER TABLE [dbo].[MainOfficeConfiguration] ADD  DEFAULT ((0)) FOR [IsSharingEfin]
GO
ALTER TABLE [dbo].[NotificationMaster] ADD  CONSTRAINT [DF_NotificationMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[OfficeManagement] ADD  CONSTRAINT [DF_OfficeManagement_EFIN]  DEFAULT ((0)) FOR [EFIN]
GO
ALTER TABLE [dbo].[OfficeManagement] ADD  CONSTRAINT [DF_OfficeManagement_UpdateDate]  DEFAULT (getdate()) FOR [UpdatedDate]
GO
ALTER TABLE [dbo].[OfficeManagement] ADD  CONSTRAINT [DF_OfficeManagement_IsArchived]  DEFAULT ((0)) FOR [IsArchived]
GO
ALTER TABLE [dbo].[OfficeManagement] ADD  CONSTRAINT [DF_OfficeManagement_IsHold]  DEFAULT ((0)) FOR [IsHold]
GO
ALTER TABLE [dbo].[PermissionMaster] ADD  CONSTRAINT [DF_PermissionMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[PhoneTypeCustomerMap] ADD  CONSTRAINT [DF_PhoneTypeCustomerMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[PhoneTypeMaster] ADD  CONSTRAINT [DF_PhoneTypeMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[RoleMaster] ADD  CONSTRAINT [DF_RoleMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[RolePermissionMap] ADD  CONSTRAINT [DF_RolePermissionMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[Salesforce_Opportunity] ADD  CONSTRAINT [DF_Salesforce_Opportunity_IsEMPCustomerCreated]  DEFAULT ((0)) FOR [IsEMPCustomerCreated]
GO
ALTER TABLE [dbo].[salesforce_sync_summary] ADD  CONSTRAINT [DF_salesforce_sync_summary_sync_timestamp]  DEFAULT (getdate()) FOR [sync_timestamp]
GO
ALTER TABLE [dbo].[salesforce_sync_summary] ADD  DEFAULT ((0)) FOR [IsEMPtoSFDC]
GO
ALTER TABLE [dbo].[SalesYearEntityMap] ADD  CONSTRAINT [DF_SalesYearEntityMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[SalesYearMaster] ADD  CONSTRAINT [DF_SalesYearMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[SecurityAnswerUserMap] ADD  CONSTRAINT [DF_SecurityAnswerUserMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[SecurityQuestionMaster] ADD  CONSTRAINT [DF_SecurityQuestionMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[SitemapMaster] ADD  CONSTRAINT [DF_SitemapMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[SitemapMaster] ADD  CONSTRAINT [DF_SitemapMaster_DisplayBeforeVerify]  DEFAULT ((0)) FOR [DisplayBeforeVerify]
GO
ALTER TABLE [dbo].[SitemapPermissionMap] ADD  CONSTRAINT [DF_SitemapPermissionMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[SiteMapRolePermission] ADD  CONSTRAINT [DF_SiteMapRolePermission_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[SubSiteConfiguration] ADD  CONSTRAINT [DF_SubSiteConfiguration_CanSubSiteLoginToEmp]  DEFAULT ((0)) FOR [CanSubSiteLoginToEmp]
GO
ALTER TABLE [dbo].[SubSiteOfficeConfig] ADD  DEFAULT ((0)) FOR [HasBusinessSoftware]
GO
ALTER TABLE [dbo].[SubSiteOfficeConfig] ADD  DEFAULT ((0)) FOR [IsSharingEFIN]
GO
ALTER TABLE [dbo].[TooltipMaster] ADD  CONSTRAINT [DF_TooltipMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[UpdateBankEnrollmentStatus_AuditLog] ADD  CONSTRAINT [DF_UpdateBankEnrollmentStatus_AuditLog_UpdatedDate]  DEFAULT (getdate()) FOR [UpdatedDate]
GO
ALTER TABLE [dbo].[UserGroupMap] ADD  CONSTRAINT [DF_UserGroupMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[UserMaster] ADD  CONSTRAINT [DF_UserMaster_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[UserMaster] ADD  CONSTRAINT [DF_UserMaster_IsFirstLogin]  DEFAULT ((0)) FOR [IsFirstLogin]
GO
ALTER TABLE [dbo].[UserNotificationsMap] ADD  CONSTRAINT [DF_UserNotificationsMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[UserRolesMap] ADD  CONSTRAINT [DF_UserRolesMap_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[UtaxCrosslinkDetails] ADD  CONSTRAINT [DF_UtaxCrosslinkDetails_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[AffiliationProgramEntityMap]  WITH CHECK ADD  CONSTRAINT [FK_AffiliationProgramEntityMap_AffiliateProgramMaster] FOREIGN KEY([AffiliateProgramId])
REFERENCES [dbo].[AffiliateProgramMaster] ([Id])
GO
ALTER TABLE [dbo].[AffiliationProgramEntityMap] CHECK CONSTRAINT [FK_AffiliationProgramEntityMap_AffiliateProgramMaster]
GO
ALTER TABLE [dbo].[BankEntityMap]  WITH CHECK ADD  CONSTRAINT [FK_BankEntityMap_BankMaster] FOREIGN KEY([BankId])
REFERENCES [dbo].[BankMaster] ([Id])
GO
ALTER TABLE [dbo].[BankEntityMap] CHECK CONSTRAINT [FK_BankEntityMap_BankMaster]
GO
ALTER TABLE [dbo].[BankSubQuestions]  WITH CHECK ADD  CONSTRAINT [FK_BankSubQuestions_BankMaster] FOREIGN KEY([BankId])
REFERENCES [dbo].[BankMaster] ([Id])
GO
ALTER TABLE [dbo].[BankSubQuestions] CHECK CONSTRAINT [FK_BankSubQuestions_BankMaster]
GO
ALTER TABLE [dbo].[ContactPersonTitleCustomerMap]  WITH CHECK ADD  CONSTRAINT [FK_ContactPersonTitleCustomerMap_ContactPersonTitle] FOREIGN KEY([ContactPersonTitleId])
REFERENCES [dbo].[ContactPersonTitleMaster] ([Id])
GO
ALTER TABLE [dbo].[ContactPersonTitleCustomerMap] CHECK CONSTRAINT [FK_ContactPersonTitleCustomerMap_ContactPersonTitle]
GO
ALTER TABLE [dbo].[CustomerPaymentViaCreditCard]  WITH CHECK ADD  CONSTRAINT [FK_CustomerPaymentViaCreditCard_CustomerPaymentOptions] FOREIGN KEY([PaymentOptionId])
REFERENCES [dbo].[CustomerPaymentOptions] ([Id])
GO
ALTER TABLE [dbo].[CustomerPaymentViaCreditCard] CHECK CONSTRAINT [FK_CustomerPaymentViaCreditCard_CustomerPaymentOptions]
GO
ALTER TABLE [dbo].[EntityMaster]  WITH CHECK ADD  CONSTRAINT [FK_EntityMaster_AccessTypeMaster] FOREIGN KEY([AccessTypeId])
REFERENCES [dbo].[AccessTypeMaster] ([Id])
GO
ALTER TABLE [dbo].[EntityMaster] CHECK CONSTRAINT [FK_EntityMaster_AccessTypeMaster]
GO
ALTER TABLE [dbo].[FeeEntityMap]  WITH CHECK ADD  CONSTRAINT [FK_FeeEntityMap_EntityMaster] FOREIGN KEY([EntityId])
REFERENCES [dbo].[EntityMaster] ([Id])
GO
ALTER TABLE [dbo].[FeeEntityMap] CHECK CONSTRAINT [FK_FeeEntityMap_EntityMaster]
GO
ALTER TABLE [dbo].[FeeEntityMap]  WITH CHECK ADD  CONSTRAINT [FK_FeeEntityMap_FeeMaster] FOREIGN KEY([FeeId])
REFERENCES [dbo].[FeeMaster] ([Id])
GO
ALTER TABLE [dbo].[FeeEntityMap] CHECK CONSTRAINT [FK_FeeEntityMap_FeeMaster]
GO
ALTER TABLE [dbo].[GroupRoleMap]  WITH CHECK ADD  CONSTRAINT [FK_GroupRoleMap_GroupMaster] FOREIGN KEY([GroupId])
REFERENCES [dbo].[GroupMaster] ([Id])
GO
ALTER TABLE [dbo].[GroupRoleMap] CHECK CONSTRAINT [FK_GroupRoleMap_GroupMaster]
GO
ALTER TABLE [dbo].[GroupRoleMap]  WITH CHECK ADD  CONSTRAINT [FK_GroupRoleMap_RoleMaster] FOREIGN KEY([RoleId])
REFERENCES [dbo].[RoleMaster] ([Id])
GO
ALTER TABLE [dbo].[GroupRoleMap] CHECK CONSTRAINT [FK_GroupRoleMap_RoleMaster]
GO
ALTER TABLE [dbo].[PhoneTypeCustomerMap]  WITH CHECK ADD  CONSTRAINT [FK_PhoneTypeCustomerMap_PhoneTypeMaster] FOREIGN KEY([PhoneTypeId])
REFERENCES [dbo].[PhoneTypeMaster] ([Id])
GO
ALTER TABLE [dbo].[PhoneTypeCustomerMap] CHECK CONSTRAINT [FK_PhoneTypeCustomerMap_PhoneTypeMaster]
GO
ALTER TABLE [dbo].[RolePermissionMap]  WITH CHECK ADD  CONSTRAINT [FK_RolePermissionMap_PermissionMaster] FOREIGN KEY([PermissionId])
REFERENCES [dbo].[PermissionMaster] ([Id])
GO
ALTER TABLE [dbo].[RolePermissionMap] CHECK CONSTRAINT [FK_RolePermissionMap_PermissionMaster]
GO
ALTER TABLE [dbo].[RolePermissionMap]  WITH CHECK ADD  CONSTRAINT [FK_RolePermissionMap_RoleMaster] FOREIGN KEY([RoleId])
REFERENCES [dbo].[RoleMaster] ([Id])
GO
ALTER TABLE [dbo].[RolePermissionMap] CHECK CONSTRAINT [FK_RolePermissionMap_RoleMaster]
GO
ALTER TABLE [dbo].[SalesYearEntityMap]  WITH CHECK ADD  CONSTRAINT [FK_SalesYearEntityMap_EntityMaster] FOREIGN KEY([EntityId])
REFERENCES [dbo].[EntityMaster] ([Id])
GO
ALTER TABLE [dbo].[SalesYearEntityMap] CHECK CONSTRAINT [FK_SalesYearEntityMap_EntityMaster]
GO
ALTER TABLE [dbo].[SalesYearEntityMap]  WITH CHECK ADD  CONSTRAINT [FK_SalesYearEntityMap_SalesYearMaster] FOREIGN KEY([SalesYearId])
REFERENCES [dbo].[SalesYearMaster] ([Id])
GO
ALTER TABLE [dbo].[SalesYearEntityMap] CHECK CONSTRAINT [FK_SalesYearEntityMap_SalesYearMaster]
GO
ALTER TABLE [dbo].[SitemapPermissionMap]  WITH CHECK ADD  CONSTRAINT [FK_SitemapPermissionMap_PermissionMaster] FOREIGN KEY([PermissionId])
REFERENCES [dbo].[PermissionMaster] ([Id])
GO
ALTER TABLE [dbo].[SitemapPermissionMap] CHECK CONSTRAINT [FK_SitemapPermissionMap_PermissionMaster]
GO
ALTER TABLE [dbo].[SitemapPermissionMap]  WITH CHECK ADD  CONSTRAINT [FK_SitemapPermissionMap_SitemapMaster] FOREIGN KEY([SiteMapId])
REFERENCES [dbo].[SitemapMaster] ([Id])
GO
ALTER TABLE [dbo].[SitemapPermissionMap] CHECK CONSTRAINT [FK_SitemapPermissionMap_SitemapMaster]
GO
ALTER TABLE [dbo].[SiteMapRolePermission]  WITH CHECK ADD  CONSTRAINT [FK_SiteMapRolePermission_RoleMaster] FOREIGN KEY([RoleId])
REFERENCES [dbo].[RoleMaster] ([Id])
GO
ALTER TABLE [dbo].[SiteMapRolePermission] CHECK CONSTRAINT [FK_SiteMapRolePermission_RoleMaster]
GO
ALTER TABLE [dbo].[SiteMapRolePermission]  WITH CHECK ADD  CONSTRAINT [FK_SiteMapRolePermission_SitemapMaster] FOREIGN KEY([SiteMapId])
REFERENCES [dbo].[SitemapMaster] ([Id])
GO
ALTER TABLE [dbo].[SiteMapRolePermission] CHECK CONSTRAINT [FK_SiteMapRolePermission_SitemapMaster]
GO
ALTER TABLE [dbo].[SubSiteAffiliateProgramConfig]  WITH CHECK ADD  CONSTRAINT [FK_SubSiteAffiliateProgramConfig_SubSiteConfiguration] FOREIGN KEY([SubSiteConfiguration_ID])
REFERENCES [dbo].[SubSiteConfiguration] ([ID])
GO
ALTER TABLE [dbo].[SubSiteAffiliateProgramConfig] CHECK CONSTRAINT [FK_SubSiteAffiliateProgramConfig_SubSiteConfiguration]
GO
ALTER TABLE [dbo].[SubSiteBankConfig]  WITH CHECK ADD  CONSTRAINT [FK_SubSiteBankConfig_SubSiteConfiguration] FOREIGN KEY([SubSiteConfiguration_ID])
REFERENCES [dbo].[SubSiteConfiguration] ([ID])
GO
ALTER TABLE [dbo].[SubSiteBankConfig] CHECK CONSTRAINT [FK_SubSiteBankConfig_SubSiteConfiguration]
GO
ALTER TABLE [dbo].[SubSiteConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_SubSiteConfiguration_SubSiteConfiguration] FOREIGN KEY([emp_CustomerInformation_ID])
REFERENCES [dbo].[emp_CustomerInformation] ([Id])
GO
ALTER TABLE [dbo].[SubSiteConfiguration] CHECK CONSTRAINT [FK_SubSiteConfiguration_SubSiteConfiguration]
GO
ALTER TABLE [dbo].[TooltipMaster]  WITH CHECK ADD  CONSTRAINT [FK_TooltipMaster_SitemapMaster] FOREIGN KEY([SitemapId])
REFERENCES [dbo].[SitemapMaster] ([Id])
GO
ALTER TABLE [dbo].[TooltipMaster] CHECK CONSTRAINT [FK_TooltipMaster_SitemapMaster]
GO
ALTER TABLE [dbo].[UserGroupMap]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupMap_GroupMaster] FOREIGN KEY([GroupId])
REFERENCES [dbo].[GroupMaster] ([Id])
GO
ALTER TABLE [dbo].[UserGroupMap] CHECK CONSTRAINT [FK_UserGroupMap_GroupMaster]
GO
ALTER TABLE [dbo].[UserGroupMap]  WITH CHECK ADD  CONSTRAINT [FK_UserGroupMap_UserMaster] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserMaster] ([Id])
GO
ALTER TABLE [dbo].[UserGroupMap] CHECK CONSTRAINT [FK_UserGroupMap_UserMaster]
GO
ALTER TABLE [dbo].[UserMaster]  WITH CHECK ADD  CONSTRAINT [FK_UserMaster_EntityMaster] FOREIGN KEY([EntityId])
REFERENCES [dbo].[EntityMaster] ([Id])
GO
ALTER TABLE [dbo].[UserMaster] CHECK CONSTRAINT [FK_UserMaster_EntityMaster]
GO
ALTER TABLE [dbo].[UserMaster]  WITH CHECK ADD  CONSTRAINT [FK_UserMaster_UserMaster] FOREIGN KEY([Id])
REFERENCES [dbo].[UserMaster] ([Id])
GO
ALTER TABLE [dbo].[UserMaster] CHECK CONSTRAINT [FK_UserMaster_UserMaster]
GO
ALTER TABLE [dbo].[UserNotificationsMap]  WITH CHECK ADD  CONSTRAINT [FK_UserNotificationsMap_NotificationMaster] FOREIGN KEY([NotificationId])
REFERENCES [dbo].[NotificationMaster] ([Id])
GO
ALTER TABLE [dbo].[UserNotificationsMap] CHECK CONSTRAINT [FK_UserNotificationsMap_NotificationMaster]
GO
ALTER TABLE [dbo].[UserRolesMap]  WITH CHECK ADD  CONSTRAINT [FK_UserRolesMap_RoleMaster] FOREIGN KEY([RoleId])
REFERENCES [dbo].[RoleMaster] ([Id])
GO
ALTER TABLE [dbo].[UserRolesMap] CHECK CONSTRAINT [FK_UserRolesMap_RoleMaster]
GO
ALTER TABLE [dbo].[UserRolesMap]  WITH CHECK ADD  CONSTRAINT [FK_UserRolesMap_UserMaster] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserMaster] ([Id])
GO
ALTER TABLE [dbo].[UserRolesMap] CHECK CONSTRAINT [FK_UserRolesMap_UserMaster]
GO
USE [master]
GO
ALTER DATABASE [EMPDB_uTax_13072017] SET  READ_WRITE 
GO
