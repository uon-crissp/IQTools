using System.Windows.Forms;
namespace IQTools
{
  partial class frmMain
  {
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose ( bool disposing )
    {
      if (disposing && (components != null))
      {

        components.Dispose ( );

      }
      base.Dispose ( disposing );
    }

    #region Windows Form Designer generated code

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent ( )
    {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmMain));
            this.tpHelp = new System.Windows.Forms.TabPage();
            this.spcHelp = new System.Windows.Forms.SplitContainer();
            this.pictureBox2 = new System.Windows.Forms.PictureBox();
            this.picHelp = new System.Windows.Forms.PictureBox();
            this.spcHelpTab = new System.Windows.Forms.SplitContainer();
            this.lstDocuments = new System.Windows.Forms.ListBox();
            this.webHelp = new System.Windows.Forms.WebBrowser();
            this.pnlVersionLabels = new System.Windows.Forms.Panel();
            this.lblAppVersion = new System.Windows.Forms.Label();
            this.txtVersion = new System.Windows.Forms.TextBox();
            this.lblDBVersion = new System.Windows.Forms.Label();
            this.txtDate = new System.Windows.Forms.TextBox();
            this.ofdUtility = new System.Windows.Forms.OpenFileDialog();
            this.tpSMS = new System.Windows.Forms.TabPage();
            this.tpQueries = new System.Windows.Forms.TabPage();
            this.tpReports = new System.Windows.Forms.TabPage();
            this.spcHome = new System.Windows.Forms.SplitContainer();
            this.lblLTFUApplicable = new System.Windows.Forms.Label();
            this.piclogo = new System.Windows.Forms.PictureBox();
            this.picHome = new System.Windows.Forms.PictureBox();
            this.spcHomeTab1 = new System.Windows.Forms.SplitContainer();
            this.pnlHome = new System.Windows.Forms.Panel();
            this.gbART = new System.Windows.Forms.GroupBox();
            this.lblLowVL = new System.Windows.Forms.Label();
            this.txtLowVL = new System.Windows.Forms.TextBox();
            this.optVLDetect = new System.Windows.Forms.RadioButton();
            this.optVL = new System.Windows.Forms.RadioButton();
            this.TxtMA = new System.Windows.Forms.TextBox();
            this.lblMA = new System.Windows.Forms.Label();
            this.OptMA = new System.Windows.Forms.RadioButton();
            this.optART = new System.Windows.Forms.RadioButton();
            this.optNoARTNoCD4 = new System.Windows.Forms.RadioButton();
            this.dtpAllApp = new System.Windows.Forms.DateTimePicker();
            this.optAllApp = new System.Windows.Forms.RadioButton();
            this.label84 = new System.Windows.Forms.Label();
            this.dtpMAP = new System.Windows.Forms.DateTimePicker();
            this.optMAP = new System.Windows.Forms.RadioButton();
            this.cmdART = new System.Windows.Forms.Button();
            this.dgvAdherence = new System.Windows.Forms.DataGridView();
            this.tcMain = new System.Windows.Forms.TabControl();
            this.tpStandardQueries = new System.Windows.Forms.TabPage();
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.label1 = new System.Windows.Forms.Label();
            this.cboQuery = new System.Windows.Forms.ComboBox();
            this.lblFrom = new System.Windows.Forms.Label();
            this.dtpFrom = new System.Windows.Forms.DateTimePicker();
            this.lblTo = new System.Windows.Forms.Label();
            this.dtpTo = new System.Windows.Forms.DateTimePicker();
            this.cmdLoadReport = new System.Windows.Forms.Button();
            this.flowLayoutPanel2 = new System.Windows.Forms.FlowLayoutPanel();
            this.cmdExportToExcel = new System.Windows.Forms.Button();
            this.dgvQryData = new System.Windows.Forms.DataGridView();
            this.pictureBox4 = new System.Windows.Forms.PictureBox();
            this.tpNewReports = new System.Windows.Forms.TabPage();
            this.tpEMRAccess = new System.Windows.Forms.TabPage();
            this.tpForum = new System.Windows.Forms.TabPage();
            this.panel59 = new System.Windows.Forms.Panel();
            this.fbd = new System.Windows.Forms.FolderBrowserDialog();
            this.cboMainLanguage = new System.Windows.Forms.ComboBox();
            this.label148 = new System.Windows.Forms.Label();
            this.spcMain = new System.Windows.Forms.SplitContainer();
            this.lblNotify = new System.Windows.Forms.Label();
            this.picProgress = new System.Windows.Forms.PictureBox();
            this.pictureBox31 = new System.Windows.Forms.PictureBox();
            this.tpHelp.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.spcHelp)).BeginInit();
            this.spcHelp.Panel1.SuspendLayout();
            this.spcHelp.Panel2.SuspendLayout();
            this.spcHelp.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picHelp)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.spcHelpTab)).BeginInit();
            this.spcHelpTab.Panel1.SuspendLayout();
            this.spcHelpTab.Panel2.SuspendLayout();
            this.spcHelpTab.SuspendLayout();
            this.pnlVersionLabels.SuspendLayout();
            this.tpReports.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.spcHome)).BeginInit();
            this.spcHome.Panel1.SuspendLayout();
            this.spcHome.Panel2.SuspendLayout();
            this.spcHome.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.piclogo)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picHome)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.spcHomeTab1)).BeginInit();
            this.spcHomeTab1.Panel1.SuspendLayout();
            this.spcHomeTab1.Panel2.SuspendLayout();
            this.spcHomeTab1.SuspendLayout();
            this.pnlHome.SuspendLayout();
            this.gbART.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvAdherence)).BeginInit();
            this.tcMain.SuspendLayout();
            this.tpStandardQueries.SuspendLayout();
            this.tableLayoutPanel1.SuspendLayout();
            this.flowLayoutPanel1.SuspendLayout();
            this.flowLayoutPanel2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvQryData)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox4)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.spcMain)).BeginInit();
            this.spcMain.Panel1.SuspendLayout();
            this.spcMain.Panel2.SuspendLayout();
            this.spcMain.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picProgress)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox31)).BeginInit();
            this.SuspendLayout();
            // 
            // tpHelp
            // 
            this.tpHelp.BackColor = System.Drawing.Color.WhiteSmoke;
            this.tpHelp.Controls.Add(this.spcHelp);
            this.tpHelp.Location = new System.Drawing.Point(4, 24);
            this.tpHelp.Margin = new System.Windows.Forms.Padding(0);
            this.tpHelp.Name = "tpHelp";
            this.tpHelp.Size = new System.Drawing.Size(1256, 620);
            this.tpHelp.TabIndex = 7;
            this.tpHelp.Text = "Help";
            // 
            // spcHelp
            // 
            this.spcHelp.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spcHelp.FixedPanel = System.Windows.Forms.FixedPanel.Panel1;
            this.spcHelp.IsSplitterFixed = true;
            this.spcHelp.Location = new System.Drawing.Point(0, 0);
            this.spcHelp.Name = "spcHelp";
            this.spcHelp.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // spcHelp.Panel1
            // 
            this.spcHelp.Panel1.BackColor = System.Drawing.Color.White;
            this.spcHelp.Panel1.Controls.Add(this.pictureBox2);
            this.spcHelp.Panel1.Controls.Add(this.picHelp);
            // 
            // spcHelp.Panel2
            // 
            this.spcHelp.Panel2.Controls.Add(this.spcHelpTab);
            this.spcHelp.Size = new System.Drawing.Size(1256, 620);
            this.spcHelp.SplitterDistance = 60;
            this.spcHelp.SplitterWidth = 1;
            this.spcHelp.TabIndex = 5;
            // 
            // pictureBox2
            // 
            this.pictureBox2.Dock = System.Windows.Forms.DockStyle.Right;
            this.pictureBox2.Location = new System.Drawing.Point(1120, 0);
            this.pictureBox2.Margin = new System.Windows.Forms.Padding(0);
            this.pictureBox2.Name = "pictureBox2";
            this.pictureBox2.Size = new System.Drawing.Size(136, 60);
            this.pictureBox2.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBox2.TabIndex = 3;
            this.pictureBox2.TabStop = false;
            // 
            // picHelp
            // 
            this.picHelp.BackColor = System.Drawing.Color.White;
            this.picHelp.Dock = System.Windows.Forms.DockStyle.Left;
            this.picHelp.Image = global::IQTools.Properties.Resources.iqtools;
            this.picHelp.InitialImage = null;
            this.picHelp.Location = new System.Drawing.Point(0, 0);
            this.picHelp.Margin = new System.Windows.Forms.Padding(0);
            this.picHelp.Name = "picHelp";
            this.picHelp.Size = new System.Drawing.Size(228, 60);
            this.picHelp.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.picHelp.TabIndex = 2;
            this.picHelp.TabStop = false;
            // 
            // spcHelpTab
            // 
            this.spcHelpTab.BackColor = System.Drawing.Color.Transparent;
            this.spcHelpTab.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spcHelpTab.FixedPanel = System.Windows.Forms.FixedPanel.Panel1;
            this.spcHelpTab.IsSplitterFixed = true;
            this.spcHelpTab.Location = new System.Drawing.Point(0, 0);
            this.spcHelpTab.Margin = new System.Windows.Forms.Padding(0);
            this.spcHelpTab.Name = "spcHelpTab";
            // 
            // spcHelpTab.Panel1
            // 
            this.spcHelpTab.Panel1.Controls.Add(this.lstDocuments);
            this.spcHelpTab.Panel1.Padding = new System.Windows.Forms.Padding(5);
            // 
            // spcHelpTab.Panel2
            // 
            this.spcHelpTab.Panel2.Controls.Add(this.webHelp);
            this.spcHelpTab.Panel2.Padding = new System.Windows.Forms.Padding(5);
            this.spcHelpTab.Size = new System.Drawing.Size(1256, 559);
            this.spcHelpTab.SplitterDistance = 239;
            this.spcHelpTab.SplitterWidth = 1;
            this.spcHelpTab.TabIndex = 4;
            // 
            // lstDocuments
            // 
            this.lstDocuments.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.lstDocuments.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.lstDocuments.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lstDocuments.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lstDocuments.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.lstDocuments.FormattingEnabled = true;
            this.lstDocuments.ItemHeight = 17;
            this.lstDocuments.Items.AddRange(new object[] {
            "Query Guide"});
            this.lstDocuments.Location = new System.Drawing.Point(5, 5);
            this.lstDocuments.Name = "lstDocuments";
            this.lstDocuments.Size = new System.Drawing.Size(229, 549);
            this.lstDocuments.TabIndex = 1;
            this.lstDocuments.SelectedIndexChanged += new System.EventHandler(this.lstDocuments_SelectedIndexChanged);
            // 
            // webHelp
            // 
            this.webHelp.Dock = System.Windows.Forms.DockStyle.Fill;
            this.webHelp.Location = new System.Drawing.Point(5, 5);
            this.webHelp.Margin = new System.Windows.Forms.Padding(0);
            this.webHelp.MinimumSize = new System.Drawing.Size(20, 20);
            this.webHelp.Name = "webHelp";
            this.webHelp.Size = new System.Drawing.Size(1006, 549);
            this.webHelp.TabIndex = 0;
            this.webHelp.Url = new System.Uri("", System.UriKind.Relative);
            // 
            // pnlVersionLabels
            // 
            this.pnlVersionLabels.BackColor = System.Drawing.Color.Transparent;
            this.pnlVersionLabels.Controls.Add(this.lblAppVersion);
            this.pnlVersionLabels.Controls.Add(this.txtVersion);
            this.pnlVersionLabels.Controls.Add(this.lblDBVersion);
            this.pnlVersionLabels.Controls.Add(this.txtDate);
            this.pnlVersionLabels.Dock = System.Windows.Forms.DockStyle.Right;
            this.pnlVersionLabels.Location = new System.Drawing.Point(980, 0);
            this.pnlVersionLabels.Name = "pnlVersionLabels";
            this.pnlVersionLabels.Padding = new System.Windows.Forms.Padding(0, 10, 0, 0);
            this.pnlVersionLabels.Size = new System.Drawing.Size(284, 32);
            this.pnlVersionLabels.TabIndex = 7;
            // 
            // lblAppVersion
            // 
            this.lblAppVersion.AutoSize = true;
            this.lblAppVersion.BackColor = System.Drawing.Color.Transparent;
            this.lblAppVersion.Font = new System.Drawing.Font("Calibri", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblAppVersion.ForeColor = System.Drawing.Color.White;
            this.lblAppVersion.Location = new System.Drawing.Point(3, 10);
            this.lblAppVersion.Name = "lblAppVersion";
            this.lblAppVersion.Size = new System.Drawing.Size(81, 13);
            this.lblAppVersion.TabIndex = 7;
            this.lblAppVersion.Text = "IQTools Version:";
            this.lblAppVersion.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // txtVersion
            // 
            this.txtVersion.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(45)))), ((int)(((byte)(137)))), ((int)(((byte)(239)))));
            this.txtVersion.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.txtVersion.Font = new System.Drawing.Font("Calibri", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtVersion.ForeColor = System.Drawing.Color.White;
            this.txtVersion.Location = new System.Drawing.Point(85, 10);
            this.txtVersion.Name = "txtVersion";
            this.txtVersion.Size = new System.Drawing.Size(50, 14);
            this.txtVersion.TabIndex = 8;
            this.txtVersion.Text = "AppVersion";
            // 
            // lblDBVersion
            // 
            this.lblDBVersion.AutoSize = true;
            this.lblDBVersion.BackColor = System.Drawing.Color.Transparent;
            this.lblDBVersion.Font = new System.Drawing.Font("Calibri", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblDBVersion.ForeColor = System.Drawing.Color.White;
            this.lblDBVersion.Location = new System.Drawing.Point(141, 10);
            this.lblDBVersion.Name = "lblDBVersion";
            this.lblDBVersion.Size = new System.Drawing.Size(93, 13);
            this.lblDBVersion.TabIndex = 5;
            this.lblDBVersion.Text = "Database Version:";
            this.lblDBVersion.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // txtDate
            // 
            this.txtDate.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(45)))), ((int)(((byte)(137)))), ((int)(((byte)(239)))));
            this.txtDate.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.txtDate.Font = new System.Drawing.Font("Calibri", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtDate.ForeColor = System.Drawing.Color.White;
            this.txtDate.Location = new System.Drawing.Point(234, 10);
            this.txtDate.Name = "txtDate";
            this.txtDate.Size = new System.Drawing.Size(50, 14);
            this.txtDate.TabIndex = 6;
            this.txtDate.Text = "DBVersion";
            this.txtDate.DoubleClick += new System.EventHandler(this.txtDate_DoubleClick);
            // 
            // ofdUtility
            // 
            this.ofdUtility.FileName = "IQTools.Bak";
            this.ofdUtility.Filter = "\"SQL Backup|*.Bak|Access Files|*.mdb|All Files|*.*\"";
            this.ofdUtility.InitialDirectory = "\\\\Database";
            // 
            // tpSMS
            // 
            this.tpSMS.BackColor = System.Drawing.Color.Transparent;
            this.tpSMS.Location = new System.Drawing.Point(4, 24);
            this.tpSMS.Margin = new System.Windows.Forms.Padding(0);
            this.tpSMS.Name = "tpSMS";
            this.tpSMS.Size = new System.Drawing.Size(1256, 620);
            this.tpSMS.TabIndex = 5;
            this.tpSMS.Text = "Messaging";
            this.tpSMS.UseVisualStyleBackColor = true;
            // 
            // tpQueries
            // 
            this.tpQueries.Location = new System.Drawing.Point(4, 24);
            this.tpQueries.Margin = new System.Windows.Forms.Padding(0);
            this.tpQueries.Name = "tpQueries";
            this.tpQueries.Size = new System.Drawing.Size(1256, 620);
            this.tpQueries.TabIndex = 4;
            this.tpQueries.Text = "Query Builder";
            this.tpQueries.UseVisualStyleBackColor = true;
            // 
            // tpReports
            // 
            this.tpReports.BackColor = System.Drawing.Color.Transparent;
            this.tpReports.Controls.Add(this.spcHome);
            this.tpReports.Location = new System.Drawing.Point(4, 24);
            this.tpReports.Margin = new System.Windows.Forms.Padding(0);
            this.tpReports.Name = "tpReports";
            this.tpReports.Size = new System.Drawing.Size(1256, 620);
            this.tpReports.TabIndex = 2;
            this.tpReports.Text = "Home";
            // 
            // spcHome
            // 
            this.spcHome.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spcHome.FixedPanel = System.Windows.Forms.FixedPanel.Panel1;
            this.spcHome.IsSplitterFixed = true;
            this.spcHome.Location = new System.Drawing.Point(0, 0);
            this.spcHome.Margin = new System.Windows.Forms.Padding(0);
            this.spcHome.Name = "spcHome";
            this.spcHome.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // spcHome.Panel1
            // 
            this.spcHome.Panel1.BackColor = System.Drawing.Color.White;
            this.spcHome.Panel1.Controls.Add(this.lblLTFUApplicable);
            this.spcHome.Panel1.Controls.Add(this.piclogo);
            this.spcHome.Panel1.Controls.Add(this.picHome);
            // 
            // spcHome.Panel2
            // 
            this.spcHome.Panel2.BackColor = System.Drawing.Color.WhiteSmoke;
            this.spcHome.Panel2.Controls.Add(this.spcHomeTab1);
            this.spcHome.Size = new System.Drawing.Size(1256, 620);
            this.spcHome.SplitterDistance = 60;
            this.spcHome.SplitterWidth = 1;
            this.spcHome.TabIndex = 7;
            // 
            // lblLTFUApplicable
            // 
            this.lblLTFUApplicable.AutoSize = true;
            this.lblLTFUApplicable.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblLTFUApplicable.ForeColor = System.Drawing.Color.Red;
            this.lblLTFUApplicable.Location = new System.Drawing.Point(325, 32);
            this.lblLTFUApplicable.Name = "lblLTFUApplicable";
            this.lblLTFUApplicable.Size = new System.Drawing.Size(45, 17);
            this.lblLTFUApplicable.TabIndex = 3;
            this.lblLTFUApplicable.Text = "label1";
            // 
            // piclogo
            // 
            this.piclogo.Dock = System.Windows.Forms.DockStyle.Right;
            this.piclogo.Location = new System.Drawing.Point(1120, 0);
            this.piclogo.Margin = new System.Windows.Forms.Padding(0);
            this.piclogo.Name = "piclogo";
            this.piclogo.Size = new System.Drawing.Size(136, 60);
            this.piclogo.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.piclogo.TabIndex = 2;
            this.piclogo.TabStop = false;
            // 
            // picHome
            // 
            this.picHome.BackColor = System.Drawing.Color.White;
            this.picHome.Dock = System.Windows.Forms.DockStyle.Left;
            this.picHome.Image = global::IQTools.Properties.Resources.iqtools;
            this.picHome.InitialImage = null;
            this.picHome.Location = new System.Drawing.Point(0, 0);
            this.picHome.Margin = new System.Windows.Forms.Padding(0);
            this.picHome.Name = "picHome";
            this.picHome.Size = new System.Drawing.Size(228, 60);
            this.picHome.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.picHome.TabIndex = 1;
            this.picHome.TabStop = false;
            // 
            // spcHomeTab1
            // 
            this.spcHomeTab1.BackColor = System.Drawing.Color.WhiteSmoke;
            this.spcHomeTab1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spcHomeTab1.FixedPanel = System.Windows.Forms.FixedPanel.Panel1;
            this.spcHomeTab1.IsSplitterFixed = true;
            this.spcHomeTab1.Location = new System.Drawing.Point(0, 0);
            this.spcHomeTab1.Margin = new System.Windows.Forms.Padding(0);
            this.spcHomeTab1.Name = "spcHomeTab1";
            // 
            // spcHomeTab1.Panel1
            // 
            this.spcHomeTab1.Panel1.AutoScroll = true;
            this.spcHomeTab1.Panel1.BackColor = System.Drawing.Color.WhiteSmoke;
            this.spcHomeTab1.Panel1.Controls.Add(this.pnlHome);
            // 
            // spcHomeTab1.Panel2
            // 
            this.spcHomeTab1.Panel2.Controls.Add(this.dgvAdherence);
            this.spcHomeTab1.Size = new System.Drawing.Size(1256, 559);
            this.spcHomeTab1.SplitterDistance = 285;
            this.spcHomeTab1.SplitterWidth = 1;
            this.spcHomeTab1.TabIndex = 4;
            // 
            // pnlHome
            // 
            this.pnlHome.AutoScroll = true;
            this.pnlHome.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.pnlHome.Controls.Add(this.gbART);
            this.pnlHome.Controls.Add(this.cmdART);
            this.pnlHome.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlHome.Location = new System.Drawing.Point(0, 0);
            this.pnlHome.Margin = new System.Windows.Forms.Padding(0);
            this.pnlHome.Name = "pnlHome";
            this.pnlHome.Padding = new System.Windows.Forms.Padding(5);
            this.pnlHome.Size = new System.Drawing.Size(285, 559);
            this.pnlHome.TabIndex = 0;
            // 
            // gbART
            // 
            this.gbART.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.gbART.Controls.Add(this.lblLowVL);
            this.gbART.Controls.Add(this.txtLowVL);
            this.gbART.Controls.Add(this.optVLDetect);
            this.gbART.Controls.Add(this.optVL);
            this.gbART.Controls.Add(this.TxtMA);
            this.gbART.Controls.Add(this.lblMA);
            this.gbART.Controls.Add(this.OptMA);
            this.gbART.Controls.Add(this.optART);
            this.gbART.Controls.Add(this.optNoARTNoCD4);
            this.gbART.Controls.Add(this.dtpAllApp);
            this.gbART.Controls.Add(this.optAllApp);
            this.gbART.Controls.Add(this.label84);
            this.gbART.Controls.Add(this.dtpMAP);
            this.gbART.Controls.Add(this.optMAP);
            this.gbART.Dock = System.Windows.Forms.DockStyle.Top;
            this.gbART.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.gbART.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.gbART.Location = new System.Drawing.Point(5, 36);
            this.gbART.Margin = new System.Windows.Forms.Padding(0);
            this.gbART.Name = "gbART";
            this.gbART.Padding = new System.Windows.Forms.Padding(0);
            this.gbART.Size = new System.Drawing.Size(275, 490);
            this.gbART.TabIndex = 0;
            this.gbART.TabStop = false;
            this.gbART.Enter += new System.EventHandler(this.gbART_Enter);
            // 
            // lblLowVL
            // 
            this.lblLowVL.AutoSize = true;
            this.lblLowVL.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblLowVL.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.lblLowVL.Location = new System.Drawing.Point(69, 326);
            this.lblLowVL.Name = "lblLowVL";
            this.lblLowVL.Size = new System.Drawing.Size(43, 13);
            this.lblLowVL.TabIndex = 23;
            this.lblLowVL.Text = "Low VL:";
            // 
            // txtLowVL
            // 
            this.txtLowVL.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.txtLowVL.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtLowVL.Location = new System.Drawing.Point(119, 323);
            this.txtLowVL.Name = "txtLowVL";
            this.txtLowVL.Size = new System.Drawing.Size(79, 23);
            this.txtLowVL.TabIndex = 22;
            this.txtLowVL.Text = "1000";
            // 
            // optVLDetect
            // 
            this.optVLDetect.AutoSize = true;
            this.optVLDetect.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.optVLDetect.Location = new System.Drawing.Point(7, 300);
            this.optVLDetect.Name = "optVLDetect";
            this.optVLDetect.Size = new System.Drawing.Size(168, 17);
            this.optVLDetect.TabIndex = 21;
            this.optVLDetect.TabStop = true;
            this.optVLDetect.Text = "Detectable Viral Load above";
            this.optVLDetect.UseVisualStyleBackColor = true;
            // 
            // optVL
            // 
            this.optVL.AutoSize = true;
            this.optVL.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.optVL.Location = new System.Drawing.Point(7, 266);
            this.optVL.Name = "optVL";
            this.optVL.Size = new System.Drawing.Size(152, 17);
            this.optVL.TabIndex = 20;
            this.optVL.TabStop = true;
            this.optVL.Text = "Due For a Viral Load Test";
            this.optVL.UseVisualStyleBackColor = true;
            // 
            // TxtMA
            // 
            this.TxtMA.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TxtMA.Location = new System.Drawing.Point(151, 114);
            this.TxtMA.Name = "TxtMA";
            this.TxtMA.Size = new System.Drawing.Size(47, 23);
            this.TxtMA.TabIndex = 19;
            // 
            // lblMA
            // 
            this.lblMA.AutoSize = true;
            this.lblMA.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblMA.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.lblMA.Location = new System.Drawing.Point(77, 118);
            this.lblMA.Name = "lblMA";
            this.lblMA.Size = new System.Drawing.Size(54, 13);
            this.lblMA.TabIndex = 18;
            this.lblMA.Text = "# of Days:";
            this.lblMA.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // OptMA
            // 
            this.OptMA.AutoSize = true;
            this.OptMA.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.OptMA.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.OptMA.Location = new System.Drawing.Point(6, 137);
            this.OptMA.Name = "OptMA";
            this.OptMA.Size = new System.Drawing.Size(163, 17);
            this.OptMA.TabIndex = 17;
            this.OptMA.Text = "Missed Appointments (ALL)";
            this.OptMA.UseVisualStyleBackColor = true;
            this.OptMA.CheckedChanged += new System.EventHandler(this.OptMA_CheckedChanged);
            // 
            // optART
            // 
            this.optART.AutoSize = true;
            this.optART.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.optART.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.optART.Location = new System.Drawing.Point(6, 22);
            this.optART.Name = "optART";
            this.optART.Size = new System.Drawing.Size(85, 17);
            this.optART.TabIndex = 16;
            this.optART.Text = "All Patients ";
            this.optART.UseVisualStyleBackColor = true;
            // 
            // optNoARTNoCD4
            // 
            this.optNoARTNoCD4.AutoSize = true;
            this.optNoARTNoCD4.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.optNoARTNoCD4.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.optNoARTNoCD4.Location = new System.Drawing.Point(6, 225);
            this.optNoARTNoCD4.Name = "optNoARTNoCD4";
            this.optNoARTNoCD4.Size = new System.Drawing.Size(178, 17);
            this.optNoARTNoCD4.TabIndex = 9;
            this.optNoARTNoCD4.Text = "Not on ART and no CD4 done";
            this.optNoARTNoCD4.UseVisualStyleBackColor = true;
            // 
            // dtpAllApp
            // 
            this.dtpAllApp.CustomFormat = "yyyy-MM-dd";
            this.dtpAllApp.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dtpAllApp.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpAllApp.Location = new System.Drawing.Point(69, 196);
            this.dtpAllApp.Name = "dtpAllApp";
            this.dtpAllApp.ShowCheckBox = true;
            this.dtpAllApp.Size = new System.Drawing.Size(129, 23);
            this.dtpAllApp.TabIndex = 6;
            // 
            // optAllApp
            // 
            this.optAllApp.AutoSize = true;
            this.optAllApp.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.optAllApp.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.optAllApp.Location = new System.Drawing.Point(6, 170);
            this.optAllApp.Name = "optAllApp";
            this.optAllApp.Size = new System.Drawing.Size(156, 17);
            this.optAllApp.TabIndex = 5;
            this.optAllApp.Text = "View all appointment for:";
            this.optAllApp.UseVisualStyleBackColor = true;
            // 
            // label84
            // 
            this.label84.AutoSize = true;
            this.label84.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label84.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.label84.Location = new System.Drawing.Point(27, 88);
            this.label84.Name = "label84";
            this.label84.Size = new System.Drawing.Size(33, 13);
            this.label84.TabIndex = 3;
            this.label84.Text = "As at:";
            // 
            // dtpMAP
            // 
            this.dtpMAP.CustomFormat = "yyyy-MM-dd";
            this.dtpMAP.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dtpMAP.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpMAP.Location = new System.Drawing.Point(69, 86);
            this.dtpMAP.Name = "dtpMAP";
            this.dtpMAP.ShowCheckBox = true;
            this.dtpMAP.Size = new System.Drawing.Size(129, 23);
            this.dtpMAP.TabIndex = 2;
            // 
            // optMAP
            // 
            this.optMAP.AutoSize = true;
            this.optMAP.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.optMAP.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.optMAP.Location = new System.Drawing.Point(6, 58);
            this.optMAP.Name = "optMAP";
            this.optMAP.Size = new System.Drawing.Size(166, 17);
            this.optMAP.TabIndex = 1;
            this.optMAP.Text = "Missed ARV Pickup Analysis";
            this.optMAP.UseVisualStyleBackColor = true;
            this.optMAP.CheckedChanged += new System.EventHandler(this.optMAP_CheckedChanged);
            // 
            // cmdART
            // 
            this.cmdART.BackColor = System.Drawing.Color.WhiteSmoke;
            this.cmdART.Dock = System.Windows.Forms.DockStyle.Top;
            this.cmdART.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(45)))), ((int)(((byte)(137)))), ((int)(((byte)(239)))));
            this.cmdART.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(45)))), ((int)(((byte)(137)))), ((int)(((byte)(239)))));
            this.cmdART.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.cmdART.Location = new System.Drawing.Point(5, 5);
            this.cmdART.Name = "cmdART";
            this.cmdART.Size = new System.Drawing.Size(275, 31);
            this.cmdART.TabIndex = 0;
            this.cmdART.Text = "View the report";
            this.cmdART.UseVisualStyleBackColor = true;
            this.cmdART.Click += new System.EventHandler(this.cmdART_Click);
            // 
            // dgvAdherence
            // 
            this.dgvAdherence.AllowUserToAddRows = false;
            this.dgvAdherence.AllowUserToDeleteRows = false;
            this.dgvAdherence.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.dgvAdherence.BackgroundColor = System.Drawing.Color.WhiteSmoke;
            this.dgvAdherence.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvAdherence.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
            this.dgvAdherence.ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode.EnableAlwaysIncludeHeaderText;
            this.dgvAdherence.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            this.dgvAdherence.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvAdherence.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvAdherence.Location = new System.Drawing.Point(0, 0);
            this.dgvAdherence.Margin = new System.Windows.Forms.Padding(0);
            this.dgvAdherence.Name = "dgvAdherence";
            this.dgvAdherence.ReadOnly = true;
            this.dgvAdherence.RowHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            this.dgvAdherence.RowHeadersWidth = 17;
            this.dgvAdherence.Size = new System.Drawing.Size(970, 559);
            this.dgvAdherence.TabIndex = 4;
            this.dgvAdherence.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvAdherence_CellContentClick);
            this.dgvAdherence.DataError += new System.Windows.Forms.DataGridViewDataErrorEventHandler(this.dgvAdherence_DataError);
            // 
            // tcMain
            // 
            this.tcMain.Controls.Add(this.tpReports);
            this.tcMain.Controls.Add(this.tpStandardQueries);
            this.tcMain.Controls.Add(this.tpNewReports);
            this.tcMain.Controls.Add(this.tpQueries);
            this.tcMain.Controls.Add(this.tpSMS);
            this.tcMain.Controls.Add(this.tpEMRAccess);
            this.tcMain.Controls.Add(this.tpHelp);
            this.tcMain.Controls.Add(this.tpForum);
            this.tcMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tcMain.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tcMain.Location = new System.Drawing.Point(0, 0);
            this.tcMain.Margin = new System.Windows.Forms.Padding(0);
            this.tcMain.Name = "tcMain";
            this.tcMain.Padding = new System.Drawing.Point(0, 0);
            this.tcMain.SelectedIndex = 0;
            this.tcMain.Size = new System.Drawing.Size(1264, 648);
            this.tcMain.TabIndex = 0;
            this.tcMain.Selected += new System.Windows.Forms.TabControlEventHandler(this.tcMain_Selected);
            // 
            // tpStandardQueries
            // 
            this.tpStandardQueries.Controls.Add(this.tableLayoutPanel1);
            this.tpStandardQueries.Location = new System.Drawing.Point(4, 24);
            this.tpStandardQueries.Name = "tpStandardQueries";
            this.tpStandardQueries.Size = new System.Drawing.Size(1256, 620);
            this.tpStandardQueries.TabIndex = 12;
            this.tpStandardQueries.Text = "Standard Queries";
            this.tpStandardQueries.UseVisualStyleBackColor = true;
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.ColumnCount = 1;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel1.Controls.Add(this.flowLayoutPanel1, 0, 1);
            this.tableLayoutPanel1.Controls.Add(this.flowLayoutPanel2, 0, 3);
            this.tableLayoutPanel1.Controls.Add(this.dgvQryData, 0, 2);
            this.tableLayoutPanel1.Controls.Add(this.pictureBox4, 0, 0);
            this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 4;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 30F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 30F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(1256, 620);
            this.tableLayoutPanel1.TabIndex = 0;
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(239)))), ((int)(((byte)(244)))), ((int)(((byte)(255)))));
            this.flowLayoutPanel1.Controls.Add(this.label1);
            this.flowLayoutPanel1.Controls.Add(this.cboQuery);
            this.flowLayoutPanel1.Controls.Add(this.lblFrom);
            this.flowLayoutPanel1.Controls.Add(this.dtpFrom);
            this.flowLayoutPanel1.Controls.Add(this.lblTo);
            this.flowLayoutPanel1.Controls.Add(this.dtpTo);
            this.flowLayoutPanel1.Controls.Add(this.cmdLoadReport);
            this.flowLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.flowLayoutPanel1.Location = new System.Drawing.Point(0, 60);
            this.flowLayoutPanel1.Margin = new System.Windows.Forms.Padding(0);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(1256, 30);
            this.flowLayoutPanel1.TabIndex = 1;
            // 
            // label1
            // 
            this.label1.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 7);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(76, 15);
            this.label1.TabIndex = 0;
            this.label1.Text = "Select Query:";
            // 
            // cboQuery
            // 
            this.cboQuery.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.cboQuery.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboQuery.FormattingEnabled = true;
            this.cboQuery.Items.AddRange(new object[] {
            "<-- Select a Report -->",
            "New Clients on ART",
            "Current on ART",
            "Clients with Valid Viral Load",
            "Suppressed Clients",
            "Missed Appointments",
            "12 Months ART Cohort",
            "12 Months ART Cohort Linelist",
            "Recent Lost To Follow-up Clients",
            "Client Classification - Well, Advanced Disease, Stable, Unstable",
            "Client Classification Line List",
            "FMAPS Pharmacy report",
            "HEI Register",
            "Presumptive TB Register",
            "High Viral Load Register",
            "Patients without next appointment",
            "Pending appoinments"});
            this.cboQuery.Location = new System.Drawing.Point(85, 4);
            this.cboQuery.Name = "cboQuery";
            this.cboQuery.Size = new System.Drawing.Size(456, 23);
            this.cboQuery.TabIndex = 1;
            this.cboQuery.SelectedIndexChanged += new System.EventHandler(this.cboQuery_SelectedIndexChanged);
            // 
            // lblFrom
            // 
            this.lblFrom.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lblFrom.AutoSize = true;
            this.lblFrom.Location = new System.Drawing.Point(547, 7);
            this.lblFrom.Name = "lblFrom";
            this.lblFrom.Size = new System.Drawing.Size(65, 15);
            this.lblFrom.TabIndex = 3;
            this.lblFrom.Text = "Date From:";
            // 
            // dtpFrom
            // 
            this.dtpFrom.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.dtpFrom.CustomFormat = "dd-MMM-yyyy";
            this.dtpFrom.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpFrom.Location = new System.Drawing.Point(618, 3);
            this.dtpFrom.Name = "dtpFrom";
            this.dtpFrom.Size = new System.Drawing.Size(126, 23);
            this.dtpFrom.TabIndex = 2;
            // 
            // lblTo
            // 
            this.lblTo.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lblTo.AutoSize = true;
            this.lblTo.Location = new System.Drawing.Point(750, 7);
            this.lblTo.Name = "lblTo";
            this.lblTo.Size = new System.Drawing.Size(49, 15);
            this.lblTo.TabIndex = 4;
            this.lblTo.Text = "Date To:";
            // 
            // dtpTo
            // 
            this.dtpTo.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.dtpTo.CustomFormat = "dd-MMM-yyyy";
            this.dtpTo.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpTo.Location = new System.Drawing.Point(805, 3);
            this.dtpTo.Name = "dtpTo";
            this.dtpTo.Size = new System.Drawing.Size(125, 23);
            this.dtpTo.TabIndex = 5;
            // 
            // cmdLoadReport
            // 
            this.cmdLoadReport.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.cmdLoadReport.Location = new System.Drawing.Point(936, 3);
            this.cmdLoadReport.Name = "cmdLoadReport";
            this.cmdLoadReport.Size = new System.Drawing.Size(75, 23);
            this.cmdLoadReport.TabIndex = 6;
            this.cmdLoadReport.Text = "Load";
            this.cmdLoadReport.UseVisualStyleBackColor = true;
            this.cmdLoadReport.Click += new System.EventHandler(this.cmdLoadReport_Click);
            // 
            // flowLayoutPanel2
            // 
            this.flowLayoutPanel2.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.flowLayoutPanel2.Controls.Add(this.cmdExportToExcel);
            this.flowLayoutPanel2.FlowDirection = System.Windows.Forms.FlowDirection.RightToLeft;
            this.flowLayoutPanel2.Location = new System.Drawing.Point(674, 590);
            this.flowLayoutPanel2.Margin = new System.Windows.Forms.Padding(0);
            this.flowLayoutPanel2.Name = "flowLayoutPanel2";
            this.flowLayoutPanel2.Size = new System.Drawing.Size(582, 30);
            this.flowLayoutPanel2.TabIndex = 2;
            // 
            // cmdExportToExcel
            // 
            this.cmdExportToExcel.Location = new System.Drawing.Point(399, 3);
            this.cmdExportToExcel.Name = "cmdExportToExcel";
            this.cmdExportToExcel.Size = new System.Drawing.Size(180, 23);
            this.cmdExportToExcel.TabIndex = 0;
            this.cmdExportToExcel.Text = "Export to Excel";
            this.cmdExportToExcel.UseVisualStyleBackColor = true;
            this.cmdExportToExcel.Click += new System.EventHandler(this.cmdExportToExcel_Click);
            // 
            // dgvQryData
            // 
            this.dgvQryData.AllowUserToAddRows = false;
            this.dgvQryData.AllowUserToDeleteRows = false;
            this.dgvQryData.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.DisplayedCells;
            this.dgvQryData.BackgroundColor = System.Drawing.Color.White;
            this.dgvQryData.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvQryData.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvQryData.Location = new System.Drawing.Point(3, 93);
            this.dgvQryData.Name = "dgvQryData";
            this.dgvQryData.ReadOnly = true;
            this.dgvQryData.Size = new System.Drawing.Size(1250, 494);
            this.dgvQryData.TabIndex = 3;
            // 
            // pictureBox4
            // 
            this.pictureBox4.ErrorImage = global::IQTools.Properties.Resources.iqtools;
            this.pictureBox4.Image = global::IQTools.Properties.Resources.iqtools;
            this.pictureBox4.Location = new System.Drawing.Point(0, 0);
            this.pictureBox4.Margin = new System.Windows.Forms.Padding(0);
            this.pictureBox4.Name = "pictureBox4";
            this.pictureBox4.Size = new System.Drawing.Size(228, 60);
            this.pictureBox4.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBox4.TabIndex = 6;
            this.pictureBox4.TabStop = false;
            // 
            // tpNewReports
            // 
            this.tpNewReports.Location = new System.Drawing.Point(4, 24);
            this.tpNewReports.Name = "tpNewReports";
            this.tpNewReports.Size = new System.Drawing.Size(1256, 620);
            this.tpNewReports.TabIndex = 11;
            this.tpNewReports.Text = "Reports";
            this.tpNewReports.UseVisualStyleBackColor = true;
            // 
            // tpEMRAccess
            // 
            this.tpEMRAccess.Location = new System.Drawing.Point(4, 24);
            this.tpEMRAccess.Name = "tpEMRAccess";
            this.tpEMRAccess.Size = new System.Drawing.Size(1256, 620);
            this.tpEMRAccess.TabIndex = 9;
            this.tpEMRAccess.Text = "EMR";
            this.tpEMRAccess.UseVisualStyleBackColor = true;
            // 
            // tpForum
            // 
            this.tpForum.Location = new System.Drawing.Point(4, 24);
            this.tpForum.Name = "tpForum";
            this.tpForum.Size = new System.Drawing.Size(1256, 620);
            this.tpForum.TabIndex = 10;
            this.tpForum.Text = "Forum";
            this.tpForum.UseVisualStyleBackColor = true;
            // 
            // panel59
            // 
            this.panel59.Location = new System.Drawing.Point(0, 0);
            this.panel59.Name = "panel59";
            this.panel59.Size = new System.Drawing.Size(200, 100);
            this.panel59.TabIndex = 0;
            // 
            // cboMainLanguage
            // 
            this.cboMainLanguage.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.cboMainLanguage.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboMainLanguage.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cboMainLanguage.FormattingEnabled = true;
            this.cboMainLanguage.Location = new System.Drawing.Point(1143, 1);
            this.cboMainLanguage.Name = "cboMainLanguage";
            this.cboMainLanguage.Size = new System.Drawing.Size(121, 23);
            this.cboMainLanguage.TabIndex = 1;
            // 
            // label148
            // 
            this.label148.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.label148.AutoSize = true;
            this.label148.BackColor = System.Drawing.SystemColors.Window;
            this.label148.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label148.Location = new System.Drawing.Point(1074, 4);
            this.label148.Name = "label148";
            this.label148.Size = new System.Drawing.Size(59, 15);
            this.label148.TabIndex = 2;
            this.label148.Text = "Language";
            // 
            // spcMain
            // 
            this.spcMain.BackColor = System.Drawing.Color.WhiteSmoke;
            this.spcMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spcMain.FixedPanel = System.Windows.Forms.FixedPanel.Panel2;
            this.spcMain.IsSplitterFixed = true;
            this.spcMain.Location = new System.Drawing.Point(0, 0);
            this.spcMain.Margin = new System.Windows.Forms.Padding(0);
            this.spcMain.Name = "spcMain";
            this.spcMain.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // spcMain.Panel1
            // 
            this.spcMain.Panel1.Controls.Add(this.tcMain);
            // 
            // spcMain.Panel2
            // 
            this.spcMain.Panel2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(45)))), ((int)(((byte)(137)))), ((int)(((byte)(239)))));
            this.spcMain.Panel2.Controls.Add(this.pnlVersionLabels);
            this.spcMain.Panel2.Controls.Add(this.lblNotify);
            this.spcMain.Panel2.Controls.Add(this.picProgress);
            this.spcMain.Panel2MinSize = 32;
            this.spcMain.Size = new System.Drawing.Size(1264, 681);
            this.spcMain.SplitterDistance = 648;
            this.spcMain.SplitterWidth = 1;
            this.spcMain.TabIndex = 3;
            // 
            // lblNotify
            // 
            this.lblNotify.AutoSize = true;
            this.lblNotify.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblNotify.ForeColor = System.Drawing.Color.White;
            this.lblNotify.Location = new System.Drawing.Point(46, 11);
            this.lblNotify.MaximumSize = new System.Drawing.Size(500, 20);
            this.lblNotify.MinimumSize = new System.Drawing.Size(10, 0);
            this.lblNotify.Name = "lblNotify";
            this.lblNotify.Size = new System.Drawing.Size(10, 15);
            this.lblNotify.TabIndex = 1;
            // 
            // picProgress
            // 
            this.picProgress.Location = new System.Drawing.Point(8, 1);
            this.picProgress.Name = "picProgress";
            this.picProgress.Size = new System.Drawing.Size(32, 32);
            this.picProgress.TabIndex = 0;
            this.picProgress.TabStop = false;
            // 
            // pictureBox31
            // 
            this.pictureBox31.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(204)))), ((int)(((byte)(204)))), ((int)(((byte)(255)))));
            this.pictureBox31.Dock = System.Windows.Forms.DockStyle.Top;
            this.pictureBox31.Location = new System.Drawing.Point(3, 3);
            this.pictureBox31.Name = "pictureBox31";
            this.pictureBox31.Size = new System.Drawing.Size(980, 40);
            this.pictureBox31.TabIndex = 25;
            this.pictureBox31.TabStop = false;
            // 
            // frmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 17F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(1264, 681);
            this.Controls.Add(this.spcMain);
            this.Controls.Add(this.label148);
            this.Controls.Add(this.cboMainLanguage);
            this.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MinimumSize = new System.Drawing.Size(600, 600);
            this.Name = "frmMain";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = " IQTools ";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.frmMain_FormClosed);
            this.Load += new System.EventHandler(this.frmMain_Load);
            this.tpHelp.ResumeLayout(false);
            this.spcHelp.Panel1.ResumeLayout(false);
            this.spcHelp.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.spcHelp)).EndInit();
            this.spcHelp.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picHelp)).EndInit();
            this.spcHelpTab.Panel1.ResumeLayout(false);
            this.spcHelpTab.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.spcHelpTab)).EndInit();
            this.spcHelpTab.ResumeLayout(false);
            this.pnlVersionLabels.ResumeLayout(false);
            this.pnlVersionLabels.PerformLayout();
            this.tpReports.ResumeLayout(false);
            this.spcHome.Panel1.ResumeLayout(false);
            this.spcHome.Panel1.PerformLayout();
            this.spcHome.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.spcHome)).EndInit();
            this.spcHome.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.piclogo)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picHome)).EndInit();
            this.spcHomeTab1.Panel1.ResumeLayout(false);
            this.spcHomeTab1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.spcHomeTab1)).EndInit();
            this.spcHomeTab1.ResumeLayout(false);
            this.pnlHome.ResumeLayout(false);
            this.gbART.ResumeLayout(false);
            this.gbART.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvAdherence)).EndInit();
            this.tcMain.ResumeLayout(false);
            this.tpStandardQueries.ResumeLayout(false);
            this.tableLayoutPanel1.ResumeLayout(false);
            this.flowLayoutPanel1.ResumeLayout(false);
            this.flowLayoutPanel1.PerformLayout();
            this.flowLayoutPanel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvQryData)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox4)).EndInit();
            this.spcMain.Panel1.ResumeLayout(false);
            this.spcMain.Panel2.ResumeLayout(false);
            this.spcMain.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.spcMain)).EndInit();
            this.spcMain.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.picProgress)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox31)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

    }

    #endregion

    private TabPage tpHelp;
    private TabPage tpSMS;
    private TabPage tpQueries;
    private TabPage tpReports;
    private Label lblDBVersion;
    private TextBox txtDate;
    private Panel panel59;
    private PictureBox pictureBox31;   
    private FolderBrowserDialog fbd;
    private ComboBox cboMainLanguage;
    private Label label148;
    private Label lblAppVersion;
    private TextBox txtVersion;
    private SplitContainer spcMain;
    public PictureBox picProgress;
    public Label lblNotify;
    private TabPage tpForum;
    public TabControl tcMain;
    public TabPage tpEMRAccess;
    private TabPage tpNewReports;
    private SplitContainer spcHome;
    private PictureBox picHome;
    private SplitContainer spcHelpTab;
    private ListBox lstDocuments;
    private WebBrowser webHelp;
    private SplitContainer spcHelp;
    private PictureBox picHelp;
    private Panel pnlVersionLabels;
    private OpenFileDialog ofdUtility;
    private PictureBox piclogo;
    private PictureBox pictureBox2;
        private SplitContainer spcHomeTab1;
        private Panel pnlHome;
        private GroupBox gbART;
        private Label lblLowVL;
        private TextBox txtLowVL;
        private RadioButton optVLDetect;
        private RadioButton optVL;
        private TextBox TxtMA;
        private Label lblMA;
        private RadioButton OptMA;
        private RadioButton optART;
        private RadioButton optNoARTNoCD4;
        private DateTimePicker dtpAllApp;
        private RadioButton optAllApp;
        private Label label84;
        private DateTimePicker dtpMAP;
        private RadioButton optMAP;
        private Button cmdART;
        private DataGridView dgvAdherence;
        private Label lblLTFUApplicable;
        private TabPage tpStandardQueries;
        private TableLayoutPanel tableLayoutPanel1;
        private FlowLayoutPanel flowLayoutPanel1;
        private Label label1;
        private ComboBox cboQuery;
        private DateTimePicker dtpFrom;
        private Label lblFrom;
        private Label lblTo;
        private DateTimePicker dtpTo;
        private Button cmdLoadReport;
        private FlowLayoutPanel flowLayoutPanel2;
        private Button cmdExportToExcel;
        private DataGridView dgvQryData;
        private PictureBox pictureBox4;
    }
}

