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
            label14 = new Label();
            actionInput = new TextBox();
            label13 = new Label();
            panel1 = new Panel();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            label1.Location = new Point(50, 46);
            label1.Name = "label1";
            label1.Size = new Size(191, 30);
            label1.TabIndex = 99;
            label1.Text = "Enter Search Field:";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Segoe UI", 14F, FontStyle.Regular, GraphicsUnit.Point);
            label2.Location = new Point(50, 99);
            label2.Name = "label2";
            label2.Size = new Size(62, 25);
            label2.TabIndex = 98;
            label2.Text = "Name";
            // 
            // searchQuereyTextBox
            // 
            searchQuereyTextBox.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            searchQuereyTextBox.Location = new Point(50, 127);
            searchQuereyTextBox.Name = "searchQuereyTextBox";
            searchQuereyTextBox.Size = new Size(345, 36);
            searchQuereyTextBox.TabIndex = 0;
            searchQuereyTextBox.KeyDown += searchQueryTextBox_KeyDown;
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            label14.Location = new Point(196, 556);
            label14.Margin = new Padding(1, 0, 1, 0);
            label14.Name = "label14";
            label14.Size = new Size(554, 30);
            label14.TabIndex = 45;
            label14.Text = "1. Item Page    2. Edit    3. Cancel Add    4. Update Notes";
            // 
            // actionInput
            // 
            actionInput.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            actionInput.Location = new Point(113, 553);
            actionInput.Margin = new Padding(0);
            actionInput.MaxLength = 2;
            actionInput.Name = "actionInput";
            actionInput.Size = new Size(40, 36);
            actionInput.TabIndex = 1;
            actionInput.KeyDown += actionInput_KeyDown;
            // 
            // label13
            // 
            label13.AutoSize = true;
            label13.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            label13.Location = new Point(15, 556);
            label13.Margin = new Padding(1, 0, 1, 0);
            label13.Name = "label13";
            label13.Size = new Size(97, 30);
            label13.TabIndex = 44;
            label13.Text = "ACTION:";
            // 
            // panel1
            // 
            panel1.BorderStyle = BorderStyle.Fixed3D;
            panel1.Location = new Point(0, 0);
            panel1.Name = "panel1";
            panel1.Size = new Size(1290, 452);
            panel1.TabIndex = 100;
            // 
            // DbSearch
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.Blue;
            Controls.Add(label14);
            Controls.Add(actionInput);
            Controls.Add(label13);
            Controls.Add(searchQuereyTextBox);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(panel1);
            ForeColor = Color.White;
            Name = "DbSearch";
            Size = new Size(1290, 600);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private Label label2;
        private TextBox searchQuereyTextBox;
        private Label label14;
        private TextBox actionInput;
        private Label label13;
        private Panel panel1;
    }
}
