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
            actionInput = new TextBox();
            label3 = new Label();
            label4 = new Label();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI", 18F, FontStyle.Regular, GraphicsUnit.Point);
            label1.Location = new Point(3, 0);
            label1.Name = "label1";
            label1.Size = new Size(659, 32);
            label1.TabIndex = 0;
            label1.Text = "SUPPLIERS MATCHING YOUR INPUT. PLEASE SELECT ACTION.";
            // 
            // resultSelectionListView
            // 
            resultSelectionListView.BackColor = Color.Blue;
            resultSelectionListView.Columns.AddRange(new ColumnHeader[] { NUM, NAME, CITY, STATE });
            resultSelectionListView.Font = new Font("Segoe UI", 18F, FontStyle.Regular, GraphicsUnit.Point);
            resultSelectionListView.ForeColor = Color.White;
            resultSelectionListView.HeaderStyle = ColumnHeaderStyle.Nonclickable;
            resultSelectionListView.Location = new Point(0, 35);
            resultSelectionListView.MultiSelect = false;
            resultSelectionListView.Name = "resultSelectionListView";
            resultSelectionListView.Size = new Size(1290, 447);
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
            label2.Font = new Font("Segoe UI", 18F, FontStyle.Regular, GraphicsUnit.Point);
            label2.Location = new Point(3, 502);
            label2.Name = "label2";
            label2.Size = new Size(273, 32);
            label2.TabIndex = 2;
            label2.Text = "Select Supplier Number:";
            // 
            // selectedItemNumber
            // 
            selectedItemNumber.Font = new Font("Segoe UI", 18F, FontStyle.Regular, GraphicsUnit.Point);
            selectedItemNumber.Location = new Point(282, 499);
            selectedItemNumber.Name = "selectedItemNumber";
            selectedItemNumber.Size = new Size(45, 39);
            selectedItemNumber.TabIndex = 3;
            selectedItemNumber.TextChanged += selectedItemNumber_TextChanged;
            selectedItemNumber.KeyDown += selectedItemNumber_KeyDown;
            // 
            // actionInput
            // 
            actionInput.Font = new Font("Segoe UI", 18F, FontStyle.Regular, GraphicsUnit.Point);
            actionInput.Location = new Point(96, 549);
            actionInput.Name = "actionInput";
            actionInput.Size = new Size(45, 39);
            actionInput.TabIndex = 5;
            actionInput.KeyDown += textBox2_KeyDown;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Segoe UI", 18F, FontStyle.Regular, GraphicsUnit.Point);
            label3.Location = new Point(3, 552);
            label3.Name = "label3";
            label3.Size = new Size(87, 32);
            label3.TabIndex = 4;
            label3.Text = "Action:";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Segoe UI", 16F, FontStyle.Regular, GraphicsUnit.Point);
            label4.Location = new Point(165, 552);
            label4.Name = "label4";
            label4.Size = new Size(629, 30);
            label4.TabIndex = 6;
            label4.Text = "1. NextPg   2. PreviousPg   3. FirstPg   4. Add Supplier   5. Cancel";
            // 
            // MatchSelect
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.Blue;
            Controls.Add(label4);
            Controls.Add(actionInput);
            Controls.Add(label3);
            Controls.Add(selectedItemNumber);
            Controls.Add(label2);
            Controls.Add(resultSelectionListView);
            Controls.Add(label1);
            ForeColor = Color.White;
            Name = "MatchSelect";
            Size = new Size(1290, 600);
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
        private TextBox actionInput;
        private Label label3;
        private Label label4;
        private ColumnHeader NUM;
    }
}
