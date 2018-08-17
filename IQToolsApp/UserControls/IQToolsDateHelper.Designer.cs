namespace IQTools.UserControls
{
    partial class IQToolsDateHelper
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
            this.flPDateHelper = new System.Windows.Forms.FlowLayoutPanel();
            this.cboDateRanges = new System.Windows.Forms.ComboBox();
            this.lstPeriods = new System.Windows.Forms.ListBox();
            this.flPDateHelper.SuspendLayout();
            this.SuspendLayout();
            // 
            // flPDateHelper
            // 
            this.flPDateHelper.AutoScroll = true;
            this.flPDateHelper.AutoSize = true;
            this.flPDateHelper.Controls.Add(this.cboDateRanges);
            this.flPDateHelper.Controls.Add(this.lstPeriods);
            this.flPDateHelper.Dock = System.Windows.Forms.DockStyle.Fill;
            this.flPDateHelper.FlowDirection = System.Windows.Forms.FlowDirection.TopDown;
            this.flPDateHelper.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.flPDateHelper.Location = new System.Drawing.Point(0, 0);
            this.flPDateHelper.Margin = new System.Windows.Forms.Padding(0);
            this.flPDateHelper.Name = "flPDateHelper";
            this.flPDateHelper.Size = new System.Drawing.Size(200, 298);
            this.flPDateHelper.TabIndex = 0;
            // 
            // cboDateRanges
            // 
            this.cboDateRanges.FormattingEnabled = true;
            this.cboDateRanges.Items.AddRange(new object[] {
            "Monthly",
            "Quarterly",
            "Semi-Annually",
            "Annually"});
            this.cboDateRanges.Location = new System.Drawing.Point(3, 3);
            this.cboDateRanges.MinimumSize = new System.Drawing.Size(190, 0);
            this.cboDateRanges.Name = "cboDateRanges";
            this.cboDateRanges.Size = new System.Drawing.Size(194, 21);
            this.cboDateRanges.TabIndex = 0;
            // 
            // lstPeriods
            // 
            this.lstPeriods.FormattingEnabled = true;
            this.lstPeriods.Location = new System.Drawing.Point(3, 30);
            this.lstPeriods.MinimumSize = new System.Drawing.Size(190, 250);
            this.lstPeriods.Name = "lstPeriods";
            this.lstPeriods.Size = new System.Drawing.Size(194, 251);
            this.lstPeriods.TabIndex = 1;
            // 
            // IQToolsDateHelper
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoScroll = true;
            this.AutoSize = true;
            this.Controls.Add(this.flPDateHelper);
            this.Margin = new System.Windows.Forms.Padding(0);
            this.Name = "IQToolsDateHelper";
            this.Size = new System.Drawing.Size(200, 298);
            this.flPDateHelper.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.FlowLayoutPanel flPDateHelper;
        public System.Windows.Forms.ComboBox cboDateRanges;
        public System.Windows.Forms.ListBox lstPeriods;
    }
}
