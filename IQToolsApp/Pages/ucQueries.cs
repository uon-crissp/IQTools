using System;
using System.Data;
using System.Windows.Forms;
using DataLayer;
using BusinessLayer;
using System.Data.SqlClient;
using System.Threading;
using System.Reflection;
using ActiveDatabaseSoftware.ActiveQueryBuilder;
//using MySql.Data.MySqlClient;
using System.Collections;
using MySql.Data.MySqlClient;


namespace IQTools.Pages
{
    public partial class ucQueries : UserControl
    {
        frmMain fMain;
        string server = "mysql";
        string iqtoolsConnString = Entity.getconnString(clsGbl.xmlPath);
        SelectedQuery sq = new SelectedQuery();
        QueryBuilder qb = new QueryBuilder();
        DataSet categories = new DataSet();
        DataTable subCategories = new DataTable();


        public ucQueries(frmMain frm)
        {
            InitializeComponent();
            fMain = frm;
            cboQueryGroup.SelectedIndex = 0;
            if (Entity.getDevelopmentRight(BusinessLayer.clsGbl.xmlPath) == "0") cboQueryGroup.Visible = false; else cboQueryGroup.Visible = true;
            chkFilterReports.CheckedChanged += new EventHandler(Filters_Changed);
            chkFilterAggregates.CheckedChanged += new EventHandler(Filters_Changed);
            chkFilterLineLists.CheckedChanged += new EventHandler(Filters_Changed);
            chkFilterSystem.CheckedChanged += new EventHandler(Filters_Changed);
            chkFilterUserQueries.CheckedChanged += new EventHandler(Filters_Changed);
            txtSearchQuery.TextChanged += new EventHandler(Filters_Changed);
        }

        private void previewData(string sql)
        {
            getQueryParameters();
            Entity en = new Entity();
            try
            {
                SetControlPropertyThreadSafe(fMain.picProgress, "Image", Properties.Resources.progressWheel5);
                SetControlPropertyThreadSafe(fMain.lblNotify, "Text", "Running Query....");
                DataTable dt = (DataTable)en.ReturnObject(iqtoolsConnString, ClsUtility.theParams
                    , sql, ClsUtility.ObjectEnum.DataTable, server);

                SetControlPropertyThreadSafe(dgvPreview, "DataSource", dt);
                setEMRLinkColumn(dgvPreview, clsGbl.PMMS.ToLower());
                analyzeResults();
            }
            catch (Exception ex) { MessageBox.Show(ex.Message); }
            finally
            {
                SetControlPropertyThreadSafe(fMain.picProgress, "Image", null);
                SetControlPropertyThreadSafe(fMain.lblNotify, "Text", dgvPreview.Rows.Count.ToString() + " Records");
            }
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

        private void sqlTextEditor1_Leave(object sender, EventArgs e)
        {
            try
            {
                queryBuilder1.SQL = sqlTextEditor1.Text;
                qb.SQL = sqlTextEditor1.Text;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Parsing error");
            }

        }

        private void plainTextSQLBuilder1_SQLUpdated(object sender, EventArgs e)
        {
            sqlTextEditor1.Text = plainTextSQLBuilder1.SQL;
        }

        private void QueryBuilder_SetupProperties(string serverType)
        {
            queryBuilder1.ExpressionEditor = expressionEditor1;
            sqlTextEditor1.QueryBuilder = queryBuilder1;

            if (serverType.ToLower() == "mssql")
            {
                SqlConnection mssqlConn = (SqlConnection)Entity.GetConnection(iqtoolsConnString, "mssql");
                MSSQLSyntaxProvider syntaxProvider = new MSSQLSyntaxProvider();
                MSSQLMetadataProvider metadataProvider = new MSSQLMetadataProvider();

                metadataProvider.Connection = mssqlConn;
                queryBuilder1.SyntaxProvider = syntaxProvider;
                queryBuilder1.MetadataProvider = metadataProvider;
                qb.SyntaxProvider = syntaxProvider;
                qb.MetadataProvider = metadataProvider;
            }
            else if (serverType.ToLower() == "mysql")
            {
                string connstring = string.Format("Server={0}; database={1}; UID={2}; password={3}", "localhost", "migration_tr", "root", "test");
                MySqlConnection mysqlConn = new MySqlConnection(connstring);
                MySQLSyntaxProvider mysqlSyntaxProvider = new MySQLSyntaxProvider();
                MySQLMetadataProvider mysqlMetadataProvider = new MySQLMetadataProvider();

                mysqlMetadataProvider.Connection = mysqlConn;
                queryBuilder1.SyntaxProvider = mysqlSyntaxProvider;
                queryBuilder1.MetadataProvider = mysqlMetadataProvider;
                qb.SyntaxProvider = mysqlSyntaxProvider;
            }
            else if (serverType.ToLower() == "pgsql")
            {
                //NpgsqlConnection pgsqlConn = (NpgsqlConnection)Entity.GetConnection(iqtoolsConnString, "pgsql");
                //PostgreSQLSyntaxProvider pgsqlSyntaxProvider = new PostgreSQLSyntaxProvider();
                ////UniversalSyntaxProvider uSyntaxProvider = new UniversalSyntaxProvider();
                //UniversalMetadataProvider umdprovider = new UniversalMetadataProvider();

                //umdprovider.Connection = pgsqlConn;
                //queryBuilder1.SyntaxProvider = pgsqlSyntaxProvider;
                ////queryBuilder1.SyntaxProvider = uSyntaxProvider;
                //queryBuilder1.MetadataProvider = umdprovider;
                //qb.SyntaxProvider = pgsqlSyntaxProvider;
                ////qb.SyntaxProvider = uSyntaxProvider;

            }


            if (rdbAdvanced.Checked)
            {
                queryBuilder1.RefreshMetadata();
            }
            else if (rdbBasic.Checked)
            {
                if (server == "pgsql")
                { queryBuilder1.MetadataContainer.LoadFromXMLFile("Resources\\iqtools_cpad.xml"); }
                else
                {
                    queryBuilder1.MetadataContainer.LoadFromXMLFile("Resources\\iqtools_iqcare.xml");
                }

            }

        }

        private void QueryBuilder_Init(object sender, EventArgs e)
        {
            this.QueryBuilder_SetupProperties(server);
        }

        private void tcQueryManager_Selected(object sender, TabControlEventArgs e)
        {
            if (e.TabPage == tpQueryPreview)
            {
                if (sqlTextEditor1.Text == String.Empty)
                {
                    sq.qryName = String.Empty;
                }

                if (sq.qryName == String.Empty)
                {
                    cboQueryCategory.DataSource = new BindingSource(categories.Tables[0], null);
                    cboQueryCategory.DisplayMember = "Category";
                    cboQueryCategory_SelectedIndexChanged(sender, e);
                }
                ////AQB Bug? sqlTextEditor1_Leave Not fired if Designer Used
                queryBuilder1.SQL = sqlTextEditor1.Text;
                qb.SQL = sqlTextEditor1.Text;
                ////
                if (qb.SQL != String.Empty)
                {
                    string sql = qb.SQL;
                    dgvPreview.DataSource = null;
                    dgvQueryAnalytics.Rows.Clear();

                    Thread previewDataThread = new Thread(() => previewData(sql));
                    previewDataThread.SetApartmentState(ApartmentState.STA);
                    previewDataThread.Start();
                }
                else
                {

                }

            }
            else if (e.TabPage == tpQueryManage)
            {
                //if (txtSearchQuery.Text == String.Empty)
                //{
                loadQueries();
                Filters_Changed(sender, e);
                //}
            }
            else if (e.TabPage == tpQueryDesign)
            { }
        }

        private void populateCategories()
        {
            Entity en = new Entity();
            string sp = "pr_GetQueryCategories_IQTools";
            ClsUtility.Init_Hashtable();
            try
            {
                categories = (DataSet)en.ReturnObject(iqtoolsConnString, ClsUtility.theParams, sp, ClsUtility.ObjectEnum.DataSet, server);
            }
            catch (Exception ex) { MessageBox.Show(ex.Message); }
        }

        private void dgvPreview_DataError(object sender, DataGridViewDataErrorEventArgs e)
        {
            if ((e.Exception) is ConstraintException)
            {
                DataGridView view = (DataGridView)sender;
                view.Rows[e.RowIndex].ErrorText = "Error";
                view.Rows[e.RowIndex].Cells[e.ColumnIndex].ErrorText = "Error";
                e.ThrowException = false;
            }
        }

        private void rdbAdvanced_CheckedChanged(object sender, EventArgs e)
        {
            this.QueryBuilder_SetupProperties(server);
        }

        private void getQueryParameters()
        {
            if (server == "mssql")
            {
                SqlCommand cmd = new SqlCommand(queryBuilder1.SQL);
                if (qb.Parameters.Count > 0)
                {
                    Hashtable myParameters = new Hashtable(); int j = 0; myParameters.Clear();
                    for (int i = 0; i < qb.Parameters.Count; i++)
                    {
                        j = 0;
                        SqlParameter p = new SqlParameter();
                        p.ParameterName = qb.Parameters[i].FullName;
                        p.DbType = qb.Parameters[i].DataType;
                        foreach (DictionaryEntry de in myParameters)
                        {
                            if (de.Key.ToString().Trim().ToLower() == qb.Parameters[i].FullName.Trim().ToLower())
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
                    //using (frmQryParameters qpf = new frmQryParameters ( qb.Parameters, cmd ))
                    //{
                    //  qpf.StartPosition = FormStartPosition.CenterScreen;
                    //  qpf.ShowDialog ( );
                    //}

                    using (frmQueryParameters qp = new frmQueryParameters(qb.Parameters, cmd))
                    {
                        qp.StartPosition = FormStartPosition.CenterScreen;
                        qp.ShowDialog();
                    }
                }
            }
            else if (server == "mysql")
            {
                MySqlCommand cmd = new MySqlCommand(qb.SQL);

                if (qb.Parameters.Count > 0)
                {
                    Hashtable myParameters = new Hashtable(); int j = 0; myParameters.Clear();
                    for (int i = 0; i < qb.Parameters.Count; i++)
                    {
                        j = 0;
                        SqlParameter p = new SqlParameter();
                        p.ParameterName = qb.Parameters[i].FullName;
                        p.DbType = qb.Parameters[i].DataType;
                        foreach (DictionaryEntry de in myParameters)
                        {
                            if (de.Key.ToString().Trim().ToLower() == qb.Parameters[i].FullName.Trim().ToLower())
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

                    using (frmQryParameters qpf = new frmQryParameters(qb.Parameters, cmd))
                    {
                        qpf.StartPosition = FormStartPosition.CenterScreen;
                        qpf.ShowDialog();
                    }
                }
            }

            else if (server == "pgsql")
            {
                ////MySqlCommand cmd = new MySqlCommand(qb.SQL);
                //NpgsqlCommand cmd = new NpgsqlCommand(qb.SQL);

                //if (qb.Parameters.Count > 0)
                //{
                //    Hashtable myParameters = new Hashtable(); int j = 0; myParameters.Clear();
                //    for (int i = 0; i < qb.Parameters.Count; i++)
                //    {
                //        j = 0;

                //        NpgsqlParameter p = new NpgsqlParameter();
                //        p.ParameterName = qb.Parameters[i].FullName;
                //        p.DbType = qb.Parameters[i].DataType;
                //        foreach (DictionaryEntry de in myParameters)
                //        {
                //            if (de.Key.ToString().Trim().ToLower() == qb.Parameters[i].FullName.Trim().ToLower())
                //            {
                //                j = 1;
                //                break;
                //            }
                //        }
                //        if (j == 0)
                //        {
                //            cmd.Parameters.Add(p);
                //            myParameters.Add(p.ParameterName, p.DbType);
                //        }
                //    }

                //    using (frmQueryParameters qp = new frmQueryParameters(qb.Parameters, cmd))
                //    {
                //        qp.StartPosition = FormStartPosition.CenterScreen;
                //        qp.ShowDialog();
                //    }
                //}
            }

        }

        private void setEMRLinkColumn(DataGridView dgv, string EMR)
        {
            if (EMR == "iqcare" && dgv.Columns.Contains("PatientPK"))
            {
                try
                {
                    DataGridViewLinkColumn dgvlc = new DataGridViewLinkColumn();
                    dgvlc.DataPropertyName = "PatientPK";
                    dgvlc.HeaderText = "IQCare Link";
                    dgvlc.Name = "PtnPk"; //Rename the Column since we need to hide PatientPK 
                    if (dgv.InvokeRequired)
                    {
                        this.Invoke(new MethodInvoker(delegate
                    {
                        dgv.Columns.Add(dgvlc);
                        dgv.Columns["PtnPk"].DisplayIndex = 0;
                        dgv.Columns["PatientPK"].Visible = false;
                    }));
                    }
                    else
                    {
                        dgv.Columns.Add(dgvlc);
                        dgv.Columns["PtnPk"].DisplayIndex = 0;
                        dgv.Columns["PatientPK"].Visible = false;
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, Assets.Messages.ErrorHeader);
                }
            }
        }

        private void dgvPreview_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (this.dgvPreview.Columns[e.ColumnIndex] is DataGridViewLinkColumn)
            {
                string link = this.dgvPreview[e.ColumnIndex, e.RowIndex].Value.ToString();
                if (link != String.Empty)
                {
                    clsGbl.EMRPatientPK = link;
                    fMain.tcMain.SelectedTab = fMain.tpEMRAccess;
                }
            }
        }

        private void loadQueries()
        {
            string sp = "pr_GetQueries_IQTools";
            ClsUtility.Init_Hashtable();
            ClsUtility.AddParameters("@EMR", SqlDbType.VarChar, clsGbl.PMMSType);
            Entity en = new Entity();
            try
            {
                DataTable queryDT = (DataTable)en.ReturnObject(iqtoolsConnString, ClsUtility.theParams, sp
                                        , ClsUtility.ObjectEnum.DataTable, server);
                dgvManageQueries.DataSource = clsGbl.Queries;
                dgvManageQueries.Columns["qryID"].Visible = false;
                dgvManageQueries.Columns["qryDefinition"].Visible = false;
                dgvManageQueries.Columns["QueryDescription"].Width = 300;
                dgvManageQueries.Columns["Report"].Visible = false;
                dgvManageQueries.Columns["LineList"].Visible = false;
                dgvManageQueries.Columns["Aggregate"].Visible = false;
                dgvManageQueries.Columns["System"].Visible = false;
                dgvManageQueries.Columns["MyQueries"].Visible = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void Filters_Changed(object sender, EventArgs e)
        {

            string filter = String.Format("([QueryName] LIKE '%{0}%' OR [QueryDescription] LIKE '%{0}%' " +
                                       "OR [SubCategory] LIKE '%{0}%' OR [Category] LIKE '%{0}%')", txtSearchQuery.Text);
            filter += " AND (1=0 ";

            if (chkFilterLineLists.Checked)
                filter += " OR [LineList] = 1";
            if (chkFilterReports.Checked)
                filter += " OR [Report] = 1";
            if (chkFilterSystem.Checked)
                filter += " OR [System] = 1";
            if (chkFilterAggregates.Checked)
                filter += " OR [Aggregate] = 1";
            if (chkFilterUserQueries.Checked)
                filter += " OR [MyQueries] = 1";

            filter += ")";
            (dgvManageQueries.DataSource as DataTable).DefaultView.RowFilter = filter;
        }

        private void dgvManageQueries_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            gpbDesign.Text = dgvManageQueries.CurrentRow.Cells["QueryName"].Value.ToString();
            lblQueryDescription.Text = dgvManageQueries.CurrentRow.Cells["QueryDescription"].Value.ToString();
            sq.qryID = Convert.ToInt32(dgvManageQueries.CurrentRow.Cells["qryID"].Value.ToString());
            sq.qrySQL = dgvManageQueries.CurrentRow.Cells["qryDefinition"].Value.ToString();
            sq.qryName = dgvManageQueries.CurrentRow.Cells["QueryName"].Value.ToString();
            sq.qryDescription = dgvManageQueries.CurrentRow.Cells["QueryDescription"].Value.ToString();
            sq.qryCategory = dgvManageQueries.CurrentRow.Cells["Category"].Value.ToString();
            sq.qrySubCategory = dgvManageQueries.CurrentRow.Cells["SubCategory"].Value.ToString();
        }

        private void btnPreviewQuery_Click(object sender, EventArgs e)
        {
            sqlTextEditor1.Text = sq.qrySQL;
            qb.SQL = sq.qrySQL;
            txtQueryName.Text = sq.qryName;
            txtQueryDescription.Text = sq.qryDescription;
            cboQueryCategory.Text = sq.qryCategory;
            cboQuerySubCategory.Text = sq.qrySubCategory;
            dgvPreview.DataSource = null;
            tcQueryManager.SelectedTab = tpQueryPreview;
        }

        private void btnDesignQuery_Click(object sender, EventArgs e)
        {
            txtQueryName.Text = sq.qryName;
            txtQueryDescription.Text = sq.qryDescription;
            cboQueryCategory.Text = sq.qryCategory;
            cboQuerySubCategory.Text = sq.qrySubCategory;

            sqlTextEditor1.Text = sq.qrySQL;
            tcQueryManager.SelectedTab = tpQueryDesign;
            sqlTextEditor1_Leave(sender, e);
        }

        private void analyzeResults()
        {

            try
            {
                DataTable results = (DataTable)dgvPreview.DataSource;
                decimal availability = 0;
                int rowCount = results.Rows.Count;
                string availabilityPercent = "";

                for (int i = 0; i < results.Columns.Count; i++)
                {
                    if (dgvQueryAnalytics.InvokeRequired)
                    {
                        this.Invoke(new MethodInvoker(delegate
                    {
                        for (int j = 0; j < results.Rows.Count; j++)
                        {
                            if (dgvPreview[i, j].Value.ToString() != String.Empty)
                            { availability += 1; }
                        }
                        if (rowCount > 0)
                        {
                            availabilityPercent = Convert.ToInt32(100 * (availability / rowCount)) + "%";
                        }
                        else availabilityPercent = "-";
                        dgvQueryAnalytics.Rows.Add(results.Columns[i].ColumnName, availabilityPercent);
                        availability = 0;
                    }));
                    }
                    else
                    { dgvQueryAnalytics.Rows.Add(results.Columns[i].ColumnName); }
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            string validate = validateSave(txtQueryName.Text, txtQueryDescription.Text);
            if (validate == "new")
            {
                MessageBox.Show("A New Query '" + txtQueryName.Text + "' Will Be Created", "Save Query", MessageBoxButtons.OKCancel, MessageBoxIcon.Question);
                saveQuery(txtQueryName.Text.Trim(), txtQueryDescription.Text.Trim(), cboQueryCategory.Text.Trim(), cboQuerySubCategory.Text.Trim(), queryBuilder1.SQL, cboQueryGroup.Text.Trim()
                  );

            }
            else if (validate == "exists")
            {
                if (MessageBox.Show("'" + txtQueryName.Text + "' Exists. Do You Wish To Overwrite It?", "Save Query", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    saveQuery(txtQueryName.Text.Trim(), txtQueryDescription.Text.Trim(), cboQueryCategory.Text.Trim(), cboQuerySubCategory.Text.Trim(), queryBuilder1.SQL, cboQueryGroup.Text.Trim());
                }
                else
                {
                    txtQueryName.Focus();
                    txtQueryName.SelectAll();
                }
            }
            else if (validate == "missing")
            {
                MessageBox.Show("Please Enter A Valid Name And Description For Your Query", "Save Query", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            else
                MessageBox.Show(validate, "Save Query", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        private string validateSave(string qryName, string qryDescription)
        {
            if (qryName.Trim() != String.Empty && qryDescription.Trim() != String.Empty)
            {
                try
                {
                    Entity en = new Entity();
                    ClsUtility.Init_Hashtable();
                    string sp = "pr_CheckQuery_IQTools";
                    ClsUtility.AddParameters("@qryName", SqlDbType.VarChar, qryName);
                    DataTable dt = (DataTable)en.ReturnObject(iqtoolsConnString, ClsUtility.theParams
                        , sp, ClsUtility.ObjectEnum.DataTable, server);

                    if (dt.Rows.Count == 0)
                        return "new";
                    else
                        return "exists";
                }
                catch (Exception ex) { return ex.Message; }
            }
            else
                return "missing";
        }

        private void saveQuery(string qryName, string qryDescription, string qryCategory, string qrySubCategory, string qrySQL, string qryGroup)
        {
            string sp = "pr_SaveQuery_IQTools";
            ClsUtility.Init_Hashtable();
            ClsUtility.AddParameters("@qryName", SqlDbType.VarChar, qryName);
            ClsUtility.AddParameters("@qryDescription", SqlDbType.VarChar, qryDescription);
            ClsUtility.AddParameters("@qryCategory", SqlDbType.VarChar, qryCategory);
            ClsUtility.AddParameters("@qrySubCategory", SqlDbType.VarChar, qrySubCategory);
            ClsUtility.AddParameters("@qrySQL", SqlDbType.VarChar, qrySQL);
            ClsUtility.AddParameters("@qryGroup", SqlDbType.VarChar, qryGroup);
            ClsUtility.AddParameters("@devFlag", SqlDbType.Int, Convert.ToInt32(Entity.getDevelopmentRight(clsGbl.xmlPath)));

            Entity en = new Entity();
            int i = 0;
            try
            {
                i = (int)en.ReturnObject(iqtoolsConnString, ClsUtility.theParams, sp
                            , ClsUtility.ObjectEnum.ExecuteNonQuery, server);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {
                if (i != 0)
                    MessageBox.Show(qryName + " Was Saved Successfully", "Save Query", MessageBoxButtons.OK);
                else
                {
                    if (MessageBox.Show("Oops, " + qryName + " Was Not Saved. Please Try Again.", "Saving Query", MessageBoxButtons.RetryCancel, MessageBoxIcon.Warning) == DialogResult.Retry)
                        saveQuery(qryName, qryDescription, qryCategory, qrySubCategory, qrySQL, qryGroup);
                }
                refreshQueries();
            }

        }

        private class SelectedQuery
        {
            public int qryID;
            public string qryName = String.Empty;
            public string qryDescription;
            public string qryCategory;
            public string qrySubCategory;
            public string qrySQL;
        }

        private void cboQueryCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            //cboQuerySubCategory.DataSource = new BindingSource(categories.Tables[1], null);
            subCategories = categories.Tables[1];
            subCategories.DefaultView.RowFilter = String.Format("Category = '{0}'", cboQueryCategory.Text);
            cboQuerySubCategory.DataSource = new BindingSource(subCategories, null);
            cboQuerySubCategory.DisplayMember = "sbCategory";
        }

        private void ucQueries_Load(object sender, EventArgs e)
        {
            populateCategories();
        }

        private void refreshQueries()
        {
            clsGbl.Queries.Clear();
            string sp = "pr_GetQueries_IQTools";
            ClsUtility.Init_Hashtable();
            ClsUtility.AddParameters("@EMR", SqlDbType.VarChar, clsGbl.PMMS);
            Entity en = new Entity();
            try
            {
                clsGbl.Queries = (DataTable)en.ReturnObject(iqtoolsConnString, ClsUtility.theParams, sp
                                        , ClsUtility.ObjectEnum.DataTable, server);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void lnkExportToExcel_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            //dgvQueryAnalytics does not have a DataSource. Create Datatable from contents
            DataTable stats = new DataTable();
            if (dgvQueryAnalytics.Rows.Count > 0)
            {
                foreach (DataGridViewColumn col in dgvQueryAnalytics.Columns)
                {
                    stats.Columns.Add(col.HeaderText);
                }
                foreach (DataGridViewRow row in dgvQueryAnalytics.Rows)
                {
                    DataRow dRow = stats.NewRow();
                    foreach (DataGridViewCell cell in row.Cells)
                    {
                        dRow[cell.ColumnIndex] = cell.Value;
                    }
                    stats.Rows.Add(dRow);
                }
            }
            if (dgvPreview.Rows.Count > 0)
            {
                try
                {
                    Thread exportDataThread = new Thread(() => exportDataToExcel((DataTable)dgvPreview.DataSource, stats));
                    exportDataThread.SetApartmentState(ApartmentState.STA);
                    exportDataThread.Start();
                }
                catch
                { }
            }
        }

        private void exportDataToExcel(DataTable dT, DataTable stats)
        {
            string exportPath = @"IQTools Reports";
            ExcelReports ER = new ExcelReports();
            try
            {
                SetControlPropertyThreadSafe(fMain.picProgress, "Image", Properties.Resources.progressWheel5);
                SetControlPropertyThreadSafe(fMain.lblNotify, "Text", "Exporting Results To Excel....");
                ER.ExportToExcel(dT, stats, exportPath);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {

                SetControlPropertyThreadSafe(fMain.picProgress, "Image", null);
                SetControlPropertyThreadSafe(fMain.lblNotify, "Text", "Successfully Exported");
            }
        }
    }
}
