namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    partial class RemitToUpdateInfo
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
            label15 = new Label();
            actionInput = new TextBox();
            label16 = new Label();
            panel1 = new Panel();
            SuspendLayout();
            // 
            // label15
            // 
            label15.AutoSize = true;
            label15.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            label15.ForeColor = Color.White;
            label15.Location = new Point(198, 551);
            label15.Margin = new Padding(1, 0, 1, 0);
            label15.Name = "label15";
            label15.Size = new Size(630, 30);
            label15.TabIndex = 107;
            label15.Text = "1. Save Updates    2. Edit Screen    3. Delete Supplier    4. Cancel";
            // 
            // actionInput
            // 
            actionInput.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            actionInput.ForeColor = Color.Black;
            actionInput.Location = new Point(115, 548);
            actionInput.Margin = new Padding(0);
            actionInput.MaxLength = 2;
            actionInput.Name = "actionInput";
            actionInput.Size = new Size(40, 36);
            actionInput.TabIndex = 105;
            // 
            // label16
            // 
            label16.AutoSize = true;
            label16.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            label16.ForeColor = Color.White;
            label16.Location = new Point(17, 551);
            label16.Margin = new Padding(1, 0, 1, 0);
            label16.Name = "label16";
            label16.Size = new Size(97, 30);
            label16.TabIndex = 106;
            label16.Text = "ACTION:";
            // 
            // panel1
            // 
            panel1.BorderStyle = BorderStyle.Fixed3D;
            panel1.Location = new Point(0, 0);
            panel1.Name = "panel1";
            panel1.Size = new Size(1290, 536);
            panel1.TabIndex = 108;
            // 
            // RemitToUpdateInfo
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.Blue;
            Controls.Add(panel1);
            Controls.Add(label15);
            Controls.Add(actionInput);
            Controls.Add(label16);
            ForeColor = Color.White;
            Name = "RemitToUpdateInfo";
            Size = new Size(1290, 600);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label15;
        private TextBox actionInput;
        private Label label16;
        private Panel panel1;
    }
}
