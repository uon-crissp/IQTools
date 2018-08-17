namespace IQTools.Pages
{
    partial class ucIQToolsForum
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
            this.wbForum = new System.Windows.Forms.WebBrowser();
            this.SuspendLayout();
            // 
            // wbForum
            // 
            this.wbForum.Dock = System.Windows.Forms.DockStyle.Fill;
            this.wbForum.Location = new System.Drawing.Point(0, 0);
            this.wbForum.MinimumSize = new System.Drawing.Size(20, 20);
            this.wbForum.Name = "wbForum";
            this.wbForum.Size = new System.Drawing.Size(943, 473);
            this.wbForum.TabIndex = 0;
            this.wbForum.Url = new System.Uri("https://groups.google.com/forum/#!forum/iqtools", System.UriKind.Absolute);
            this.wbForum.DocumentCompleted += new System.Windows.Forms.WebBrowserDocumentCompletedEventHandler(this.wbForum_DocumentCompleted);
            this.wbForum.Navigated += new System.Windows.Forms.WebBrowserNavigatedEventHandler(this.wbForum_Navigated);
            this.wbForum.Navigating += new System.Windows.Forms.WebBrowserNavigatingEventHandler(this.wbForum_Navigating);
            // 
            // ucIQToolsForum
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.wbForum);
            this.Name = "ucIQToolsForum";
            this.Size = new System.Drawing.Size(943, 473);
            this.Load += new System.EventHandler(this.ucIQToolsForum_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.WebBrowser wbForum;
    }
}
