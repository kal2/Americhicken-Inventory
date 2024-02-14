namespace Inventory.Programs.Utilities
{
    partial class UserConfirmation
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
            warningLabel = new Label();
            confirmationInput = new TextBox();
            SuspendLayout();
            // 
            // warningLabel
            // 
            warningLabel.AutoSize = true;
            warningLabel.Font = new Font("Segoe UI", 16F);
            warningLabel.ForeColor = Color.White;
            warningLabel.Location = new Point(235, 28);
            warningLabel.Name = "warningLabel";
            warningLabel.Size = new Size(796, 30);
            warningLabel.TabIndex = 0;
            warningLabel.Text = "THESE CHANGES CANNOT BE UNDONE. DO YOU WANT TO CONTINUE?     (Y/N)";
            // 
            // confirmationInput
            // 
            confirmationInput.BackColor = Color.Maroon;
            confirmationInput.BorderStyle = BorderStyle.None;
            confirmationInput.Font = new Font("Segoe UI", 15F);
            confirmationInput.ForeColor = Color.White;
            confirmationInput.Location = new Point(1034, 26);
            confirmationInput.Margin = new Padding(0);
            confirmationInput.MaxLength = 2;
            confirmationInput.Name = "confirmationInput";
            confirmationInput.Size = new Size(40, 27);
            confirmationInput.TabIndex = 47;
            confirmationInput.KeyDown += confirmationInput_KeyDown;
            // 
            // UserConfirmation
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.Transparent;
            Controls.Add(confirmationInput);
            Controls.Add(warningLabel);
            Name = "UserConfirmation";
            Size = new Size(1309, 86);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label warningLabel;
        public TextBox confirmationInput;
    }
}
