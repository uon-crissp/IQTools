using System;
using System.Collections.Generic;
using System.Data;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace IQTools
{
    public partial class frmBulkPatientSummaries : Form
    {
        string sConn = "";

        public frmBulkPatientSummaries(string sConnectionString)
        {
            InitializeComponent();
            sConn = sConnectionString;
        }

        private void cmdGo_Click(object sender, EventArgs e)
        {
            dgvPatients.DataSource = null;
            dgvPatients.Columns.Clear();

            LoadpatientsInGrid();

            cmdImport.Enabled = false;
        }

        public void LoadpatientsInGrid()
        {
            DateTime startDate = Convert.ToDateTime(dtpVisitDate.Text);


            //Load patients form DB, based on visitdate
            string SQLQuery = "SELECT PatientID, PatientName, Gender, AgeCurrent, MAX(b.VisitDate) LastVisit" +
                                " FROM dbo.tmp_PatientMaster a" +
                                " INNER JOIN dbo.tmp_ClinicalEncounters b ON a.PatientPK = b.PatientPK" +
                                " WHERE b.VisitDate = CAST('" + startDate + "' AS DATETIME)" +
                                " GROUP BY PatientID, PatientName, Gender, AgeCurrent ORDER BY MAX(b.VisitDate) ";

            SqlConnection con = new SqlConnection(sConn);

            con.Open();

            SqlCommand command = new SqlCommand(SQLQuery, con);
            command.CommandType = CommandType.Text;

            DataTable dt = new DataTable();
            SqlDataAdapter adapter = new SqlDataAdapter();
            adapter.SelectCommand = command;
            adapter.Fill(dt);

            dgvPatients.DataSource = dt;

            con.Close();


            //Add Checkbox column
            if (dgvPatients.Columns[0].HeaderText != "Select")
            {
                DataGridViewCheckBoxColumn selectPatient = new DataGridViewCheckBoxColumn();
                selectPatient.HeaderText = "Select";
                selectPatient.FalseValue = "0";
                selectPatient.TrueValue = "1";
                dgvPatients.Columns.Insert(0, selectPatient);
            }

            dgvPatients.Columns[1].Width = 200;
            dgvPatients.Columns[2].Width = 200;

            chkSelectAll.Text = "Select all [" + Convert.ToString(dgvPatients.RowCount) + " records]";
        }

        private void cmdImport_Click(object sender, EventArgs e)
        {
            OpenFileDialog browseFile = new OpenFileDialog();
            browseFile.DereferenceLinks = true;
            browseFile.Filter = "Excel|*.xls|Excel 2010|*.xlsx";

            browseFile.Title = "Browse Excel file";


            //if (browseFile.ShowDialog() == DialogResult.OK)
            //{
            //    dgvPatients.DataSource = null;
            //    dgvPatients.Columns.Clear();

            //    var xl = new FileInfo(browseFile.FileName);
            //    using (var package = new ExcelPackage(x1))
            //    { 
                   
            //    Excel.Workbook workbook = app.Workbooks.Open(browseFile.FileName);
            //    Excel.Worksheet worksheet = (Excel.Worksheet)workbook.ActiveSheet;

            //    int rcount = worksheet.UsedRange.Rows.Count;

            //    int i = 0;

            //    //Initializing Columns
            //    dgvPatients.ColumnCount = worksheet.UsedRange.Columns.Count;

            //    for (int x = 0; x < dgvPatients.ColumnCount; x++)
            //    {
            //        dgvPatients.Columns[x].Name = "Column" + x.ToString();
            //    }

            //    for (; i < rcount; i++)
            //    {
            //        dgvPatients.Rows.Add(((Excel.Range)worksheet.Cells[i + 1, 1]).Value, ((Excel.Range)worksheet.Cells[i + 1, 2]).Value);
            //    }

            //    //Add Checkbox column
            //    if (dgvPatients.Columns[0].HeaderText != "Select")
            //    {
            //        DataGridViewCheckBoxColumn selectPatient = new DataGridViewCheckBoxColumn();
            //        selectPatient.HeaderText = "Select";
            //        selectPatient.FalseValue = "0";
            //        selectPatient.TrueValue = "1";
            //        dgvPatients.Columns.Insert(0, selectPatient);
            //    }

            //    chkSelectAll.Text = "Select all [" + Convert.ToString(dgvPatients.RowCount) + " records]";
            //}
        }

        private void chkSelectAll_CheckedChanged(object sender, EventArgs e)
        {
            if (chkSelectAll.Checked == true)
            {
                foreach (DataGridViewRow row in dgvPatients.Rows)
                {
                    row.Cells[0].Value = true;
                }
            }
            else
            {
                foreach (DataGridViewRow row in dgvPatients.Rows)
                {
                    row.Cells[0].Value = false;
                }
            }
        }

        private void cmdCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void cmdSubmit_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Generate reports for the selected clients?", "Confirm..", MessageBoxButtons.YesNo, MessageBoxIcon.Information) == DialogResult.Yes)
            {
                BusinessLayer.clsGbl.PatientIDs = new List<string>();

                foreach (DataGridViewRow row in dgvPatients.Rows)
                {
                    if (Convert.ToInt16(row.Cells[0].Value) == 1)
                    {
                        BusinessLayer.clsGbl.PatientIDs.Add(row.Cells[1].Value.ToString());
                    }
                }

                this.Close();
            }
        }

        private void frmBulkPatientSummaries_Load(object sender, EventArgs e)
        {

        }
    }
}
