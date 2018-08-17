using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace IQTools.Pages
{
    public partial class ucIQToolsForum : UserControl
    {
        frmMain fMain;
       
        public ucIQToolsForum(frmMain frm)
        {
            InitializeComponent();
            fMain = frm;
        }
        private void ucIQToolsForum_Load(object sender, EventArgs e)
        {
            string url = "https://groups.google.com/forum/#!forum/iqtools";
            wbForum.ScriptErrorsSuppressed = true;
            //wbForum.WebBrowserShortcutsEnabled = true;
            wbForum.Navigate(url);
        }

        private void wbForum_Navigated(object sender, WebBrowserNavigatedEventArgs e)
        {
            fMain.lblNotify.Text = wbForum.Url.ToString();
            fMain.picProgress.Image = null; 
        }

        private void wbForum_Navigating(object sender, WebBrowserNavigatingEventArgs e)
        {
            fMain.picProgress.Image = Properties.Resources.progressWheel5;
        }

        private void wbForum_DocumentCompleted(object sender, WebBrowserDocumentCompletedEventArgs e)
        {
            fMain.picProgress.Image = null; 
        }

    }
}
