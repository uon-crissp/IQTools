using System;
using System.Windows.Forms;
using BusinessLayer;
using DataLayer;


namespace IQTools.Pages
{
    public partial class ucEMRAccess : UserControl
    {
        frmMain fMain;
        string patientPK = "0";
        string emrType = Entity.GetEMRType();
        public ucEMRAccess(frmMain frm)
        {
            InitializeComponent();
            fMain = frm;
        }

        private void ucEMRAccess_Load(object sender, EventArgs e)
        {
            wbEMR.ScriptErrorsSuppressed = true;
            wbEMR.WebBrowserShortcutsEnabled = true;
            
            //wbEMR.ShowPropertiesDialog();
            wbEMR.Select();
        }

        private string GetIQCareURL()
        {
            //Entity en = new Entity();
            //ClsUtility.Init_Hashtable();

            //String url = "";
            //String encryptURL = "";
            //String cryptURL = "";
            //try
            //{
            //    string IQCareUserName = clsGbl.loggedInUser.UserName;
            //    string UserID = clsGbl.loggedInUser.UserID.ToString();
            //    string IQCarePassword = ClsUtility.Decrypt(clsGbl.loggedInUser.Password);
            //    string TechnicalArea = "1";//theDr["IQTechnicalArea"].ToString().Trim(); Not used
            //    string server = "localhost";//theDr["IQServer"].ToString().Trim();
            //    string protocol = "http";//theDr["IQProtocol"].ToString().Trim();
            //    string port = "58789";//theDr["IQPort"].ToString().Trim();
            //    string FacilityID = clsGbl.loggedInUser.FacilityID.ToString();//"755";

            //    cryptURL = String.Format("Ptn_Pk={0}&UserName={1}&Password={2}&technicalArea={3}&UserID={4}&FacilityID={5}"
            //        , clsGbl.EMRPatientPK, IQCareUserName, IQCarePassword, TechnicalArea, UserID, FacilityID);
            //    encryptURL = ClsUtility.Encrypt(cryptURL);

            //    //Format the URL
            //    //url = protocol + "://" + server + ":" + port + "/iqcare/frmConnect.aspx?enc=" + encryptURL;
            //    url = String.Format("{0}://{1}:{2}/frmConnect.aspx?enc={3}"
            //        ,protocol,server,port,encryptURL);
            //    return url;
            //}
            //catch (Exception ex)
            //{
            //    if (ex.Message.ToLower() == "there is no row at position 0.")
            //    {
            //        //MessageBox.Show ( "Connection to IQCare Has Not Been Configured. Please Enter Your Connection Details Under The Administration Page", "IQTools", MessageBoxButtons.OK, MessageBoxIcon.Question );
            //    }
            //    else
            //    {
            //        MessageBox.Show(ex.Message);
            //    }
            //    return null;
            //}

            string url = string.Empty;
            string encryptURL = string.Empty;
            string cryptURL = string.Empty;
            string page = string.Empty;
            //if (Convert.ToDouble(clsGbl.EmrVersion) < Convert.ToDouble(3.6))
            //{
            //    page = "frmConnect.aspx";
            //}
            //else
            page = "frmConnect36.aspx";
            try
            {
                string IQCareUserName = clsGbl.loggedInUser.UserName;
                string UserID = clsGbl.loggedInUser.UserID.ToString();
                string IQCarePassword = ClsUtility.Decrypt(clsGbl.loggedInUser.Password);
                string TechnicalArea = "1"; //Not used
                string server = clsGbl.EMRIPAddress;
                string protocol = "http";
                string port = "80";
                string FacilityID = clsGbl.loggedInUser.FacilityID.ToString();

                cryptURL = String.Format("Ptn_Pk={0}&UserName={1}&Password={2}&technicalArea={3}&UserID={4}&FacilityID={5}"
                    , clsGbl.EMRPatientPK, IQCareUserName, IQCarePassword, TechnicalArea, UserID, FacilityID);
                encryptURL = ClsUtility.Encrypt(cryptURL);

                //Format the URL
                //url = protocol + "://" + server + ":" + port + "/iqcare/frmConnect.aspx?enc=" + encryptURL;
                url = String.Format("{0}://{1}:{2}/iqcare/{3}?enc={4}"
                    , protocol, server, port, page, encryptURL);
                return url;
            }
            catch (Exception ex)
            {
                if (ex.Message.ToLower() == "there is no row at position 0.")
                {
                    //MessageBox.Show ( "Connection to IQCare Has Not Been Configured. Please Enter Your Connection Details Under The Administration Page", "IQTools", MessageBoxButtons.OK, MessageBoxIcon.Question );
                }
                else
                {
                    MessageBox.Show(ex.Message);
                }
                return null;
            }

        }

        private void wbEMR_Navigated(object sender, WebBrowserNavigatedEventArgs e)
        {
            if(wbEMR.Url.ToString() != "about:blank")
            fMain.lblNotify.Text = wbEMR.Url.ToString();            
        }

        private void wbEMR_DocumentCompleted(object sender, WebBrowserDocumentCompletedEventArgs e)
        {         
            fMain.picProgress.Image = null;
            //if(e.Url.
            //wbEMR.ScriptErrorsSuppressed = true; 
            //MessageBox.Show(e.Url.ToString());         
        }

        private void wbEMR_Navigating(object sender, WebBrowserNavigatingEventArgs e)
        {
            fMain.picProgress.Image = Properties.Resources.progressWheel5;
        }

        private void navigateIQCare()
        {
            if (clsGbl.EMRPatientPK != patientPK)
            {
                //string url = "http://192.168.1.12/iqcare/frmlogin.aspx";
                string url = GetIQCareURL();
                wbEMR.Navigate(url);
                fMain.lblNotify.Text = url;
                fMain.picProgress.Image = Properties.Resources.progress2;
            }
            patientPK = clsGbl.EMRPatientPK;
        }

        private void ucEMRAccess_Enter(object sender, EventArgs e)
        {
            if (emrType == "iqcare")
            {
                navigateIQCare();
            }
            else if (emrType == "isante")
            {
                navigateISante();
            }
            else
                MessageBox.Show("Not Implemented", Assets.Messages.InfoHeader);
        }

        private void navigateISante()
        {
            wbEMR.ScriptErrorsSuppressed = false;
            string url = "https://192.168.1.16/isante";
            wbEMR.Navigate(url);
            fMain.lblNotify.Text = url;
            fMain.picProgress.Image = Properties.Resources.progress2;
            //wbEMR.ScriptErrorsSuppressed = true;
        }
    }
}
