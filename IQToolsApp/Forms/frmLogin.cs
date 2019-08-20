using System;
using System.Data;
using System.Windows.Forms;
using DataLayer;
using BusinessLayer;
using System.Threading;
using System.Reflection;
using System.Data.Sql;
using System.Data.SqlClient;

namespace IQTools
{
    public partial class frmLogin : Form
    {
        string serverType = string.Empty;
        string emrType = string.Empty;
        string iqtoolsConnectionString = Entity.GetConnString();

        public void InitializeForm()
        {
            if (System.Deployment.Application.ApplicationDeployment.IsNetworkDeployed)
                clsGbl.IQToolsVersion = System.Deployment.Application.ApplicationDeployment.CurrentDeployment.CurrentVersion.ToString();
            else
                clsGbl.IQToolsVersion = Application.ProductVersion;
            this.Text = "IQTools | v" + clsGbl.IQToolsVersion;
            serverType = Entity.GetServerType();
            emrType = Entity.GetEMRType();
            if (iqtoolsConnectionString != String.Empty)
            {
                if (!Entity.ValidateSettings(serverType))
                {
                    clsGbl.SettingsValid = false;
                    lblLoad.Text = "Invalid Settings";
                    picLoad.Image = Properties.Resources.wrong;
                }
                else
                {
                    clsGbl.SettingsValid = true;
                    lblLoad.Text = "Ready";
                    picLoad.Image = Properties.Resources.right;
                    activateRefresh();
                    activateSatelliteCombo();
                }
            }
            else
            {
                clsGbl.SettingsValid = false;
                lblLoad.Text = "Invalid Settings";
                picLoad.Image = Properties.Resources.wrong;
            }  
        }

        public frmLogin()
        {
            InitializeComponent();
        }

        private void cmdLogin_Click(object sender, EventArgs e)
        {
            string selectedFacility = "";

            if (!rdoLFTU30Days.Checked && !rdoLFTU90Days.Checked)
            {
                MessageBox.Show("Please select the LTFU criteria", Assets.Messages.InfoHeader, MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            if (clsGbl.SettingsValid == false)
            {
                MessageBox.Show(Assets.Messages.InvalidSettings, Assets.Messages.InfoHeader, MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            else
            {
                if (rdoLFTU30Days.Checked)
                {
                    clsGbl.LTFUApplicable = "LTFU 30 Days Applicable";
                }
                else
                {
                    clsGbl.LTFUApplicable = "LTFU 90 Days Applicable";
                }

                if (txtUser.Text != "" && txtPassword.Text != "")
                {
                    if (emrType == "iqcare")
                    {
                        if (cboFacility.SelectedIndex > -1)
                            selectedFacility = cboFacility.SelectedItem.ToString();
                        else
                        {
                            MessageBox.Show("Please Select A Facility To Proceed", Assets.Messages.InfoHeader
                                , MessageBoxButtons.OK, MessageBoxIcon.Information);
                            return;
                        }
                    }
                    if (loginEMR(emrType, txtUser.Text.Trim(), txtPassword.Text, selectedFacility))
                    {
                        Thread loadThread = new Thread(() => LoadIQTools(chkRefresh.Checked));
                        loadThread.SetApartmentState(ApartmentState.STA);
                        loadThread.Start();
                    }
                }
                else
                {
                    MessageBox.Show(Assets.Messages.MissingCredentials, Assets.Messages.InfoHeader
                        , MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
        }
        
        private void frmLogin_Load(object sender, EventArgs e)
        {
            InitializeForm();
        }

        private void activateRefresh()
        {
            if (serverType == "pgsql")
                chkRefresh.Checked = true;
            if (Entity.GetRefreshRights() == "no")
            {
                chkRefresh.Checked = false;
                chkRefresh.Enabled = false;
            }
        }

        private bool loginEMR(string emr, string userName, string password, string facilityName)
        {
            string emrConnString = "";
            ClsUtility.Init_Hashtable();
            Entity en = new Entity();
            try
            {
                if (emr.ToLower() == "iqcare")
                {
                    DataRow dr;

                    emrConnString = Entity.GetEMRConnString();

                    string sPassword = ClsUtility.Encrypt(password);
                    string sSQL = "SELECT top 1 a.userID, a.UserName, a.Password, a.UserFirstName, a.UserLastName, c.GroupName, f.FacilityID, f.SatelliteID MFLCode FROM " +
                                "(Select FacilityID, SatelliteID FROM mst_Facility WHERE FacilityName = '" + facilityName + "') f, " +
                                "mst_user a " +
                                "INNER JOIN dbo.lnk_UserGroup b ON a.UserID = b.UserID " +
                                "INNER JOIN dbo.mst_Groups c ON b.GroupID = c.GroupID " +
                                "WHERE a.DeleteFlag = 0 AND a.UserName = '" + userName + "' AND Password = '" + sPassword + "'";
                    try
                    {
                        dr = (DataRow)en.ReturnObject(emrConnString, ClsUtility.theParams, sSQL, ClsUtility.ObjectEnum.DataRow, serverType);
                    }
                    catch (Exception ex)
                    {
                        if (ex.Message.Contains("There is no row at position 0"))
                        {
                            MessageBox.Show(Assets.Messages.InvalidUser, Assets.Messages.ErrorHeader, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            return false;
                        }
                        else
                        {
                            MessageBox.Show(ex.Message, Assets.Messages.ErrorHeader);
                            return false;
                        }
                    }
                    if (dr.Table.Rows.Count >= 1)
                    {
                        clsGbl.loggedInUser.UserID = Convert.ToInt16(dr["userID"]);
                        clsGbl.loggedInUser.UserName = dr["UserName"].ToString();
                        clsGbl.loggedInUser.Password = dr["Password"].ToString();
                        clsGbl.loggedInUser.FirstName = dr["UserFirstName"].ToString();
                        clsGbl.loggedInUser.LastName = dr["UserLastName"].ToString();
                        clsGbl.loggedInUser.Group = dr["GroupName"].ToString();
                        clsGbl.loggedInUser.FacilityID = Convert.ToInt16(dr["FacilityID"]);
                        clsGbl.loggedInUser.FacilityName = facilityName;
                        clsGbl.loggedInUser.MFLCode = dr["MFLCode"].ToString();
                        return true;
                    }
                    else
                    {
                        MessageBox.Show(Assets.Messages.InvalidUser, Assets.Messages.ErrorHeader);
                        return false;
                    }
                }

                else return true;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, Assets.Messages.ErrorHeader);
                return false;
            }
        }

        private void activateSatelliteCombo()
        {
            if (emrType == "iqcare")
            {
                lblFacility.Visible = true;
                cboFacility.Visible = true;
                lblCriteria.Visible = true;

                string sql = "Select FacilityName, FacilityID FROM mst_Facility WHERE DeleteFlag = 0";
                Entity en = new Entity();

                string emrConnString = Entity.GetEMRConnString();

                DataTable dt = (DataTable)en.ReturnObject(emrConnString, ClsUtility.theParams
                    , sql, ClsUtility.ObjectEnum.DataTable, serverType);
                DataTableReader dtr = dt.CreateDataReader();
                cboFacility.Items.Clear();
                while (dtr.Read())
                {
                    cboFacility.Items.Add(dtr[0].ToString());
                }

                cboFacility.SelectedIndex = 0;
            }
        }

        private void LoadIQTools(bool refresh)
        {
            SetControlPropertyThreadSafe(cmdLogin, "Enabled", false);
            SetControlPropertyThreadSafe(picLoad, "Image", Properties.Resources.progress4);

            if (ForceUpgrade())
            {
                refresh = true;
                SetControlPropertyThreadSafe(lblLoad, "Text", "Updating IQTools DB, Please Wait...");

                Entity.ForceUpgrade();
            }

            SetControlPropertyThreadSafe(lblLoad, "Text", "Loading, Please Wait...");
            string connectionString = Entity.GetConnString();
            int i = 0;
            Entity en = new Entity();
            ClsUtility.Init_Hashtable();
            try
            {
                if (emrType == "iqcare")
                {
                    try
                    {
                        if (refresh)
                        {
                            Entity.DropIQToolsObjects(emrType, serverType);
                            Entity.CreateIQToolsObjects(emrType, serverType);
                            if (Entity.DecryptMstPatient())
                            {
                                ClsUtility.Init_Hashtable();
                                try
                                {
                                    try
                                    {
                                        i = (int)en.ReturnObject(connectionString, ClsUtility.theParams
                                                                            , "pr_RefreshIQTools"
                                                                            , ClsUtility.ObjectEnum.ExecuteNonQuery, "mssql");
                                    }
                                    catch (Exception ex) { MessageBox.Show(ex.Message); }
                                    ClsUtility.Init_Hashtable();
                                }
                                catch (Exception ex)
                                {
                                    //EH.LogError(ex.Message, "<<frmLoad:loadIQTools()>>", serverType);
                                    //clsGbl.IQDirection = "connect";
                                    MessageBox.Show(ex.Message);
                                }
                            }
                        }

                        Form tmp = new frmMain();
                        AccessContol();
                        Application.Run(tmp);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show(ex.Message);
                        MessageBox.Show("There Was A Problem Accessing The EMR Database, Data May Not Have Been Loaded Into IQTools"
                                                , "IQTools Connection Error", MessageBoxButtons.OKCancel, MessageBoxIcon.Error);
                        SetControlPropertyThreadSafe(cmdLogin, "Enabled", true);
                        SetControlPropertyThreadSafe(picLoad, "Image", null);
                        SetControlPropertyThreadSafe(lblLoad, "Text", "");
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("IQTools Could Not Connect To The EMR Database, Please Configure IQTools. Error Message=" + ex.Message
                                    , "IQTools Connection Error", MessageBoxButtons.OKCancel, MessageBoxIcon.Error);
                SetControlPropertyThreadSafe(cmdLogin, "Enabled", true);
                SetControlPropertyThreadSafe(picLoad, "Image", null);
                SetControlPropertyThreadSafe(lblLoad, "Text", "");
            }

        }

        private void AccessContol()
        {
            if (InvokeRequired)
            { this.Invoke(new MethodInvoker(delegate { this.Hide(); })); }
            else { this.Hide(); }
        }

        private delegate void SetControlPropertyThreadSafeDelegate(Control control, string propertyName, object propertyValue);

        private static void SetControlPropertyThreadSafe(Control control, string propertyName, object propertyValue)
        {
            if (control.InvokeRequired)
            {
                control.Invoke(new SetControlPropertyThreadSafeDelegate(SetControlPropertyThreadSafe)
                    , new object[] { control, propertyName, propertyValue });
            }
            else
            {
                control.GetType().InvokeMember(propertyName, BindingFlags.SetProperty, null, control
                    , new object[] { propertyValue });
            }
        }

        private void tcLogin_SelectedIndexChanged(object sender, EventArgs e)
        {
            if(tcLogin.SelectedTab == tpSettings)
            {
                Thread g = new Thread(() => GetSqlServers());
                g.SetApartmentState(ApartmentState.STA);
                g.Start();
            }
            if(tcLogin.SelectedTab == tpLogin)
            {
                iqtoolsConnectionString = Entity.GetConnString();
                InitializeForm();
            }
        }

        private void GetSqlServers()
        {

            if (cboSQLServer.InvokeRequired)
            {
                cboSQLServer.Invoke(new MethodInvoker(delegate
                {
                    cboSQLServer.Items.Clear();
                }));
            }
            else
            {
                cboSQLServer.Items.Clear();
            }

            SetControlPropertyThreadSafe(lblSaveProgress, "Text", "Getting List Of SQL Servers");
            SetControlPropertyThreadSafe(picSettingsProgress, "Image", Properties.Resources.progress4);
            SetControlPropertyThreadSafe(cboSQLServer, "DataSource", null);
            SetControlPropertyThreadSafe(cboSQLServer, "Enabled", false);
            DataTable servers = SqlDataSourceEnumerator.Instance.GetDataSources();
            if (servers.Rows.Count > 0)
            {
                string displayMember = string.Empty;
                for (int i = 0; i < servers.Rows.Count; i++)
                {
                    if ((servers.Rows[i]["Version"].ToString()) != string.Empty)
                    {
                        if ((servers.Rows[i]["InstanceName"].ToString()) != string.Empty)
                        {
                            if (cboSQLServer.InvokeRequired)
                            {
                                cboSQLServer.Invoke(new MethodInvoker(delegate
                                {
                                    cboSQLServer.Items.Add(servers.Rows[i]["ServerName"] + "\\" + servers.Rows[i]["InstanceName"]);
                                }));
                            }
                            else
                            {
                                cboSQLServer.Items.Add(servers.Rows[i]["ServerName"] + "\\" + servers.Rows[i]["InstanceName"]);
                            }
                        }

                        else
                        {
                            if (cboSQLServer.InvokeRequired)
                            {
                                cboSQLServer.Invoke(new MethodInvoker(delegate
                                {
                                    cboSQLServer.Items.Add(servers.Rows[i]["ServerName"]);
                                }));
                            }
                            else
                            {
                                cboSQLServer.Items.Add(servers.Rows[i]["ServerName"]);
                            }
                        }
                    }
                }
            }
            else
            {

                MessageBox.Show("No Named SQL Server Instances Were Found. Please check that the SQL Server Browser Service is running. " +
                    " You may still be able to connect by manually typing the Instance Name into the SQL Server Drop Down Box."
                    ,"IQTools | Server Not Found", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }

            SetControlPropertyThreadSafe(lblSaveProgress, "Text", "Done");
            SetControlPropertyThreadSafe(cboSQLServer, "Enabled", true);
            SetControlPropertyThreadSafe(picSettingsProgress, "Image", Properties.Resources.right);
        }

        private void cboIQCareDatabase_Enter(object sender, EventArgs e)
        {
            try {
                string connString = string.Empty;
                if (cboSQLServer.Text.Trim() != string.Empty && txtServerUserName.Text.Trim() != string.Empty
                    && txtServerPassword.Text != string.Empty)
                {
                    connString =
                        CreateConnectionString(cboSQLServer.Text.Trim(), txtServerUserName.Text.Trim(), txtServerPassword.Text, string.Empty);
                    cboIQCareDatabase.DataSource = new BindingSource(GetIQCareDBs(connString), null);
                    cboIQCareDatabase.DisplayMember = "IQCareDB";
                    cboIQCareDatabase.SelectedIndex = -1;
                    cboIQToolsDatabase.DataSource = new BindingSource(GetIQToolsDBs(connString), null);
                    cboIQToolsDatabase.DisplayMember = "IQToolsDB";
                    cboIQToolsDatabase.SelectedIndex = -1;
                    picServer.Image = Properties.Resources.right;
                    picUserName.Image = Properties.Resources.right;
                    picPassword.Image = Properties.Resources.right; 
                }
            }
            catch(Exception ex)
            {
                if (ex.Message.ToLower().Contains("login failed"))
                {
                    picServer.Image = Properties.Resources.right;
                    picUserName.Image = Properties.Resources.right;
                    picPassword.Image = Properties.Resources.wrong;
                }
                MessageBox.Show(ex.Message);
                
            }
            
        }

        private string CreateConnectionString(string server, string username, string pass, string db)
        {
            if(db != string.Empty)
            {
                return string.Format("server = {0}; user id={1}; password={2};database={3}", server, username, pass, db);
            }
            else
                return string.Format("server = {0}; user id={1}; password={2}", server, username, pass);
        }

        private DataTable GetIQCareDBs(string connString)
        {
            Entity en = new Entity();
            DataTable dt = (DataTable)en.ReturnObject(connString, null
                        , "SELECT d.name IQCareDB, f.name logicalName FROM master..sysaltfiles f " +
                        "INNER JOIN master..sysdatabases d ON f.dbid = d.dbid " +
                        "Where f.name like '%iqcare%' and f.fileid = 1"
                        , ClsUtility.ObjectEnum.DataTable, serverType);
            return dt;
        }

        private DataTable GetIQToolsDBs(string connString)
        {
            Entity en = new Entity();
            DataTable dt = (DataTable)en.ReturnObject(connString, null
                 , "SELECT d.name IQToolsDB, f.name logicalName FROM master..sysaltfiles f " +
                        "INNER JOIN master..sysdatabases d ON f.dbid = d.dbid " +
                        "Where f.name like '%iqtools%' and f.fileid = 1"
                        , ClsUtility.ObjectEnum.DataTable, serverType);
            return dt;
        }

        private void cboIQCareDatabase_SelectedIndexChanged(object sender, EventArgs e)
        {
           
        }

        private string GetIQCareVersion(string connString)
        {
            string IQCareVersion = string.Empty;
            try {
                Entity en = new Entity();
                DataRow dr = (DataRow)en.ReturnObject(connString, null, "SELECT TOP 1 AppVer FROM AppAdmin"
                    , ClsUtility.ObjectEnum.DataRow, serverType);
                IQCareVersion = dr["AppVer"].ToString();                
            }
            catch(Exception ex)
            {
                if (ex.Message.ToLower().Contains("not exist"))
                    return "Not An IQCare DB";
            }
            return IQCareVersion;
        }

        private void cboIQCareDatabase_SelectionChangeCommitted(object sender, EventArgs e)
        {
            try
            {
                string connString = string.Empty;
                if (cboSQLServer.Text.Trim() != string.Empty && txtServerUserName.Text.Trim() != string.Empty
                    && txtServerPassword.Text != string.Empty && cboIQCareDatabase.Text.Trim() != string.Empty)
                {
                    connString =
                        CreateConnectionString(cboSQLServer.Text.Trim(), txtServerUserName.Text.Trim(), txtServerPassword.Text
                        , cboIQCareDatabase.Text.Trim());
                    string IQCareVersion = GetIQCareVersion(connString);
                    if (IQCareVersion != string.Empty && IQCareVersion.ToLower() != "Not An IQCare DB")
                    {
                        picIQCareDB.Image = Properties.Resources.right;
                        lblIQCareVersion.Text = IQCareVersion;
                    }
                    else
                    {
                        picIQCareDB.Image = Properties.Resources.wrong;
                        lblIQCareVersion.Text = IQCareVersion;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private string GetIQToolsVersion(string connString)
        {
            string IQToolsVersion = string.Empty;
            try
            {
                Entity en = new Entity();
                DataRow dr = (DataRow)en.ReturnObject(connString, null, "Select DBVersion FROM aa_Version"
                    , ClsUtility.ObjectEnum.DataRow, serverType);
                IQToolsVersion = dr["DBVersion"].ToString();
            }
            catch (Exception ex)
            {
                //if (ex.Message.ToLower().Contains("not exist"))
                //    return "Not An IQCare DB";
                MessageBox.Show(ex.Message);
            }
            return IQToolsVersion;
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            bool updateDB = chkUpdateIQTools.Checked;
            string server = cboSQLServer.Text.Trim();
            string serverUserName = txtServerUserName.Text.Trim();
            string serverPassword = txtServerPassword.Text;
            string iqcareDB = cboIQCareDatabase.Text.Trim();
            string iqtoolsDB = cboIQToolsDatabase.Text.Trim();
            string serverIP = string.Empty;
            if (server.IndexOf("\\") != -1)
            {
                serverIP = server.Substring(0, server.IndexOf("\\"));
            }
            else
            {
                serverIP = server;
            }
            if (serverIP == ".")
            {
                serverIP = "localhost";
            }

            Thread saveSettingsT = new Thread(() => SaveSettings(updateDB, server, serverIP, serverUserName, serverPassword
                , iqcareDB, iqtoolsDB));
            saveSettingsT.SetApartmentState(ApartmentState.STA);
            saveSettingsT.Start();
        }

        private void CheckVersions()
        {
            
            //clsGbl.IQToolsVersion = Application.ProductVersion;
            //txtVersion.Text = Application.ProductVersion;
            if (System.Deployment.Application.ApplicationDeployment.IsNetworkDeployed)
                clsGbl.IQToolsVersion = System.Deployment.Application.ApplicationDeployment.CurrentDeployment.CurrentVersion.ToString();
            else
                clsGbl.IQToolsVersion = Application.ProductVersion;

            string DBVersion = GetIQToolsVersion(Entity.GetConnString());

            if (clsGbl.IQToolsVersion.ToLower() != DBVersion.ToLower())
            {
                MessageBox.Show(
                "This IQTools App Has Been Updated to Version " + 
                clsGbl.IQToolsVersion + ". Please Reconfigure the Connection to IQCare and Update the IQTools DB","IQTools | Update"
                ,MessageBoxButtons.OK,MessageBoxIcon.Information);
                tcLogin.SelectedTab = tpSettings;
                cmdLogin.Enabled = false;
            }
        }

        private bool ForceUpgrade()
        {
            if (System.Deployment.Application.ApplicationDeployment.IsNetworkDeployed)
                clsGbl.IQToolsVersion = System.Deployment.Application.ApplicationDeployment.CurrentDeployment.CurrentVersion.ToString();
            else
                clsGbl.IQToolsVersion = Application.ProductVersion;

            string DBVersion = GetIQToolsVersion(Entity.GetConnString());

            if (clsGbl.IQToolsVersion.ToLower() != DBVersion.ToLower())
            {
                return true;
            }
            else return false;
        }

        private void SaveSettings(bool updateDB, string server, string serverIP, string serverUserName, string serverPassword, string iqcareDB, string iqtoolsDB)
        {
            SetControlPropertyThreadSafe(picSettingsProgress, "Image", Properties.Resources.progress4);
            SetControlPropertyThreadSafe(lblSaveProgress, "Text", "Saving...");
            SetControlPropertyThreadSafe(btnSave, "Enabled", false);
            string iqtoolsConnectionString = CreateConnectionString(server, serverUserName, serverPassword, iqtoolsDB);
            string iqcareConnectionString = CreateConnectionString(server, serverUserName, serverPassword, iqcareDB);

            if (updateDB)
            {
                if (Entity.CreateIQToolsDB("microsoft sql server", serverUserName, server, serverPassword, iqtoolsDB, "iqcare"))
                {
                    Entity.SetConnString(iqtoolsConnectionString);
                    Entity.SetServerType("mssql");
                    Entity.SetEMRConnString(iqtoolsConnectionString, iqcareConnectionString, serverIP, iqcareDB, "iqcare", "mssql", GetIQCareVersion(iqcareConnectionString));
                }
                else
                {
                    SetControlPropertyThreadSafe(picSettingsProgress, "Image", null);
                    SetControlPropertyThreadSafe(lblSaveProgress, "Text", "Error Updating the IQTools DB");
                    SetControlPropertyThreadSafe(btnSave, "Enabled", true);
                    return;
                }
            }
            else
            {
                Entity.SetConnString(iqtoolsConnectionString);
                Entity.SetServerType("mssql");
                Entity.SetEMRConnString(iqtoolsConnectionString, iqcareConnectionString, serverIP, iqcareDB, "iqcare", "mssql", GetIQCareVersion(iqcareConnectionString));
            }

            SetControlPropertyThreadSafe(picSettingsProgress, "Image", null);
            SetControlPropertyThreadSafe(lblSaveProgress, "Text", "");
            SetControlPropertyThreadSafe(btnSave, "Enabled", true);
            SetControlPropertyThreadSafe(tcLogin, "SelectedTab", tpLogin);
            SetControlPropertyThreadSafe(picLoad, "Image", Properties.Resources.right);
            SetControlPropertyThreadSafe(lblLoad, "Text", "Settings Successfully Saved");
        }

        private void rdoLFTU30Days_CheckedChanged(object sender, EventArgs e)
        {
            string connectionString = Entity.GetConnString();
            SqlConnection myConn = new SqlConnection();
            myConn.ConnectionString = connectionString;

            if (rdoLFTU30Days.Checked)
            { 
                Entity.UpdateIQToolsSystemFunctions(myConn);
            }
        }

        private void rdoLFTU90Days_CheckedChanged(object sender, EventArgs e)
        {
            string connectionString = Entity.GetConnString();
            SqlConnection myConn = new SqlConnection();
            myConn.ConnectionString = connectionString;

            if (rdoLFTU90Days.Checked)
            {
                Entity.UpdateIQToolsSystemFunctions_90dayLFTU(myConn);
            }
        }
    }
}

    