
/****** Object:  Table [dbo].[aa_XLMaps]    ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_XLMaps]') AND type in (N'U'))
DROP TABLE [dbo].[aa_XLMaps]
GO
/****** Object:  Table [dbo].[aa_Version]     ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_Version]') AND type in (N'U'))
DROP TABLE [dbo].[aa_Version]
GO
/****** Object:  Table [dbo].[aa_SBCategory]    ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_SBCategory]') AND type in (N'U'))
DROP TABLE [dbo].[aa_SBCategory]
GO
/****** Object:  Table [dbo].[aa_Reports]     ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_Reports]') AND type in (N'U'))
DROP TABLE [dbo].[aa_Reports]
GO
/****** Object:  Table [dbo].[aa_ReportParameters]     ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_ReportParameters]') AND type in (N'U'))
DROP TABLE [dbo].[aa_ReportParameters]
GO
/****** Object:  Table [dbo].[aa_ReportLineLists]     ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_ReportLineLists]') AND type in (N'U'))
DROP TABLE [dbo].[aa_ReportLineLists]
GO
/****** Object:  Table [dbo].[aa_ReportGroups]     ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_ReportGroups]') AND type in (N'U'))
DROP TABLE [dbo].[aa_ReportGroups]
GO
/****** Object:  Table [dbo].[aa_Queries]     ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_Queries]') AND type in (N'U'))
DROP TABLE [dbo].[aa_Queries]
GO
/****** Object:  Table [dbo].[aa_Category]     ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_Category]') AND type in (N'U'))
DROP TABLE [dbo].[aa_Category]
GO


/****** Object:  Table [dbo].[aa_Category]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_Category]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_Category](
	[CatID] [bigint] IDENTITY(1,1) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[UpdateDate] [datetime] NULL,
	[CreateDate] [datetime] NULL,
	[Deleteflag] [bit] NULL,
	[Excel] [bit] NULL,
 CONSTRAINT [PK_mst_category] PRIMARY KEY CLUSTERED 
(
	[CatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[aa_Database]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_Database]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_Database](
	[DbID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[DBName] [nvarchar](35) NULL,
	[IPAddress] [nvarchar](50) NULL,
	[Server] [nvarchar](50) NULL,
	[ConnString] [nvarchar](max) NOT NULL,
	[DBase] [nvarchar](max) NULL,
	[PMMSType] [nvarchar](50) NULL,
	[IQStatus] [nvarchar](50) NULL,
	[PMMS] [nvarchar](50) NULL,
	[DHISPortal] [varchar](max) NULL,
	[MFLCode] [varchar](100) NULL,
	[EMRVersion] [varchar](100) NULL,
	[CountryCode] [varchar](10) NULL,
	[UpdateDate] [datetime] NULL,
	[CreateDate] [datetime] NULL,
	[Deleteflag] [bit] NULL,
 CONSTRAINT [PK_mst_Database] PRIMARY KEY CLUSTERED 
(
	[DbID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[aa_Lang]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_Lang]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_Lang](
	[LangID] [bigint] IDENTITY(1,1) NOT NULL,
	[Language] [nvarchar](50) NULL,
	[Deleteflag] [bit] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_aa_Lang] PRIMARY KEY CLUSTERED 
(
	[LangID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[aa_Queries]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_Queries]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_Queries](
	[qryID] [bigint] IDENTITY(1,1) NOT NULL,
	[qryName] [nvarchar](50) NOT NULL,
	[qryDefinition] [nvarchar](max) NOT NULL,
	[qryDescription] [nvarchar](200) NOT NULL,
	[qryType] [nvarchar](10) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[Deleteflag] [bit] NULL,
	[MkTable] [int] NULL,
	[Decrypt] [bit] NULL,
	[Hidden] [bit] NULL,
	[qryGroup] [nvarchar](50) NULL,
	[UID] [int] NULL,
 CONSTRAINT [PK_mst_Queries] PRIMARY KEY CLUSTERED 
(
	[qryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[aa_ReportGroups]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_ReportGroups]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_ReportGroups](
	[ReportGroupID] [int] IDENTITY(1,1) NOT NULL,
	[GroupName] [varchar](100) NOT NULL,
	[Position] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[aa_ReportLineLists]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_ReportLineLists]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_ReportLineLists](
	[LineListID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [int] NOT NULL,
	[QryID] [int] NOT NULL,
	[WorksheetName] [varchar](20) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteFlag] [int] NULL,
 CONSTRAINT [PK_aa_ReportLineLists] PRIMARY KEY CLUSTERED 
(
	[LineListID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[aa_ReportParameters]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_ReportParameters]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_ReportParameters](
	[ReportParamID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [int] NULL,
	[ParamName] [varchar](100) NULL,
	[ParamLabel] [varchar](100) NULL,
	[ParamType] [varchar](50) NULL,
	[ParamDefaultValue] [varchar](100) NULL,
	[Position] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteFlag] [bit] NULL,
 CONSTRAINT [PK_aa_ReportParameters] PRIMARY KEY CLUSTERED 
(
	[ReportParamID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[aa_Reports]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_Reports]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_Reports](
	[ReportID] [int] IDENTITY(1,1) NOT NULL,
	[ReportName] [varchar](100) NULL,
	[ReportDisplayName] [varchar](250) NULL,
	[ReportDescription] [varchar](max) NULL,
	[QueryCategoryID] [int] NULL,
	[ExcelTemplateName] [varchar](100) NULL,
	[ExcelWorksheetName] [varchar](50) NULL,
	[ReportGroupID] [int] NULL,
	[Password] VARCHAR(100) NULL,
 CONSTRAINT [PK_aa_Reports] PRIMARY KEY CLUSTERED 
(
	[ReportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[aa_SBCategory]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_SBCategory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_SBCategory](
	[sbCatID] [bigint] IDENTITY(1,1) NOT NULL,
	[sbCategory] [nvarchar](50) NULL,
	[catID] [bigint] NULL,
	[QryID] [bigint] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteFlag] [bit] NULL,
	[Psn] [bigint] NULL,
	[sbDescription] [nvarchar](800) NULL,
	[Flatten] [bit] NULL,
	[DHISDatasetID] [varchar](50) NULL,
 CONSTRAINT [PK_aa_xlCategory] PRIMARY KEY CLUSTERED 
(
	[sbCatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[aa_SMS]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_SMS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_SMS](
	[msgID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[QryID] [bigint] NOT NULL,
	[Message] [nvarchar](160) NOT NULL,
	[LangID] [bigint] NOT NULL,
	[Deleteflag] [bit] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_aa_SMS] PRIMARY KEY CLUSTERED 
(
	[msgID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[aa_SMSLogs]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_SMSLogs]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_SMSLogs](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[PatientPK] [varchar](50) NULL,
	[Phone] [varchar](20) NULL,
	[Message] [varchar](2000) NULL,
	[MsgSent] [tinyint] NULL,
	[MsgFailed] [tinyint] NULL,
	[MsgReceived] [tinyint] NULL,
	[LogDate] [datetime] NULL,
	[UserID] [int] NULL,
 CONSTRAINT [PK_aa_SMSLogs] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[aa_SMSSchedules]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_SMSSchedules]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_SMSSchedules](
	[ScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[ScheduleName] [varchar](200) NULL,
	[QryID] [int] NULL,
	[SendUsing] [varchar](200) NULL,
	[SendUsingDetails] [varchar](200) NULL,
	[DailyDaysEarlier] [int] NULL,
	[ScheduleType] [varchar](50) NULL,
	[DailyTime] [datetime] NULL,
	[WeeklyDay] [varchar](50) NULL,
	[WeeklyTime] [datetime] NULL,
	[MonthlyDay] [int] NULL,
	[MonthlyTime] [datetime] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteFlag] [bit] NULL,
 CONSTRAINT [PK_aa_ScheduleID] PRIMARY KEY CLUSTERED 
(
	[ScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[aa_UserCategory]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_UserCategory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_UserCategory](
	[CatID] [bigint] IDENTITY(1,1) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[UpdateDate] [datetime] NULL,
	[CreateDate] [datetime] NULL,
	[Deleteflag] [bit] NULL,
	[Excel] [bit] NULL,
 CONSTRAINT [PK_CatID] PRIMARY KEY CLUSTERED 
(
	[CatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[aa_UserGroups]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_UserGroups]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_UserGroups](
	[GID] [bigint] IDENTITY(1,1) NOT NULL,
	[GroupName] [nvarchar](50) NULL,
	[UpdateDate] [datetime] NULL,
	[CreateDate] [datetime] NULL,
	[DeleteFlag] [bit] NULL,
 CONSTRAINT [PK_aa_UserGroups] PRIMARY KEY CLUSTERED 
(
	[GID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[aa_UserQueries]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_UserQueries]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_UserQueries](
	[QryID] [bigint] IDENTITY(1,1) NOT NULL,
	[QryName] [nvarchar](50) NOT NULL,
	[QryDefinition] [nvarchar](max) NOT NULL,
	[QryDescription] [nvarchar](200) NOT NULL,
	[QryType] [nvarchar](10) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[Deleteflag] [bit] NULL,
	[MkTable] [int] NULL,
	[Decrypt] [bit] NULL,
	[Hidden] [bit] NULL,
	[QryGroup] [nvarchar](50) NULL,
	[UID] [int] NULL,
 CONSTRAINT [PK_QryID] PRIMARY KEY CLUSTERED 
(
	[QryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[aa_UserSBCategory]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_UserSBCategory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_UserSBCategory](
	[SBCatID] [bigint] IDENTITY(1,1) NOT NULL,
	[SBCategory] [nvarchar](50) NULL,
	[CatID] [bigint] NULL,
	[QryID] [bigint] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteFlag] [bit] NULL,
	[Psn] [bigint] NULL,
	[SBDescription] [nvarchar](800) NULL,
	[Flatten] [bit] NULL,
	[DHISDatasetID] [varchar](50) NULL,
 CONSTRAINT [PK_SBCatID] PRIMARY KEY CLUSTERED 
(
	[SBCatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[aa_Version]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_Version]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_Version](
	[AppID] [int] IDENTITY(1,1) NOT NULL,
	[AppName] [nvarchar](50) NULL,
	[AppVersion] [nvarchar](50) NULL,
	[AppDate] [datetime] NULL,
	[DBVersion] [nvarchar](50) NULL,
	[AppAuthor] [nvarchar](50) NULL,
	[AppManager] [nvarchar](50) NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_aa_version] PRIMARY KEY CLUSTERED 
(
	[AppID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[aa_XLMaps]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aa_XLMaps]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aa_XLMaps](
	[xlsID] [bigint] IDENTITY(1,1) NOT NULL,
	[xlsCell] [nvarchar](50) NOT NULL,
	[qryID] [bigint] NOT NULL,
	[xlsTitle] [nvarchar](max) NOT NULL,
	[Deleteflag] [bit] NULL,
	[CreateDate] [datetime] NULL,
	[xlCatID] [bigint] NULL,
	[DHISElementID] [varchar](50) NULL,
	[CategoryOptionID] [varchar](50) NULL,
 CONSTRAINT [PK_mst_xlMaps] PRIMARY KEY CLUSTERED 
(
	[xlsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
