using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Data.Common;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using ActiveDatabaseSoftware.ActiveQueryBuilder;
using DataLayer;

namespace IQTools
{
	public partial class frmQryParameters : Form
	{
		private ParameterList parameters;
		private DbCommand command;

        public frmQryParameters(ParameterList pl, DbCommand cmd)
        {
            parameters = pl;
            command = cmd;

            InitializeComponent();
            int j = 0;
            Hashtable myParameters = new Hashtable(); myParameters.Clear();
            for (int i = 0; i < parameters.Count; i++)
            {
                Parameter p = parameters[i];
                string s = "";

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
                    if (p.ComparedObject != "")
                    {                        
                        s += p.ComparedObject + ".";                    
                    }

                    if (p.ComparedField != "")
                    {                        
                        s += p.ComparedField + " ";                    
                    }

                    s += p.CompareOperator;

                    int row = grid.Rows.Add();
                    grid.Rows[row].Cells[0].Value = p.FullName;

                    grid.Rows[row].Cells[1].Value = s;
                    grid.Rows[row].Cells[2].Value = p.DataType.ToString();

                    myParameters.Add(p.FullName, p.DataType.ToString());
                    
                }
            }
        }

        private void buttonOk_Click(object sender, EventArgs e)
        {            
            try
            {
                for (int i = 0; i < grid.Rows.Count; i++)
                {
                    command.Parameters[i].Value = grid.Rows[i].Cells[3].Value;
                    ClsUtility.AddParameters(command.Parameters[i].ParameterName, SqlDbType.Text, command.Parameters[i].Value.ToString());
                    this.Close();
                }
            }
            catch (Exception ex) 
            { 
                if (ex.GetType().ToString() == "System.NullReferenceException")
                {
                    if (MessageBox.Show("One Or More Parameters Was Not Provided", "Query Parameters", MessageBoxButtons.AbortRetryIgnore, MessageBoxIcon.Error) != DialogResult.Retry)
                        this.Close();
                }
                else
                    MessageBox.Show(ex.Message);                 
            }
        }
       
	}
}