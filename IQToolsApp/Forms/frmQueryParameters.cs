using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Data.Common;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Collections;
using ActiveDatabaseSoftware.ActiveQueryBuilder;
using DataLayer;

namespace IQTools
{
    public partial class frmQueryParameters : Form
    {
        private ParameterList parameters;
        private DbCommand command;

        public frmQueryParameters(ParameterList pl, DbCommand cmd)
        {
            parameters = pl;
            command = cmd;

            InitializeComponent();
            int j = 0;
            Hashtable myParameters = new Hashtable();
            for (int i = 0; i < parameters.Count; i++)
            {
                Parameter p = parameters[i];
                j = 0;
                foreach (DictionaryEntry de in myParameters)
                {
                    if (de.Key.ToString().Trim().ToLower() == p.FullName.Trim().ToLower())
                    {
                        j = 1;
                        break;
                    }
                }
                if (j == 0)
                {
                    int row = dgvQryParams.Rows.Add();
                    dgvQryParams.Rows[row].Cells[0].Value = p.FullName;
                    dgvQryParams.Rows[row].Cells[1].Value = p.DataType.ToString();
                    myParameters.Add(p.FullName, p.DataType.ToString());
                }

            }
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            ClsUtility.Init_Hashtable();
            string ParamValue = "";
            string ParamName = "";
            try
            {
                for (int i = 0; i < dgvQryParams.Rows.Count; i++)
                {
                    ParamName = dgvQryParams.Rows[i].Cells[0].Value.ToString();
                    ParamValue = dgvQryParams.Rows[i].Cells[2].Value.ToString();
                    ClsUtility.AddParameters(ParamName, SqlDbType.Text, ParamValue);
                    this.Close();
                }
            }
            catch (Exception ex)
            {
                if (ex.GetType().ToString() == "System.NullReferenceException")
                {
                    if (MessageBox.Show("One Or More Parameters Was Not Provided", "Query Parameters"
                        , MessageBoxButtons.AbortRetryIgnore, MessageBoxIcon.Error) != DialogResult.Retry)
                        this.Close();
                }
                else
                    MessageBox.Show(ex.Message);
            }
        }
    }
}
