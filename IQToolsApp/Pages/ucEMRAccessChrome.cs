using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
//using Awesomium.Core;
//using Awesomium.Windows.Forms;
//using BusinessLayer;
//using DataLayer;

namespace IQTools.Pages
{
    public partial class ucEMRAccessChrome : UserControl
    {
        //frmMain fMain;
        //string patientPK = "0";
        //public ucEMRAccessChrome(frmMain frm)
        //{
        //    InitializeComponent();
        //    fMain = frm;
        //}

        //private void ucEMRAccessChrome_Load(object sender, EventArgs e)
        //{
            
        //}

        //private string GetIQCareURL()
        //{
        //    string url = string.Empty;
        //    string encryptURL = string.Empty;
        //    string cryptURL = string.Empty;
        //    string page = string.Empty;
        //    if (Convert.ToDouble(clsGbl.EmrVersion) < Convert.ToDouble(3.6))
        //    {
        //        page = "frmConnect.aspx";
        //    }
        //    else page = "frmConnect36.aspx";
        //    try
        //    {
        //        string IQCareUserName = clsGbl.loggedInUser.UserName;
        //        string UserID = clsGbl.loggedInUser.UserID.ToString();
        //        string IQCarePassword = ClsUtility.Decrypt(clsGbl.loggedInUser.Password);
        //        string TechnicalArea = "1"; //Not used
        //        string server = clsGbl.EMRIPAddress;
        //        string protocol = "http";
        //        string port = "80";
        //        string FacilityID = clsGbl.loggedInUser.FacilityID.ToString();

        //        cryptURL = String.Format("Ptn_Pk={0}&UserName={1}&Password={2}&technicalArea={3}&UserID={4}&FacilityID={5}"
        //            , clsGbl.EMRPatientPK, IQCareUserName, IQCarePassword, TechnicalArea, UserID, FacilityID);
        //        encryptURL = ClsUtility.Encrypt(cryptURL);

        //        //Format the URL
        //        //url = protocol + "://" + server + ":" + port + "/iqcare/frmConnect.aspx?enc=" + encryptURL;
        //        url = String.Format("{0}://{1}:{2}/iqcare/{3}?enc={4}"
        //            , protocol, server, port, page, encryptURL);
        //        return url;
        //    }
        //    catch (Exception ex)
        //    {
        //        if (ex.Message.ToLower() == "there is no row at position 0.")
        //        {
        //            //MessageBox.Show ( "Connection to IQCare Has Not Been Configured. Please Enter Your Connection Details Under The Administration Page", "IQTools", MessageBoxButtons.OK, MessageBoxIcon.Question );
        //        }
        //        else
        //        {
        //            MessageBox.Show(ex.Message);
        //        }
        //        return null;
        //    }
        //}

        //private void navigateIQCare()
        //{
        //    if (clsGbl.EMRPatientPK != patientPK)
        //    {
        //        //string url = "http://192.168.1.12/iqcare/frmlogin.aspx";
        //        string url = GetIQCareURL();
        //        //wbEMR.Navigate(url);
        //        chromeWC.Source = new Uri(url);
        //        fMain.lblNotify.Text = url;
        //        fMain.picProgress.Image = Properties.Resources.progressWheel5;
        //    }
        //    patientPK = clsGbl.EMRPatientPK;
        //}

        //private void ucEMRAccessChrome_Enter(object sender, EventArgs e)
        //{
        //    if (emrType == "iqcare")
        //    {
        //        navigateIQCare();
        //    }
        //    else if (emrType == "isante")
        //    {
        //        navigateISante();
        //    }
        //    else
        //        MessageBox.Show("Not Implemented", Assets.Messages.InfoHeader);
        //}

        //private void navigateISante()
        //{
        //    //wbEMR.ScriptErrorsSuppressed = false;
        //    string url = "https://192.168.1.16/isante";
        //    chromeWC.Source = new Uri(url);
        //    //wbEMR.Navigate(url);
        //    fMain.lblNotify.Text = url;
        //    fMain.picProgress.Image = Properties.Resources.progress2;
        //    //wbEMR.ScriptErrorsSuppressed = true;
        //}

        //private void Awesomium_Windows_Forms_WebControl_DocumentReady(object sender, DocumentReadyEventArgs e)
        //{
        //    if (chromeWC.Source.ToString() != "about:blank")
        //    {
        //        fMain.lblNotify.Text = chromeWC.Source.ToString();
        //    }
        //    fMain.picProgress.Image = null;
        //}

        //private void Awesomium_Windows_Forms_WebControl_AddressChanged(object sender, UrlEventArgs e)
        //{
        //    fMain.picProgress.Image = Properties.Resources.progressWheel5;
        //}
    }
}
