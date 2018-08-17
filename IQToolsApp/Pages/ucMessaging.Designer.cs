namespace IQTools.Pages
{
    partial class ucMessaging
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ucMessaging));
            this.tcMessaging = new System.Windows.Forms.TabControl();
            this.tpSendSMS = new System.Windows.Forms.TabPage();
            this.tlpSendSMS = new System.Windows.Forms.TableLayoutPanel();
            this.spcSendSMS = new System.Windows.Forms.SplitContainer();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.gbRecipients = new System.Windows.Forms.GroupBox();
            this.txtNoOfRecords = new System.Windows.Forms.Label();
            this.cmdImportFromXL = new System.Windows.Forms.Button();
            this.cboCategory = new System.Windows.Forms.ComboBox();
            this.lblOR = new System.Windows.Forms.Label();
            this.cboSubCategory = new System.Windows.Forms.ComboBox();
            this.lblCategory = new System.Windows.Forms.Label();
            this.lblSubCategory = new System.Windows.Forms.Label();
            this.dgvRecipients = new System.Windows.Forms.DataGridView();
            this.gbLogs = new System.Windows.Forms.GroupBox();
            this.txtLogs = new System.Windows.Forms.TextBox();
            this.gbMessage = new System.Windows.Forms.GroupBox();
            this.tableLayoutPanel3 = new System.Windows.Forms.TableLayoutPanel();
            this.lbLanguages = new System.Windows.Forms.ListBox();
            this.txtMessageToSend = new System.Windows.Forms.TextBox();
            this.gbSendUsing = new System.Windows.Forms.GroupBox();
            this.lblConnectionStatus = new System.Windows.Forms.Label();
            this.lblStatus = new System.Windows.Forms.Label();
            this.cmdLoadModem = new System.Windows.Forms.Button();
            this.cboModemWebService = new System.Windows.Forms.ComboBox();
            this.rbSendUsingWebServ = new System.Windows.Forms.RadioButton();
            this.rbSendUsingModem = new System.Windows.Forms.RadioButton();
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.cmdSend = new System.Windows.Forms.Button();
            this.cmdClearAll = new System.Windows.Forms.Button();
            this.tpSMSLogs = new System.Windows.Forms.TabPage();
            this.tlpSMSLogs = new System.Windows.Forms.TableLayoutPanel();
            this.tlpSMSLogs2 = new System.Windows.Forms.TableLayoutPanel();
            this.dgvSMSLogs = new System.Windows.Forms.DataGridView();
            this.panel5 = new System.Windows.Forms.Panel();
            this.txtSQL = new ActiveDatabaseSoftware.ExpressionEditor.SqlTextEditor();
            this.QBQTool = new ActiveDatabaseSoftware.ActiveQueryBuilder.QueryBuilder();
            this.cmdRetrieve = new System.Windows.Forms.Button();
            this.rbInbox = new System.Windows.Forms.RadioButton();
            this.rbFailedMessages = new System.Windows.Forms.RadioButton();
            this.rbSentMessages = new System.Windows.Forms.RadioButton();
            this.lblSMSLogsEndDate = new System.Windows.Forms.Label();
            this.lblSMSLogsStartDate = new System.Windows.Forms.Label();
            this.dtpSMSLogsEndDate = new System.Windows.Forms.DateTimePicker();
            this.dtpSMSLogsStartDate = new System.Windows.Forms.DateTimePicker();
            this.flowLayoutPanel8 = new System.Windows.Forms.FlowLayoutPanel();
            this.CmdClearLogs = new System.Windows.Forms.Button();
            this.cmdResendFailedMsgs = new System.Windows.Forms.Button();
            this.tpSettings = new System.Windows.Forms.TabPage();
            this.tlpSMSSettings = new System.Windows.Forms.TableLayoutPanel();
            this.tableLayoutPanel7 = new System.Windows.Forms.TableLayoutPanel();
            this.tableLayoutPanel8 = new System.Windows.Forms.TableLayoutPanel();
            this.gbCountryCode = new System.Windows.Forms.GroupBox();
            this.label20 = new System.Windows.Forms.Label();
            this.cboCountryCode = new System.Windows.Forms.ComboBox();
            this.txtCountryCode = new System.Windows.Forms.TextBox();
            this.cmdSaveCountryCode = new System.Windows.Forms.Button();
            this.lblCountryCode = new System.Windows.Forms.Label();
            this.gbMessageSettings = new System.Windows.Forms.GroupBox();
            this.lbSettingsSubCategory = new System.Windows.Forms.ListBox();
            this.cboSettingsCategory = new System.Windows.Forms.ComboBox();
            this.lblMessageCat = new System.Windows.Forms.Label();
            this.tableLayoutPanel9 = new System.Windows.Forms.TableLayoutPanel();
            this.tableLayoutPanel10 = new System.Windows.Forms.TableLayoutPanel();
            this.lblSettingsLanguage = new System.Windows.Forms.Label();
            this.lblSettingsMessage = new System.Windows.Forms.Label();
            this.cboSettingslanguage = new System.Windows.Forms.ComboBox();
            this.txtSettingsMessage = new System.Windows.Forms.TextBox();
            this.flowLayoutPanel2 = new System.Windows.Forms.FlowLayoutPanel();
            this.cmdSettingsSave = new System.Windows.Forms.Button();
            this.cmdSettingsDelete = new System.Windows.Forms.Button();
            this.tableLayoutPanel11 = new System.Windows.Forms.TableLayoutPanel();
            this.lblSMSDescription = new System.Windows.Forms.Label();
            this.tpScheduling = new System.Windows.Forms.TabPage();
            this.tableLayoutPanel15 = new System.Windows.Forms.TableLayoutPanel();
            this.tableLayoutPanel17 = new System.Windows.Forms.TableLayoutPanel();
            this.panel18 = new System.Windows.Forms.Panel();
            this.tableLayoutPanel18 = new System.Windows.Forms.TableLayoutPanel();
            this.lblScheduleSendUsing = new System.Windows.Forms.Label();
            this.rbScheduleDaily = new System.Windows.Forms.RadioButton();
            this.rbScheduleWeekly = new System.Windows.Forms.RadioButton();
            this.rbScheduleMonthly = new System.Windows.Forms.RadioButton();
            this.lblScheduleType = new System.Windows.Forms.Label();
            this.flowLayoutPanel3 = new System.Windows.Forms.FlowLayoutPanel();
            this.rbScheduleModem = new System.Windows.Forms.RadioButton();
            this.rbScheduleWebService = new System.Windows.Forms.RadioButton();
            this.flowLayoutPanel4 = new System.Windows.Forms.FlowLayoutPanel();
            this.numDaysEarlier = new System.Windows.Forms.NumericUpDown();
            this.lblDaysEarlier = new System.Windows.Forms.Label();
            this.dtpDailyTime = new System.Windows.Forms.DateTimePicker();
            this.flowLayoutPanel5 = new System.Windows.Forms.FlowLayoutPanel();
            this.lblWeeklyEvery = new System.Windows.Forms.Label();
            this.cboWeeklyDay = new System.Windows.Forms.ComboBox();
            this.lblWeeklyAt = new System.Windows.Forms.Label();
            this.dtpWeeklyTime = new System.Windows.Forms.DateTimePicker();
            this.flowLayoutPanel6 = new System.Windows.Forms.FlowLayoutPanel();
            this.lblMonthlyOnDay = new System.Windows.Forms.Label();
            this.numMonthlyDay = new System.Windows.Forms.NumericUpDown();
            this.lblMonthlyAt = new System.Windows.Forms.Label();
            this.dtpMonthlyTime = new System.Windows.Forms.DateTimePicker();
            this.cboScheduleModem = new System.Windows.Forms.ComboBox();
            this.cboScheduleSubCategory = new System.Windows.Forms.ComboBox();
            this.lblScheduleSubCategory = new System.Windows.Forms.Label();
            this.lblScheduleCategory = new System.Windows.Forms.Label();
            this.cboScheduleCategory = new System.Windows.Forms.ComboBox();
            this.txtScheduleName = new System.Windows.Forms.TextBox();
            this.lblScheduleName = new System.Windows.Forms.Label();
            this.lblScheduleID = new System.Windows.Forms.Label();
            this.txtScheduleID = new System.Windows.Forms.TextBox();
            this.flowLayoutPanel7 = new System.Windows.Forms.FlowLayoutPanel();
            this.cmdScheduleDelete = new System.Windows.Forms.Button();
            this.cmdScheduleSave = new System.Windows.Forms.Button();
            this.cmdScheduleClear = new System.Windows.Forms.Button();
            this.dgvSchedules = new System.Windows.Forms.DataGridView();
            this.sqlData = new ActiveDatabaseSoftware.ActiveQueryBuilder.MSSQLMetadataProvider(this.components);
            this.sqlSyntax = new ActiveDatabaseSoftware.ActiveQueryBuilder.MSSQLSyntaxProvider(this.components);
            this.ptSQL = new ActiveDatabaseSoftware.ActiveQueryBuilder.PlainTextSQLBuilder(this.components);
            this.eventMetadataProvider1 = new ActiveDatabaseSoftware.ActiveQueryBuilder.EventMetadataProvider(this.components);
            this.spcMain = new System.Windows.Forms.SplitContainer();
            this.piclogo = new System.Windows.Forms.PictureBox();
            this.picMessaging = new System.Windows.Forms.PictureBox();
            this.tcMessaging.SuspendLayout();
            this.tpSendSMS.SuspendLayout();
            this.tlpSendSMS.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.spcSendSMS)).BeginInit();
            this.spcSendSMS.Panel1.SuspendLayout();
            this.spcSendSMS.Panel2.SuspendLayout();
            this.spcSendSMS.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
            this.gbRecipients.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvRecipients)).BeginInit();
            this.gbLogs.SuspendLayout();
            this.gbMessage.SuspendLayout();
            this.tableLayoutPanel3.SuspendLayout();
            this.gbSendUsing.SuspendLayout();
            this.flowLayoutPanel1.SuspendLayout();
            this.tpSMSLogs.SuspendLayout();
            this.tlpSMSLogs.SuspendLayout();
            this.tlpSMSLogs2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvSMSLogs)).BeginInit();
            this.panel5.SuspendLayout();
            this.flowLayoutPanel8.SuspendLayout();
            this.tpSettings.SuspendLayout();
            this.tlpSMSSettings.SuspendLayout();
            this.tableLayoutPanel7.SuspendLayout();
            this.tableLayoutPanel8.SuspendLayout();
            this.gbCountryCode.SuspendLayout();
            this.gbMessageSettings.SuspendLayout();
            this.tableLayoutPanel9.SuspendLayout();
            this.tableLayoutPanel10.SuspendLayout();
            this.flowLayoutPanel2.SuspendLayout();
            this.tableLayoutPanel11.SuspendLayout();
            this.tpScheduling.SuspendLayout();
            this.tableLayoutPanel15.SuspendLayout();
            this.tableLayoutPanel17.SuspendLayout();
            this.panel18.SuspendLayout();
            this.tableLayoutPanel18.SuspendLayout();
            this.flowLayoutPanel3.SuspendLayout();
            this.flowLayoutPanel4.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numDaysEarlier)).BeginInit();
            this.flowLayoutPanel5.SuspendLayout();
            this.flowLayoutPanel6.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numMonthlyDay)).BeginInit();
            this.flowLayoutPanel7.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvSchedules)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.spcMain)).BeginInit();
            this.spcMain.Panel1.SuspendLayout();
            this.spcMain.Panel2.SuspendLayout();
            this.spcMain.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.piclogo)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picMessaging)).BeginInit();
            this.SuspendLayout();
            // 
            // tcMessaging
            // 
            this.tcMessaging.Controls.Add(this.tpSendSMS);
            this.tcMessaging.Controls.Add(this.tpSMSLogs);
            this.tcMessaging.Controls.Add(this.tpSettings);
            this.tcMessaging.Controls.Add(this.tpScheduling);
            this.tcMessaging.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tcMessaging.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tcMessaging.Location = new System.Drawing.Point(0, 0);
            this.tcMessaging.Margin = new System.Windows.Forms.Padding(0);
            this.tcMessaging.Name = "tcMessaging";
            this.tcMessaging.SelectedIndex = 0;
            this.tcMessaging.Size = new System.Drawing.Size(1083, 441);
            this.tcMessaging.TabIndex = 3;
            // 
            // tpSendSMS
            // 
            this.tpSendSMS.Controls.Add(this.tlpSendSMS);
            this.tpSendSMS.Location = new System.Drawing.Point(4, 24);
            this.tpSendSMS.Margin = new System.Windows.Forms.Padding(0);
            this.tpSendSMS.Name = "tpSendSMS";
            this.tpSendSMS.Size = new System.Drawing.Size(1075, 413);
            this.tpSendSMS.TabIndex = 0;
            this.tpSendSMS.Text = "Send SMS";
            this.tpSendSMS.UseVisualStyleBackColor = true;
            // 
            // tlpSendSMS
            // 
            this.tlpSendSMS.ColumnCount = 1;
            this.tlpSendSMS.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tlpSendSMS.Controls.Add(this.spcSendSMS, 0, 0);
            this.tlpSendSMS.Controls.Add(this.flowLayoutPanel1, 0, 1);
            this.tlpSendSMS.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tlpSendSMS.Location = new System.Drawing.Point(0, 0);
            this.tlpSendSMS.Margin = new System.Windows.Forms.Padding(0);
            this.tlpSendSMS.Name = "tlpSendSMS";
            this.tlpSendSMS.RowCount = 2;
            this.tlpSendSMS.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tlpSendSMS.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 50F));
            this.tlpSendSMS.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tlpSendSMS.Size = new System.Drawing.Size(1075, 413);
            this.tlpSendSMS.TabIndex = 0;
            // 
            // spcSendSMS
            // 
            this.spcSendSMS.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spcSendSMS.Location = new System.Drawing.Point(0, 0);
            this.spcSendSMS.Margin = new System.Windows.Forms.Padding(0);
            this.spcSendSMS.Name = "spcSendSMS";
            // 
            // spcSendSMS.Panel1
            // 
            this.spcSendSMS.Panel1.BackColor = System.Drawing.Color.WhiteSmoke;
            this.spcSendSMS.Panel1.Controls.Add(this.tableLayoutPanel2);
            // 
            // spcSendSMS.Panel2
            // 
            this.spcSendSMS.Panel2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.spcSendSMS.Panel2.Controls.Add(this.gbLogs);
            this.spcSendSMS.Panel2.Controls.Add(this.gbMessage);
            this.spcSendSMS.Panel2.Controls.Add(this.gbSendUsing);
            this.spcSendSMS.Size = new System.Drawing.Size(1075, 363);
            this.spcSendSMS.SplitterDistance = 640;
            this.spcSendSMS.SplitterWidth = 1;
            this.spcSendSMS.TabIndex = 0;
            // 
            // tableLayoutPanel2
            // 
            this.tableLayoutPanel2.ColumnCount = 1;
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel2.Controls.Add(this.gbRecipients, 0, 0);
            this.tableLayoutPanel2.Controls.Add(this.dgvRecipients, 0, 1);
            this.tableLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel2.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel2.Margin = new System.Windows.Forms.Padding(0);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 2;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 174F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel2.Size = new System.Drawing.Size(640, 363);
            this.tableLayoutPanel2.TabIndex = 0;
            // 
            // gbRecipients
            // 
            this.gbRecipients.BackColor = System.Drawing.Color.Transparent;
            this.gbRecipients.Controls.Add(this.txtNoOfRecords);
            this.gbRecipients.Controls.Add(this.cmdImportFromXL);
            this.gbRecipients.Controls.Add(this.cboCategory);
            this.gbRecipients.Controls.Add(this.lblOR);
            this.gbRecipients.Controls.Add(this.cboSubCategory);
            this.gbRecipients.Controls.Add(this.lblCategory);
            this.gbRecipients.Controls.Add(this.lblSubCategory);
            this.gbRecipients.Dock = System.Windows.Forms.DockStyle.Fill;
            this.gbRecipients.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.gbRecipients.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.gbRecipients.Location = new System.Drawing.Point(3, 3);
            this.gbRecipients.Name = "gbRecipients";
            this.gbRecipients.Size = new System.Drawing.Size(634, 168);
            this.gbRecipients.TabIndex = 0;
            this.gbRecipients.TabStop = false;
            this.gbRecipients.Text = "RECIPIENTS:";
            // 
            // txtNoOfRecords
            // 
            this.txtNoOfRecords.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.txtNoOfRecords.AutoSize = true;
            this.txtNoOfRecords.Font = new System.Drawing.Font("Verdana", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtNoOfRecords.Location = new System.Drawing.Point(541, 152);
            this.txtNoOfRecords.Name = "txtNoOfRecords";
            this.txtNoOfRecords.Size = new System.Drawing.Size(59, 13);
            this.txtNoOfRecords.TabIndex = 7;
            this.txtNoOfRecords.Text = "Records";
            // 
            // cmdImportFromXL
            // 
            this.cmdImportFromXL.Location = new System.Drawing.Point(146, 125);
            this.cmdImportFromXL.Name = "cmdImportFromXL";
            this.cmdImportFromXL.Size = new System.Drawing.Size(210, 25);
            this.cmdImportFromXL.TabIndex = 6;
            this.cmdImportFromXL.Text = "Import from Excel";
            this.cmdImportFromXL.UseVisualStyleBackColor = true;
            this.cmdImportFromXL.Click += new System.EventHandler(this.cmdImportFromXL_Click);
            // 
            // cboCategory
            // 
            this.cboCategory.FormattingEnabled = true;
            this.cboCategory.Location = new System.Drawing.Point(146, 29);
            this.cboCategory.Name = "cboCategory";
            this.cboCategory.Size = new System.Drawing.Size(353, 21);
            this.cboCategory.TabIndex = 4;
            this.cboCategory.SelectedIndexChanged += new System.EventHandler(this.cboCategory_SelectedIndexChanged);
            // 
            // lblOR
            // 
            this.lblOR.AutoSize = true;
            this.lblOR.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblOR.Location = new System.Drawing.Point(223, 100);
            this.lblOR.Name = "lblOR";
            this.lblOR.Size = new System.Drawing.Size(22, 13);
            this.lblOR.TabIndex = 3;
            this.lblOR.Text = "OR";
            // 
            // cboSubCategory
            // 
            this.cboSubCategory.FormattingEnabled = true;
            this.cboSubCategory.Location = new System.Drawing.Point(146, 61);
            this.cboSubCategory.Name = "cboSubCategory";
            this.cboSubCategory.Size = new System.Drawing.Size(353, 21);
            this.cboSubCategory.TabIndex = 5;
            this.cboSubCategory.SelectedIndexChanged += new System.EventHandler(this.cboSubCategory_SelectedIndexChanged);
            // 
            // lblCategory
            // 
            this.lblCategory.AutoSize = true;
            this.lblCategory.Location = new System.Drawing.Point(29, 32);
            this.lblCategory.Name = "lblCategory";
            this.lblCategory.Size = new System.Drawing.Size(56, 13);
            this.lblCategory.TabIndex = 0;
            this.lblCategory.Text = "Category:";
            // 
            // lblSubCategory
            // 
            this.lblSubCategory.AutoSize = true;
            this.lblSubCategory.Location = new System.Drawing.Point(29, 64);
            this.lblSubCategory.Name = "lblSubCategory";
            this.lblSubCategory.Size = new System.Drawing.Size(79, 13);
            this.lblSubCategory.TabIndex = 1;
            this.lblSubCategory.Text = "Sub Category:";
            // 
            // dgvRecipients
            // 
            this.dgvRecipients.BackgroundColor = System.Drawing.Color.WhiteSmoke;
            this.dgvRecipients.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvRecipients.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvRecipients.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvRecipients.GridColor = System.Drawing.Color.WhiteSmoke;
            this.dgvRecipients.Location = new System.Drawing.Point(3, 177);
            this.dgvRecipients.Name = "dgvRecipients";
            this.dgvRecipients.Size = new System.Drawing.Size(634, 183);
            this.dgvRecipients.TabIndex = 1;
            // 
            // gbLogs
            // 
            this.gbLogs.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.gbLogs.Controls.Add(this.txtLogs);
            this.gbLogs.Location = new System.Drawing.Point(3, 313);
            this.gbLogs.Name = "gbLogs";
            this.gbLogs.Size = new System.Drawing.Size(436, 2);
            this.gbLogs.TabIndex = 2;
            this.gbLogs.TabStop = false;
            this.gbLogs.Text = "LOGS:";
            // 
            // txtLogs
            // 
            this.txtLogs.Dock = System.Windows.Forms.DockStyle.Fill;
            this.txtLogs.Location = new System.Drawing.Point(3, 19);
            this.txtLogs.Multiline = true;
            this.txtLogs.Name = "txtLogs";
            this.txtLogs.ReadOnly = true;
            this.txtLogs.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtLogs.Size = new System.Drawing.Size(430, 0);
            this.txtLogs.TabIndex = 0;
            // 
            // gbMessage
            // 
            this.gbMessage.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.gbMessage.Controls.Add(this.tableLayoutPanel3);
            this.gbMessage.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.gbMessage.Location = new System.Drawing.Point(3, 155);
            this.gbMessage.Name = "gbMessage";
            this.gbMessage.Size = new System.Drawing.Size(436, 137);
            this.gbMessage.TabIndex = 1;
            this.gbMessage.TabStop = false;
            this.gbMessage.Text = "MESSAGE:";
            // 
            // tableLayoutPanel3
            // 
            this.tableLayoutPanel3.ColumnCount = 2;
            this.tableLayoutPanel3.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.74233F));
            this.tableLayoutPanel3.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 66.25767F));
            this.tableLayoutPanel3.Controls.Add(this.lbLanguages, 0, 0);
            this.tableLayoutPanel3.Controls.Add(this.txtMessageToSend, 1, 0);
            this.tableLayoutPanel3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel3.Location = new System.Drawing.Point(3, 19);
            this.tableLayoutPanel3.Margin = new System.Windows.Forms.Padding(0);
            this.tableLayoutPanel3.Name = "tableLayoutPanel3";
            this.tableLayoutPanel3.RowCount = 1;
            this.tableLayoutPanel3.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel3.Size = new System.Drawing.Size(430, 115);
            this.tableLayoutPanel3.TabIndex = 0;
            // 
            // lbLanguages
            // 
            this.lbLanguages.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.lbLanguages.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lbLanguages.FormattingEnabled = true;
            this.lbLanguages.ItemHeight = 15;
            this.lbLanguages.Location = new System.Drawing.Point(3, 3);
            this.lbLanguages.Name = "lbLanguages";
            this.lbLanguages.Size = new System.Drawing.Size(139, 109);
            this.lbLanguages.TabIndex = 0;
            this.lbLanguages.SelectedIndexChanged += new System.EventHandler(this.lbLanguages_SelectedIndexChanged);
            // 
            // txtMessageToSend
            // 
            this.txtMessageToSend.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.txtMessageToSend.Dock = System.Windows.Forms.DockStyle.Fill;
            this.txtMessageToSend.Location = new System.Drawing.Point(148, 3);
            this.txtMessageToSend.Multiline = true;
            this.txtMessageToSend.Name = "txtMessageToSend";
            this.txtMessageToSend.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.txtMessageToSend.Size = new System.Drawing.Size(279, 109);
            this.txtMessageToSend.TabIndex = 1;
            // 
            // gbSendUsing
            // 
            this.gbSendUsing.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.gbSendUsing.Controls.Add(this.lblConnectionStatus);
            this.gbSendUsing.Controls.Add(this.lblStatus);
            this.gbSendUsing.Controls.Add(this.cmdLoadModem);
            this.gbSendUsing.Controls.Add(this.cboModemWebService);
            this.gbSendUsing.Controls.Add(this.rbSendUsingWebServ);
            this.gbSendUsing.Controls.Add(this.rbSendUsingModem);
            this.gbSendUsing.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.gbSendUsing.Location = new System.Drawing.Point(3, 4);
            this.gbSendUsing.Name = "gbSendUsing";
            this.gbSendUsing.Size = new System.Drawing.Size(436, 130);
            this.gbSendUsing.TabIndex = 0;
            this.gbSendUsing.TabStop = false;
            this.gbSendUsing.Text = "SEND USING:";
            // 
            // lblConnectionStatus
            // 
            this.lblConnectionStatus.AutoSize = true;
            this.lblConnectionStatus.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblConnectionStatus.ForeColor = System.Drawing.Color.Red;
            this.lblConnectionStatus.Location = new System.Drawing.Point(92, 99);
            this.lblConnectionStatus.Name = "lblConnectionStatus";
            this.lblConnectionStatus.Size = new System.Drawing.Size(86, 13);
            this.lblConnectionStatus.TabIndex = 5;
            this.lblConnectionStatus.Text = "Not Connected";
            // 
            // lblStatus
            // 
            this.lblStatus.AutoSize = true;
            this.lblStatus.Location = new System.Drawing.Point(29, 99);
            this.lblStatus.Name = "lblStatus";
            this.lblStatus.Size = new System.Drawing.Size(42, 15);
            this.lblStatus.TabIndex = 4;
            this.lblStatus.Text = "Status:";
            // 
            // cmdLoadModem
            // 
            this.cmdLoadModem.Location = new System.Drawing.Point(337, 59);
            this.cmdLoadModem.Name = "cmdLoadModem";
            this.cmdLoadModem.Size = new System.Drawing.Size(43, 23);
            this.cmdLoadModem.TabIndex = 3;
            this.cmdLoadModem.Text = "...";
            this.cmdLoadModem.UseVisualStyleBackColor = true;
            this.cmdLoadModem.Click += new System.EventHandler(this.cmdLoadModem_Click);
            // 
            // cboModemWebService
            // 
            this.cboModemWebService.FormattingEnabled = true;
            this.cboModemWebService.Location = new System.Drawing.Point(33, 61);
            this.cboModemWebService.Name = "cboModemWebService";
            this.cboModemWebService.Size = new System.Drawing.Size(297, 23);
            this.cboModemWebService.TabIndex = 2;
            this.cboModemWebService.SelectedIndexChanged += new System.EventHandler(this.cboModemWebService_SelectedIndexChanged);
            // 
            // rbSendUsingWebServ
            // 
            this.rbSendUsingWebServ.AutoSize = true;
            this.rbSendUsingWebServ.Location = new System.Drawing.Point(171, 30);
            this.rbSendUsingWebServ.Name = "rbSendUsingWebServ";
            this.rbSendUsingWebServ.Size = new System.Drawing.Size(88, 19);
            this.rbSendUsingWebServ.TabIndex = 1;
            this.rbSendUsingWebServ.Text = "Web service";
            this.rbSendUsingWebServ.UseVisualStyleBackColor = true;
            this.rbSendUsingWebServ.CheckedChanged += new System.EventHandler(this.rbSendUsingWebServ_CheckedChanged);
            // 
            // rbSendUsingModem
            // 
            this.rbSendUsingModem.AutoSize = true;
            this.rbSendUsingModem.Checked = true;
            this.rbSendUsingModem.Location = new System.Drawing.Point(33, 30);
            this.rbSendUsingModem.Name = "rbSendUsingModem";
            this.rbSendUsingModem.Size = new System.Drawing.Size(67, 19);
            this.rbSendUsingModem.TabIndex = 0;
            this.rbSendUsingModem.TabStop = true;
            this.rbSendUsingModem.Text = "Modem";
            this.rbSendUsingModem.UseVisualStyleBackColor = true;
            this.rbSendUsingModem.CheckedChanged += new System.EventHandler(this.rbSendUsingModem_CheckedChanged);
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.flowLayoutPanel1.Controls.Add(this.cmdSend);
            this.flowLayoutPanel1.Controls.Add(this.cmdClearAll);
            this.flowLayoutPanel1.FlowDirection = System.Windows.Forms.FlowDirection.RightToLeft;
            this.flowLayoutPanel1.Location = new System.Drawing.Point(724, 366);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(348, 44);
            this.flowLayoutPanel1.TabIndex = 1;
            // 
            // cmdSend
            // 
            this.cmdSend.Location = new System.Drawing.Point(232, 3);
            this.cmdSend.Name = "cmdSend";
            this.cmdSend.Size = new System.Drawing.Size(113, 40);
            this.cmdSend.TabIndex = 0;
            this.cmdSend.Text = "Send";
            this.cmdSend.UseVisualStyleBackColor = true;
            this.cmdSend.Click += new System.EventHandler(this.cmdSend_Click);
            // 
            // cmdClearAll
            // 
            this.cmdClearAll.Location = new System.Drawing.Point(105, 3);
            this.cmdClearAll.Name = "cmdClearAll";
            this.cmdClearAll.Size = new System.Drawing.Size(121, 40);
            this.cmdClearAll.TabIndex = 1;
            this.cmdClearAll.Text = "Clear all";
            this.cmdClearAll.UseVisualStyleBackColor = true;
            this.cmdClearAll.Click += new System.EventHandler(this.cmdClearAll_Click);
            // 
            // tpSMSLogs
            // 
            this.tpSMSLogs.Controls.Add(this.tlpSMSLogs);
            this.tpSMSLogs.Location = new System.Drawing.Point(4, 24);
            this.tpSMSLogs.Name = "tpSMSLogs";
            this.tpSMSLogs.Size = new System.Drawing.Size(1075, 413);
            this.tpSMSLogs.TabIndex = 2;
            this.tpSMSLogs.Text = "SMS Logs";
            this.tpSMSLogs.UseVisualStyleBackColor = true;
            // 
            // tlpSMSLogs
            // 
            this.tlpSMSLogs.ColumnCount = 1;
            this.tlpSMSLogs.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tlpSMSLogs.Controls.Add(this.tlpSMSLogs2, 0, 0);
            this.tlpSMSLogs.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tlpSMSLogs.Location = new System.Drawing.Point(0, 0);
            this.tlpSMSLogs.Name = "tlpSMSLogs";
            this.tlpSMSLogs.RowCount = 1;
            this.tlpSMSLogs.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tlpSMSLogs.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 413F));
            this.tlpSMSLogs.Size = new System.Drawing.Size(1075, 413);
            this.tlpSMSLogs.TabIndex = 1;
            // 
            // tlpSMSLogs2
            // 
            this.tlpSMSLogs2.ColumnCount = 1;
            this.tlpSMSLogs2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tlpSMSLogs2.Controls.Add(this.dgvSMSLogs, 0, 1);
            this.tlpSMSLogs2.Controls.Add(this.panel5, 0, 0);
            this.tlpSMSLogs2.Controls.Add(this.flowLayoutPanel8, 0, 2);
            this.tlpSMSLogs2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tlpSMSLogs2.Location = new System.Drawing.Point(0, 0);
            this.tlpSMSLogs2.Margin = new System.Windows.Forms.Padding(0);
            this.tlpSMSLogs2.Name = "tlpSMSLogs2";
            this.tlpSMSLogs2.RowCount = 3;
            this.tlpSMSLogs2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 98F));
            this.tlpSMSLogs2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tlpSMSLogs2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 40F));
            this.tlpSMSLogs2.Size = new System.Drawing.Size(1075, 413);
            this.tlpSMSLogs2.TabIndex = 4;
            // 
            // dgvSMSLogs
            // 
            this.dgvSMSLogs.AllowUserToAddRows = false;
            this.dgvSMSLogs.BackgroundColor = System.Drawing.Color.WhiteSmoke;
            this.dgvSMSLogs.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvSMSLogs.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvSMSLogs.Location = new System.Drawing.Point(3, 101);
            this.dgvSMSLogs.Name = "dgvSMSLogs";
            this.dgvSMSLogs.Size = new System.Drawing.Size(1069, 269);
            this.dgvSMSLogs.TabIndex = 0;
            // 
            // panel5
            // 
            this.panel5.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.panel5.Controls.Add(this.txtSQL);
            this.panel5.Controls.Add(this.QBQTool);
            this.panel5.Controls.Add(this.cmdRetrieve);
            this.panel5.Controls.Add(this.rbInbox);
            this.panel5.Controls.Add(this.rbFailedMessages);
            this.panel5.Controls.Add(this.rbSentMessages);
            this.panel5.Controls.Add(this.lblSMSLogsEndDate);
            this.panel5.Controls.Add(this.lblSMSLogsStartDate);
            this.panel5.Controls.Add(this.dtpSMSLogsEndDate);
            this.panel5.Controls.Add(this.dtpSMSLogsStartDate);
            this.panel5.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel5.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.panel5.Location = new System.Drawing.Point(3, 3);
            this.panel5.Name = "panel5";
            this.panel5.Size = new System.Drawing.Size(1069, 92);
            this.panel5.TabIndex = 1;
            // 
            // txtSQL
            // 
            this.txtSQL.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.txtSQL.CommentColor = System.Drawing.Color.Green;
            this.txtSQL.FunctionColor = System.Drawing.Color.Purple;
            this.txtSQL.InactiveSelectionBackColor = System.Drawing.SystemColors.InactiveCaption;
            this.txtSQL.KeywordColor = System.Drawing.Color.Blue;
            this.txtSQL.Location = new System.Drawing.Point(875, 18);
            this.txtSQL.Name = "txtSQL";
            this.txtSQL.NumberColor = System.Drawing.Color.DarkCyan;
            this.txtSQL.QueryBuilder = this.QBQTool;
            this.txtSQL.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            this.txtSQL.SelectionTextColor = System.Drawing.SystemColors.HighlightText;
            this.txtSQL.Size = new System.Drawing.Size(89, 43);
            this.txtSQL.StringColor = System.Drawing.Color.DarkRed;
            this.txtSQL.TabIndex = 11;
            this.txtSQL.Text = "sqlTextEditor1";
            this.txtSQL.TextColor = System.Drawing.SystemColors.WindowText;
            this.txtSQL.TextPadding = new System.Windows.Forms.Padding(3, 0, 0, 0);
            this.txtSQL.Visible = false;
            // 
            // QBQTool
            // 
            this.QBQTool.AddObjectFormOptions.MinimumSize = new System.Drawing.Size(430, 430);
            this.QBQTool.CriteriaListOptions.BackColor = System.Drawing.SystemColors.Window;
            this.QBQTool.CriteriaListOptions.CriteriaListFont = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.QBQTool.DiagramObjectColor = System.Drawing.SystemColors.Window;
            this.QBQTool.DiagramObjectFont = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.QBQTool.DiagramPaneColor = System.Drawing.SystemColors.Window;
            this.QBQTool.ExpressionEditor = null;
            this.QBQTool.FieldListOptions.DescriptionColumnOptions.Color = System.Drawing.Color.LightBlue;
            this.QBQTool.FieldListOptions.MarkColumnOptions.PKIcon = ((System.Drawing.Image)(resources.GetObject("resource.PKIcon")));
            this.QBQTool.FieldListOptions.NameColumnOptions.Color = System.Drawing.SystemColors.WindowText;
            this.QBQTool.FieldListOptions.NameColumnOptions.PKColor = System.Drawing.SystemColors.WindowText;
            this.QBQTool.FieldListOptions.TypeColumnOptions.Color = System.Drawing.SystemColors.GrayText;
            this.QBQTool.FocusedDiagramObjectColor = System.Drawing.SystemColors.Window;
            this.QBQTool.Location = new System.Drawing.Point(750, 18);
            this.QBQTool.MetadataProvider = null;
            this.QBQTool.MetadataTreeOptions.BackColor = System.Drawing.SystemColors.Window;
            this.QBQTool.MetadataTreeOptions.ImageList = null;
            this.QBQTool.MetadataTreeOptions.ProceduresNodeText = null;
            this.QBQTool.MetadataTreeOptions.SynonymsNodeText = null;
            this.QBQTool.MetadataTreeOptions.TablesNodeText = null;
            this.QBQTool.MetadataTreeOptions.ViewsNodeText = null;
            this.QBQTool.Name = "QBQTool";
            this.QBQTool.QueryStructureTreeOptions.BackColor = System.Drawing.SystemColors.Window;
            this.QBQTool.QueryStructureTreeOptions.FieldImageIndex = 8;
            this.QBQTool.QueryStructureTreeOptions.FieldsImageIndex = 7;
            this.QBQTool.QueryStructureTreeOptions.FromImageIndex = 4;
            this.QBQTool.QueryStructureTreeOptions.FromObjImageIndex = 0;
            this.QBQTool.QueryStructureTreeOptions.ImageList = null;
            this.QBQTool.QueryStructureTreeOptions.QueriesImageIndex = 3;
            this.QBQTool.Size = new System.Drawing.Size(92, 43);
            this.QBQTool.SleepModeText = null;
            this.QBQTool.SnapSize = new System.Drawing.Size(5, 5);
            this.QBQTool.SQLChanging = false;
            this.QBQTool.SyntaxProvider = null;
            this.QBQTool.TabIndex = 10;
            this.QBQTool.TreeFont = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.QBQTool.Visible = false;
            // 
            // cmdRetrieve
            // 
            this.cmdRetrieve.Location = new System.Drawing.Point(496, 53);
            this.cmdRetrieve.Name = "cmdRetrieve";
            this.cmdRetrieve.Size = new System.Drawing.Size(121, 23);
            this.cmdRetrieve.TabIndex = 7;
            this.cmdRetrieve.Text = "Retrieve";
            this.cmdRetrieve.UseVisualStyleBackColor = true;
            this.cmdRetrieve.Click += new System.EventHandler(this.cmdRetrieve_Click);
            // 
            // rbInbox
            // 
            this.rbInbox.AutoSize = true;
            this.rbInbox.Location = new System.Drawing.Point(367, 56);
            this.rbInbox.Name = "rbInbox";
            this.rbInbox.Size = new System.Drawing.Size(54, 19);
            this.rbInbox.TabIndex = 6;
            this.rbInbox.Text = "Inbox";
            this.rbInbox.UseVisualStyleBackColor = true;
            // 
            // rbFailedMessages
            // 
            this.rbFailedMessages.AutoSize = true;
            this.rbFailedMessages.Location = new System.Drawing.Point(195, 56);
            this.rbFailedMessages.Name = "rbFailedMessages";
            this.rbFailedMessages.Size = new System.Drawing.Size(110, 19);
            this.rbFailedMessages.TabIndex = 5;
            this.rbFailedMessages.Text = "Failed messages";
            this.rbFailedMessages.UseVisualStyleBackColor = true;
            this.rbFailedMessages.CheckedChanged += new System.EventHandler(this.rbFailedMessages_CheckedChanged);
            // 
            // rbSentMessages
            // 
            this.rbSentMessages.AutoSize = true;
            this.rbSentMessages.Checked = true;
            this.rbSentMessages.Location = new System.Drawing.Point(17, 56);
            this.rbSentMessages.Name = "rbSentMessages";
            this.rbSentMessages.Size = new System.Drawing.Size(102, 19);
            this.rbSentMessages.TabIndex = 4;
            this.rbSentMessages.TabStop = true;
            this.rbSentMessages.Text = "Sent messages";
            this.rbSentMessages.UseVisualStyleBackColor = true;
            // 
            // lblSMSLogsEndDate
            // 
            this.lblSMSLogsEndDate.AutoSize = true;
            this.lblSMSLogsEndDate.Location = new System.Drawing.Point(259, 23);
            this.lblSMSLogsEndDate.Name = "lblSMSLogsEndDate";
            this.lblSMSLogsEndDate.Size = new System.Drawing.Size(57, 15);
            this.lblSMSLogsEndDate.TabIndex = 3;
            this.lblSMSLogsEndDate.Text = "End Date:";
            // 
            // lblSMSLogsStartDate
            // 
            this.lblSMSLogsStartDate.AutoSize = true;
            this.lblSMSLogsStartDate.Location = new System.Drawing.Point(14, 23);
            this.lblSMSLogsStartDate.Name = "lblSMSLogsStartDate";
            this.lblSMSLogsStartDate.Size = new System.Drawing.Size(61, 15);
            this.lblSMSLogsStartDate.TabIndex = 2;
            this.lblSMSLogsStartDate.Text = "Start Date:";
            // 
            // dtpSMSLogsEndDate
            // 
            this.dtpSMSLogsEndDate.CustomFormat = "yyyy-MM-dd";
            this.dtpSMSLogsEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpSMSLogsEndDate.Location = new System.Drawing.Point(341, 18);
            this.dtpSMSLogsEndDate.Name = "dtpSMSLogsEndDate";
            this.dtpSMSLogsEndDate.Size = new System.Drawing.Size(135, 23);
            this.dtpSMSLogsEndDate.TabIndex = 1;
            // 
            // dtpSMSLogsStartDate
            // 
            this.dtpSMSLogsStartDate.CustomFormat = "yyyy-MM-dd";
            this.dtpSMSLogsStartDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpSMSLogsStartDate.Location = new System.Drawing.Point(104, 18);
            this.dtpSMSLogsStartDate.Name = "dtpSMSLogsStartDate";
            this.dtpSMSLogsStartDate.Size = new System.Drawing.Size(131, 23);
            this.dtpSMSLogsStartDate.TabIndex = 0;
            // 
            // flowLayoutPanel8
            // 
            this.flowLayoutPanel8.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.flowLayoutPanel8.Controls.Add(this.CmdClearLogs);
            this.flowLayoutPanel8.Controls.Add(this.cmdResendFailedMsgs);
            this.flowLayoutPanel8.FlowDirection = System.Windows.Forms.FlowDirection.RightToLeft;
            this.flowLayoutPanel8.Location = new System.Drawing.Point(646, 376);
            this.flowLayoutPanel8.Name = "flowLayoutPanel8";
            this.flowLayoutPanel8.Size = new System.Drawing.Size(426, 34);
            this.flowLayoutPanel8.TabIndex = 2;
            // 
            // CmdClearLogs
            // 
            this.CmdClearLogs.Location = new System.Drawing.Point(317, 3);
            this.CmdClearLogs.Name = "CmdClearLogs";
            this.CmdClearLogs.Size = new System.Drawing.Size(106, 30);
            this.CmdClearLogs.TabIndex = 3;
            this.CmdClearLogs.Text = "Clear Logs";
            this.CmdClearLogs.UseVisualStyleBackColor = true;
            this.CmdClearLogs.Click += new System.EventHandler(this.CmdClearLogs_Click);
            // 
            // cmdResendFailedMsgs
            // 
            this.cmdResendFailedMsgs.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.cmdResendFailedMsgs.Enabled = false;
            this.cmdResendFailedMsgs.Location = new System.Drawing.Point(94, 3);
            this.cmdResendFailedMsgs.Name = "cmdResendFailedMsgs";
            this.cmdResendFailedMsgs.Size = new System.Drawing.Size(217, 30);
            this.cmdResendFailedMsgs.TabIndex = 2;
            this.cmdResendFailedMsgs.Text = "Resend failed messages";
            this.cmdResendFailedMsgs.UseVisualStyleBackColor = true;
            this.cmdResendFailedMsgs.Click += new System.EventHandler(this.cmdResendFailedMsgs_Click);
            // 
            // tpSettings
            // 
            this.tpSettings.Controls.Add(this.tlpSMSSettings);
            this.tpSettings.Location = new System.Drawing.Point(4, 24);
            this.tpSettings.Name = "tpSettings";
            this.tpSettings.Padding = new System.Windows.Forms.Padding(3);
            this.tpSettings.Size = new System.Drawing.Size(1075, 413);
            this.tpSettings.TabIndex = 1;
            this.tpSettings.Text = "Settings";
            this.tpSettings.UseVisualStyleBackColor = true;
            this.tpSettings.Enter += new System.EventHandler(this.tpSettings_Enter);
            // 
            // tlpSMSSettings
            // 
            this.tlpSMSSettings.ColumnCount = 1;
            this.tlpSMSSettings.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tlpSMSSettings.Controls.Add(this.tableLayoutPanel7, 0, 0);
            this.tlpSMSSettings.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tlpSMSSettings.Location = new System.Drawing.Point(3, 3);
            this.tlpSMSSettings.Name = "tlpSMSSettings";
            this.tlpSMSSettings.RowCount = 1;
            this.tlpSMSSettings.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tlpSMSSettings.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 407F));
            this.tlpSMSSettings.Size = new System.Drawing.Size(1069, 407);
            this.tlpSMSSettings.TabIndex = 0;
            // 
            // tableLayoutPanel7
            // 
            this.tableLayoutPanel7.ColumnCount = 2;
            this.tableLayoutPanel7.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 350F));
            this.tableLayoutPanel7.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel7.Controls.Add(this.tableLayoutPanel8, 0, 0);
            this.tableLayoutPanel7.Controls.Add(this.tableLayoutPanel9, 1, 0);
            this.tableLayoutPanel7.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel7.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel7.Margin = new System.Windows.Forms.Padding(0);
            this.tableLayoutPanel7.Name = "tableLayoutPanel7";
            this.tableLayoutPanel7.RowCount = 1;
            this.tableLayoutPanel7.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel7.Size = new System.Drawing.Size(1069, 407);
            this.tableLayoutPanel7.TabIndex = 4;
            // 
            // tableLayoutPanel8
            // 
            this.tableLayoutPanel8.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.tableLayoutPanel8.ColumnCount = 1;
            this.tableLayoutPanel8.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel8.Controls.Add(this.gbCountryCode, 0, 0);
            this.tableLayoutPanel8.Controls.Add(this.gbMessageSettings, 0, 1);
            this.tableLayoutPanel8.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel8.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.tableLayoutPanel8.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel8.Margin = new System.Windows.Forms.Padding(0);
            this.tableLayoutPanel8.Name = "tableLayoutPanel8";
            this.tableLayoutPanel8.RowCount = 2;
            this.tableLayoutPanel8.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 140F));
            this.tableLayoutPanel8.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel8.Size = new System.Drawing.Size(350, 407);
            this.tableLayoutPanel8.TabIndex = 0;
            // 
            // gbCountryCode
            // 
            this.gbCountryCode.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.gbCountryCode.Controls.Add(this.label20);
            this.gbCountryCode.Controls.Add(this.cboCountryCode);
            this.gbCountryCode.Controls.Add(this.txtCountryCode);
            this.gbCountryCode.Controls.Add(this.cmdSaveCountryCode);
            this.gbCountryCode.Controls.Add(this.lblCountryCode);
            this.gbCountryCode.Location = new System.Drawing.Point(3, 3);
            this.gbCountryCode.Name = "gbCountryCode";
            this.gbCountryCode.Size = new System.Drawing.Size(344, 105);
            this.gbCountryCode.TabIndex = 0;
            this.gbCountryCode.TabStop = false;
            this.gbCountryCode.Text = "COUNTRY CODE:";
            // 
            // label20
            // 
            this.label20.AutoSize = true;
            this.label20.Location = new System.Drawing.Point(22, 25);
            this.label20.Name = "label20";
            this.label20.Size = new System.Drawing.Size(53, 15);
            this.label20.TabIndex = 10;
            this.label20.Text = "Country:";
            // 
            // cboCountryCode
            // 
            this.cboCountryCode.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboCountryCode.FormattingEnabled = true;
            this.cboCountryCode.Items.AddRange(new object[] {
            "Kenya",
            "Tanzania",
            "Uganda",
            "Others"});
            this.cboCountryCode.Location = new System.Drawing.Point(140, 16);
            this.cboCountryCode.Name = "cboCountryCode";
            this.cboCountryCode.Size = new System.Drawing.Size(171, 23);
            this.cboCountryCode.TabIndex = 9;
            this.cboCountryCode.SelectedIndexChanged += new System.EventHandler(this.cboCountryCode_SelectedIndexChanged);
            // 
            // txtCountryCode
            // 
            this.txtCountryCode.Location = new System.Drawing.Point(140, 45);
            this.txtCountryCode.Name = "txtCountryCode";
            this.txtCountryCode.Size = new System.Drawing.Size(171, 23);
            this.txtCountryCode.TabIndex = 2;
            // 
            // cmdSaveCountryCode
            // 
            this.cmdSaveCountryCode.Location = new System.Drawing.Point(224, 74);
            this.cmdSaveCountryCode.Name = "cmdSaveCountryCode";
            this.cmdSaveCountryCode.Size = new System.Drawing.Size(87, 23);
            this.cmdSaveCountryCode.TabIndex = 1;
            this.cmdSaveCountryCode.Text = "Save";
            this.cmdSaveCountryCode.UseVisualStyleBackColor = true;
            this.cmdSaveCountryCode.Click += new System.EventHandler(this.cmdSaveCountryCode_Click);
            // 
            // lblCountryCode
            // 
            this.lblCountryCode.AutoSize = true;
            this.lblCountryCode.Location = new System.Drawing.Point(22, 54);
            this.lblCountryCode.Name = "lblCountryCode";
            this.lblCountryCode.Size = new System.Drawing.Size(82, 15);
            this.lblCountryCode.TabIndex = 0;
            this.lblCountryCode.Text = "Country code:";
            // 
            // gbMessageSettings
            // 
            this.gbMessageSettings.Controls.Add(this.lbSettingsSubCategory);
            this.gbMessageSettings.Controls.Add(this.cboSettingsCategory);
            this.gbMessageSettings.Controls.Add(this.lblMessageCat);
            this.gbMessageSettings.Dock = System.Windows.Forms.DockStyle.Fill;
            this.gbMessageSettings.Location = new System.Drawing.Point(3, 143);
            this.gbMessageSettings.Name = "gbMessageSettings";
            this.gbMessageSettings.Size = new System.Drawing.Size(344, 261);
            this.gbMessageSettings.TabIndex = 1;
            this.gbMessageSettings.TabStop = false;
            this.gbMessageSettings.Text = "MESSAGE SETTINGS:";
            // 
            // lbSettingsSubCategory
            // 
            this.lbSettingsSubCategory.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lbSettingsSubCategory.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.lbSettingsSubCategory.FormattingEnabled = true;
            this.lbSettingsSubCategory.ItemHeight = 15;
            this.lbSettingsSubCategory.Location = new System.Drawing.Point(21, 70);
            this.lbSettingsSubCategory.Name = "lbSettingsSubCategory";
            this.lbSettingsSubCategory.Size = new System.Drawing.Size(315, 124);
            this.lbSettingsSubCategory.TabIndex = 2;
            this.lbSettingsSubCategory.SelectedIndexChanged += new System.EventHandler(this.lbSettingsSubCategory_SelectedIndexChanged);
            // 
            // cboSettingsCategory
            // 
            this.cboSettingsCategory.FormattingEnabled = true;
            this.cboSettingsCategory.Items.AddRange(new object[] {
            "Appointments"});
            this.cboSettingsCategory.Location = new System.Drawing.Point(100, 32);
            this.cboSettingsCategory.Name = "cboSettingsCategory";
            this.cboSettingsCategory.Size = new System.Drawing.Size(228, 23);
            this.cboSettingsCategory.TabIndex = 1;
            this.cboSettingsCategory.SelectedIndexChanged += new System.EventHandler(this.cboSettingsCategory_SelectedIndexChanged);
            // 
            // lblMessageCat
            // 
            this.lblMessageCat.AutoSize = true;
            this.lblMessageCat.Location = new System.Drawing.Point(17, 35);
            this.lblMessageCat.Name = "lblMessageCat";
            this.lblMessageCat.Size = new System.Drawing.Size(58, 15);
            this.lblMessageCat.TabIndex = 0;
            this.lblMessageCat.Text = "Category:";
            // 
            // tableLayoutPanel9
            // 
            this.tableLayoutPanel9.BackColor = System.Drawing.Color.WhiteSmoke;
            this.tableLayoutPanel9.CellBorderStyle = System.Windows.Forms.TableLayoutPanelCellBorderStyle.Single;
            this.tableLayoutPanel9.ColumnCount = 1;
            this.tableLayoutPanel9.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel9.Controls.Add(this.tableLayoutPanel10, 0, 1);
            this.tableLayoutPanel9.Controls.Add(this.tableLayoutPanel11, 0, 0);
            this.tableLayoutPanel9.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel9.Location = new System.Drawing.Point(350, 0);
            this.tableLayoutPanel9.Margin = new System.Windows.Forms.Padding(0);
            this.tableLayoutPanel9.Name = "tableLayoutPanel9";
            this.tableLayoutPanel9.RowCount = 2;
            this.tableLayoutPanel9.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 40F));
            this.tableLayoutPanel9.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel9.Size = new System.Drawing.Size(719, 407);
            this.tableLayoutPanel9.TabIndex = 1;
            // 
            // tableLayoutPanel10
            // 
            this.tableLayoutPanel10.ColumnCount = 2;
            this.tableLayoutPanel10.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 117F));
            this.tableLayoutPanel10.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel10.Controls.Add(this.lblSettingsLanguage, 0, 0);
            this.tableLayoutPanel10.Controls.Add(this.lblSettingsMessage, 0, 1);
            this.tableLayoutPanel10.Controls.Add(this.cboSettingslanguage, 1, 0);
            this.tableLayoutPanel10.Controls.Add(this.txtSettingsMessage, 1, 1);
            this.tableLayoutPanel10.Controls.Add(this.flowLayoutPanel2, 1, 2);
            this.tableLayoutPanel10.Location = new System.Drawing.Point(4, 45);
            this.tableLayoutPanel10.Name = "tableLayoutPanel10";
            this.tableLayoutPanel10.RowCount = 3;
            this.tableLayoutPanel10.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 40F));
            this.tableLayoutPanel10.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel10.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 40F));
            this.tableLayoutPanel10.Size = new System.Drawing.Size(574, 249);
            this.tableLayoutPanel10.TabIndex = 0;
            // 
            // lblSettingsLanguage
            // 
            this.lblSettingsLanguage.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.lblSettingsLanguage.AutoSize = true;
            this.lblSettingsLanguage.Location = new System.Drawing.Point(52, 12);
            this.lblSettingsLanguage.Name = "lblSettingsLanguage";
            this.lblSettingsLanguage.Size = new System.Drawing.Size(62, 15);
            this.lblSettingsLanguage.TabIndex = 0;
            this.lblSettingsLanguage.Text = "Language:";
            // 
            // lblSettingsMessage
            // 
            this.lblSettingsMessage.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblSettingsMessage.AutoSize = true;
            this.lblSettingsMessage.Location = new System.Drawing.Point(58, 40);
            this.lblSettingsMessage.Name = "lblSettingsMessage";
            this.lblSettingsMessage.Size = new System.Drawing.Size(56, 15);
            this.lblSettingsMessage.TabIndex = 1;
            this.lblSettingsMessage.Text = "Message:";
            // 
            // cboSettingslanguage
            // 
            this.cboSettingslanguage.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.cboSettingslanguage.FormattingEnabled = true;
            this.cboSettingslanguage.Location = new System.Drawing.Point(120, 8);
            this.cboSettingslanguage.Name = "cboSettingslanguage";
            this.cboSettingslanguage.Size = new System.Drawing.Size(451, 23);
            this.cboSettingslanguage.TabIndex = 2;
            this.cboSettingslanguage.SelectedIndexChanged += new System.EventHandler(this.cboSettingslanguage_SelectedIndexChanged);
            // 
            // txtSettingsMessage
            // 
            this.txtSettingsMessage.Dock = System.Windows.Forms.DockStyle.Fill;
            this.txtSettingsMessage.Location = new System.Drawing.Point(120, 43);
            this.txtSettingsMessage.Multiline = true;
            this.txtSettingsMessage.Name = "txtSettingsMessage";
            this.txtSettingsMessage.Size = new System.Drawing.Size(451, 163);
            this.txtSettingsMessage.TabIndex = 3;
            // 
            // flowLayoutPanel2
            // 
            this.flowLayoutPanel2.Controls.Add(this.cmdSettingsSave);
            this.flowLayoutPanel2.Controls.Add(this.cmdSettingsDelete);
            this.flowLayoutPanel2.Location = new System.Drawing.Point(120, 212);
            this.flowLayoutPanel2.Name = "flowLayoutPanel2";
            this.flowLayoutPanel2.Size = new System.Drawing.Size(325, 34);
            this.flowLayoutPanel2.TabIndex = 4;
            // 
            // cmdSettingsSave
            // 
            this.cmdSettingsSave.Location = new System.Drawing.Point(3, 3);
            this.cmdSettingsSave.Name = "cmdSettingsSave";
            this.cmdSettingsSave.Size = new System.Drawing.Size(118, 23);
            this.cmdSettingsSave.TabIndex = 0;
            this.cmdSettingsSave.Text = "Save/Update";
            this.cmdSettingsSave.UseVisualStyleBackColor = true;
            this.cmdSettingsSave.Click += new System.EventHandler(this.cmdSettingsSave_Click);
            // 
            // cmdSettingsDelete
            // 
            this.cmdSettingsDelete.Location = new System.Drawing.Point(127, 3);
            this.cmdSettingsDelete.Name = "cmdSettingsDelete";
            this.cmdSettingsDelete.Size = new System.Drawing.Size(115, 23);
            this.cmdSettingsDelete.TabIndex = 1;
            this.cmdSettingsDelete.Text = "Delete";
            this.cmdSettingsDelete.UseVisualStyleBackColor = true;
            this.cmdSettingsDelete.Click += new System.EventHandler(this.cmdSettingsDelete_Click);
            // 
            // tableLayoutPanel11
            // 
            this.tableLayoutPanel11.BackColor = System.Drawing.SystemColors.Control;
            this.tableLayoutPanel11.ColumnCount = 1;
            this.tableLayoutPanel11.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel11.Controls.Add(this.lblSMSDescription, 0, 0);
            this.tableLayoutPanel11.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel11.ForeColor = System.Drawing.SystemColors.ControlLight;
            this.tableLayoutPanel11.Location = new System.Drawing.Point(4, 4);
            this.tableLayoutPanel11.Name = "tableLayoutPanel11";
            this.tableLayoutPanel11.RowCount = 1;
            this.tableLayoutPanel11.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel11.Size = new System.Drawing.Size(711, 34);
            this.tableLayoutPanel11.TabIndex = 1;
            // 
            // lblSMSDescription
            // 
            this.lblSMSDescription.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lblSMSDescription.AutoSize = true;
            this.lblSMSDescription.ForeColor = System.Drawing.SystemColors.ControlText;
            this.lblSMSDescription.Location = new System.Drawing.Point(3, 9);
            this.lblSMSDescription.Name = "lblSMSDescription";
            this.lblSMSDescription.Size = new System.Drawing.Size(112, 15);
            this.lblSMSDescription.TabIndex = 0;
            this.lblSMSDescription.Text = "Short appointments";
            // 
            // tpScheduling
            // 
            this.tpScheduling.Controls.Add(this.tableLayoutPanel15);
            this.tpScheduling.Location = new System.Drawing.Point(4, 24);
            this.tpScheduling.Name = "tpScheduling";
            this.tpScheduling.Size = new System.Drawing.Size(1075, 413);
            this.tpScheduling.TabIndex = 3;
            this.tpScheduling.Text = "Scheduling";
            this.tpScheduling.UseVisualStyleBackColor = true;
            // 
            // tableLayoutPanel15
            // 
            this.tableLayoutPanel15.ColumnCount = 1;
            this.tableLayoutPanel15.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel15.Controls.Add(this.tableLayoutPanel17, 0, 0);
            this.tableLayoutPanel15.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel15.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel15.Name = "tableLayoutPanel15";
            this.tableLayoutPanel15.RowCount = 1;
            this.tableLayoutPanel15.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel15.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 413F));
            this.tableLayoutPanel15.Size = new System.Drawing.Size(1075, 413);
            this.tableLayoutPanel15.TabIndex = 2;
            // 
            // tableLayoutPanel17
            // 
            this.tableLayoutPanel17.CellBorderStyle = System.Windows.Forms.TableLayoutPanelCellBorderStyle.Single;
            this.tableLayoutPanel17.ColumnCount = 1;
            this.tableLayoutPanel17.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel17.Controls.Add(this.panel18, 0, 0);
            this.tableLayoutPanel17.Controls.Add(this.flowLayoutPanel7, 0, 1);
            this.tableLayoutPanel17.Controls.Add(this.dgvSchedules, 0, 2);
            this.tableLayoutPanel17.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel17.Location = new System.Drawing.Point(3, 3);
            this.tableLayoutPanel17.Name = "tableLayoutPanel17";
            this.tableLayoutPanel17.RowCount = 3;
            this.tableLayoutPanel17.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 200F));
            this.tableLayoutPanel17.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 40F));
            this.tableLayoutPanel17.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel17.Size = new System.Drawing.Size(1069, 407);
            this.tableLayoutPanel17.TabIndex = 4;
            // 
            // panel18
            // 
            this.panel18.Controls.Add(this.tableLayoutPanel18);
            this.panel18.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel18.Location = new System.Drawing.Point(4, 4);
            this.panel18.Name = "panel18";
            this.panel18.Size = new System.Drawing.Size(1061, 194);
            this.panel18.TabIndex = 0;
            // 
            // tableLayoutPanel18
            // 
            this.tableLayoutPanel18.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.tableLayoutPanel18.ColumnCount = 4;
            this.tableLayoutPanel18.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 175F));
            this.tableLayoutPanel18.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel18.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 175F));
            this.tableLayoutPanel18.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel18.Controls.Add(this.lblScheduleSendUsing, 0, 4);
            this.tableLayoutPanel18.Controls.Add(this.rbScheduleDaily, 3, 0);
            this.tableLayoutPanel18.Controls.Add(this.rbScheduleWeekly, 3, 2);
            this.tableLayoutPanel18.Controls.Add(this.rbScheduleMonthly, 3, 4);
            this.tableLayoutPanel18.Controls.Add(this.lblScheduleType, 2, 0);
            this.tableLayoutPanel18.Controls.Add(this.flowLayoutPanel3, 1, 4);
            this.tableLayoutPanel18.Controls.Add(this.flowLayoutPanel4, 3, 1);
            this.tableLayoutPanel18.Controls.Add(this.flowLayoutPanel5, 3, 3);
            this.tableLayoutPanel18.Controls.Add(this.flowLayoutPanel6, 3, 5);
            this.tableLayoutPanel18.Controls.Add(this.cboScheduleModem, 1, 5);
            this.tableLayoutPanel18.Controls.Add(this.cboScheduleSubCategory, 1, 3);
            this.tableLayoutPanel18.Controls.Add(this.lblScheduleSubCategory, 0, 3);
            this.tableLayoutPanel18.Controls.Add(this.lblScheduleCategory, 0, 2);
            this.tableLayoutPanel18.Controls.Add(this.cboScheduleCategory, 1, 2);
            this.tableLayoutPanel18.Controls.Add(this.txtScheduleName, 1, 1);
            this.tableLayoutPanel18.Controls.Add(this.lblScheduleName, 0, 1);
            this.tableLayoutPanel18.Controls.Add(this.lblScheduleID, 0, 0);
            this.tableLayoutPanel18.Controls.Add(this.txtScheduleID, 1, 0);
            this.tableLayoutPanel18.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel18.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.tableLayoutPanel18.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel18.Margin = new System.Windows.Forms.Padding(0);
            this.tableLayoutPanel18.Name = "tableLayoutPanel18";
            this.tableLayoutPanel18.RowCount = 6;
            this.tableLayoutPanel18.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
            this.tableLayoutPanel18.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66666F));
            this.tableLayoutPanel18.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66666F));
            this.tableLayoutPanel18.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66666F));
            this.tableLayoutPanel18.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66666F));
            this.tableLayoutPanel18.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
            this.tableLayoutPanel18.Size = new System.Drawing.Size(1061, 194);
            this.tableLayoutPanel18.TabIndex = 5;
            // 
            // lblScheduleSendUsing
            // 
            this.lblScheduleSendUsing.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.lblScheduleSendUsing.AutoSize = true;
            this.lblScheduleSendUsing.Font = new System.Drawing.Font("Segoe UI Semibold", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblScheduleSendUsing.Location = new System.Drawing.Point(107, 137);
            this.lblScheduleSendUsing.Name = "lblScheduleSendUsing";
            this.lblScheduleSendUsing.Size = new System.Drawing.Size(65, 13);
            this.lblScheduleSendUsing.TabIndex = 4;
            this.lblScheduleSendUsing.Text = "Send using:";
            // 
            // rbScheduleDaily
            // 
            this.rbScheduleDaily.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.rbScheduleDaily.AutoSize = true;
            this.rbScheduleDaily.Checked = true;
            this.rbScheduleDaily.Location = new System.Drawing.Point(708, 6);
            this.rbScheduleDaily.Name = "rbScheduleDaily";
            this.rbScheduleDaily.Size = new System.Drawing.Size(51, 19);
            this.rbScheduleDaily.TabIndex = 9;
            this.rbScheduleDaily.TabStop = true;
            this.rbScheduleDaily.Text = "Daily";
            this.rbScheduleDaily.UseVisualStyleBackColor = true;
            // 
            // rbScheduleWeekly
            // 
            this.rbScheduleWeekly.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.rbScheduleWeekly.AutoSize = true;
            this.rbScheduleWeekly.Location = new System.Drawing.Point(708, 70);
            this.rbScheduleWeekly.Name = "rbScheduleWeekly";
            this.rbScheduleWeekly.Size = new System.Drawing.Size(63, 19);
            this.rbScheduleWeekly.TabIndex = 10;
            this.rbScheduleWeekly.Text = "Weekly";
            this.rbScheduleWeekly.UseVisualStyleBackColor = true;
            // 
            // rbScheduleMonthly
            // 
            this.rbScheduleMonthly.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.rbScheduleMonthly.AutoSize = true;
            this.rbScheduleMonthly.Location = new System.Drawing.Point(708, 134);
            this.rbScheduleMonthly.Name = "rbScheduleMonthly";
            this.rbScheduleMonthly.Size = new System.Drawing.Size(70, 19);
            this.rbScheduleMonthly.TabIndex = 11;
            this.rbScheduleMonthly.Text = "Monthly";
            this.rbScheduleMonthly.UseVisualStyleBackColor = true;
            // 
            // lblScheduleType
            // 
            this.lblScheduleType.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.lblScheduleType.AutoSize = true;
            this.lblScheduleType.Font = new System.Drawing.Font("Segoe UI Semibold", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblScheduleType.Location = new System.Drawing.Point(647, 9);
            this.lblScheduleType.Name = "lblScheduleType";
            this.lblScheduleType.Size = new System.Drawing.Size(55, 13);
            this.lblScheduleType.TabIndex = 12;
            this.lblScheduleType.Text = "Schedule:";
            // 
            // flowLayoutPanel3
            // 
            this.flowLayoutPanel3.Controls.Add(this.rbScheduleModem);
            this.flowLayoutPanel3.Controls.Add(this.rbScheduleWebService);
            this.flowLayoutPanel3.Location = new System.Drawing.Point(178, 131);
            this.flowLayoutPanel3.Name = "flowLayoutPanel3";
            this.flowLayoutPanel3.Size = new System.Drawing.Size(313, 26);
            this.flowLayoutPanel3.TabIndex = 13;
            // 
            // rbScheduleModem
            // 
            this.rbScheduleModem.AutoSize = true;
            this.rbScheduleModem.Checked = true;
            this.rbScheduleModem.Location = new System.Drawing.Point(3, 3);
            this.rbScheduleModem.Name = "rbScheduleModem";
            this.rbScheduleModem.Size = new System.Drawing.Size(67, 19);
            this.rbScheduleModem.TabIndex = 0;
            this.rbScheduleModem.TabStop = true;
            this.rbScheduleModem.Text = "Modem";
            this.rbScheduleModem.UseVisualStyleBackColor = true;
            // 
            // rbScheduleWebService
            // 
            this.rbScheduleWebService.AutoSize = true;
            this.rbScheduleWebService.Location = new System.Drawing.Point(76, 3);
            this.rbScheduleWebService.Name = "rbScheduleWebService";
            this.rbScheduleWebService.Size = new System.Drawing.Size(88, 19);
            this.rbScheduleWebService.TabIndex = 1;
            this.rbScheduleWebService.Text = "Web service";
            this.rbScheduleWebService.UseVisualStyleBackColor = true;
            this.rbScheduleWebService.CheckedChanged += new System.EventHandler(this.rbScheduleWebService_CheckedChanged);
            // 
            // flowLayoutPanel4
            // 
            this.flowLayoutPanel4.Controls.Add(this.numDaysEarlier);
            this.flowLayoutPanel4.Controls.Add(this.lblDaysEarlier);
            this.flowLayoutPanel4.Controls.Add(this.dtpDailyTime);
            this.flowLayoutPanel4.Location = new System.Drawing.Point(708, 35);
            this.flowLayoutPanel4.Name = "flowLayoutPanel4";
            this.flowLayoutPanel4.Size = new System.Drawing.Size(347, 26);
            this.flowLayoutPanel4.TabIndex = 15;
            // 
            // numDaysEarlier
            // 
            this.numDaysEarlier.Location = new System.Drawing.Point(3, 3);
            this.numDaysEarlier.Name = "numDaysEarlier";
            this.numDaysEarlier.Size = new System.Drawing.Size(49, 23);
            this.numDaysEarlier.TabIndex = 0;
            this.numDaysEarlier.Value = new decimal(new int[] {
            2,
            0,
            0,
            0});
            // 
            // lblDaysEarlier
            // 
            this.lblDaysEarlier.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lblDaysEarlier.AutoSize = true;
            this.lblDaysEarlier.Location = new System.Drawing.Point(58, 7);
            this.lblDaysEarlier.Name = "lblDaysEarlier";
            this.lblDaysEarlier.Size = new System.Drawing.Size(79, 15);
            this.lblDaysEarlier.TabIndex = 0;
            this.lblDaysEarlier.Text = "days earlier at";
            // 
            // dtpDailyTime
            // 
            this.dtpDailyTime.Format = System.Windows.Forms.DateTimePickerFormat.Time;
            this.dtpDailyTime.Location = new System.Drawing.Point(143, 3);
            this.dtpDailyTime.Name = "dtpDailyTime";
            this.dtpDailyTime.ShowUpDown = true;
            this.dtpDailyTime.Size = new System.Drawing.Size(122, 23);
            this.dtpDailyTime.TabIndex = 1;
            // 
            // flowLayoutPanel5
            // 
            this.flowLayoutPanel5.Controls.Add(this.lblWeeklyEvery);
            this.flowLayoutPanel5.Controls.Add(this.cboWeeklyDay);
            this.flowLayoutPanel5.Controls.Add(this.lblWeeklyAt);
            this.flowLayoutPanel5.Controls.Add(this.dtpWeeklyTime);
            this.flowLayoutPanel5.Location = new System.Drawing.Point(708, 99);
            this.flowLayoutPanel5.Name = "flowLayoutPanel5";
            this.flowLayoutPanel5.Size = new System.Drawing.Size(347, 26);
            this.flowLayoutPanel5.TabIndex = 16;
            // 
            // lblWeeklyEvery
            // 
            this.lblWeeklyEvery.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lblWeeklyEvery.AutoSize = true;
            this.lblWeeklyEvery.Location = new System.Drawing.Point(3, 7);
            this.lblWeeklyEvery.Name = "lblWeeklyEvery";
            this.lblWeeklyEvery.Size = new System.Drawing.Size(35, 15);
            this.lblWeeklyEvery.TabIndex = 6;
            this.lblWeeklyEvery.Text = "Every";
            // 
            // cboWeeklyDay
            // 
            this.cboWeeklyDay.FormattingEnabled = true;
            this.cboWeeklyDay.Items.AddRange(new object[] {
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
            "Sunday"});
            this.cboWeeklyDay.Location = new System.Drawing.Point(44, 3);
            this.cboWeeklyDay.Name = "cboWeeklyDay";
            this.cboWeeklyDay.Size = new System.Drawing.Size(131, 23);
            this.cboWeeklyDay.TabIndex = 0;
            // 
            // lblWeeklyAt
            // 
            this.lblWeeklyAt.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lblWeeklyAt.AutoSize = true;
            this.lblWeeklyAt.Location = new System.Drawing.Point(181, 7);
            this.lblWeeklyAt.Name = "lblWeeklyAt";
            this.lblWeeklyAt.Size = new System.Drawing.Size(17, 15);
            this.lblWeeklyAt.TabIndex = 4;
            this.lblWeeklyAt.Text = "at";
            // 
            // dtpWeeklyTime
            // 
            this.dtpWeeklyTime.Format = System.Windows.Forms.DateTimePickerFormat.Time;
            this.dtpWeeklyTime.Location = new System.Drawing.Point(204, 3);
            this.dtpWeeklyTime.Name = "dtpWeeklyTime";
            this.dtpWeeklyTime.ShowUpDown = true;
            this.dtpWeeklyTime.Size = new System.Drawing.Size(131, 23);
            this.dtpWeeklyTime.TabIndex = 5;
            // 
            // flowLayoutPanel6
            // 
            this.flowLayoutPanel6.Controls.Add(this.lblMonthlyOnDay);
            this.flowLayoutPanel6.Controls.Add(this.numMonthlyDay);
            this.flowLayoutPanel6.Controls.Add(this.lblMonthlyAt);
            this.flowLayoutPanel6.Controls.Add(this.dtpMonthlyTime);
            this.flowLayoutPanel6.Location = new System.Drawing.Point(708, 163);
            this.flowLayoutPanel6.Name = "flowLayoutPanel6";
            this.flowLayoutPanel6.Size = new System.Drawing.Size(347, 28);
            this.flowLayoutPanel6.TabIndex = 17;
            // 
            // lblMonthlyOnDay
            // 
            this.lblMonthlyOnDay.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lblMonthlyOnDay.AutoSize = true;
            this.lblMonthlyOnDay.Location = new System.Drawing.Point(3, 7);
            this.lblMonthlyOnDay.Name = "lblMonthlyOnDay";
            this.lblMonthlyOnDay.Size = new System.Drawing.Size(45, 15);
            this.lblMonthlyOnDay.TabIndex = 0;
            this.lblMonthlyOnDay.Text = "On day";
            // 
            // numMonthlyDay
            // 
            this.numMonthlyDay.Location = new System.Drawing.Point(54, 3);
            this.numMonthlyDay.Maximum = new decimal(new int[] {
            31,
            0,
            0,
            0});
            this.numMonthlyDay.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numMonthlyDay.Name = "numMonthlyDay";
            this.numMonthlyDay.Size = new System.Drawing.Size(61, 23);
            this.numMonthlyDay.TabIndex = 2;
            this.numMonthlyDay.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            // 
            // lblMonthlyAt
            // 
            this.lblMonthlyAt.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lblMonthlyAt.AutoSize = true;
            this.lblMonthlyAt.Location = new System.Drawing.Point(121, 7);
            this.lblMonthlyAt.Name = "lblMonthlyAt";
            this.lblMonthlyAt.Size = new System.Drawing.Size(17, 15);
            this.lblMonthlyAt.TabIndex = 3;
            this.lblMonthlyAt.Text = "at";
            // 
            // dtpMonthlyTime
            // 
            this.dtpMonthlyTime.Format = System.Windows.Forms.DateTimePickerFormat.Time;
            this.dtpMonthlyTime.Location = new System.Drawing.Point(144, 3);
            this.dtpMonthlyTime.Name = "dtpMonthlyTime";
            this.dtpMonthlyTime.ShowUpDown = true;
            this.dtpMonthlyTime.Size = new System.Drawing.Size(136, 23);
            this.dtpMonthlyTime.TabIndex = 1;
            // 
            // cboScheduleModem
            // 
            this.cboScheduleModem.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.cboScheduleModem.FormattingEnabled = true;
            this.cboScheduleModem.Location = new System.Drawing.Point(178, 165);
            this.cboScheduleModem.Name = "cboScheduleModem";
            this.cboScheduleModem.Size = new System.Drawing.Size(287, 23);
            this.cboScheduleModem.TabIndex = 18;
            // 
            // cboScheduleSubCategory
            // 
            this.cboScheduleSubCategory.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.cboScheduleSubCategory.FormattingEnabled = true;
            this.cboScheduleSubCategory.Location = new System.Drawing.Point(178, 100);
            this.cboScheduleSubCategory.Name = "cboScheduleSubCategory";
            this.cboScheduleSubCategory.Size = new System.Drawing.Size(287, 23);
            this.cboScheduleSubCategory.TabIndex = 7;
            // 
            // lblScheduleSubCategory
            // 
            this.lblScheduleSubCategory.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.lblScheduleSubCategory.AutoSize = true;
            this.lblScheduleSubCategory.Font = new System.Drawing.Font("Segoe UI Semibold", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblScheduleSubCategory.Location = new System.Drawing.Point(95, 105);
            this.lblScheduleSubCategory.Name = "lblScheduleSubCategory";
            this.lblScheduleSubCategory.Size = new System.Drawing.Size(77, 13);
            this.lblScheduleSubCategory.TabIndex = 2;
            this.lblScheduleSubCategory.Text = "Sub category:";
            // 
            // lblScheduleCategory
            // 
            this.lblScheduleCategory.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.lblScheduleCategory.AutoSize = true;
            this.lblScheduleCategory.Font = new System.Drawing.Font("Segoe UI Semibold", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblScheduleCategory.Location = new System.Drawing.Point(115, 73);
            this.lblScheduleCategory.Name = "lblScheduleCategory";
            this.lblScheduleCategory.Size = new System.Drawing.Size(57, 13);
            this.lblScheduleCategory.TabIndex = 1;
            this.lblScheduleCategory.Text = "Category:";
            // 
            // cboScheduleCategory
            // 
            this.cboScheduleCategory.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.cboScheduleCategory.FormattingEnabled = true;
            this.cboScheduleCategory.Items.AddRange(new object[] {
            "Appointments"});
            this.cboScheduleCategory.Location = new System.Drawing.Point(178, 68);
            this.cboScheduleCategory.Name = "cboScheduleCategory";
            this.cboScheduleCategory.Size = new System.Drawing.Size(287, 23);
            this.cboScheduleCategory.TabIndex = 6;
            this.cboScheduleCategory.SelectedIndexChanged += new System.EventHandler(this.cboScheduleCategory_SelectedIndexChanged);
            // 
            // txtScheduleName
            // 
            this.txtScheduleName.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.txtScheduleName.Location = new System.Drawing.Point(178, 36);
            this.txtScheduleName.Name = "txtScheduleName";
            this.txtScheduleName.Size = new System.Drawing.Size(287, 23);
            this.txtScheduleName.TabIndex = 5;
            // 
            // lblScheduleName
            // 
            this.lblScheduleName.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.lblScheduleName.AutoSize = true;
            this.lblScheduleName.Font = new System.Drawing.Font("Segoe UI Semibold", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblScheduleName.Location = new System.Drawing.Point(86, 41);
            this.lblScheduleName.Name = "lblScheduleName";
            this.lblScheduleName.Size = new System.Drawing.Size(86, 13);
            this.lblScheduleName.TabIndex = 0;
            this.lblScheduleName.Text = "Schedule name:";
            // 
            // lblScheduleID
            // 
            this.lblScheduleID.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.lblScheduleID.AutoSize = true;
            this.lblScheduleID.Font = new System.Drawing.Font("Segoe UI Semibold", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblScheduleID.Location = new System.Drawing.Point(103, 9);
            this.lblScheduleID.Name = "lblScheduleID";
            this.lblScheduleID.Size = new System.Drawing.Size(69, 13);
            this.lblScheduleID.TabIndex = 19;
            this.lblScheduleID.Text = "Schedule ID:";
            // 
            // txtScheduleID
            // 
            this.txtScheduleID.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.txtScheduleID.Location = new System.Drawing.Point(178, 4);
            this.txtScheduleID.Name = "txtScheduleID";
            this.txtScheduleID.ReadOnly = true;
            this.txtScheduleID.Size = new System.Drawing.Size(287, 23);
            this.txtScheduleID.TabIndex = 20;
            // 
            // flowLayoutPanel7
            // 
            this.flowLayoutPanel7.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.flowLayoutPanel7.Controls.Add(this.cmdScheduleDelete);
            this.flowLayoutPanel7.Controls.Add(this.cmdScheduleSave);
            this.flowLayoutPanel7.Controls.Add(this.cmdScheduleClear);
            this.flowLayoutPanel7.FlowDirection = System.Windows.Forms.FlowDirection.RightToLeft;
            this.flowLayoutPanel7.Location = new System.Drawing.Point(344, 205);
            this.flowLayoutPanel7.Name = "flowLayoutPanel7";
            this.flowLayoutPanel7.Size = new System.Drawing.Size(381, 34);
            this.flowLayoutPanel7.TabIndex = 1;
            // 
            // cmdScheduleDelete
            // 
            this.cmdScheduleDelete.Location = new System.Drawing.Point(256, 3);
            this.cmdScheduleDelete.Name = "cmdScheduleDelete";
            this.cmdScheduleDelete.Size = new System.Drawing.Size(122, 23);
            this.cmdScheduleDelete.TabIndex = 0;
            this.cmdScheduleDelete.Text = "Delete";
            this.cmdScheduleDelete.UseVisualStyleBackColor = true;
            this.cmdScheduleDelete.Click += new System.EventHandler(this.cmdScheduleDelete_Click);
            // 
            // cmdScheduleSave
            // 
            this.cmdScheduleSave.Location = new System.Drawing.Point(131, 3);
            this.cmdScheduleSave.Name = "cmdScheduleSave";
            this.cmdScheduleSave.Size = new System.Drawing.Size(119, 23);
            this.cmdScheduleSave.TabIndex = 1;
            this.cmdScheduleSave.Text = "Save/Update";
            this.cmdScheduleSave.UseVisualStyleBackColor = true;
            this.cmdScheduleSave.Click += new System.EventHandler(this.cmdScheduleSave_Click);
            // 
            // cmdScheduleClear
            // 
            this.cmdScheduleClear.Location = new System.Drawing.Point(19, 3);
            this.cmdScheduleClear.Name = "cmdScheduleClear";
            this.cmdScheduleClear.Size = new System.Drawing.Size(106, 23);
            this.cmdScheduleClear.TabIndex = 2;
            this.cmdScheduleClear.Text = "Clear all";
            this.cmdScheduleClear.UseVisualStyleBackColor = true;
            this.cmdScheduleClear.Click += new System.EventHandler(this.cmdScheduleClear_Click);
            // 
            // dgvSchedules
            // 
            this.dgvSchedules.AllowUserToAddRows = false;
            this.dgvSchedules.BackgroundColor = System.Drawing.Color.WhiteSmoke;
            this.dgvSchedules.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvSchedules.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvSchedules.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvSchedules.Location = new System.Drawing.Point(4, 246);
            this.dgvSchedules.Name = "dgvSchedules";
            this.dgvSchedules.ReadOnly = true;
            this.dgvSchedules.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvSchedules.Size = new System.Drawing.Size(1061, 157);
            this.dgvSchedules.TabIndex = 2;
            this.dgvSchedules.SelectionChanged += new System.EventHandler(this.dgvSchedules_SelectionChanged);
            // 
            // sqlData
            // 
            this.sqlData.Connection = null;
            // 
            // ptSQL
            // 
            this.ptSQL.DynamicIndents = false;
            this.ptSQL.DynamicRightMargin = false;
            this.ptSQL.ExpressionSubqueryFormat.MainPartsFromNewLine = false;
            // 
            // eventMetadataProvider1
            // 
            this.eventMetadataProvider1.ExecSQL += new ActiveDatabaseSoftware.ActiveQueryBuilder.ExecSQLEventHandler(this.eventMetadataProvider1_ExecSQL);
            // 
            // spcMain
            // 
            this.spcMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spcMain.FixedPanel = System.Windows.Forms.FixedPanel.Panel1;
            this.spcMain.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.spcMain.IsSplitterFixed = true;
            this.spcMain.Location = new System.Drawing.Point(0, 0);
            this.spcMain.Margin = new System.Windows.Forms.Padding(1);
            this.spcMain.Name = "spcMain";
            this.spcMain.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // spcMain.Panel1
            // 
            this.spcMain.Panel1.BackColor = System.Drawing.Color.White;
            this.spcMain.Panel1.Controls.Add(this.piclogo);
            this.spcMain.Panel1.Controls.Add(this.picMessaging);
            // 
            // spcMain.Panel2
            // 
            this.spcMain.Panel2.Controls.Add(this.tcMessaging);
            this.spcMain.Size = new System.Drawing.Size(1083, 502);
            this.spcMain.SplitterDistance = 60;
            this.spcMain.SplitterWidth = 1;
            this.spcMain.TabIndex = 4;
            // 
            // piclogo
            // 
            this.piclogo.Dock = System.Windows.Forms.DockStyle.Right;
            this.piclogo.Location = new System.Drawing.Point(947, 0);
            this.piclogo.Margin = new System.Windows.Forms.Padding(0);
            this.piclogo.Name = "piclogo";
            this.piclogo.Size = new System.Drawing.Size(136, 60);
            this.piclogo.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.piclogo.TabIndex = 3;
            this.piclogo.TabStop = false;
            // 
            // picMessaging
            // 
            this.picMessaging.BackColor = System.Drawing.Color.White;
            this.picMessaging.Dock = System.Windows.Forms.DockStyle.Left;
            this.picMessaging.Image = global::IQTools.Properties.Resources.iqtools;
            this.picMessaging.InitialImage = null;
            this.picMessaging.Location = new System.Drawing.Point(0, 0);
            this.picMessaging.Name = "picMessaging";
            this.picMessaging.Size = new System.Drawing.Size(228, 60);
            this.picMessaging.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.picMessaging.TabIndex = 1;
            this.picMessaging.TabStop = false;
            // 
            // ucMessaging
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.spcMain);
            this.Font = new System.Drawing.Font("Verdana", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Name = "ucMessaging";
            this.Size = new System.Drawing.Size(1083, 502);
            this.Load += new System.EventHandler(this.ucMessaging_Load);
            this.tcMessaging.ResumeLayout(false);
            this.tpSendSMS.ResumeLayout(false);
            this.tlpSendSMS.ResumeLayout(false);
            this.spcSendSMS.Panel1.ResumeLayout(false);
            this.spcSendSMS.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.spcSendSMS)).EndInit();
            this.spcSendSMS.ResumeLayout(false);
            this.tableLayoutPanel2.ResumeLayout(false);
            this.gbRecipients.ResumeLayout(false);
            this.gbRecipients.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvRecipients)).EndInit();
            this.gbLogs.ResumeLayout(false);
            this.gbLogs.PerformLayout();
            this.gbMessage.ResumeLayout(false);
            this.tableLayoutPanel3.ResumeLayout(false);
            this.tableLayoutPanel3.PerformLayout();
            this.gbSendUsing.ResumeLayout(false);
            this.gbSendUsing.PerformLayout();
            this.flowLayoutPanel1.ResumeLayout(false);
            this.tpSMSLogs.ResumeLayout(false);
            this.tlpSMSLogs.ResumeLayout(false);
            this.tlpSMSLogs2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvSMSLogs)).EndInit();
            this.panel5.ResumeLayout(false);
            this.panel5.PerformLayout();
            this.flowLayoutPanel8.ResumeLayout(false);
            this.tpSettings.ResumeLayout(false);
            this.tlpSMSSettings.ResumeLayout(false);
            this.tableLayoutPanel7.ResumeLayout(false);
            this.tableLayoutPanel8.ResumeLayout(false);
            this.gbCountryCode.ResumeLayout(false);
            this.gbCountryCode.PerformLayout();
            this.gbMessageSettings.ResumeLayout(false);
            this.gbMessageSettings.PerformLayout();
            this.tableLayoutPanel9.ResumeLayout(false);
            this.tableLayoutPanel10.ResumeLayout(false);
            this.tableLayoutPanel10.PerformLayout();
            this.flowLayoutPanel2.ResumeLayout(false);
            this.tableLayoutPanel11.ResumeLayout(false);
            this.tableLayoutPanel11.PerformLayout();
            this.tpScheduling.ResumeLayout(false);
            this.tableLayoutPanel15.ResumeLayout(false);
            this.tableLayoutPanel17.ResumeLayout(false);
            this.panel18.ResumeLayout(false);
            this.tableLayoutPanel18.ResumeLayout(false);
            this.tableLayoutPanel18.PerformLayout();
            this.flowLayoutPanel3.ResumeLayout(false);
            this.flowLayoutPanel3.PerformLayout();
            this.flowLayoutPanel4.ResumeLayout(false);
            this.flowLayoutPanel4.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numDaysEarlier)).EndInit();
            this.flowLayoutPanel5.ResumeLayout(false);
            this.flowLayoutPanel5.PerformLayout();
            this.flowLayoutPanel6.ResumeLayout(false);
            this.flowLayoutPanel6.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numMonthlyDay)).EndInit();
            this.flowLayoutPanel7.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvSchedules)).EndInit();
            this.spcMain.Panel1.ResumeLayout(false);
            this.spcMain.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.spcMain)).EndInit();
            this.spcMain.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.piclogo)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picMessaging)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TabControl tcMessaging;
        private System.Windows.Forms.TabPage tpSendSMS;
        private System.Windows.Forms.TableLayoutPanel tlpSendSMS;
        private System.Windows.Forms.SplitContainer spcSendSMS;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel2;
        private System.Windows.Forms.GroupBox gbRecipients;
        private System.Windows.Forms.Button cmdImportFromXL;
        private System.Windows.Forms.ComboBox cboCategory;
        private System.Windows.Forms.Label lblOR;
        private System.Windows.Forms.ComboBox cboSubCategory;
        private System.Windows.Forms.Label lblCategory;
        private System.Windows.Forms.Label lblSubCategory;
        private System.Windows.Forms.DataGridView dgvRecipients;
        private System.Windows.Forms.GroupBox gbLogs;
        private System.Windows.Forms.TextBox txtLogs;
        private System.Windows.Forms.GroupBox gbMessage;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel3;
        private System.Windows.Forms.ListBox lbLanguages;
        private System.Windows.Forms.TextBox txtMessageToSend;
        private System.Windows.Forms.GroupBox gbSendUsing;
        private System.Windows.Forms.Label lblConnectionStatus;
        private System.Windows.Forms.Label lblStatus;
        private System.Windows.Forms.Button cmdLoadModem;
        private System.Windows.Forms.ComboBox cboModemWebService;
        private System.Windows.Forms.RadioButton rbSendUsingWebServ;
        private System.Windows.Forms.RadioButton rbSendUsingModem;
        private System.Windows.Forms.TabPage tpSMSLogs;
        private System.Windows.Forms.TableLayoutPanel tlpSMSLogs;
        private System.Windows.Forms.TableLayoutPanel tlpSMSLogs2;
        private System.Windows.Forms.DataGridView dgvSMSLogs;
        private System.Windows.Forms.Panel panel5;
        private System.Windows.Forms.Button cmdRetrieve;
        private System.Windows.Forms.RadioButton rbInbox;
        private System.Windows.Forms.RadioButton rbFailedMessages;
        private System.Windows.Forms.RadioButton rbSentMessages;
        private System.Windows.Forms.Label lblSMSLogsEndDate;
        private System.Windows.Forms.Label lblSMSLogsStartDate;
        private System.Windows.Forms.DateTimePicker dtpSMSLogsEndDate;
        private System.Windows.Forms.DateTimePicker dtpSMSLogsStartDate;
        private System.Windows.Forms.Button cmdResendFailedMsgs;
        private System.Windows.Forms.TabPage tpSettings;
        private System.Windows.Forms.TableLayoutPanel tlpSMSSettings;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel7;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel8;
        private System.Windows.Forms.GroupBox gbCountryCode;
        private System.Windows.Forms.Label label20;
        private System.Windows.Forms.ComboBox cboCountryCode;
        private System.Windows.Forms.TextBox txtCountryCode;
        private System.Windows.Forms.Button cmdSaveCountryCode;
        private System.Windows.Forms.Label lblCountryCode;
        private System.Windows.Forms.GroupBox gbMessageSettings;
        private System.Windows.Forms.ListBox lbSettingsSubCategory;
        private System.Windows.Forms.ComboBox cboSettingsCategory;
        private System.Windows.Forms.Label lblMessageCat;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel9;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel10;
        private System.Windows.Forms.Label lblSettingsLanguage;
        private System.Windows.Forms.Label lblSettingsMessage;
        private System.Windows.Forms.ComboBox cboSettingslanguage;
        private System.Windows.Forms.TextBox txtSettingsMessage;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel2;
        private System.Windows.Forms.Button cmdSettingsSave;
        private System.Windows.Forms.Button cmdSettingsDelete;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel11;
        private System.Windows.Forms.Label lblSMSDescription;
        private System.Windows.Forms.TabPage tpScheduling;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel15;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel17;
        private System.Windows.Forms.Panel panel18;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel18;
        private System.Windows.Forms.Label lblScheduleName;
        private System.Windows.Forms.Label lblScheduleSendUsing;
        private System.Windows.Forms.Label lblScheduleCategory;
        private System.Windows.Forms.Label lblScheduleSubCategory;
        private System.Windows.Forms.TextBox txtScheduleName;
        private System.Windows.Forms.ComboBox cboScheduleCategory;
        private System.Windows.Forms.ComboBox cboScheduleSubCategory;
        private System.Windows.Forms.RadioButton rbScheduleDaily;
        private System.Windows.Forms.RadioButton rbScheduleWeekly;
        private System.Windows.Forms.RadioButton rbScheduleMonthly;
        private System.Windows.Forms.Label lblScheduleType;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel3;
        private System.Windows.Forms.RadioButton rbScheduleModem;
        private System.Windows.Forms.RadioButton rbScheduleWebService;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel4;
        private System.Windows.Forms.NumericUpDown numDaysEarlier;
        private System.Windows.Forms.Label lblDaysEarlier;
        private System.Windows.Forms.DateTimePicker dtpDailyTime;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel5;
        private System.Windows.Forms.Label lblWeeklyEvery;
        private System.Windows.Forms.ComboBox cboWeeklyDay;
        private System.Windows.Forms.Label lblWeeklyAt;
        private System.Windows.Forms.DateTimePicker dtpWeeklyTime;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel6;
        private System.Windows.Forms.Label lblMonthlyOnDay;
        private System.Windows.Forms.NumericUpDown numMonthlyDay;
        private System.Windows.Forms.Label lblMonthlyAt;
        private System.Windows.Forms.DateTimePicker dtpMonthlyTime;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel7;
        private System.Windows.Forms.Button cmdScheduleDelete;
        private System.Windows.Forms.Button cmdScheduleSave;
        private System.Windows.Forms.DataGridView dgvSchedules;
        protected ActiveDatabaseSoftware.ActiveQueryBuilder.MSSQLMetadataProvider sqlData;
        private ActiveDatabaseSoftware.ActiveQueryBuilder.MSSQLSyntaxProvider sqlSyntax;
        private ActiveDatabaseSoftware.ActiveQueryBuilder.PlainTextSQLBuilder ptSQL;
        private ActiveDatabaseSoftware.ActiveQueryBuilder.EventMetadataProvider eventMetadataProvider1;
        private System.Windows.Forms.Label txtNoOfRecords;
        private ActiveDatabaseSoftware.ExpressionEditor.SqlTextEditor txtSQL;
        private ActiveDatabaseSoftware.ActiveQueryBuilder.QueryBuilder QBQTool;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel8;
        private System.Windows.Forms.Button CmdClearLogs;
        private System.Windows.Forms.ComboBox cboScheduleModem;
        private System.Windows.Forms.Label lblScheduleID;
        private System.Windows.Forms.TextBox txtScheduleID;
        private System.Windows.Forms.Button cmdScheduleClear;
        private System.Windows.Forms.SplitContainer spcMain;
        private System.Windows.Forms.PictureBox picMessaging;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
        private System.Windows.Forms.Button cmdSend;
        private System.Windows.Forms.Button cmdClearAll;
        private System.Windows.Forms.PictureBox piclogo;
    }
}
