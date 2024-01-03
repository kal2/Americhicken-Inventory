namespace Inventory
{
    partial class MenuList
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
            menuListBox = new ListBox();
            SuspendLayout();
            // 
            // menuListBox
            // 
            menuListBox.BackColor = Color.FromArgb(1, 0, 128);
            menuListBox.BorderStyle = BorderStyle.None;
            menuListBox.Dock = DockStyle.Fill;
            menuListBox.Font = new Font("Segoe UI", 18F);
            menuListBox.ForeColor = Color.White;
            menuListBox.FormattingEnabled = true;
            menuListBox.ImeMode = ImeMode.On;
            menuListBox.ItemHeight = 32;
            menuListBox.Items.AddRange(new object[] { "1 - PURCHASE ORDERS", "2 - CUSTOMER INVOICES", "3 - DISBURSEMENTS / SUPPLIER INVOICES", "4 - RECEIPTS", "5 - JOURNAL/LEDGER POSTING", "6 - REPORTS", "7 - INVENTORY - REPORTS/VIEW ACTIVITY", "8 - FILE MAINTENANCE", "9 - EXIT" });
            menuListBox.Location = new Point(0, 0);
            menuListBox.Name = "menuListBox";
            menuListBox.Size = new Size(1293, 451);
            menuListBox.TabIndex = 0;
            // 
            // MenuList
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            AutoSize = true;
            BackColor = Color.FromArgb(1, 0, 128);
            Controls.Add(menuListBox);
            ForeColor = Color.White;
            Name = "MenuList";
            Size = new Size(1293, 451);
            ResumeLayout(false);
        }

        #endregion

        private ListBox menuListBox;
    }
}
