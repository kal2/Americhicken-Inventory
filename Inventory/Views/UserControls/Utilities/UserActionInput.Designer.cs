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
            label14 = new Label();
            actionInput = new TextBox();
            label13 = new Label();
            SuspendLayout();
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            label14.Location = new Point(197, 26);
            label14.Margin = new Padding(1, 0, 1, 0);
            label14.Name = "label14";
            label14.Size = new Size(554, 30);
            label14.TabIndex = 48;
            label14.Text = "1. Item Page    2. Edit    3. Cancel Add    4. Update Notes";
            // 
            // actionInput
            // 
            actionInput.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            actionInput.Location = new Point(114, 23);
            actionInput.Margin = new Padding(0);
            actionInput.MaxLength = 2;
            actionInput.Name = "actionInput";
            actionInput.Size = new Size(40, 36);
            actionInput.TabIndex = 46;
            // 
            // label13
            // 
            label13.AutoSize = true;
            label13.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            label13.Location = new Point(16, 26);
            label13.Margin = new Padding(1, 0, 1, 0);
            label13.Name = "label13";
            label13.Size = new Size(97, 30);
            label13.TabIndex = 47;
            label13.Text = "ACTION:";
            // 
            // UserActionInput
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.Blue;
            Controls.Add(label14);
            Controls.Add(actionInput);
            Controls.Add(label13);
            ForeColor = Color.White;
            Name = "UserActionInput";
            Size = new Size(1309, 86);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label14;
        private Label label13;
        public TextBox actionInput;
    }
}
