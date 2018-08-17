using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using DataLayer;

namespace IQTools
{
    public partial class frmDHISPassword : Form
    {
        public String UName = "";
        public String PWord = "";
        public String MFLCode = "";
        public String DHIS2URL = "";
        Entity theObject = new Entity();
        public frmDHISPassword()
        {
            InitializeComponent();
            DataTable theDt = (DataTable)theObject.ReturnObject(Entity.getconnString(BusinessLayer.clsGbl.xmlPath), ClsUtility.theParams, "SELECT DHISPortal,MFLCode from aa_Database", ClsUtility.ObjectEnum.DataTable, "mssql");
            DataTableReader theDr = theDt.CreateDataReader();
            txtDHIS2Portal.Text = "http://test.hiskenya.org";
            while (theDr.Read())
            {
                txtDHIS2Portal.Text = (theDr["DHISPortal"].ToString());
                txtMFLCode.Text = (theDr["MFLCode"].ToString());
            }
        }

        private void btnConnect_Click(object sender, EventArgs e)
        {
            if (txtPassword.Text.Trim() == "" || txtUserName.Text.Trim() == "" || txtMFLCode.Text.Trim() == "" || txtDHIS2Portal.Text.Trim() == "")
            {
                MessageBox.Show("Some information is missing, please insert and try again.", "DHIS 2 Login", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            //TODO VY. pick username and password and connect to DHIS2
            UName = txtUserName.Text.Trim();
            PWord = txtPassword.Text.Trim();
            MFLCode = txtMFLCode.Text.Trim();
            DHIS2URL = txtDHIS2Portal.Text.Trim();

            int i = (int)theObject.ReturnObject(Entity.getconnString(BusinessLayer.clsGbl.xmlPath), ClsUtility.theParams, "UPDATE aa_Database SET DHISPortal='" + txtDHIS2Portal.Text.Trim() + "',MFLCode='" + txtMFLCode.Text.Trim() + "'", ClsUtility.ObjectEnum.ExecuteNonQuery, "mssql");



            //TODO VY test if suppied credentials will authenticate succcessfullly
            DialogResult = DialogResult.OK;
            this.Close();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.Cancel;
            this.Close();
           
        }

        private void frmDHISPassword_Load(object sender, EventArgs e)
        {

        }
    }
}
