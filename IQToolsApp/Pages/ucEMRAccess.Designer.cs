namespace IQTools.Pages
{
    partial class ucEMRAccess
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
            this.wbEMR = new System.Windows.Forms.WebBrowser();
            this.SuspendLayout();
            // 
            // wbEMR
            // 
            this.wbEMR.Dock = System.Windows.Forms.DockStyle.Fill;
            this.wbEMR.Location = new System.Drawing.Point(0, 0);
            this.wbEMR.MinimumSize = new System.Drawing.Size(20, 20);
            this.wbEMR.Name = "wbEMR";
            this.wbEMR.Size = new System.Drawing.Size(866, 422);
            this.wbEMR.TabIndex = 0;
            this.wbEMR.Url = new System.Uri("", System.UriKind.Relative);
            this.wbEMR.DocumentCompleted += new System.Windows.Forms.WebBrowserDocumentCompletedEventHandler(this.wbEMR_DocumentCompleted);
            this.wbEMR.Navigated += new System.Windows.Forms.WebBrowserNavigatedEventHandler(this.wbEMR_Navigated);
            this.wbEMR.Navigating += new System.Windows.Forms.WebBrowserNavigatingEventHandler(this.wbEMR_Navigating);
            // 
            // ucEMRAccess
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.Controls.Add(this.wbEMR);
            this.Name = "ucEMRAccess";
            this.Size = new System.Drawing.Size(866, 422);
            this.Load += new System.EventHandler(this.ucEMRAccess_Load);
            this.Enter += new System.EventHandler(this.ucEMRAccess_Enter);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.WebBrowser wbEMR;


    }
}
