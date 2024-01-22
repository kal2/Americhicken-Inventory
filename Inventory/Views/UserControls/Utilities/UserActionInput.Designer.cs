namespace Inventory.Views.UserControls.Utilities
{
    partial class UserActionInput
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
            userActionCommandsLabel = new Label();
            actionInput = new TextBox();
            textBoxLabel = new Label();
            SuspendLayout();
            // 
            // userActionCommandsLabel
            // 
            userActionCommandsLabel.AutoSize = true;
            userActionCommandsLabel.Font = new Font("Segoe UI", 16F);
            userActionCommandsLabel.Location = new Point(197, 26);
            userActionCommandsLabel.Margin = new Padding(1, 0, 1, 0);
            userActionCommandsLabel.Name = "userActionCommandsLabel";
            userActionCommandsLabel.Size = new Size(0, 30);
            userActionCommandsLabel.TabIndex = 48;
            // 
            // actionInput
            // 
            actionInput.BackColor = Color.Maroon;
            actionInput.Font = new Font("Segoe UI", 15F);
            actionInput.ForeColor = Color.White;
            actionInput.Location = new Point(114, 23);
            actionInput.Margin = new Padding(0);
            actionInput.MaxLength = 2;
            actionInput.Name = "actionInput";
            actionInput.Size = new Size(40, 34);
            actionInput.TabIndex = 46;
            // 
            // textBoxLabel
            // 
            textBoxLabel.AutoSize = true;
            textBoxLabel.Font = new Font("Segoe UI", 16F);
            textBoxLabel.Location = new Point(16, 26);
            textBoxLabel.Margin = new Padding(1, 0, 1, 0);
            textBoxLabel.Name = "textBoxLabel";
            textBoxLabel.Size = new Size(96, 30);
            textBoxLabel.TabIndex = 47;
            textBoxLabel.Text = "CHOICE:";
            // 
            // UserActionInput
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.Transparent;
            Controls.Add(userActionCommandsLabel);
            Controls.Add(actionInput);
            Controls.Add(textBoxLabel);
            ForeColor = Color.White;
            Name = "UserActionInput";
            Size = new Size(1309, 86);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion
        public TextBox actionInput;
        public Label userActionCommandsLabel;
        public Label textBoxLabel;
    }
}
