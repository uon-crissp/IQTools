using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.Data.OleDb;
using System.Configuration;
using System.IO;
using System.Text;
using System.Windows.Forms;
using Microsoft.Win32;

namespace DataLayer
{
    public class Entity : ProcessBase
    {

        public Entity()
        {
        }

        private void CreateFormBuilderViews(string connString)
        {
            SqlConnection IQcareConn = new SqlConnection();
            IQcareConn.ConnectionString = connString;
            IQcareConn.Open();
            string viewsQry = @"
                    declare @tableNames Varchar(150)

                    declare tablesCursor  Cursor FOR
                    Select name from sys.tables where name like '%DTL_FB%'

                    open tablesCursor
                    Fetch next from tablesCursor into @tableNames
                    while (@@FETCH_STATUS=0)
                    BEGIN
	                    declare @id int,@column_Name varchar(100),@bindTable varchar(100),@sqlQry varchar(max);  
	                    set @sqlQry='SELECT '                          
	                    declare columnsCursor cursor for
	                    select distinct clm.ordinal_position, clm.column_name,cf.BindTable from information_schema.columns  clm
	                    left join mst_customFormField cf on clm.Column_name=cf.FieldName
	                    where clm.table_name= @tableNames order by clm.ORDINAL_POSITION
	                    open columnscursor
	                    Fetch next from columnsCursor into @id, @column_Name,@bindTable
	                    while (@@FETCH_STATUS=0)
	                    BEGIN
		                    if (@bindTable is null or @bindTable='')
		                    Begin
			                    set	@sqlQry=@sqlQry + '[' +@column_Name + '],'
		                    end
		                    else
		                    Begin
			                    set @sqlQry=@sqlQry + '(SELECT NAME FROM mst_moddecode where id=[' + @column_Name + '])[' + @column_Name + '],'
		                    end
		                    fetch columnsCursor into @id,@column_Name,@bindTable
	                    end
	                    set @sqlQry=substring(@sqlQry, 1, (len(@sqlQry) - 1)) + ' FROM [' + @tableNames +']'


                        exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[dbo].[vw_' + @tableNames + ']''))
                        DROP VIEW [dbo].[vw_' + @tableNames + ']')
                        exec('CREATE VIEW [dbo].[vw_' + @tableNames + '] AS ' +@sqlQry);

	                        CLOSE columnsCursor;
	                        DEALLOCATE columnsCursor;
                         fetch tablesCursor into @tableNames
                        end
                        CLOSE tablesCursor;
                        DEALLOCATE tablesCursor;";
            SqlCommand mycmd = new SqlCommand(viewsQry, IQcareConn);
            int resuting = mycmd.ExecuteNonQuery();
            mycmd.Dispose();
        }

        public static string GetEMRType()
        {
            return "iqcare";
        }

        public static string GetEMRDatabaseName(string sConnstring)
        {
            try
            {
                IDbConnection connection = new SqlConnection(sConnstring);
                var dbName = connection.Database;
                return dbName;
            }
            catch
            {
                return "IQCare";
            }
        }

        public static bool DropIQToolsObjects(string emrType, string serverType)
        {
            string connString = GetConnString();
            try
            {
                DataTable theDt = new DataTable(); int i = 0;
                Entity theObject = new Entity(); ClsUtility.Init_Hashtable();
                string toDrop = "Select Name FROM sys.synonyms";
                theDt = (DataTable)theObject.ReturnObject(connString, ClsUtility.theParams
                    , toDrop, ClsUtility.ObjectEnum.DataTable, serverType);
                DataTableReader dTr;
                dTr = theDt.CreateDataReader();

                if (serverType.ToLower() == "mssql" || emrType.ToLower() == "" || emrType.ToLower() == "msaccess")
                {
                    while (dTr.Read())
                    {
                        try
                        {
                            i = (int)theObject.ReturnObject(connString, ClsUtility.theParams
                          , "DROP Synonym [dbo].[" + dTr[0].ToString().Trim() + "]", ClsUtility.ObjectEnum.ExecuteNonQuery, "mssql");
                        }
                        catch { }

                        try
                        {
                            i = (int)theObject.ReturnObject(connString, ClsUtility.theParams
                          , "DROP Table [" + dTr[0].ToString().Trim() + "]", ClsUtility.ObjectEnum.ExecuteNonQuery, "mssql");
                        }
                        catch { }
                    }
                    try
                    {
                        i = (int)theObject.ReturnObject(connString, ClsUtility.theParams
                      , "DROP TABLE mst_Patient_decoded", ClsUtility.ObjectEnum.ExecuteNonQuery, "mssql");
                    }
                    catch { }
                    try
                    {
                        i = (int)theObject.ReturnObject(connString, ClsUtility.theParams
                      , "DROP TABLE dtl_PatientContacts", ClsUtility.ObjectEnum.ExecuteNonQuery, "mssql");
                    }
                    catch { }
                    try
                    {
                        i = (int)theObject.ReturnObject(connString, ClsUtility.theParams
                      , "DROP TABLE Person_Decoded", ClsUtility.ObjectEnum.ExecuteNonQuery, "mssql");
                    }
                    catch { }
                }
                return true;

            }
            catch (Exception ex)
            {
                if (ex.Message.ToLower().Substring(0, 21) == "cannot use drop table")
                {
                    //SqlConnection cnn = new SqlConnection(Entity.getconnString(clsGbl.xmlPath));
                    //cnn.Open();
                    //SqlCommand cmm = new SqlCommand("UPDATE aa_Database Set Connstring = '' WHERE DBName = 'IQTools'"); cmm.Connection = cnn;
                    //int i = cmm.ExecuteNonQuery();
                    //cnn.Close(); cmm.Dispose(); cnn.Dispose();
                }

                return true;
            }
        }

        public static bool CreateIQToolsObjects(string emrType, string serverType)
        {
            string connString = GetConnString();
            Entity en = new Entity();
            string EMRConnString = Entity.GetEMRConnString();

            try
            {
                string toCreate = "select '[' + (select top 1 name COLLATE DATABASE_DEFAULT from sys.servers where product = 'SQL Server') + '].[" + GetEMRDatabaseName(EMRConnString) + "].[' + b.name + '].[' + a.name + ']' s, '[' + b.name + '].[' + a.name + ']' o " +
                                    " from sys.tables a inner join sys.schemas b on a.schema_id = b.schema_id where a.name not like 'sys%' " +
                                    " union " +
                                    " select '[' + (select top 1 name COLLATE DATABASE_DEFAULT from sys.servers where product = 'SQL Server') +'].[" + GetEMRDatabaseName(EMRConnString) + "].[' + b.name + '].[' + a.name + ']' s, '[' + b.name + '].[' + a.name + ']' o " +
                                    " from sys.views a inner " +
                                    " join sys.schemas b on a.schema_id = b.schema_id where a.name not like 'sys%' ";

                DataTable dt = (DataTable)en.ReturnObject(EMRConnString, null, toCreate, ClsUtility.ObjectEnum.DataTable, serverType);
                DataTableReader dreader = dt.CreateDataReader();
                while (dreader.Read())
                {
                    string createSynonym = "CREATE SYNONYM " + dreader["o"].ToString() + "FOR " + dreader["s"].ToString();
                    int i = (int)en.ReturnObject(connString, ClsUtility.theParams, createSynonym, ClsUtility.ObjectEnum.ExecuteNonQuery, serverType);
                }

                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public static string getconnString(string xmlPath)
        {
            return GetConnString();
        }

        public static string GetConnString()
        {
            string versionDependent = Application.UserAppDataRegistry.Name;
            string versionIndependent = versionDependent.Substring(0, versionDependent.LastIndexOf("\\"));

            string ConnectionString = String.Empty;
            if (Registry.GetValue(versionIndependent, "ConnectionString", null) != null)
            {
                return ClsUtility.Decrypt(Registry.GetValue(versionIndependent, "ConnectionString", null).ToString());
            }
            else
            {
                return ConnectionString;
            }
        }

        public static string GetEMRConnString()
        {
            string versionDependent = Application.UserAppDataRegistry.Name;
            string versionIndependent = versionDependent.Substring(0, versionDependent.LastIndexOf("\\"));

            string ConnectionString = String.Empty;
            if (Registry.GetValue(versionIndependent, "EMRConnectionString", null) != null)
            {
                return ClsUtility.Decrypt(Registry.GetValue(versionIndependent, "EMRConnectionString", null).ToString());
            }
            else
            {
                return ConnectionString;
            }
        }

        public static void SetConnString(string ConnectionString)
        {
            string versionDependent = Application.UserAppDataRegistry.Name;
            string versionIndependent = versionDependent.Substring(0, versionDependent.LastIndexOf("\\"));
            Registry.SetValue(versionIndependent, "ConnectionString", ClsUtility.Encrypt(ConnectionString));
        }

        public static void SetEMRConnString(string IQToolsConnectionString, string EMRConnectionString, string IPAddress, string EMRDB, string EMRType, string ServerType, string EMRVersion)
        {
            string versionDependent = Application.UserAppDataRegistry.Name;
            string versionIndependent = versionDependent.Substring(0, versionDependent.LastIndexOf("\\"));
            Registry.SetValue(versionIndependent, "EMRConnectionString", ClsUtility.Encrypt(EMRConnectionString));

            try
            {
                Entity en = new Entity();
                ClsUtility.Init_Hashtable();
                string sql = "UPDATE aa_Database SET "
                                                + "IPAddress = '" + IPAddress + "', "
                                                + "DBase = '" + EMRDB + "',  connString='"
                                                + ClsUtility.Encrypt(EMRConnectionString) + "', PMMSType = '" + ServerType
                                                + "', IQStatus='No Data', UpdateDate=Null, PMMS = '" + EMRType + "',EMRVersion = '"
                                                + EMRVersion + "' WHERE DBName='IQTools'";
                int i = (int)en.ReturnObject(IQToolsConnectionString, ClsUtility.theParams
                                                , sql
                                                , ClsUtility.ObjectEnum.ExecuteNonQuery, "mssql");
                if (i == 0)
                {
                    sql = "INSERT INTO aa_Database (DBName, IPAddress,ConnString, DBase, PMMSType, IQStatus, PMMS, EMRVersion, CreateDate) " +
                                   "VALUES ('IQTools','" + IPAddress + "','" + ClsUtility.Encrypt(EMRConnectionString) + "','" + EMRDB + "','" + ServerType + "','No Data','" + EMRType + "','" + EMRVersion + "', GETDATE())";
                    i = (int)en.ReturnObject(IQToolsConnectionString, ClsUtility.theParams
                                               , sql
                                               , ClsUtility.ObjectEnum.ExecuteNonQuery, "mssql");
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public static void SetServerType(string ServerType)
        {
            var configFile = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            var appSettings = configFile.AppSettings.Settings;
            appSettings["ServerType"].Value = ServerType;
            configFile.Save(ConfigurationSaveMode.Modified);
            ConfigurationManager.RefreshSection(configFile.AppSettings.SectionInformation.Name);
        }

        public static string GetServerType()
        {
            var configFile = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            var appSettings = configFile.AppSettings.Settings;
            return appSettings["ServerType"].Value.ToLower();
        }

        public static string GetRefreshRights()
        {
            var configFile = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            var appSettings = configFile.AppSettings.Settings;
            return appSettings["AllowRefresh"].Value.ToLower();
        }

        public static string GetDevRights()
        {
            var configFile = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            var appSettings = configFile.AppSettings.Settings;
            return appSettings["Development"].Value.ToLower();
        }

        public static string getServerType(string xmlPath)
        {
            return GetServerType();
        }

        public static string getDevelopmentRight(string xmlPath)
        {
            return GetDevRights();
        }

        public static string getRefreshRights(string xmlPath)
        {
            return GetRefreshRights();
        }

        public object ReturnObject(string ConString, Hashtable Params, string CommandText, ClsUtility.ObjectEnum Obj, string pmmsType)
        {
            switch (pmmsType.Trim().ToLower())
            {
                case "mssql":
                    {
                        return MsSQLObject(ConString, Params, CommandText, Obj);
                    }
                case "access":
                    {
                        return AccessObject(ConString, Params, CommandText, Obj);
                    }
                default:
                    {
                        return MsSQLObject(ConString, Params, CommandText, Obj);
                    }

            }
        }

        private object MsSQLObject(string ConString, Hashtable Params, string CommandText, ClsUtility.ObjectEnum Obj)
        {
            int i;
            string cmdpara, cmdvalue, cmddbtype;
            SqlCommand theCmd = new SqlCommand();
            SqlTransaction theTran = (SqlTransaction)this.Transaction;
            SqlConnection cnn;

            if (null == this.Connection)
            {
                cnn = (SqlConnection)GetConnection(ConString, "mssql");
            }
            else
            {
                cnn = (SqlConnection)this.Connection;
            }

            if (null == this.Transaction)
            {
                theCmd = new SqlCommand(CommandText, cnn);
            }
            else
            {
                theCmd = new SqlCommand(CommandText, cnn, theTran);
            }
            if (Params != null)
            {
                for (i = 1; i <= Params.Count;)
                {
                    cmdpara = Params[i].ToString();
                    cmddbtype = Params[i + 1].ToString();
                    cmdvalue = Params[i + 2].ToString();
                    theCmd.Parameters.AddWithValue(cmdpara, cmddbtype).Value = cmdvalue;
                    i = i + 3;
                }
            }
            theCmd.CommandTimeout = 0;
            theCmd.CommandType = CommandType.StoredProcedure;
            string theSubstring = CommandText.Substring(0, 6).ToUpper();
            switch (theSubstring)
            {
                case "SELECT":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "UPDATE":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "RESTOR":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "INSERT":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "DELETE":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "CREATE":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "DROP S":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "DROP V":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "DBCC C":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "DBCC S":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "BACKUP":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "EXEC S":
                    theCmd.CommandType = CommandType.Text;
                    break;
                case "SET DA":
                    theCmd.CommandType = CommandType.Text;
                    break;
                    //case "WITH I"://TODO DONE for common table expressions start with an I for the CTE name
                    //    theCmd.CommandType = CommandType.Text;
                    //    break;
            }
            if (CommandText.Substring(0, 4).ToUpper() == "WITH") //CTE
                theCmd.CommandType = CommandType.Text;
            if (CommandText.IndexOf("SET OFFLINE") > 0 || CommandText.IndexOf("SET ONLINE") > 0)
                theCmd.CommandType = CommandType.Text;
            if (CommandText.Length >= 15)
            { if (CommandText.Substring(0, 15).ToUpper() == "DROP TABLE [TMP" || CommandText.Substring(0, 15).ToUpper() == "DROP TABLE [MGR" || CommandText.Substring(0, 15).ToUpper() == "DROP TABLE [TPS") theCmd.CommandType = CommandType.Text; }
            if (CommandText.Length >= 10)
            { if (CommandText.Substring(0, 10).ToUpper() == "DROP SYNON") theCmd.CommandType = CommandType.Text; }
            if (CommandText.Length >= 30)
            { if (CommandText.Substring(0, 30).ToUpper() == "DROP TABLE MST_PATIENT_DECODED") theCmd.CommandType = CommandType.Text; }
            if (CommandText.Length >= 25)
            { if (CommandText.Substring(0, 25).ToUpper() == "DROP TABLE PERSON_DECODED") theCmd.CommandType = CommandType.Text; }
            //if (CommandText.Length >= 30)
            //{ if (CommandText.Substring(0, 30).ToUpper() == "DROP TABLE DTL_PATIENTCONTACTS") theCmd.CommandType = CommandType.Text; }



            theCmd.Connection = cnn;

            try
            {
                SqlCommand cm;
                if (ClsUtility.SDate != "")
                {
                    cm = new SqlCommand("SET Dateformat " + ClsUtility.SDate, cnn);
                    cm.ExecuteNonQuery();
                    cm.Dispose();
                }
                cm = null;
                if (Obj == ClsUtility.ObjectEnum.DataSet)
                {
                    SqlDataAdapter theAdpt = new SqlDataAdapter(theCmd);
                    DataSet theDS = new DataSet();
                    //theDS.Tables[0].BeginLoadData();
                    theAdpt.Fill(theDS);
                    //theDS.Tables[0].EndLoadData();
                    return theDS;
                }

                if (Obj == ClsUtility.ObjectEnum.DataTable)
                {
                    SqlDataAdapter theAdpt = new SqlDataAdapter(theCmd);
                    DataTable theDT = new DataTable();
                    theDT.BeginLoadData();
                    theAdpt.Fill(theDT);
                    theDT.EndLoadData();
                    return theDT;
                }

                if (Obj == ClsUtility.ObjectEnum.DataRow)
                {
                    SqlDataAdapter theAdpt = new SqlDataAdapter(theCmd);
                    DataTable theDT = new DataTable();
                    theDT.BeginLoadData();
                    theAdpt.Fill(theDT);
                    theDT.EndLoadData();
                    return theDT.Rows[0];
                }

                if (Obj == ClsUtility.ObjectEnum.ExecuteNonQuery)
                {
                    int NoRowsAffected = theCmd.ExecuteNonQuery();
                    return NoRowsAffected;
                }

                if (null == this.Connection)
                    cnn.Close();
                return 0;
            }
            catch (Exception err)
            {
                throw err;
                //return null;
            }

            finally
            {
                if (null != cnn)
                    if (null == this.Connection)
                        cnn.Close();
            }
        }

        private object AccessObject(string ConString, Hashtable Params, string CommandText, ClsUtility.ObjectEnum Obj)
        {
            return null;
        }

        public static object getdbConn(SqlConnection conn, string pmm)
        {
            string connStr; string pmmType;
            connStr = ""; pmmType = "";

            try
            {
                SqlCommand comm;
                if (pmm == "msaccess")
                { comm = new SqlCommand("SELECT connString, PMMSType From aa_Database WHERE DbName = '" + "IQTools" + "'", conn); }
                else
                { comm = new SqlCommand("SELECT connString, PMMSType From aa_Database WHERE DbName = '" + pmm + "'", conn); }
                SqlDataReader sDR = comm.ExecuteReader();
                while (sDR.Read())
                {
                    connStr = ClsUtility.Decrypt(sDR[0].ToString());
                    if (pmm == "msaccess")
                    { pmmType = "msaccess"; }
                    else
                    { pmmType = sDR[1].ToString(); }
                    break;
                }
            }
            catch (Exception ex)
            {
                connStr = ex.Message;
                connStr = "";
            }

            return GetConnection(connStr, pmmType);
        }
 
        public static string getdbConnString(SqlConnection conn, string pmm)
        {
            return GetEMRConnString();
        }

        public static object GetConnection(string ConString, string dbType)
        {
            switch (dbType)
            {
                case "mssql":
                    {
                        SqlConnection connection = new SqlConnection(ConString);
                        connection.Open();
                        return connection;
                    }

                case "msaccess":
                    {
                        OleDbConnection connection = new OleDbConnection(ConString);
                        connection.Open();
                        return connection;
                    }
                default:
                    {
                        SqlConnection connection = new SqlConnection(ConString);
                        connection.Open();
                        return connection;
                    }
            }
        }
 
        public static string getRemoteServiceURL(string xmlPath)
        {
            //XmlDocument theXML = new XmlDocument();
            //theXML.Load(xmlPath);
            //XmlNode nd = theXML.SelectSingleNode("//add[@key='RemoteWebServiceURL']");
            //if (nd != null)
            //{
            //    return nd.Attributes["value"].Value; //return the value of the value attribute of this node
            //}
            //return "";
            return GetRemoteServiceURL();
        }

        public static string GetRemoteServiceURL()
        {
            var configFile = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            var appSettings = configFile.AppSettings.Settings;
            return appSettings["RemoteWebServiceURL"].Value.ToLower();
        }

        private static void BackupIQToolsDB(string dbName, string Server, string User, string Password)
        {
            //try
            //{
            //    ServerConnection srvConn = new ServerConnection(Server);
            //    srvConn.LoginSecure = false;
            //    srvConn.Login = User;
            //    srvConn.Password = Password;
            //    Server s = new Server(srvConn);
            //    string BackupPath = s.BackupDirectory;
                
            //    string backupSQL = "IF EXISTS(Select name from sys.databases where name = '" + dbName + "') BEGIN " +
            //                    "BACKUP DATABASE [" + dbName + "]" +
            //                   "TO DISK = N'" + BackupPath + "\\" + dbName + "_Backup.bak' " +
            //                   "WITH NOFORMAT, INIT,  " +
            //                   "NAME = N'IQTools-Full Database Backup', " +
            //                   "SKIP, NOREWIND, NOUNLOAD END";

            //    srvConn.ExecuteNonQuery(backupSQL);
            //}
            //catch (Exception ex)
            //{
            //    throw ex;
            //}
        }

        public static void ForceUpgrade()
        {
            SqlConnection srvConn = new SqlConnection();
            srvConn.ConnectionString = GetConnString();

            try
            {
                UpdateIQToolsSystemTables(srvConn);
                UpdateIQToolsSystemFunctions(srvConn);
                UpdateIQToolsSystemProcedures(srvConn);
                UpdateIQToolsSystemReports(srvConn);
            }
            catch (Exception ex)
            {
                throw ex;
            }

            finally
            {
                srvConn.Close();
            }
        }
        
        private static void UpdateIQToolsDB(string dbName, string Server, string User, string Password)
        {
            try
            {
                string constring = "Data Source=" + Server + "; Initial Catalog=Master;Persist Security Info=True;User ID=" + User + ";Password=" + Password;
                SqlConnection srvConn = new SqlConnection(constring);

                string createSQL = "IF NOT EXISTS (Select name from sys.databases where name = '" + dbName + "') CREATE DATABASE [" + dbName + "]";
               
                try
                {
                    ExecuteNonQuery(createSQL, srvConn);
                }
                catch(Exception ex)
                {
                    MessageBox.Show(createSQL + " - " + ex.Message);
                }

                constring = "Data Source=" + Server + "; Initial Catalog=" + dbName + ";Persist Security Info=True;User ID=" + User + ";Password=" + Password;
                srvConn = new SqlConnection(constring);

                UpdateIQToolsSystemTables(srvConn);
                UpdateIQToolsSystemFunctions(srvConn);
                UpdateIQToolsSystemProcedures(srvConn);
                UpdateIQToolsSystemReports(srvConn);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.InnerException.ToString(), "Updating IQTools");
                throw ex;
            }
        }



        private static void UpdateIQToolsSystemTables(SqlConnection conn)
        {
            try
            {
                string TableDef = "DB\\IQCare\\Tables.sql";
                FileInfo tables = new FileInfo(TableDef);
                string tablesScript = tables.OpenText().ReadToEnd();
                ExecuteNonQuery(tablesScript, conn);

                string VersionDef = "DB\\IQCare\\Version.sql";
                FileInfo version = new FileInfo(VersionDef);
                string versionScript = version.OpenText().ReadToEnd();
                ExecuteNonQuery(versionScript, conn);
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        private static void UpdateIQToolsSystemFunctions(SqlConnection conn)
        {
            try
            {
                foreach (string s in Directory.GetFiles("DB\\Functions"))
                {
                    if (File.Exists(s))
                    {
                        FileInfo f = new FileInfo(s);
                        string fs = f.OpenText().ReadToEnd();
                        ExecuteNonQuery(fs, conn);
                    }
                }
                foreach (string subfolder in Directory.GetDirectories("DB\\Functions"))
                {
                    foreach (string f in Directory.GetFiles(subfolder))
                    {
                        if (File.Exists(f))
                        {
                            FileInfo fi = new FileInfo(f);
                            string fs = fi.OpenText().ReadToEnd();
                            ExecuteNonQuery(fs, conn);
                        }
                    }
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        private static void UpdateIQToolsSystemProcedures(SqlConnection conn)
        {
            try
            {
                foreach (string s in Directory.GetFiles("DB\\Procedures"))
                {
                    if (File.Exists(s))
                    {
                        FileInfo f = new FileInfo(s);
                        string fs = f.OpenText().ReadToEnd();
                        ExecuteNonQuery(fs, conn);
                    }
                }
                foreach (string subfolder in Directory.GetDirectories("DB\\Procedures"))
                {
                    foreach (string f in Directory.GetFiles(subfolder))
                    {
                        if (File.Exists(f))
                        {
                            FileInfo fi = new FileInfo(f);
                            string fs = fi.OpenText().ReadToEnd();
                            ExecuteNonQuery(fs, conn);
                        }
                    }
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        private static void UpdateIQToolsSystemReports(SqlConnection conn)
        {
            //Reports
            try
            {
                foreach (string s in Directory.GetFiles("Reports"))
                {
                    if (File.Exists(s))
                    {
                        FileInfo f = new FileInfo(s);
                        string fs = f.OpenText().ReadToEnd();
                        ExecuteNonQuery(fs, conn);
                    }
                }
                foreach (string subfolder in Directory.GetDirectories("Reports"))
                {
                    foreach (string f in Directory.GetFiles(subfolder))
                    {
                        if (File.Exists(f))
                        {
                            FileInfo fi = new FileInfo(f);
                            string fs = fi.OpenText().ReadToEnd();
                            ExecuteNonQuery(fs, conn);
                        }
                    }
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public static bool CreateIQToolsDB(string EMRServerType, string IQToolsUser, string IQToolsServer, string IQToolsPassword, string IQToolsDB, string EMR)
        {
            try
            {
                String constring = "Data Source=" + IQToolsServer + "; Initial Catalog=Master;Persist Security Info=True;User ID=" + IQToolsUser + ";Password=" + IQToolsPassword;
                SqlConnection srvConn = new SqlConnection(constring);

                DataSet theDtr;
                string mdf = string.Empty, ldf = string.Empty, logicalname = string.Empty;
                try
                {
                    try ////Check if Select DB is an IQTools DB by Logical Name
                    {
                        theDtr = ExecuteReader("USE [" + IQToolsDB + "];SELECT file_name(1) AS 'LogicalName'", constring);
                        logicalname = theDtr.Tables[0].Rows[0]["LogicalName"].ToString();
                    }
                    catch { }

                    if (logicalname.Trim().ToLower().Contains("iqtools") || logicalname.Trim().ToLower() == "")
                    {                      
                        if (EMRServerType.ToLower() == "microsoft sql server")
                        {
                            #region SQL_Server
                            try
                            {
                                if (EMR.ToLower() == "iqcare")
                                {
                                    try {
                                        BackupIQToolsDB(IQToolsDB, IQToolsServer, IQToolsUser, IQToolsPassword);
                                    }
                                    catch(Exception ex)
                                    {
                                        MessageBox.Show("Backup " + ex.Message);
                                    }
                                    try {
                                        UpdateIQToolsDB(IQToolsDB, IQToolsServer, IQToolsUser, IQToolsPassword);
                                    }
                                    catch(Exception ex)
                                    { MessageBox.Show(ex.Message); }
                                }                                
                                else
                                {
                                    return false;
                                }

                            }
                            catch(Exception ex)                            {
                                MessageBox.Show(ex.Message);
                                return false;
                            }
                            #endregion SQL_Server
                        }                        
                        else
                        {
                            return false;
                        }
                    }
                    else
                    {
                        return false;
                    }
                }
                catch (Exception ex) { throw ex; }
                return true;
            }
            catch 
            {
                return false;
            }
        }
 
        public static bool ValidateSettings(string serverType)
        {
            try
            {
                string IQToolsConnectionString = Entity.GetConnString();
                SqlConnection con = new SqlConnection(IQToolsConnectionString + ";Connection Timeout=5");
                con.Open();
                con.Close();

                string EMRConnectionString = Entity.GetEMRConnString();
                con = new SqlConnection(EMRConnectionString + ";Connection Timeout=5");
                con.Open();
                con.Close();

                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        private string GetDBDataType(string dataType)
        {
            string type = "TEXT";
            switch (dataType)
            {
                case ("System.Decimal"):
                case ("System.Double"):
                case ("System.Single"):
                    type = "DECIMAL";
                    break;

                case ("System.Boolean"):
                    type = "BIT";
                    break;

                case ("System.String"):
                    type = "NVARCHAR(255)";
                    break;

                case ("System.Int16"):
                case ("System.Int32"):
                case ("System.Int64"):
                case ("System.Byte"):
                    type = "INT";
                    break;

                case ("System.DateTime"):
                    type = "DATETIME";
                    break;
            }
            return type;
        }

        private string getConnItem(string item, SqlConnection conn)
        {
            switch (item.ToLower())
            {
                case "database":
                    return conn.Database;
                case "server":
                    return conn.DataSource;
                default:
                    return string.Empty;
            }
        }

        public bool chkAccessDB(string conntring, string emrType)
        {
            if (conntring.Trim().Substring(0, 8).ToLower() == "provider" && emrType.ToLower() != "mysql")
                return true;
            else
                return false;
        }

        void bulkcopy_SqlRowsCopied(object sender, SqlRowsCopiedEventArgs e)
        {
            Console.WriteLine(e.RowsCopied.ToString());
            //throw new Exception("The method or operation is not implemented.");
        }          

        public string getDbType(string pmmsType)
        {
            switch (pmmsType.ToLower().Trim())
            {
                case "microsoft sql server":
                    return "SQL Server";
                case "microsoft access":
                    return "Access database";
                case "mysql server":
                    return "MySQL";
                case "postgresql server":
                    return "PostGre";
                case "db2 database server":
                    return "db2";
                default:
                    return "";
            }
        }

        public static bool DecryptMstPatient()
        {
            Entity en = new Entity();
            string connectionString = GetConnString();
            string EMRConnstring = GetEMRConnString();

            try
            {
                string IQCareDB = Entity.GetEMRDatabaseName(EMRConnstring);
                string SQLString = string.Empty;
                int j = 0;               
                SqlConnection myConn = new SqlConnection();
                myConn.ConnectionString = connectionString;
                myConn.Open();

                string IQToolsDB = myConn.Database;
                myConn.ChangeDatabase(IQCareDB);
                SqlCommand myComm = new SqlCommand("Open symmetric key Key_CTC decryption by password='ttwbvXWpqb5WOLfLrBgisw=='", myConn);
                j = myComm.ExecuteNonQuery();
                myComm.Dispose(); j = 0;

                SQLString = "IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Person]'))" +
                            "Select a.Id PersonID" +
                            ", convert(varchar(100),decryptbykey(a.FirstName)) FirstName" +
                            ", convert(varchar(100),decryptbykey(a.MidName)) MidName" +
                            ", convert(varchar(100),decryptbykey(a.LastName)) LastName" +
                            ", convert(varchar(100),decryptbykey(b.PhysicalAddress)) PhysicalAddress" +
                            ", convert(varchar(100),decryptbykey(b.MobileNumber)) MobileNumber" +
                            " INTO [" + IQToolsDB + "].dbo.Person_Decoded  " +
                            " From  Person a LEFT JOIN  PersonContact b ON a.Id = b.PersonId WHERE a.DeleteFlag = 0" +
                            "IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mst_Patient]')) " +
                            "Select *, convert(varchar(100),decryptbykey(MiddleName)) dMiddleName," +
                            " convert(varchar(100),decryptbykey(firstname)) dFirstName, convert(varchar(100),decryptbykey(LastName))dLastName," +
                            " convert(varchar(100),decryptbykey(Address))dAddress, convert(varchar(100),decryptbykey(Phone)) dPhone" +
                            " INTO [" + IQToolsDB + "].dbo.mst_Patient_Decoded  From " +
                            "mst_patient Where mst_patient.deleteflag is null or mst_patient.deleteflag=0";
                

                myComm = new SqlCommand(SQLString, myConn);
                j = myComm.ExecuteNonQuery(); j = 0;
                myComm.Dispose();

                myComm = new SqlCommand("close symmetric key Key_CTC", myConn);
                j = myComm.ExecuteNonQuery();
                myComm.Dispose();
                myComm = null;
                myConn.Close();
                myConn.Dispose();
                return true;
            }
            catch (Exception ex)
            {
                throw ex;//EH.LogError(ex.Message, "<<frm_Load:Decode Mst_Patient>>", serverType);
            }
        }


        public static void ExecuteNonQuery(string sql, SqlConnection conn)
        {
            string sqlBatch = string.Empty;
            SqlCommand cmd = new SqlCommand(string.Empty, conn);
            conn.Open();
            sql += "\nGO";   // make sure last batch is executed.
            try
            {
                foreach (string line in sql.Split(new string[2] { "\n", "\r" }, StringSplitOptions.RemoveEmptyEntries))
                {
                    if (line.ToUpperInvariant().Trim() == "GO")
                    {
                        try
                        {
                            cmd.CommandText = sqlBatch;
                            cmd.ExecuteNonQuery();
                            sqlBatch = string.Empty;
                        }
                        catch
                        {
                            sqlBatch = string.Empty;
                        }
                    }
                    else
                    {
                        sqlBatch += line + "\n";
                    }
                }
            }
            finally
            {
                conn.Close();
            }
        }

        public static DataSet ExecuteReader(string sQuery, string sConstring)
        {
            DataSet ds = new DataSet();
            SqlConnection con = new SqlConnection(sConstring);
            con.Open();
            SqlCommand command = new SqlCommand(sQuery, con);
            command.CommandType = CommandType.Text;

            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = command;
            da.Fill(ds);
            con.Close();
            return ds;
        }
    }
}
