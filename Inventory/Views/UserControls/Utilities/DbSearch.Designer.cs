namespace Inventory.Views.UserControls
{
    partial class DbSearch
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
            label1 = new Label();
            label2 = new Label();
            searchQuereyTextBox = new TextBox();
            panel1 = new Panel();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.BackColor = Color.FromArgb(1, 0, 128);
            label1.Font = new Font("Segoe UI", 16F);
            label1.Location = new Point(50, 46);
            label1.Name = "label1";
            label1.Size = new Size(191, 30);
            label1.TabIndex = 99;
            label1.Text = "Enter Search Field:";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.BackColor = Color.FromArgb(1, 0, 128);
            label2.Font = new Font("Segoe UI", 14F);
            label2.Location = new Point(50, 99);
            label2.Name = "label2";
            label2.Size = new Size(62, 25);
            label2.TabIndex = 98;
            label2.Text = "Name";
            // 
            // searchQuereyTextBox
            // 
            searchQuereyTextBox.BackColor = Color.Maroon;
            searchQuereyTextBox.Font = new Font("Segoe UI", 15F, FontStyle.Bold);
            searchQuereyTextBox.ForeColor = Color.White;
            searchQuereyTextBox.Location = new Point(50, 127);
            searchQuereyTextBox.Name = "searchQuereyTextBox";
            searchQuereyTextBox.Size = new Size(575, 34);
            searchQuereyTextBox.TabIndex = 0;
            searchQuereyTextBox.KeyDown += searchQueryTextBox_KeyDown;
            // 
            // panel1
            // 
            panel1.BackColor = Color.FromArgb(1, 0, 128);
            panel1.Dock = DockStyle.Fill;
            panel1.Location = new Point(0, 0);
            panel1.Name = "panel1";
            panel1.Size = new Size(1290, 600);
            panel1.TabIndex = 100;
            // 
            // DbSearch
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            AutoSize = true;
            BackColor = Color.Blue;
            Controls.Add(searchQuereyTextBox);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(panel1);
            ForeColor = Color.White;
            Name = "DbSearch";
            Size = new Size(1290, 600);
            Load += DbSearch_Load;
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private Label label2;
        private TextBox searchQuereyTextBox;
        private Panel panel1;
    }
}
