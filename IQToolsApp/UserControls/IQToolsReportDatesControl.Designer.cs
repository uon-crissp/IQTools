namespace IQTools.UserControls
{
    partial class IQToolsReportDatesControl
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
            this.spc1 = new System.Windows.Forms.SplitContainer();
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.dtpToDate = new System.Windows.Forms.DateTimePicker();
            this.dtpFromDate = new System.Windows.Forms.DateTimePicker();
            this.lblFromDate = new System.Windows.Forms.Label();
            this.lblToDate = new System.Windows.Forms.Label();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.lstPeriods = new System.Windows.Forms.ListBox();
            this.cboDateRanges = new System.Windows.Forms.ComboBox();
            ((System.ComponentModel.ISupportInitialize)(this.spc1)).BeginInit();
            this.spc1.Panel1.SuspendLayout();
            this.spc1.Panel2.SuspendLayout();
            this.spc1.SuspendLayout();
            this.tableLayoutPanel1.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
            this.SuspendLayout();
            // 
            // spc1
            // 
            this.spc1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spc1.Location = new System.Drawing.Point(0, 0);
            this.spc1.Name = "spc1";
            this.spc1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // spc1.Panel1
            // 
            this.spc1.Panel1.Controls.Add(this.tableLayoutPanel1);
            // 
            // spc1.Panel2
            // 
            this.spc1.Panel2.Controls.Add(this.tableLayoutPanel2);
            this.spc1.Size = new System.Drawing.Size(181, 284);
            this.spc1.SplitterDistance = 60;
            this.spc1.SplitterWidth = 1;
            this.spc1.TabIndex = 0;
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.ColumnCount = 2;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tableLayoutPanel1.Controls.Add(this.dtpToDate, 1, 1);
            this.tableLayoutPanel1.Controls.Add(this.dtpFromDate, 1, 0);
            this.tableLayoutPanel1.Controls.Add(this.lblFromDate, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.lblToDate, 0, 1);
            this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 2;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(181, 60);
            this.tableLayoutPanel1.TabIndex = 0;
            // 
            // dtpToDate
            // 
            this.dtpToDate.CustomFormat = "yyyy/MM/dd";
            this.dtpToDate.Dock = System.Windows.Forms.DockStyle.Top;
            this.dtpToDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpToDate.Location = new System.Drawing.Point(46, 33);
            this.dtpToDate.Name = "dtpToDate";
            this.dtpToDate.Size = new System.Drawing.Size(132, 22);
            this.dtpToDate.TabIndex = 5;
            // 
            // dtpFromDate
            // 
            this.dtpFromDate.CustomFormat = "yyyy/MM/dd";
            this.dtpFromDate.Dock = System.Windows.Forms.DockStyle.Top;
            this.dtpFromDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpFromDate.Location = new System.Drawing.Point(46, 3);
            this.dtpFromDate.Name = "dtpFromDate";
            this.dtpFromDate.Size = new System.Drawing.Size(132, 22);
            this.dtpFromDate.TabIndex = 4;
            // 
            // lblFromDate
            // 
            this.lblFromDate.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblFromDate.AutoSize = true;
            this.lblFromDate.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblFromDate.Location = new System.Drawing.Point(3, 0);
            this.lblFromDate.Name = "lblFromDate";
            this.lblFromDate.Size = new System.Drawing.Size(37, 13);
            this.lblFromDate.TabIndex = 2;
            this.lblFromDate.Text = "From:";
            this.lblFromDate.TextAlign = System.Drawing.ContentAlignment.TopRight;
            // 
            // lblToDate
            // 
            this.lblToDate.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblToDate.AutoSize = true;
            this.lblToDate.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblToDate.Location = new System.Drawing.Point(18, 30);
            this.lblToDate.Name = "lblToDate";
            this.lblToDate.Size = new System.Drawing.Size(22, 13);
            this.lblToDate.TabIndex = 3;
            this.lblToDate.Text = "To:";
            this.lblToDate.TextAlign = System.Drawing.ContentAlignment.TopRight;
            // 
            // tableLayoutPanel2
            // 
            this.tableLayoutPanel2.ColumnCount = 1;
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel2.Controls.Add(this.lstPeriods, 0, 1);
            this.tableLayoutPanel2.Controls.Add(this.cboDateRanges, 0, 0);
            this.tableLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel2.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 2;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel2.Size = new System.Drawing.Size(181, 223);
            this.tableLayoutPanel2.TabIndex = 0;
            // 
            // lstPeriods
            // 
            this.lstPeriods.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lstPeriods.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lstPeriods.FormattingEnabled = true;
            this.lstPeriods.Location = new System.Drawing.Point(3, 30);
            this.lstPeriods.Name = "lstPeriods";
            this.lstPeriods.Size = new System.Drawing.Size(175, 190);
            this.lstPeriods.TabIndex = 2;
            // 
            // cboDateRanges
            // 
            this.cboDateRanges.Dock = System.Windows.Forms.DockStyle.Top;
            this.cboDateRanges.FormattingEnabled = true;
            this.cboDateRanges.Items.AddRange(new object[] {
            "Monthly",
            "Quarterly",
            "Semi-Annually",
            "Annually"});
            this.cboDateRanges.Location = new System.Drawing.Point(3, 3);
            this.cboDateRanges.Name = "cboDateRanges";
            this.cboDateRanges.Size = new System.Drawing.Size(175, 21);
            this.cboDateRanges.TabIndex = 1;
            // 
            // IQToolsReportDatesControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.spc1);
            this.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Name = "IQToolsReportDatesControl";
            this.Size = new System.Drawing.Size(181, 284);
            this.spc1.Panel1.ResumeLayout(false);
            this.spc1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.spc1)).EndInit();
            this.spc1.ResumeLayout(false);
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel1.PerformLayout();
            this.tableLayoutPanel2.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer spc1;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel2;
        private System.Windows.Forms.Label lblFromDate;
        private System.Windows.Forms.Label lblToDate;
        public System.Windows.Forms.DateTimePicker dtpFromDate;
        public System.Windows.Forms.DateTimePicker dtpToDate;
        public System.Windows.Forms.ComboBox cboDateRanges;
        public System.Windows.Forms.ListBox lstPeriods;

    }
}
