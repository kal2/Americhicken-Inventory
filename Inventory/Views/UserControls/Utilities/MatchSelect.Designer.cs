namespace Inventory.Views.UserControls
{
    partial class MatchSelect
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
            resultSelectionListView = new ListView();
            NUM = new ColumnHeader();
            NAME = new ColumnHeader();
            CITY = new ColumnHeader();
            STATE = new ColumnHeader();
            label2 = new Label();
            selectedItemNumber = new TextBox();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI", 18F);
            label1.Location = new Point(3, 0);
            label1.Name = "label1";
            label1.Size = new Size(659, 32);
            label1.TabIndex = 0;
            label1.Text = "SUPPLIERS MATCHING YOUR INPUT. PLEASE SELECT ACTION.";
            // 
            // resultSelectionListView
            // 
            resultSelectionListView.BackColor = Color.FromArgb(1, 0, 128);
            resultSelectionListView.Columns.AddRange(new ColumnHeader[] { NUM, NAME, CITY, STATE });
            resultSelectionListView.Font = new Font("Segoe UI", 18F);
            resultSelectionListView.ForeColor = Color.White;
            resultSelectionListView.HeaderStyle = ColumnHeaderStyle.Nonclickable;
            resultSelectionListView.Location = new Point(1, 35);
            resultSelectionListView.MultiSelect = false;
            resultSelectionListView.Name = "resultSelectionListView";
            resultSelectionListView.Size = new Size(1290, 514);
            resultSelectionListView.TabIndex = 1;
            resultSelectionListView.UseCompatibleStateImageBehavior = false;
            resultSelectionListView.View = View.Details;
            // 
            // NUM
            // 
            NUM.Text = "#";
            NUM.Width = 50;
            // 
            // NAME
            // 
            NAME.Text = "NAME";
            NAME.Width = 587;
            // 
            // CITY
            // 
            CITY.Text = "CITY";
            CITY.Width = 483;
            // 
            // STATE
            // 
            STATE.Text = "STATE";
            STATE.Width = 100;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Segoe UI", 18F);
            label2.Location = new Point(3, 558);
            label2.Name = "label2";
            label2.Size = new Size(273, 32);
            label2.TabIndex = 2;
            label2.Text = "Select Supplier Number:";
            // 
            // selectedItemNumber
            // 
            selectedItemNumber.BackColor = Color.Maroon;
            selectedItemNumber.Font = new Font("Segoe UI", 18F, FontStyle.Bold);
            selectedItemNumber.ForeColor = Color.White;
            selectedItemNumber.Location = new Point(282, 555);
            selectedItemNumber.Name = "selectedItemNumber";
            selectedItemNumber.Size = new Size(45, 39);
            selectedItemNumber.TabIndex = 3;
            selectedItemNumber.TextChanged += selectedItemNumber_TextChanged;
            selectedItemNumber.KeyDown += selectedItemNumber_KeyDown;
            // 
            // MatchSelect
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            AutoSize = true;
            BackColor = Color.FromArgb(1, 0, 128);
            Controls.Add(selectedItemNumber);
            Controls.Add(label2);
            Controls.Add(resultSelectionListView);
            Controls.Add(label1);
            ForeColor = Color.White;
            Name = "MatchSelect";
            Size = new Size(1294, 600);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private ListView resultSelectionListView;
        private ColumnHeader NAME;
        private ColumnHeader CITY;
        private ColumnHeader STATE;
        private Label label2;
        private TextBox selectedItemNumber;
        private ColumnHeader NUM;
    }
}
