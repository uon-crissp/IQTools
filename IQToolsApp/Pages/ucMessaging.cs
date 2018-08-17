using System;
using System.Drawing;
using System.Data;
using System.Windows.Forms;
using BusinessLayer;
using DataLayer;
using System.Net;
using System.Data.SqlClient;
using System.Collections;
using System.Management;
using GsmComm.PduConverter;
using GsmComm.GsmCommunication;
using ActiveDatabaseSoftware.ActiveQueryBuilder;
//using MySql.Data.MySqlClient;
using System.Threading;
using System.Data.OleDb;
using System.IO;

namespace IQTools.Pages
{
    public partial class ucMessaging : UserControl
    {
        Entity theObject = new Entity();
        DataTable theDt = new DataTable(); 
        DataTable theQryDT = new DataTable();
        string emrType = Entity.GetEMRType();
        private string TzWbsUrl = "http://41.73.195.220/IQWebServices/IQMessaging.asmx";
        string sSQl = string.Empty;
        GsmCommMain comm;
        private delegate void ConnectedHandler(bool connected);
        bool bModemConnected = false;
        bool wbsConnected = false;
        private string serverType = Entity.getServerType ( BusinessLayer.clsGbl.xmlPath );
        //private string mysqlDateFunction = "CURDATE()";
        //private string sqlServerDateFunction = "GETDATE()";
        private const string TANZANIA = "Tanzania";
        private const string UGANDA = "Uganda";
        private const string KENYA = "Kenya";
        private const int UGANDA_CODE = 256;
        private const int TANZANIA_CODE = 255;
        private const int KENYA_CODE = 254;
        private const int MSG_SENT = 1;
        private const int MSG_FAILED = 2;
        private const int MSG_RECEIVED = 3;
        ErrorLogHelper EH = new ErrorLogHelper();

        public ucMessaging()
        {
            InitializeComponent();

        }

        private void ucMessaging_Load(object sender, EventArgs e)
        {
            //populate a list of all SMS based categories...
            cboSubCategory.Items.Clear();
            cboScheduleCategory.Items.Clear();

            theDt.Clear();
            DataTableReader theDr;

            theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, 
                "SELECT DISTINCT sbCategory FROM aa_SBCategory  LEFT JOIN aa_Category ON aa_Category.CatID = aa_SBCategory.CatID "+
                "WHERE Category='Messaging' Or Category='SMS'", 
                ClsUtility.ObjectEnum.DataTable, Entity.getServerType(clsGbl.xmlPath));
            
            theDr = theDt.CreateDataReader();
            while (theDr.Read())
            {
                cboCategory.Items.Add(theDr[0].ToString());
                cboScheduleCategory.Items.Add(theDr[0].ToString());
            }

            //Load Country Code
            ClsUtility.Init_Hashtable();

            theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                "SELECT CountryCode from aa_Database",
                ClsUtility.ObjectEnum.DataTable, Entity.getServerType(clsGbl.xmlPath));

            txtCountryCode.Text = theDt.Rows[0]["CountryCode"].ToString();

            //Load schedules
            LoadSchedules();
        }

        private void cboCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cboCategory.Text != "")
            {
                //populate a list of all SMS based categories...
                cboSubCategory.Items.Clear();
                theDt.Clear();
                DataTableReader theDr;
                theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, 
                    "SELECT QryDescription FROM (aa_Queries LEFT JOIN aa_sbCategory ON aa_Queries.QryID=aa_sbCategory.QryID) "+
                    "LEFT JOIN aa_Category ON aa_Category.CatID = aa_sbCategory.CatID WHERE "+
                    " Category='Messaging' Or Category='SMS'", ClsUtility.ObjectEnum.DataTable, serverType);

                theDr = theDt.CreateDataReader();
                while (theDr.Read())
                {
                    cboSubCategory.Items.Add(theDr[0].ToString());
                }
            }
        }

        private void cboModemWebService_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (rbSendUsingWebServ.Checked)
            {
                switch (cboModemWebService.Text.ToString())
                {
                    case "Futures Group service - TZ":
                        Cursor.Current = Cursors.WaitCursor;
                        Boolean available = webServiceAvailability(TzWbsUrl);
                        Cursor.Current = Cursors.Default;
                        if (available)
                        {
                            lblConnectionStatus.Text = "Connected";
                            lblConnectionStatus.ForeColor = Color.Green;
                            wbsConnected = true;
                        }
                        else
                        {
                            lblConnectionStatus.Text = "Not Connected";
                            lblConnectionStatus.ForeColor = Color.Red;
                            wbsConnected = false;
                        }

                        break;
                    default:
                        lblConnectionStatus.Text = "Not Connected";
                        lblConnectionStatus.ForeColor = Color.Red;
                        wbsConnected = false; 
                        break;
                }
            }
            else
            {
                int port = 3;
                int baudrate = 19200;
                int timeout = 2000;

                ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_POTSModem");
                foreach (ManagementObject modem in searcher.Get())
                {
                    if (modem.GetPropertyValue("Name").ToString().Trim().ToLower() == cboModemWebService.Text.Trim().ToLower())
                    {
                        port = (int)Convert.ToSingle(modem.GetPropertyValue("AttachedTo").ToString().Substring(3)); ;
                    }

                }

                Cursor.Current = Cursors.WaitCursor;
                comm = new GsmCommMain(port, baudrate, timeout);
                Cursor.Current = Cursors.Default;
                comm.PhoneConnected += new EventHandler(comm_PhoneConnected);
                comm.PhoneDisconnected += new EventHandler(comm_PhoneDisconnected);
                // Prompt user for connection settings

                /*             frmConnection dlg = new frmConnection();
                dlg.StartPosition = FormStartPosition.CenterScreen;
                dlg.SetData(port, baudrate, timeout);
                if (dlg.ShowDialog(this) == DialogResult.OK)
                    dlg.GetData(out port, out baudrate, out timeout);
                else
                {
                    Close();
                    return;
                }*/

                bool retry;
                do
                {
                    retry = false;
                    try
                    {
                        Cursor.Current = Cursors.WaitCursor;
                        if (!comm.IsOpen()) comm.Open();
                        Cursor.Current = Cursors.Default;
                    }
                    catch (Exception)
                    {
                        if (MessageBox.Show(this, "Unable to open this modem on port: " + port, "Error",
                            MessageBoxButtons.RetryCancel, MessageBoxIcon.Warning) == DialogResult.Retry)
                            retry = true;
                        else
                        {
                            return;
                        }
                    }
                }
                while (retry);
            }
        }

        private Boolean webServiceAvailability(string url)
        {
            try
            {
                var myRequest = (HttpWebRequest)WebRequest.Create(url);

                var response = (HttpWebResponse)myRequest.GetResponse();

                if (response.StatusCode == HttpStatusCode.OK)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {
                EH.LogError(ex.Message, "Messaging", serverType);
                return false;
            }
        }

        private void cboSubCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            // get the query and populate the related query
            DataRow theDr; ClsUtility.Init_Hashtable();
            theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams
                , "SELECT DISTINCT QryName, QryDefinition FROM aa_Queries WHERE aa_Queries.QryDescription='" + cboSubCategory.Text + "'"
                , ClsUtility.ObjectEnum.DataRow, serverType);

            txtMessageToSend.Text = "";
            theDt.Clear(); lbLanguages.Items.Clear(); DataTableReader theDtr;
            try
            {
                theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, "SELECT DISTINCT Language From aa_queries Inner Join  aa_sms On aa_queries.qryID = aa_sms.QryID Inner Join " +
                        "  aa_lang On aa_sms.LangID = aa_lang.LangID WHERE aa_Queries.QryName='" + theDr["QryName"].ToString() + "'"
                        , ClsUtility.ObjectEnum.DataTable, serverType);
                theDtr = theDt.CreateDataReader();
                while (theDtr.Read())
                {
                    // populate the list box with currently available languages for the query
                    lbLanguages.Items.Add(theDtr[0].ToString());
                }
                this.Refresh();
            }
            catch { }
            // populate the list with the queries...


            // call the preview window - really! pass in the parameters before exuting the query... and previewing back here...
            Cursor.Current = Cursors.WaitCursor;
            theDt.Clear();

            if (cboSubCategory.Text != "")
            {
                // call the designer screen passing the query; lock the SQL tab
                dgvRecipients.DataSource = null;

                clsGbl.IQDirection = "messaging";
                ClsUtility.Init_Hashtable();
                clsGbl.currQuery = theDr["qryName"].ToString();
                try
                {
                    txtSQL.Text = theDr["QryDefinition"].ToString();
                    QBQTool_Load(sender, e);
                    txtSQL_Leave(sender, e);
                }
                catch 
                { }

                getParams(dgvRecipients, 5, clsGbl.PMMSType);

                Cursor.Current = Cursors.Default;
            }
        }

        private void cmdSend_Click(object sender, EventArgs e)
        {
            //This Error Messages hould be based on selected language at Login
            if (string.IsNullOrEmpty(txtCountryCode.Text))
            {
                MessageBox.Show(Assets.Messages.SMSMissingCountryCode, Assets.Messages.InfoHeader, MessageBoxButtons.OK, MessageBoxIcon.Exclamation, MessageBoxDefaultButton.Button1);
                return;
            }
            if (dgvRecipients.Rows.Count == 0)
            {
                MessageBox.Show(Assets.Messages.SMSNoRecipients, Assets.Messages.InfoHeader, MessageBoxButtons.OK, MessageBoxIcon.Exclamation, MessageBoxDefaultButton.Button1);
                return;
            }
            //if (dgvRecipients.Rows.GetRowCount(DataGridViewElementStates.Selected) == 0)
            //{
            //    MessageBox.Show("Sorry No Phone Number Selected", "IQTools", MessageBoxButtons.OK, MessageBoxIcon.Exclamation, MessageBoxDefaultButton.Button1);
            //    return;
            //}
            if (string.IsNullOrEmpty(txtMessageToSend.Text))
            {
                MessageBox.Show(Assets.Messages.SMSBlankMsg, Assets.Messages.InfoHeader, MessageBoxButtons.OK, MessageBoxIcon.Exclamation, MessageBoxDefaultButton.Button1);
                return;
            }

            if (rbSendUsingWebServ.Checked)
            {
              //Send SMS through web service
              //TzWebReference.IQMessaging Tzservice = new TzWebReference.IQMessaging ( );
              //if (wbsConnected)
              //{
              //  Thread SendSMSThread = new Thread ( ( ) => SendMsgUsingWbs ( dgvRecipients, txtMessageToSend.Text, txtCountryCode.Text, txtLogs, cmdSend, Tzservice ) );
              //  SendSMSThread.SetApartmentState ( ApartmentState.STA );
              //  try
              //  {
              //    SendSMSThread.Start ( );
              //  }
              //  catch (Exception ex)
              //  {
              //    MessageBox.Show ( ex.Message );
              //  }
              // }
              // else
              // {
              //     MessageBox.Show(Assets.Messages.SMSInternetIssue, Assets.Messages.InfoHeader);
              // }
            }
            else if (rbSendUsingModem.Checked)
            {
                //Send SMS through Modem
                if (bModemConnected)
                {
                    Thread SendSMSThread = new Thread(() => SendMsgUsingModem(dgvRecipients, txtMessageToSend.Text, txtCountryCode.Text, txtLogs, cmdSend));
                    SendSMSThread.SetApartmentState(ApartmentState.STA);
                    try
                    {
                        SendSMSThread.Start();
                    }
                    catch (Exception ex) 
                    { 
                        MessageBox.Show(ex.Message); 
                    }
                }
                else
                {
                    MessageBox.Show(Assets.Messages.SMSModemNotSelected, Assets.Messages.InfoHeader);
                }
            }
        }

        //private void SendMsgUsingWbs ( DataGridView dgv, string msg, string countryCode, TextBox outputBox, Button sendButton, TzWebReference.IQMessaging Tzservice)
        //{
        //  Cursor.Current = Cursors.WaitCursor;
        //  string PatientPK= "";
 
        //  try
        //  {
        //    foreach (DataGridViewRow dr in dgv.Rows)
        //    {
        //      try
        //      {
        //        if (dr.Cells["Phone"].Value != null && dr.Selected )
        //        {
        //          string pNum;
        //          if (dr.Cells["Phone"].Value.ToString ( ).Substring ( 0, 1 ) == "0" && countryCode.Length > 1)
        //          {
        //            pNum = countryCode.Trim ( ) + dr.Cells["Phone"].Value.ToString ( ).Substring ( 1 );
        //          }
        //          else if (dr.Cells["Phone"].Value.ToString ( ).Substring ( 0, 1 ) == "+")
        //          {
        //            pNum = dr.Cells["Phone"].Value.ToString ( );
        //          }
        //          else
        //          {
        //            pNum = "";
        //          }

        //          if (pNum != "")
        //          {
              
        //            if (dr.Cells["PatientPK"].Value.ToString() != string.Empty)
        //            {
        //              PatientPK = dr.Cells["PatientPK"].Value.ToString ( );
        //            }
                   
        //            //Use this when resending failed Messages
        //            if (msg.Trim ( ) == string.Empty)
        //            {
        //              msg = dr.Cells["Message"].Value.ToString ( );
        //            }
 
        //            try
        //            {
        //              Tzservice.SendMessage(pNum,msg);
        //              LogMessage ( PatientPK, pNum, msg, MSG_SENT );
        //              UpdateProgress ( pNum + ": Message sent ", outputBox, sendButton, false );
        //            }
        //            catch (Exception ex)
        //            {
        //              LogMessage ( PatientPK, pNum, msg, MSG_FAILED );
        //              UpdateProgress ( pNum + ": Sending failed: " + ex.Message, outputBox, sendButton, false );
        //            }

        //          }
        //          else break;
        //        }
        //      }
        //      catch
        //      {

        //      }
        //    }
        //  }
        //  catch (Exception ex)
        //  {
        //    UpdateProgress ( ex.Message, outputBox, sendButton, false );
        //  }

        //  UpdateProgress ( "", outputBox, sendButton, true );

        //}
        private void SendMsgUsingModem(DataGridView dgv, string msg, string countryCode, TextBox outputBox, Button sendButton)
        {
            Cursor.Current = Cursors.WaitCursor;
            string PatientPK="";

            try
            {
                foreach (DataGridViewRow dr in dgv.Rows)
                {
                    try
                    {
                        if (dr.Cells["Phone"].Value != null)
                        {
                            string pNum;
                            if (dr.Cells["Phone"].Value.ToString().Substring(0, 1) == "0" && countryCode.Length > 1)
                            {
                                pNum = countryCode.Trim() + dr.Cells["Phone"].Value.ToString().Substring(1);
                            }
                            else if (dr.Cells["Phone"].Value.ToString().Substring(0, 1) == "+")
                            {
                                pNum = dr.Cells["Phone"].Value.ToString();
                            }
                            else
                            {
                                pNum = "";
                            }

                            if (pNum != "")
                            {
                                //msg = msg.Replace("XX-XX-XXXX", dr.Cells["NextAppointmentDate"].Value.ToString());

                                //Use this when resending failed Messages
                                if (msg.Trim() == string.Empty)
                                {
                                    msg = dr.Cells["Message"].Value.ToString();
                                }
                                //End

                                PatientPK = dr.Cells["PatientPK"].Value.ToString();

                                try
                                {
                                    SmsSubmitPdu pdu = new SmsSubmitPdu(msg, pNum, "");

                                    comm.SendMessage(pdu);

                                    LogMessage(PatientPK, pNum, msg, MSG_SENT);
                                    UpdateProgress(pNum + ": Message sent ", outputBox, sendButton, false);
                                }
                                catch (Exception ex)
                                {
                                    LogMessage(PatientPK, pNum, msg, MSG_FAILED);
                                    UpdateProgress(pNum + ": Sending failed: " + ex.Message, outputBox, sendButton, false);
                                }

                            }
                            else break;
                        }
                    }
                    catch
                    {

                    }
                }
            }
            catch (Exception ex)
            {
                UpdateProgress(ex.Message, outputBox, sendButton, false);
            }

            UpdateProgress("", outputBox, sendButton, true);
        }

        private void UpdateProgress(string sText, TextBox txtBox, Button sendBtn, bool SendingComplete)
        {
            if (txtBox == null) return;

            if (txtBox.InvokeRequired)
            {
                txtBox.Invoke(new MethodInvoker(delegate { txtBox.Text = txtBox.Text + "\r\n" + sText; }));

                if (SendingComplete)
                {
                    sendBtn.Invoke(new MethodInvoker(delegate { sendBtn.Text = Assets.Messages.SendMsg; }));
                }
                else
                {
                    sendBtn.Invoke(new MethodInvoker(delegate { sendBtn.Text = Assets.Messages.MsgSending; }));
                }
            }
        }

        private void LogMessage(string PatientPK, string Phone, string Msg, int MsgStatus)
        {
            ClsUtility.Init_Hashtable();
            string sSQl = string.Empty;
  
            if (MsgStatus == MSG_SENT)
            {
              sSQl = "INSERT INTO aa_SMSLogs ( PatientPK , Phone , Message , MsgSent , MsgFailed , MsgReceived , LogDate , UserID)" +
                        "VALUES('" + PatientPK + "', '" + Phone + "', '" + Msg + "','1','0','0','" + DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss") + "', '" + Int32.Parse(clsGbl.loggedInUser.UserID.ToString()) + "')";
            }
            else if (MsgStatus == MSG_FAILED)
            {
              sSQl = "INSERT INTO aa_SMSLogs ( PatientPK , Phone , Message , MsgSent , MsgFailed , MsgReceived , LogDate , UserID)" +
                        "VALUES('" + PatientPK + "', '" + Phone + "', '" + Msg + "','0','1','0','" + DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss") + "','" + Int32.Parse(clsGbl.loggedInUser.UserID.ToString()) + "')";
            }
            else if (MsgStatus == MSG_RECEIVED)
            {
              sSQl = "INSERT INTO aa_SMSLogs ( PatientPK , Phone , Message , MsgSent , MsgFailed , MsgReceived , LogDate , UserID)" +
                        "VALUES('" + PatientPK + "', '" + Phone + "', '" + Msg + "','0','0','1','" + DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss") + "','" + Int32.Parse(clsGbl.loggedInUser.UserID.ToString()) + "')";
            }

            //Log SMS
            try
            {
              theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, sSQl, ClsUtility.ObjectEnum.ExecuteNonQuery,serverType);
            }
            catch (Exception ex)
            {
                EH.LogError(ex.Message, "Messaging", serverType);
            }
           
        }

        private void cboCountryCode_SelectedIndexChanged(object sender, EventArgs e)
        {
            string country = cboCountryCode.Text;
            switch (country)
            {
                case TANZANIA:
                    txtCountryCode.ReadOnly = true;
                    txtCountryCode.Text = String.Format("+{0}", TANZANIA_CODE);
                    break;

                case UGANDA:
                    txtCountryCode.ReadOnly = true;
                    txtCountryCode.Text = String.Format("+{0}", UGANDA_CODE);
                    break;

                case KENYA:
                    txtCountryCode.ReadOnly = true;
                    txtCountryCode.Text = String.Format("+{0}", KENYA_CODE);
                    break;

                default:
                    txtCountryCode.ReadOnly = false;
                    txtCountryCode.Text = "+";
                    break;
            }
        }

        private void cmdLoadModem_Click(object sender, EventArgs e)
        {
            if (rbSendUsingModem.Checked)
            {
                comm = null;
                int port = 3;
                int baudrate = 19200;
                int timeout = 2000;

                cboModemWebService.Items.Clear();
                cboModemWebService.Text = "";
                ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_POTSModem");
                foreach (ManagementObject modem in searcher.Get())
                {
                    try
                    {
                        port = (int)Convert.ToSingle(modem.GetPropertyValue("AttachedTo").ToString().Substring(3));
                        Cursor.Current = Cursors.WaitCursor;
                        comm = new GsmCommMain(port, baudrate, timeout);
                        Cursor.Current = Cursors.WaitCursor;
                        comm.Open();
                        Cursor.Current = Cursors.Default;
                        if (comm.IsOpen()) cboModemWebService.Items.Add(modem.GetPropertyValue("Name"));
                        comm.Close();
                    }
                    catch
                    { }
                    finally
                    { if (comm.IsOpen()) comm.Close(); }
                }
                if (cboModemWebService.Items.Count == 1) cboModemWebService.SelectedIndex = 0;
                else
                MessageBox.Show ( "No active modems found in this computer" );
            }
        }

        private void rbSendUsingModem_CheckedChanged(object sender, EventArgs e)
        {
            if (rbSendUsingModem.Checked)
            {
              cboModemWebService.Items.Clear ( ); cboModemWebService.ResetText ( );
            }
            else
            {
              if (comm != null && comm.IsOpen ( )) // Close Modem connection when switching to webservice
                comm.Close ( ); comm = null;
               cboModemWebService.Items.Clear ( ); cboModemWebService.ResetText ( ); //   Clear the Combo before populating the webservices 
               PopulateWebServices ( cboModemWebService );  //Populate web services on the combo box
            }
        }

        private void rbSendUsingWebServ_CheckedChanged(object sender, EventArgs e)
        {
            if (rbSendUsingWebServ.Checked)
            {
                cboModemWebService.Items.Clear();

                //populate the web services
                PopulateWebServices(cboModemWebService);
            }
            else
            {
                cboModemWebService.Items.Clear();
            }
        }

        private void PopulateWebServices(ComboBox combo)
        {
            combo.Items.Add("Futures Group service - TZ");
            combo.Items.Add("Futures Group service - KE");
            combo.Items.Add("Kenya CCK Short code");        
        }

        private void OnPhoneConnectionChange(bool connected)
        {
            if (connected)
            {
                lblConnectionStatus.Text = "Modem Connected";
                lblConnectionStatus.ForeColor = Color.Green;
                bModemConnected = true;
            }
            else
            {
                lblConnectionStatus.Text = "Not Connected";
                lblConnectionStatus.ForeColor = Color.Red;
                bModemConnected = false;
            }
        }

        private void comm_PhoneConnected(object sender, EventArgs e)
        {
            this.Invoke(new ConnectedHandler(OnPhoneConnectionChange), new object[] { true });
        }

        private void comm_PhoneDisconnected(object sender, EventArgs e)
        {
            try
            {
                this.Invoke(new ConnectedHandler(OnPhoneConnectionChange), new object[] { false });
            }
            catch
            {

            }
        }

        private void QBQTool_Load(object sender, EventArgs e)
        {
            if (QDConns(clsGbl.PMMSType))
            {
                QBQTool.SQL = txtSQL.Text;

                if (clsGbl.PMMSType.ToLower() == "mssql")
                {
                    QBQTool.MetadataProvider = eventMetadataProvider1;
                }
                else if (clsGbl.PMMSType.ToLower() == "mysql")
                {
                    //QBQTool.MetadataProvider = MySQLData;
                }
                else
                {
                    QBQTool.MetadataProvider = sqlData;
                }

                QBQTool.RefreshMetadata();
                //QBQTool.MetadataContainer.SaveToXMLFile("C:\\ISanteXML.xml");
                txtSQL.Focus();
            }
        }

        private void txtSQL_Leave(object sender, EventArgs e)
        {
            try
            {
                QBQTool.SQL = txtSQL.Text;
            }
            catch (Exception ex)
            { 
                MessageBox.Show(ex.Message, "Parsing error"); 
            }

        }

        private bool QDConns(string prvder)
        {
            switch (prvder.Trim().ToLower())
            {
                case "mssql":
                    {
                        try
                        {
                            QBQTool.MetadataProvider = sqlData;
                            QBQTool.SyntaxProvider = sqlSyntax;
                            ptSQL.QueryBuilder = QBQTool;
                            sqlData.Connection = (SqlConnection)Entity.GetConnection(Entity.getconnString(clsGbl.xmlPath), prvder);
                            return true;
                        }
                        catch
                        { return false; }
                    }
                //case "mysql":
                   // {
                        //try
                        //{
                        //    QBQTool.MetadataProvider = MySQLData;
                        //    QBQTool.SyntaxProvider = MySQLSyntax;
                        //    ptSQL.QueryBuilder = QBQTool;
                        //    //MySQLData.Connection = (MySqlConnection)Entity.getdbConn((SqlConnection)Entity.GetConnection(Entity.getconnString(clsGbl.xmlPath), serverType), "iqtools");
                        //    MySQLData.Connection = (MySqlConnection)Entity.GetConnection ( Entity.getconnString ( clsGbl.xmlPath ), serverType );
                        //    return true;
                        //}
                        //catch (Exception ex)
                        //{ EH.LogError(ex.Message, "Messaging", serverType); return false; }
                  //  }
                default:
                    {
                        try
                        {
                            QBQTool.MetadataProvider = sqlData;
                            QBQTool.SyntaxProvider = sqlSyntax;
                            ptSQL.QueryBuilder = QBQTool;
                            sqlData.Connection = (SqlConnection)Entity.GetConnection(Entity.getconnString(clsGbl.xmlPath), serverType);
                            return true;
                        }
                        catch
                        { return false; }
                    }

            }

        }

        private void getParams ( DataGridView dgv, int Rc, string pvd )
        {


          switch (pvd.Trim ( ).ToLower ( ))
          {
            case "mssql":
              {
                msSQLParams ( dgv, Rc );
                break;
              }
            case "mysql":
              {
                mySQLParams ( dgv, Rc );
                break;
              }
            default:
              { msSQLParams ( dgv, Rc ); break; }
          }
        }
        private void mySQLParams ( DataGridView dgv, int Rc )
        {
          ////CHRIS 9-19-2012 Handle Data Grid View Error on Incorrect Format
          //dgv.DataError += new DataGridViewDataErrorEventHandler ( dgv_DataError );
          //dgv.Columns.Clear ( );
          //dgv.DataSource = null;
          //if (QBQTool.MetadataProvider != null && QBQTool.MetadataProvider.Connected && QBQTool.SQL.ToString ( ).Length > 1)
          //{


          //  MySqlCommand cmd = (MySqlCommand)MySQLData.Connection.CreateCommand ( );
          //  cmd.CommandTimeout = 600;
          //  cmd.CommandText = QBQTool.SQL;


          //  if (QBQTool.Parameters.Count > 0)
          //  {
          //    Hashtable myParameters = new Hashtable ( ); int j = 0; myParameters.Clear ( );
          //    for (int i = 0; i < QBQTool.Parameters.Count; i++)
          //    {
          //      j = 0;
          //      MySqlParameter p = new MySqlParameter ( );
          //      p.ParameterName = QBQTool.Parameters[i].FullName;
          //      p.DbType = QBQTool.Parameters[i].DataType;
          //      foreach (DictionaryEntry de in myParameters)
          //      {
          //        if (de.Key.ToString ( ).Trim ( ).ToLower ( ) == QBQTool.Parameters[i].FullName.Trim ( ).ToLower ( ))
          //        {
          //          j = 1;
          //          break;
          //        }
          //      }
          //      if (j == 0)
          //      {
          //        cmd.Parameters.Add ( p );
          //        myParameters.Add ( p.ParameterName, p.DbType );
          //      }
          //    }

          //    using (frmQryParameters qpf = new frmQryParameters ( QBQTool.Parameters, cmd ))
          //    {
          //      qpf.ShowDialog ( );
          //    }
          //  }
          //  MySqlDataAdapter adapter = new MySqlDataAdapter ( cmd );
          //  DataTable TblData = new DataTable ( );
          //  try
          //  {
          //    TblData.BeginLoadData ( );
          //    adapter.Fill ( TblData );
          //    TblData.EndLoadData ( );
          //    if (clsGbl.IQDirection.ToLower ( ) != "ram2")
          //    {
          //      dgv.EndEdit ( );
          //      dgv.DataSource = TblData;
          //    }

          //    txtNoOfRecords.Text = TblData.Rows.Count.ToString ( ) + " Records";

          //    dgv.Refresh ( );
          //  }
          //  catch (Exception ex)
          //  {
          //    MessageBox.Show ( ex.Message, "SQL query error" );
          //  }
          //}
        }
        

        private void msSQLParams(DataGridView dgv, int Rc)
        {
            dgv.DataError += new DataGridViewDataErrorEventHandler(dgv_DataError);
            dgv.Columns.Clear();
            dgv.DataSource = null;
            if (QBQTool.MetadataProvider != null && QBQTool.MetadataProvider.Connected && QBQTool.SQL.ToString().Length > 1)
            {
                SqlCommand cmd = (SqlCommand)sqlData.Connection.CreateCommand();
                SqlCommand cm;
                if (ClsUtility.SDate.Length == 3)
                {
                    cm = new SqlCommand("Set dateformat " + ClsUtility.SDate, (SqlConnection)sqlData.Connection);
                    cm.ExecuteNonQuery();
                    cm.Dispose();
                }
                cm = null;
                cmd.CommandTimeout = 600;
                cmd.CommandText = QBQTool.SQL;


                if (QBQTool.Parameters.Count > 0)
                {
                    Hashtable myParameters = new Hashtable(); int j = 0; myParameters.Clear();
                    for (int i = 0; i < QBQTool.Parameters.Count; i++)
                    {
                        j = 0;
                        SqlParameter p = new SqlParameter();
                        p.ParameterName = QBQTool.Parameters[i].FullName;
                        p.DbType = QBQTool.Parameters[i].DataType;
                        foreach (DictionaryEntry de in myParameters)
                        {
                            if (de.Key.ToString().Trim().ToLower() == QBQTool.Parameters[i].FullName.Trim().ToLower())
                            {
                                j = 1;
                                break;
                            }
                        }
                        if (j == 0)
                        {
                            cmd.Parameters.Add(p);
                            myParameters.Add(p.ParameterName, p.DbType);
                        }
                    }

                    using (frmQryParameters qpf = new frmQryParameters(QBQTool.Parameters, cmd))
                    {
                        qpf.ShowDialog();
                    }
                }
                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                DataTable TblData = new DataTable();
                try
                {
                    TblData.BeginLoadData();
                    adapter.Fill(TblData);
                    TblData.EndLoadData();
                    if (clsGbl.IQDirection.ToLower() != "ram2")
                    {
                        dgv.EndEdit();
                        dgv.DataSource = TblData;
                    }

                    txtNoOfRecords.Text = TblData.Rows.Count.ToString() + " Records";

                    //TODO DONE CHRIS IQCare Integration Modify - Only for IQCARE, Showing up in all EMRS//
                    if (emrType == "iqcare")
                    {
                        try
                        {
                            DataGridViewLinkColumn dgvlc = new DataGridViewLinkColumn();
                            dgvlc.DataPropertyName = "PatientPK";
                            dgvlc.HeaderText = "Link To IQCare";
                            dgvlc.Name = "Ptn";
                            dgv.Columns.Add(dgvlc);
                            dgv.Columns["Ptn"].DisplayIndex = 0;


                            //dgv.Columns["PatientEnrollmentID"].Visible = false;
                            //this.dgvQTool.CellContentClick += new DataGridViewCellEventHandler(dgvQTool_CellContentClick);
                            //this.dgvAdherence.CellContentClick += new DataGridViewCellEventHandler(dgvAdherence_CellContentClick);
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show(ex.Message);
                        }

                        try
                        {
                            dgv.Columns["PatientPK"].Visible = false;
                        }
                        catch { }
                    }

                    dgv.Refresh();
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, "SQL query error");
                }
            }
        }

        private void dgv_DataError(object sender, DataGridViewDataErrorEventArgs anError)
        {
            //MessageBox.Show("Error Happened " + anError.Context.ToString());
            if ((anError.Exception) is ConstraintException)
            {
                DataGridView view = (DataGridView)sender;
                view.Rows[anError.RowIndex].ErrorText = "Error";
                view.Rows[anError.RowIndex].Cells[anError.ColumnIndex].ErrorText = "Error";
                anError.ThrowException = false;
            }
        }

        private void eventMetadataProvider1_ExecSQL(BaseMetadataProvider metadataProvider, string sql, bool schemaOnly, out IDataReader dataReader)
        {
            dataReader = null;
            SqlConnection cnn = new SqlConnection();
            //MySqlConnection myCnn = new MySqlConnection();
            if (clsGbl.PMMSType.ToLower() == "mssql")
            {
                cnn = new SqlConnection(Entity.getconnString(clsGbl.xmlPath));
            }
            else if (clsGbl.PMMSType.ToLower() == "mysql")
            {
                //myCnn = (MySqlConnection)Entity.getdbConn((SqlConnection)Entity.GetConnection(Entity.getconnString(clsGbl.xmlPath), "mssql"), "iqtools");
            }

            try
            {
                if (cnn != null && clsGbl.PMMSType.ToLower() == "mssql")
                {
                    if (cnn.State == ConnectionState.Closed) cnn.Open();
                    IDbCommand command = cnn.CreateCommand();
                    command.CommandText = sql;
                    dataReader = command.ExecuteReader();
                }
            }
            catch { }
        }

        private void txtSQL_TextChanged(object sender, EventArgs e)
        {

        }

        private void tpSettings_Enter(object sender, EventArgs e)
        {
            //populate the Languages
            theDt = new DataTable(); ClsUtility.Init_Hashtable(); DataTableReader theDtr; cboSettingslanguage.Items.Clear();
            try
            {
                theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, 
                        "SELECT DISTINCT Language From aa_Lang", ClsUtility.ObjectEnum.DataTable, "mssql");
                theDtr = theDt.CreateDataReader(); 
                cboSettingslanguage.Items.Clear();
                while (theDtr.Read())
                {
                    cboSettingslanguage.Items.Add(theDtr[0].ToString());
                }
            }
            catch { }

            //Populate the category
            theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                "SELECT DISTINCT sbCategory FROM aa_SBCategory  LEFT JOIN aa_Category ON aa_Category.CatID = aa_SBCategory.CatID WHERE "+
                " Category='Messaging' Or Category='SMS'",
                ClsUtility.ObjectEnum.DataTable, Entity.getServerType(clsGbl.xmlPath));

            theDtr = theDt.CreateDataReader();
            cboSettingsCategory.Items.Clear();

            while (theDtr.Read())
            {
                cboSettingsCategory.Items.Add(theDtr[0].ToString());
            }
        }

        private void cboSettingsCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            //Populate all messaging queries in the selected category
            if (cboSettingsCategory.Text != "")
            {
                theDt.Clear(); lbSettingsSubCategory.Items.Clear(); DataTableReader theDtr;
                try
                {
                    theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, 
                                    "SELECT DISTINCT QryName From aa_Queries LEFT JOIN aa_sbCategory ON aa_Queries.QryID = aa_sbCategory.QryID " +
                                    "WHERE aa_sbCategory.sbCategory='" + cboSettingsCategory.Text + 
                                    "'", 
                                    ClsUtility.ObjectEnum.DataTable, serverType);
                    
                    theDtr = theDt.CreateDataReader();
                    while (theDtr.Read())
                    {
                        lbSettingsSubCategory.Items.Add(theDtr[0].ToString());
                    }
                }
                catch 
                { 
                
                }
            }
        }

        private void lbSettingsSubCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (lbSettingsSubCategory.Text != "")
            {
                // get the query description
                DataRow theDr; 
                lblSMSDescription.Text = "";
                try
                {
                    theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, 
                        "SELECT Top 1 QryDescription From aa_queries Where QryName='" + 
                        lbSettingsSubCategory.Text + "'", ClsUtility.ObjectEnum.DataRow, serverType);

                    lblSMSDescription.Text = theDr[0].ToString();
                }
                catch 
                { 
                
                }
            }
        }

        private void cboSettingslanguage_SelectedIndexChanged(object sender, EventArgs e)
        {
            //Clear any existing message
            txtSettingsMessage.Text = "";

            try
            {
                // load the setting for the query on that particular language
                DataRow theDr; ClsUtility.Init_Hashtable();
                theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                    "SELECT DISTINCT Message From aa_queries Inner Join  aa_sms On aa_queries.qryID = aa_sms.QryID Inner Join " +
                    " aa_lang On aa_sms.LangID = aa_lang.LangID WHERE ((aa_Queries.deleteflag is null " +
                    " or aa_Queries.deleteflag =0) And (aa_SMS.DeleteFlag=0 Or aa_SMS.DeleteFlag Is null) " +
                    " And (aa_Lang.DeleteFlag Is Null Or aa_Lang.DeleteFlag=0)) And Language='" + cboSettingslanguage.Text +
                    "' And QryDescription='" + lblSMSDescription.Text + "'", ClsUtility.ObjectEnum.DataRow, serverType);

                txtSettingsMessage.Text = theDr[0].ToString();
            }
            catch
            { 
            
            }
        }

        private void cmdSettingsSave_Click(object sender, EventArgs e)
        {
            DataRow theDr; ClsUtility.Init_Hashtable();
            string langID;
            string qryID;

            if (string.IsNullOrEmpty ( txtSettingsMessage.Text ))
            {
                MessageBox.Show(Assets.Messages.SMSBlankMsgSetting, Assets.Messages.InfoHeader, MessageBoxButtons.OK, MessageBoxIcon.Exclamation, MessageBoxDefaultButton.Button1);
              return;
            }
            if (cboSettingsCategory.SelectedIndex < 0)
            {
                MessageBox.Show(Assets.Messages.SMSNoCategory, Assets.Messages.InfoHeader, MessageBoxButtons.OK, MessageBoxIcon.Exclamation, MessageBoxDefaultButton.Button1);
              return;
            }
            if (lbSettingsSubCategory.SelectedIndex == -1)
            {
                MessageBox.Show(Assets.Messages.SMSNoSubCategory, Assets.Messages.InfoHeader, MessageBoxButtons.OK, MessageBoxIcon.Exclamation, MessageBoxDefaultButton.Button1);
             return;
            }
            //Get the QueryID and Language ID
            theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, 
                    "SELECT Top 1 LangID From aa_Lang Where Language='" + cboSettingslanguage.Text + "'", ClsUtility.ObjectEnum.DataRow, serverType);
            langID = theDr[0].ToString();

            theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, 
                    "SELECT Top 1 QryID From aa_Queries Where QryName ='" + lbSettingsSubCategory.Text + 
                    "' Or QryDescription='" + lblSMSDescription.Text + "'", ClsUtility.ObjectEnum.DataRow, serverType);

            qryID = theDr[0].ToString();

            try
            {
                //Delete the existing message
                theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                        "UPDATE aa_SMS SET DeleteFlag=1, UpdateDate='"+DateTime.Now.ToString ( "yyyy-MM-dd hh:mm:ss" )+"' WHERE LangID="+langID +
                        " AND QryID="+qryID, ClsUtility.ObjectEnum.ExecuteNonQuery, serverType);
            }
            catch(Exception ex)
            {
                EH.LogError(ex.Message, "Messaging", serverType);            
            }
            
              try
              {
                string Sql = "INSERT INTO aa_SMS(QryID, Message, LangID, CreateDate) VALUES(" + qryID + ",'" + txtSettingsMessage.Text.Replace ( "'", "''" ) + "', " + langID + ",'" + DateTime.Now.ToString ( "yyyy-MM-dd hh:mm:ss" ) + "')";
                //Insert a new message
                theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams,
                    "INSERT INTO aa_SMS(QryID, Message, LangID, CreateDate) VALUES(" + qryID +
                    ",'" + txtSettingsMessage.Text.Replace ( "'", "''" ) + "', " + langID + ",'" + DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss")+"')",
                    ClsUtility.ObjectEnum.ExecuteNonQuery, serverType );
              }
              catch (Exception ex)
              {
                  EH.LogError(ex.Message, "Messaging", serverType);
              }

            
           
            MessageBox.Show("Changes saved successfully", "IQTools", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void cmdSettingsDelete_Click(object sender, EventArgs e)
        {
            DataRow theDr; ClsUtility.Init_Hashtable();
            string langID;
            string qryID;

            //Get the QueryID and Language ID
            theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                    "SELECT Top 1 LangID From aa_Lang Where Language='" + cboSettingslanguage.Text + "'", ClsUtility.ObjectEnum.DataRow, serverType);
            langID = theDr[0].ToString();

            theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, "SELECT Top 1 QryID From aa_Queries Where QryName ='" +
                    lbSettingsSubCategory.Text + "' Or QryDescription='" + lblSMSDescription.Text + "'", ClsUtility.ObjectEnum.DataRow, serverType);
            qryID = theDr[0].ToString();

            try
            {
                //Delete the existing message
                theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                        "UPDATE aa_SMS SET DeleteFlag=1, UpdateDate=getDate() WHERE LangID=" + langID +
                        " AND QryID=" + qryID, ClsUtility.ObjectEnum.ExecuteNonQuery, serverType);
            }
            catch (Exception ex)
            {
                EH.LogError(ex.Message, "Messaging", serverType);
            }

            txtSettingsMessage.Text = "";

            MessageBox.Show("Message deleted successfully", "IQTools", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void lbLanguages_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                if (cboSubCategory.Text != "" && lbLanguages.Text != "")
                {
                    DataRow theDr; ClsUtility.Init_Hashtable();
                    theDr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                            "SELECT DISTINCT Message From aa_queries Inner Join  aa_sms On aa_queries.qryID = aa_sms.QryID Inner Join " +
                            "  aa_lang On aa_sms.LangID = aa_lang.LangID WHERE ((aa_Queries.deleteflag is null or aa_Queries.deleteflag =0) " +
                            "And (aa_SMS.DeleteFlag=0 Or aa_SMS.DeleteFlag Is null) And (aa_Lang.DeleteFlag Is Null Or aa_Lang.DeleteFlag=0)) " +
                            "And Language='" + lbLanguages.Text + "' And QryDescription='" + cboSubCategory.Text + "'", ClsUtility.ObjectEnum.DataRow, serverType);

                    if (txtMessageToSend.Text.Length > 0)
                    {
                        txtMessageToSend.Text = txtMessageToSend.Text + " / " + theDr[0].ToString();
                    }
                    else
                    {
                        txtMessageToSend.Text = theDr[0].ToString();
                    }
                }
            }
            catch
            { 
                
            }
        }

        private void cmdSaveCountryCode_Click(object sender, EventArgs e)
        {
            string sCountryCode = txtCountryCode.Text;

            ClsUtility.Init_Hashtable();

            try
            {
                theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                        "UPDATE aa_Database SET CountryCode= '" + sCountryCode + "'", ClsUtility.ObjectEnum.ExecuteNonQuery, serverType);
            }
            catch
            { }

            MessageBox.Show("Country code saved");
        }

        private void cmdRetrieve_Click(object sender, EventArgs e)
        {
            DataTable theDT;
            ClsUtility.Init_Hashtable();
            string sSQLString = "";

            if (rbSentMessages.Checked)
            {   ///Make Sure You consider MySQL Environment upon Modifying this Query.
                sSQLString = "SELECT a.LogID , a.PatientPK , b.PatientName, a.Phone , a.Message ," +
                            " a.LogDate , a.UserID FROM aa_SMSLogs a" +
                            " INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK" +
                            " WHERE MsgSent = 1 and a.LogDate between " +
                            " cast('" + dtpSMSLogsStartDate.Text + "' as Datetime) and DateAdd(dd, 1, cast('" + dtpSMSLogsEndDate.Text + "' as Datetime)) ";
            }
            else if (rbFailedMessages.Checked)
            {
                sSQLString = "SELECT a.LogID , a.PatientPK , b.PatientName, a.Phone , a.Message ," +
                            " a.LogDate , a.UserID FROM aa_SMSLogs a" +
                            " INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK" +
                            " WHERE MsgFailed = 1 and a.LogDate between " +
                            " cast('" + dtpSMSLogsStartDate.Text + "' as Datetime) and DateAdd(dd, 1, cast('" + dtpSMSLogsEndDate.Text + "' as Datetime)) ";
            }
            else if (rbInbox.Checked)
            {
                ReceiveNewMessages();
                //Make Sure You consider MySQL Environment upon Modifying this Query.
                sSQLString = "SELECT a.LogID , a.PatientPK , b.PatientName, a.Phone , a.Message ," +
                            " a.LogDate , a.UserID FROM aa_SMSLogs a" +
                            " LEFT JOIN  tmp_PatientMaster b ON a.PatientPK = b.PatientPK" +
                            " WHERE MsgReceived = 1 and a.LogDate between " +
                            " cast('" + dtpSMSLogsStartDate.Text + "' as Datetime) and DateAdd(dd, 1, cast('" + dtpSMSLogsEndDate.Text + "' as Datetime)) ";
            }

            try
            {
                theDT = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                        sSQLString, ClsUtility.ObjectEnum.DataTable,serverType);  // Consider MySQL environment

                dgvSMSLogs.DataSource = null;
                dgvSMSLogs.DataSource = theDT;

                dgvSMSLogs.Columns[3].Width = 120;
                dgvSMSLogs.Columns[4].Width = 400;
                dgvSMSLogs.Columns[5].Width = 150;
            }
            catch
            {

            }
        }

        private void ReceiveNewMessages()
        {
            if (bModemConnected)
            {
                Cursor.Current = Cursors.WaitCursor;

                DecodedShortMessage[] messages;

                try
                {
                    // Read all SMS messages from SIM storage
                    messages = comm.ReadMessages(PhoneMessageStatus.All, PhoneStorageType.Sim);
                    foreach (DecodedShortMessage message in messages)
                    {
                        SmsDeliverPdu msgData = (SmsDeliverPdu)message.Data;
                        LogMessage(GetPatientIDUsingPhoneNo(msgData.OriginatingAddress), msgData.OriginatingAddress, msgData.UserDataText, MSG_RECEIVED);
                    }

                    // Read all SMS messages from Phone storage
                    messages = comm.ReadMessages(PhoneMessageStatus.All, PhoneStorageType.Phone);
                    foreach (DecodedShortMessage message in messages)
                    {
                        SmsDeliverPdu msgData = (SmsDeliverPdu)message.Data;
                        LogMessage(GetPatientIDUsingPhoneNo(msgData.OriginatingAddress), msgData.OriginatingAddress, msgData.UserDataText, MSG_RECEIVED);
                    }

                    // Delete all messages
                    comm.DeleteMessages(DeleteScope.All, PhoneStorageType.Phone);
                    comm.DeleteMessages(DeleteScope.All, PhoneStorageType.Sim);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message);
                }

                Cursor.Current = Cursors.Default;
            }
        }

        private string GetPatientIDUsingPhoneNo(string sPhone)
        {
            try
            {
                ClsUtility.Init_Hashtable();

                sPhone = sPhone.Replace(txtCountryCode.Text, "");

                DataRow dr = (DataRow)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                    "SELECT TOP 1 PatientPK FROM dbo.tmp_PatientMaster WHERE PhoneNumber LIKE '%" + sPhone + "'",
                    ClsUtility.ObjectEnum.DataRow, "mssql");

                return dr["PatientPK"].ToString();
            }
            catch
            {
                return "0";
            }
        }

        private void rbFailedMessages_CheckedChanged(object sender, EventArgs e)
        {
            cmdResendFailedMsgs.Enabled = rbFailedMessages.Checked;
        }

        private void cmdResendFailedMsgs_Click(object sender, EventArgs e)
        {
            //Switch to the Send SMS tab.
            tcMessaging.SelectedTab = tcMessaging.TabPages[0];

            txtMessageToSend.Text = "";

            dgvRecipients.DataSource = null;
            dgvRecipients.DataSource = dgvSMSLogs.DataSource;
        }

        private void CmdClearLogs_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show(Assets.Messages.ClearLogs, Assets.Messages.InfoHeader, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
                string sSQLString = "Delete from aa_SMSLogs";

                try
                {
                   
                    int i = (int)theObject.ReturnObject ( Entity.getconnString ( clsGbl.xmlPath ), ClsUtility.theParams, sSQLString , ClsUtility.ObjectEnum.ExecuteNonQuery, serverType );
                }
                catch (Exception ex)
                {
                    EH.LogError(ex.Message, "Messaging", serverType);
                }
            }
        }

        private void cmdClearAll_Click(object sender, EventArgs e)
        {
            dgvRecipients.DataSource = null;
            txtMessageToSend.Text = "";
            txtLogs.Text = "";
        }

        private void cmdImportFromXL_Click(object sender, EventArgs e)
        {
          dgvRecipients.DataSource = null;
          DataTable dt = new DataTable ( "dataTable" );
          
            try
            {
                OpenFileDialog browseFile = new OpenFileDialog();
                browseFile.DereferenceLinks = true;
                browseFile.Filter = "Excel Files|*.xls;*.xlsx;*.xlsm";
                browseFile.Title = "Browse Excel file";
                if (browseFile.ShowDialog() == DialogResult.OK)
                {

                  string fileExtension = Path.GetExtension(browseFile.FileName);
                  try
                  {
                    importToGrid ( dgvRecipients, browseFile.FileName.ToString ( ), fileExtension, "True" );

                  }
                  catch (Exception ex)
                  {
                    MessageBox.Show ( ex.Message );
                  }
                }
            }
            catch (Exception ex)
            {
                EH.LogError(ex.Message, "Messaging", serverType); 
            }
        }

        private void cmdScheduleSave_Click(object sender, EventArgs e)
        {
            string sSendUsing = string.Empty;
            ClsUtility.Init_Hashtable();
            string ScheduleType = string.Empty;

            if (rbScheduleModem.Checked)
            {
                sSendUsing = "Modem";
            }
            else
            {
                sSendUsing = "Web service";
            }

            if (rbScheduleDaily.Checked)
            {
                ScheduleType = "Daily";
            }
            else if (rbScheduleWeekly.Checked)
            {
                ScheduleType = "Weekly";
            }
            else if (rbScheduleMonthly.Checked)
            {
                ScheduleType = "Monthly";
            }

            if (txtScheduleID.Text.Length == 0)
            {
                sSQl = "INSERT INTO dbo.aa_SMSSchedules" +
                        "( ScheduleName , QryID , SendUsing , SendUsingDetails , ScheduleType, DailyDaysEarlier , DailyTime ," +
                        "WeeklyDay , WeeklyTime , MonthlyDay , MonthlyTime , CreateDate , UpdateDate , DeleteFlag)" +
                        "VALUES  ('" + txtScheduleName.Text + "', '" + cboScheduleSubCategory.SelectedValue.ToString() + "', '" + sSendUsing + "', " +
                        "'" + cboScheduleModem.Text + "', '" + ScheduleType + "', '" + numDaysEarlier.Value + "', '" + dtpDailyTime.Value + "', " +
                        "'" + cboWeeklyDay.Text + "', '" + dtpWeeklyTime.Value + "', '" + numMonthlyDay.Value + "', " +
                        "'" + dtpMonthlyTime.Value + "', '" + DateTime.Now + "', null, '0')";
            }
            else
            {
                sSQl = "UPDATE dbo.aa_SMSSchedules set ScheduleName='" + txtScheduleName.Text + "' , QryID='" + cboScheduleSubCategory.SelectedValue.ToString() + "' ," +
                        "SendUsing='" + sSendUsing + "' , SendUsingDetails='" + cboScheduleModem.Text + "' ," +
                        "ScheduleType=='" + ScheduleType + "' , DailyDaysEarlier='" + numDaysEarlier.Value + "' ," +
                        "DailyTime='" + dtpDailyTime.Value + "' , WeeklyDay='" + cboWeeklyDay.Text + "' ," +
                        "WeeklyTime='" + dtpWeeklyTime.Value + "' , MonthlyDay='" + numMonthlyDay.Value + "'," +
                        "MonthlyTime='" + dtpMonthlyTime.Value + "' , UpdateDate='" + DateTime.Now + "'" +
                        "WHERE ScheduleID=" + txtScheduleID.Text;
            }

            try
            {
                theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, sSQl, ClsUtility.ObjectEnum.ExecuteNonQuery, "mssql");
            }
            catch
            {

            }

            LoadSchedules();
        }

        private void cmdScheduleDelete_Click(object sender, EventArgs e)
        {
            try
            {
                ClsUtility.Init_Hashtable();

                sSQl = "DELETE FROM dbo.aa_SMSSchedules WHERE ScheduleID = " + dgvSchedules.SelectedRows[0].Cells[0].Value.ToString();

                try
                {
                    theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams, sSQl, ClsUtility.ObjectEnum.ExecuteNonQuery, serverType);
                }
                catch
                {

                }

                LoadSchedules();
            }
            catch { }
        }

        private void cboScheduleCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cboScheduleCategory.Text != "")
            {
                cboScheduleSubCategory.DataSource = null;

                theDt.Clear();

                theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                    "SELECT aa_Queries.QryID, aa_Queries.QryDescription FROM (aa_Queries LEFT JOIN aa_sbCategory ON aa_Queries.QryID=aa_sbCategory.QryID) " +
                    "LEFT JOIN aa_Category ON aa_Category.CatID = aa_sbCategory.CatID WHERE (aa_Queries.DeleteFlag=0 Or " +
                    "aa_Queries.DeleteFlag Is Null) And Category='Messaging' Or Category='SMS'", ClsUtility.ObjectEnum.DataTable, serverType);

                cboScheduleSubCategory.DataSource = theDt;
                cboScheduleSubCategory.ValueMember = "QryID";
                cboScheduleSubCategory.DisplayMember = "QryDescription";
            }

            LoadSchedules();
        }

        private void LoadSchedules()
        {
            try
            {
                sSQl = "SELECT a.ScheduleID , a.ScheduleName , b.sbCategory AS Category, c.qryDescription AS SubCategory, " +
                        " a.SendUsing, a.SendUsingDetails , a.ScheduleType , a.DailyDaysEarlier , a.DailyTime " +
                        ", a.WeeklyDay , a.WeeklyTime , a.MonthlyDay , a.MonthlyTime " +
                        "FROM dbo.aa_SMSSchedules a " +
                        "INNER JOIN dbo.aa_sbCategory b ON a.QryID = b.QryID " +
                        "INNER JOIN dbo.aa_Queries c ON b.QryID = c.qryID ";

                theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(clsGbl.xmlPath), ClsUtility.theParams,
                    sSQl, ClsUtility.ObjectEnum.DataTable, Entity.getServerType(clsGbl.xmlPath));

                dgvSchedules.DataSource = null;
                dgvSchedules.DataSource = theDt;
            }
            catch (Exception ex)
            {
                EH.LogError(ex.Message, "Messaging", serverType);            
            }
        }

        private void cmdScheduleClear_Click(object sender, EventArgs e)
        {
            txtScheduleID.Text = "";
            txtScheduleName.Text = "";
            //cboScheduleCategory.SelectedIndex = -1;
            //cboScheduleSubCategory.SelectedIndex = -1;
            //cboScheduleModem.SelectedIndex = -1;
            cboScheduleModem.Text = "";

            numDaysEarlier.Value = 2;
            dtpDailyTime.Value = DateTime.Now;

            //cboWeeklyDay.SelectedIndex = -1;
            dtpWeeklyTime.Value = DateTime.Now;

            numMonthlyDay.Value = 1;
            dtpMonthlyTime.Value = DateTime.Now;
        }

        private void dgvSchedules_SelectionChanged(object sender, EventArgs e)
        {
            try
            {
                txtScheduleID.Text = dgvSchedules.SelectedRows[0].Cells["ScheduleID"].Value.ToString();
                txtScheduleName.Text = dgvSchedules.SelectedRows[0].Cells["ScheduleName"].Value.ToString();

                cboScheduleCategory.Text = dgvSchedules.SelectedRows[0].Cells["Category"].Value.ToString();
                cboScheduleSubCategory.Text = dgvSchedules.SelectedRows[0].Cells["SubCategory"].Value.ToString();
                cboScheduleModem.Text = dgvSchedules.SelectedRows[0].Cells["SendUsingDetails"].Value.ToString();

                if (dgvSchedules.SelectedRows[0].Cells["SendUsing"].Value.ToString().ToLower() == "modem")
                {
                    rbScheduleModem.Checked = true;
                }
                else
                {
                    rbScheduleWebService.Checked = true;
                }

                if (dgvSchedules.SelectedRows[0].Cells["ScheduleType"].Value.ToString().ToLower() == "daily")
                {
                    rbScheduleDaily.Checked = true;
                }
                else if (dgvSchedules.SelectedRows[0].Cells["ScheduleType"].Value.ToString().ToLower() == "weekly")
                {
                    rbScheduleWeekly.Checked = true;
                }
                else if (dgvSchedules.SelectedRows[0].Cells["ScheduleType"].Value.ToString().ToLower() == "monthly")
                {
                    rbScheduleMonthly.Checked = true;
                }

                numDaysEarlier.Value = Convert.ToDecimal(dgvSchedules.SelectedRows[0].Cells["DailyDaysEarlier"].Value);
                dtpDailyTime.Value = Convert.ToDateTime(dgvSchedules.SelectedRows[0].Cells["DailyTime"].Value);

                cboWeeklyDay.Text = dgvSchedules.SelectedRows[0].Cells["WeeklyDay"].Value.ToString();
                dtpWeeklyTime.Value = Convert.ToDateTime(dgvSchedules.SelectedRows[0].Cells["WeeklyTime"].Value);

                numMonthlyDay.Value = Convert.ToDecimal(dgvSchedules.SelectedRows[0].Cells["MonthlyDay"].Value);
                dtpMonthlyTime.Value = Convert.ToDateTime(dgvSchedules.SelectedRows[0].Cells["MonthlyTime"].Value);
            }
            catch
            {

            }
        }

        private void importToGrid ( DataGridView dgv, string FilePath, string Extension, string isHDR )
        {
          Cursor.Current = Cursors.WaitCursor;
          string conStr = "";

          switch (Extension)
          {

            case ".xls": //Excel 97-03

              conStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source={0};Extended Properties='Excel 8.0;HDR={1}'";

              break;

            case ".xlsx": //Excel 07

              conStr = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source={0};Extended Properties='Excel 8.0;HDR={1}'"; 

              break;

          }

          conStr = String.Format ( conStr, FilePath, isHDR );

          System.Data.OleDb.OleDbConnection connExcel = new OleDbConnection ( conStr );

          OleDbCommand cmdExcel = new OleDbCommand ( );

          OleDbDataAdapter oda = new OleDbDataAdapter ( );

          DataTable dt = new DataTable ( );
          DataSet dSet = new System.Data.DataSet ( );
          cmdExcel.Connection = connExcel;
          //Get the name of First Sheet
          connExcel.Open ( );

          DataTable dtExcelSchema;

          dtExcelSchema = connExcel.GetOleDbSchemaTable ( OleDbSchemaGuid.Tables, null );

          string SheetName = dtExcelSchema.Rows[0]["TABLE_NAME"].ToString ( );

          connExcel.Close ( );



          //Read Data from First Sheet

          connExcel.Open ( );

          cmdExcel.CommandText = "SELECT * From [" + SheetName + "]";

          oda.SelectCommand = cmdExcel;

        
          oda.Fill (dt);

          if (dt.Rows.Count > 0)
          {
            foreach (System.Data.DataColumn column in dt.Columns)
            {
              if (column.DataType != typeof ( string ))
              {
                MessageBox.Show ( "Please Define all columns as text in your excel sheet", "IQTools", MessageBoxButtons.OK, MessageBoxIcon.Exclamation, MessageBoxDefaultButton.Button1 );
                return;
              }
              else { }
            }
          }

          for (int i = dt.Rows.Count - 1; i >= 0; i += -1)
          {
            DataRow row = dt.Rows[ i ];
            if (row[0] == null)
            {
              dt.Rows.Remove ( row );
            }
            else if (string.IsNullOrEmpty ( row[0].ToString ( ) ))
            {
              dt.Rows.Remove ( row );
            }
          }

          connExcel.Close ( );
          dgv.DataSource = dt;
          txtNoOfRecords.Text = dt.Rows.Count.ToString ( ) + " Records";

        }

        private void rbScheduleWebService_CheckedChanged(object sender, EventArgs e)
        {
            if (rbScheduleWebService.Checked)
            {
                cboScheduleModem.Items.Clear();

                //populate the web services
                PopulateWebServices(cboScheduleModem);
            }
            else
            {
                cboScheduleModem.Items.Clear();
                cboScheduleModem.Text = "";
            }
        }

    }
}
