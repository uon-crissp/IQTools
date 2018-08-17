namespace IQTools
{
    partial class frmQueryParameters
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

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.spcQueryParams = new System.Windows.Forms.SplitContainer();
            this.dgvQryParams = new System.Windows.Forms.DataGridView();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnOK = new System.Windows.Forms.Button();
            this.pName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.pType = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.pValue = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.spcQueryParams.Panel1.SuspendLayout();
            this.spcQueryParams.Panel2.SuspendLayout();
            this.spcQueryParams.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvQryParams)).BeginInit();
            this.SuspendLayout();
            // 
            // spcQueryParams
            // 
            this.spcQueryParams.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spcQueryParams.Location = new System.Drawing.Point(0, 0);
            this.spcQueryParams.Name = "spcQueryParams";
            this.spcQueryParams.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // spcQueryParams.Panel1
            // 
            this.spcQueryParams.Panel1.Controls.Add(this.dgvQryParams);
            // 
            // spcQueryParams.Panel2
            // 
            this.spcQueryParams.Panel2.Controls.Add(this.btnCancel);
            this.spcQueryParams.Panel2.Controls.Add(this.btnOK);
            this.spcQueryParams.Size = new System.Drawing.Size(531, 248);
            this.spcQueryParams.SplitterDistance = 181;
            this.spcQueryParams.SplitterWidth = 1;
            this.spcQueryParams.TabIndex = 0;
            // 
            // dgvQryParams
            // 
            this.dgvQryParams.AllowUserToAddRows = false;
            this.dgvQryParams.AllowUserToDeleteRows = false;
            this.dgvQryParams.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvQryParams.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.pName,
            this.pType,
            this.pValue});
            this.dgvQryParams.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvQryParams.Location = new System.Drawing.Point(0, 0);
            this.dgvQryParams.Name = "dgvQryParams";
            this.dgvQryParams.Size = new System.Drawing.Size(531, 181);
            this.dgvQryParams.TabIndex = 0;
            // 
            // btnCancel
            // 
            this.btnCancel.Location = new System.Drawing.Point(438, 14);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(77, 40);
            this.btnCancel.TabIndex = 1;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // btnOK
            // 
            this.btnOK.Location = new System.Drawing.Point(357, 14);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(75, 40);
            this.btnOK.TabIndex = 0;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // pName
            // 
            this.pName.HeaderText = "Parameter Name";
            this.pName.Name = "pName";
            this.pName.Width = 200;
            // 
            // pType
            // 
            this.pType.HeaderText = "Data Type";
            this.pType.Name = "pType";
            this.pType.Width = 85;
            // 
            // pValue
            // 
            this.pValue.HeaderText = "Value";
            this.pValue.Name = "pValue";
            this.pValue.Width = 200;
            // 
            // frmQueryParameters
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(531, 248);
            this.Controls.Add(this.spcQueryParams);
            this.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Name = "frmQueryParameters";
            this.Text = "Query Parameters";
            this.spcQueryParams.Panel1.ResumeLayout(false);
            this.spcQueryParams.Panel2.ResumeLayout(false);
            this.spcQueryParams.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvQryParams)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer spcQueryParams;
        private System.Windows.Forms.DataGridView dgvQryParams;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.DataGridViewTextBoxColumn pName;
        private System.Windows.Forms.DataGridViewTextBoxColumn pType;
        private System.Windows.Forms.DataGridViewTextBoxColumn pValue;
    }
}