namespace Inventory
{
    partial class MainWindow
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
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
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            dateLabel = new Label();
            programLabel = new Label();
            companyLabel = new Label();
            splitContainer1 = new SplitContainer();
            tableLayoutPanel1 = new TableLayoutPanel();
            splitContainer2 = new SplitContainer();
            userActionInputMain = new Views.UserControls.Utilities.UserActionInput();
            ((System.ComponentModel.ISupportInitialize)splitContainer1).BeginInit();
            splitContainer1.Panel1.SuspendLayout();
            splitContainer1.Panel2.SuspendLayout();
            splitContainer1.SuspendLayout();
            tableLayoutPanel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)splitContainer2).BeginInit();
            splitContainer2.Panel2.SuspendLayout();
            splitContainer2.SuspendLayout();
            SuspendLayout();
            // 
            // dateLabel
            // 
            dateLabel.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
            dateLabel.AutoSize = true;
            dateLabel.Font = new Font("Segoe UI", 12F, FontStyle.Regular, GraphicsUnit.Point);
            dateLabel.Location = new Point(1281, 35);
            dateLabel.Name = "dateLabel";
            dateLabel.RightToLeft = RightToLeft.No;
            dateLabel.Size = new Size(40, 21);
            dateLabel.TabIndex = 6;
            dateLabel.Text = "date";
            dateLabel.TextAlign = ContentAlignment.MiddleRight;
            // 
            // programLabel
            // 
            programLabel.Anchor = AnchorStyles.Bottom | AnchorStyles.Left;
            programLabel.AutoSize = true;
            programLabel.Font = new Font("Segoe UI", 12F, FontStyle.Regular, GraphicsUnit.Point);
            programLabel.Location = new Point(3, 35);
            programLabel.Name = "programLabel";
            programLabel.Size = new Size(89, 21);
            programLabel.TabIndex = 5;
            programLabel.Text = "Main Menu";
            // 
            // companyLabel
            // 
            companyLabel.Anchor = AnchorStyles.Bottom | AnchorStyles.Left;
            companyLabel.AutoSize = true;
            companyLabel.Font = new Font("Segoe UI", 12F, FontStyle.Regular, GraphicsUnit.Point);
            companyLabel.Location = new Point(3, 7);
            companyLabel.Name = "companyLabel";
            companyLabel.Size = new Size(134, 21);
            companyLabel.TabIndex = 4;
            companyLabel.Text = "AmeriChicken, Inc";
            // 
            // splitContainer1
            // 
            splitContainer1.Dock = DockStyle.Fill;
            splitContainer1.FixedPanel = FixedPanel.Panel1;
            splitContainer1.IsSplitterFixed = true;
            splitContainer1.Location = new Point(0, 0);
            splitContainer1.Name = "splitContainer1";
            splitContainer1.Orientation = Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            splitContainer1.Panel1.Controls.Add(tableLayoutPanel1);
            // 
            // splitContainer1.Panel2
            // 
            splitContainer1.Panel2.Controls.Add(splitContainer2);
            splitContainer1.Size = new Size(1324, 861);
            splitContainer1.SplitterDistance = 56;
            splitContainer1.TabIndex = 8;
            splitContainer1.TabStop = false;
            // 
            // tableLayoutPanel1
            // 
            tableLayoutPanel1.ColumnCount = 2;
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50F));
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50F));
            tableLayoutPanel1.Controls.Add(companyLabel, 0, 0);
            tableLayoutPanel1.Controls.Add(programLabel, 0, 1);
            tableLayoutPanel1.Controls.Add(dateLabel, 1, 1);
            tableLayoutPanel1.Dock = DockStyle.Fill;
            tableLayoutPanel1.Location = new Point(0, 0);
            tableLayoutPanel1.Name = "tableLayoutPanel1";
            tableLayoutPanel1.RowCount = 2;
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 50F));
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 50F));
            tableLayoutPanel1.Size = new Size(1324, 56);
            tableLayoutPanel1.TabIndex = 0;
            // 
            // splitContainer2
            // 
            splitContainer2.Dock = DockStyle.Fill;
            splitContainer2.Location = new Point(0, 0);
            splitContainer2.Name = "splitContainer2";
            splitContainer2.Orientation = Orientation.Horizontal;
            // 
            // splitContainer2.Panel1
            // 
            splitContainer2.Panel1.Padding = new Padding(10);
            // 
            // splitContainer2.Panel2
            // 
            splitContainer2.Panel2.Controls.Add(userActionInputMain);
            splitContainer2.Size = new Size(1324, 801);
            splitContainer2.SplitterDistance = 703;
            splitContainer2.TabIndex = 1;
            splitContainer2.TabStop = false;
            // 
            // userActionInputMain
            // 
            userActionInputMain.BackColor = Color.Blue;
            userActionInputMain.Dock = DockStyle.Fill;
            userActionInputMain.ForeColor = Color.White;
            userActionInputMain.Location = new Point(0, 0);
            userActionInputMain.Name = "userActionInputMain";
            userActionInputMain.Size = new Size(1324, 94);
            userActionInputMain.TabIndex = 0;
            // 
            // MainWindow
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.Blue;
            ClientSize = new Size(1324, 861);
            Controls.Add(splitContainer1);
            Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point);
            ForeColor = SystemColors.ButtonFace;
            KeyPreview = true;
            Name = "MainWindow";
            Text = "AmeriChicken Inventory";
            WindowState = FormWindowState.Maximized;
            Load += Form1_Load;
            Shown += MainWindow_Shown;
            KeyDown += MainWindow_KeyDown;
            splitContainer1.Panel1.ResumeLayout(false);
            splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)splitContainer1).EndInit();
            splitContainer1.ResumeLayout(false);
            tableLayoutPanel1.ResumeLayout(false);
            tableLayoutPanel1.PerformLayout();
            splitContainer2.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)splitContainer2).EndInit();
            splitContainer2.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion
        private Label dateLabel;
        private Label programLabel;
        private Label companyLabel;
        private SplitContainer splitContainer1;
        private TableLayoutPanel tableLayoutPanel1;
        private Views.UserControls.Utilities.UserActionInput userActionInputMain;
        private SplitContainer splitContainer2;
    }
}