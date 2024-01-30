namespace Inventory.Purchase_Orders
{
    partial class AddPO
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
            pOLabel = new Label();
            salesPersonNumber = new TextBox();
            purchaseOrderNumber = new TextBox();
            orderRevisionNumber = new TextBox();
            pOHyphen1 = new Label();
            pOHyphenLabel2 = new Label();
            brokerLabel = new Label();
            brokerNameLabel = new Label();
            holdCheckBox = new CheckBox();
            label1 = new Label();
            label2 = new Label();
            label3 = new Label();
            label4 = new Label();
            label5 = new Label();
            orderDateInput = new TextBox();
            shipDateInput = new TextBox();
            delReqdInput = new TextBox();
            textBox1 = new TextBox();
            textBox2 = new TextBox();
            label6 = new Label();
            label7 = new Label();
            label8 = new Label();
            label9 = new Label();
            label10 = new Label();
            label11 = new Label();
            label18 = new Label();
            label19 = new Label();
            textBox3 = new TextBox();
            textBox4 = new TextBox();
            textBox5 = new TextBox();
            textBox6 = new TextBox();
            textBox7 = new TextBox();
            textBox8 = new TextBox();
            textBox9 = new TextBox();
            textBox10 = new TextBox();
            textBox11 = new TextBox();
            textBox12 = new TextBox();
            textBox13 = new TextBox();
            textBox14 = new TextBox();
            SuspendLayout();
            // 
            // pOLabel
            // 
            pOLabel.AutoSize = true;
            pOLabel.Font = new Font("Segoe UI", 16F);
            pOLabel.Location = new Point(2, 3);
            pOLabel.Margin = new Padding(1, 0, 1, 0);
            pOLabel.Name = "pOLabel";
            pOLabel.Size = new Size(66, 30);
            pOLabel.TabIndex = 0;
            pOLabel.Text = "PO #:";
            // 
            // salesPersonNumber
            // 
            salesPersonNumber.BackColor = Color.Maroon;
            salesPersonNumber.Font = new Font("Segoe UI", 15F);
            salesPersonNumber.ForeColor = Color.White;
            salesPersonNumber.Location = new Point(69, 0);
            salesPersonNumber.Margin = new Padding(0);
            salesPersonNumber.MaxLength = 2;
            salesPersonNumber.Name = "salesPersonNumber";
            salesPersonNumber.Size = new Size(40, 34);
            salesPersonNumber.TabIndex = 1;
            // 
            // purchaseOrderNumber
            // 
            purchaseOrderNumber.BackColor = Color.Maroon;
            purchaseOrderNumber.Font = new Font("Segoe UI", 15F);
            purchaseOrderNumber.ForeColor = Color.White;
            purchaseOrderNumber.Location = new Point(136, 0);
            purchaseOrderNumber.Margin = new Padding(0);
            purchaseOrderNumber.MaxLength = 5;
            purchaseOrderNumber.Name = "purchaseOrderNumber";
            purchaseOrderNumber.Size = new Size(104, 34);
            purchaseOrderNumber.TabIndex = 2;
            // 
            // orderRevisionNumber
            // 
            orderRevisionNumber.BackColor = Color.Maroon;
            orderRevisionNumber.Font = new Font("Segoe UI", 15F);
            orderRevisionNumber.ForeColor = Color.White;
            orderRevisionNumber.Location = new Point(262, 0);
            orderRevisionNumber.Margin = new Padding(0);
            orderRevisionNumber.MaxLength = 2;
            orderRevisionNumber.Name = "orderRevisionNumber";
            orderRevisionNumber.Size = new Size(44, 34);
            orderRevisionNumber.TabIndex = 3;
            // 
            // pOHyphen1
            // 
            pOHyphen1.AutoSize = true;
            pOHyphen1.BackColor = Color.Transparent;
            pOHyphen1.Font = new Font("Segoe UI", 16F);
            pOHyphen1.Location = new Point(114, 3);
            pOHyphen1.Margin = new Padding(0);
            pOHyphen1.Name = "pOHyphen1";
            pOHyphen1.Size = new Size(22, 30);
            pOHyphen1.TabIndex = 4;
            pOHyphen1.Text = "-";
            // 
            // pOHyphenLabel2
            // 
            pOHyphenLabel2.AutoSize = true;
            pOHyphenLabel2.BackColor = Color.Transparent;
            pOHyphenLabel2.Font = new Font("Segoe UI", 16F);
            pOHyphenLabel2.Location = new Point(240, 3);
            pOHyphenLabel2.Margin = new Padding(0);
            pOHyphenLabel2.Name = "pOHyphenLabel2";
            pOHyphenLabel2.Size = new Size(22, 30);
            pOHyphenLabel2.TabIndex = 5;
            pOHyphenLabel2.Text = "-";
            // 
            // brokerLabel
            // 
            brokerLabel.AutoSize = true;
            brokerLabel.Font = new Font("Segoe UI", 16F);
            brokerLabel.Location = new Point(855, 3);
            brokerLabel.Name = "brokerLabel";
            brokerLabel.Size = new Size(104, 30);
            brokerLabel.TabIndex = 6;
            brokerLabel.Text = "BROKER :";
            // 
            // brokerNameLabel
            // 
            brokerNameLabel.AutoSize = true;
            brokerNameLabel.Font = new Font("Segoe UI", 16F);
            brokerNameLabel.Location = new Point(965, 3);
            brokerNameLabel.Name = "brokerNameLabel";
            brokerNameLabel.Size = new Size(127, 30);
            brokerNameLabel.TabIndex = 7;
            brokerNameLabel.Text = "placeholder";
            // 
            // holdCheckBox
            // 
            holdCheckBox.AutoSize = true;
            holdCheckBox.Font = new Font("Segoe UI", 16F);
            holdCheckBox.ForeColor = Color.White;
            holdCheckBox.Location = new Point(1192, 3);
            holdCheckBox.Name = "holdCheckBox";
            holdCheckBox.Size = new Size(89, 34);
            holdCheckBox.TabIndex = 8;
            holdCheckBox.Text = "Hold?";
            holdCheckBox.UseVisualStyleBackColor = true;
            holdCheckBox.KeyDown += holdCheckBox_KeyDown;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI", 16F);
            label1.Location = new Point(2, 61);
            label1.Margin = new Padding(1, 0, 1, 0);
            label1.Name = "label1";
            label1.Size = new Size(137, 30);
            label1.TabIndex = 9;
            label1.Text = "ORDER DATE";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Segoe UI", 16F);
            label2.Location = new Point(192, 61);
            label2.Margin = new Padding(1, 0, 1, 0);
            label2.Name = "label2";
            label2.Size = new Size(114, 30);
            label2.TabIndex = 10;
            label2.Text = "SHIP DATE";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Segoe UI", 16F);
            label3.Location = new Point(367, 61);
            label3.Margin = new Padding(1, 0, 1, 0);
            label3.Name = "label3";
            label3.Size = new Size(111, 30);
            label3.TabIndex = 11;
            label3.Text = "DEL REQD";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Segoe UI", 16F);
            label4.Location = new Point(681, 61);
            label4.Margin = new Padding(1, 0, 1, 0);
            label4.Name = "label4";
            label4.Size = new Size(120, 30);
            label4.TabIndex = 12;
            label4.Text = "CUST PO #";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Segoe UI", 16F);
            label5.Location = new Point(929, 61);
            label5.Margin = new Padding(1, 0, 1, 0);
            label5.Name = "label5";
            label5.Size = new Size(194, 30);
            label5.TabIndex = 13;
            label5.Text = "PICKUP LOCATION";
            // 
            // orderDateInput
            // 
            orderDateInput.BackColor = Color.Maroon;
            orderDateInput.Font = new Font("Segoe UI", 15F);
            orderDateInput.ForeColor = Color.White;
            orderDateInput.Location = new Point(10, 91);
            orderDateInput.Margin = new Padding(0);
            orderDateInput.MaxLength = 5;
            orderDateInput.Name = "orderDateInput";
            orderDateInput.Size = new Size(127, 34);
            orderDateInput.TabIndex = 14;
            // 
            // shipDateInput
            // 
            shipDateInput.BackColor = Color.Maroon;
            shipDateInput.Font = new Font("Segoe UI", 15F);
            shipDateInput.ForeColor = Color.White;
            shipDateInput.Location = new Point(192, 91);
            shipDateInput.Margin = new Padding(0);
            shipDateInput.MaxLength = 5;
            shipDateInput.Name = "shipDateInput";
            shipDateInput.Size = new Size(127, 34);
            shipDateInput.TabIndex = 15;
            // 
            // delReqdInput
            // 
            delReqdInput.BackColor = Color.Maroon;
            delReqdInput.Font = new Font("Segoe UI", 15F);
            delReqdInput.ForeColor = Color.White;
            delReqdInput.Location = new Point(367, 91);
            delReqdInput.Margin = new Padding(0);
            delReqdInput.MaxLength = 5;
            delReqdInput.Name = "delReqdInput";
            delReqdInput.Size = new Size(127, 34);
            delReqdInput.TabIndex = 16;
            // 
            // textBox1
            // 
            textBox1.BackColor = Color.Maroon;
            textBox1.Font = new Font("Segoe UI", 15F);
            textBox1.ForeColor = Color.White;
            textBox1.Location = new Point(681, 91);
            textBox1.Margin = new Padding(0);
            textBox1.MaxLength = 5;
            textBox1.Name = "textBox1";
            textBox1.Size = new Size(197, 34);
            textBox1.TabIndex = 17;
            // 
            // textBox2
            // 
            textBox2.BackColor = Color.Maroon;
            textBox2.Font = new Font("Segoe UI", 15F);
            textBox2.ForeColor = Color.White;
            textBox2.Location = new Point(929, 91);
            textBox2.Margin = new Padding(0);
            textBox2.MaxLength = 5;
            textBox2.Name = "textBox2";
            textBox2.Size = new Size(350, 34);
            textBox2.TabIndex = 18;
            // 
            // label6
            // 
            label6.BackColor = Color.White;
            label6.BorderStyle = BorderStyle.Fixed3D;
            label6.Location = new Point(11, 143);
            label6.Name = "label6";
            label6.Size = new Size(1270, 2);
            label6.TabIndex = 19;
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Segoe UI", 16F);
            label7.Location = new Point(517, 164);
            label7.Margin = new Padding(1, 0, 1, 0);
            label7.Name = "label7";
            label7.Size = new Size(256, 30);
            label7.TabIndex = 20;
            label7.Text = "SUPPLIER INFORMATION";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Font = new Font("Segoe UI", 16F);
            label8.Location = new Point(11, 194);
            label8.Margin = new Padding(1, 0, 1, 0);
            label8.Name = "label8";
            label8.Size = new Size(169, 30);
            label8.TabIndex = 21;
            label8.Text = "SHIPPED FROM:";
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Font = new Font("Segoe UI", 16F);
            label9.Location = new Point(681, 194);
            label9.Margin = new Padding(1, 0, 1, 0);
            label9.Name = "label9";
            label9.Size = new Size(114, 30);
            label9.TabIndex = 22;
            label9.Text = "REMIT TO:";
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Font = new Font("Segoe UI", 16F);
            label10.Location = new Point(506, 412);
            label10.Margin = new Padding(1, 0, 1, 0);
            label10.Name = "label10";
            label10.Size = new Size(278, 30);
            label10.TabIndex = 30;
            label10.Text = "CUSTOMER INFORMATION";
            // 
            // label11
            // 
            label11.BackColor = Color.White;
            label11.BorderStyle = BorderStyle.Fixed3D;
            label11.Location = new Point(11, 401);
            label11.Name = "label11";
            label11.Size = new Size(1270, 2);
            label11.TabIndex = 29;
            // 
            // label18
            // 
            label18.AutoSize = true;
            label18.Font = new Font("Segoe UI", 16F);
            label18.Location = new Point(681, 442);
            label18.Margin = new Padding(1, 0, 1, 0);
            label18.Name = "label18";
            label18.Size = new Size(91, 30);
            label18.TabIndex = 32;
            label18.Text = "BILL TO:";
            // 
            // label19
            // 
            label19.AutoSize = true;
            label19.Font = new Font("Segoe UI", 16F);
            label19.Location = new Point(11, 442);
            label19.Margin = new Padding(1, 0, 1, 0);
            label19.Name = "label19";
            label19.Size = new Size(98, 30);
            label19.TabIndex = 31;
            label19.Text = "SHIP TO:";
            // 
            // textBox3
            // 
            textBox3.BackColor = Color.Maroon;
            textBox3.Font = new Font("Segoe UI", 15F);
            textBox3.ForeColor = Color.White;
            textBox3.Location = new Point(10, 229);
            textBox3.Margin = new Padding(0, 1, 0, 1);
            textBox3.Name = "textBox3";
            textBox3.Size = new Size(484, 34);
            textBox3.TabIndex = 19;
            // 
            // textBox4
            // 
            textBox4.BackColor = Color.Maroon;
            textBox4.Font = new Font("Segoe UI", 15F);
            textBox4.ForeColor = Color.White;
            textBox4.Location = new Point(10, 267);
            textBox4.Margin = new Padding(0, 1, 0, 1);
            textBox4.Name = "textBox4";
            textBox4.Size = new Size(484, 34);
            textBox4.TabIndex = 20;
            // 
            // textBox5
            // 
            textBox5.BackColor = Color.Maroon;
            textBox5.Font = new Font("Segoe UI", 15F);
            textBox5.ForeColor = Color.White;
            textBox5.Location = new Point(10, 305);
            textBox5.Margin = new Padding(0, 1, 0, 1);
            textBox5.Name = "textBox5";
            textBox5.Size = new Size(484, 34);
            textBox5.TabIndex = 21;
            // 
            // textBox6
            // 
            textBox6.BackColor = Color.Maroon;
            textBox6.Font = new Font("Segoe UI", 15F);
            textBox6.ForeColor = Color.White;
            textBox6.Location = new Point(681, 310);
            textBox6.Margin = new Padding(0, 1, 0, 1);
            textBox6.Name = "textBox6";
            textBox6.Size = new Size(484, 34);
            textBox6.TabIndex = 24;
            // 
            // textBox7
            // 
            textBox7.BackColor = Color.Maroon;
            textBox7.Font = new Font("Segoe UI", 15F);
            textBox7.ForeColor = Color.White;
            textBox7.Location = new Point(681, 272);
            textBox7.Margin = new Padding(0, 1, 0, 1);
            textBox7.Name = "textBox7";
            textBox7.Size = new Size(484, 34);
            textBox7.TabIndex = 23;
            // 
            // textBox8
            // 
            textBox8.BackColor = Color.Maroon;
            textBox8.Font = new Font("Segoe UI", 15F);
            textBox8.ForeColor = Color.White;
            textBox8.Location = new Point(681, 234);
            textBox8.Margin = new Padding(0, 1, 0, 1);
            textBox8.Name = "textBox8";
            textBox8.Size = new Size(484, 34);
            textBox8.TabIndex = 22;
            // 
            // textBox9
            // 
            textBox9.BackColor = Color.Maroon;
            textBox9.Font = new Font("Segoe UI", 15F);
            textBox9.ForeColor = Color.White;
            textBox9.Location = new Point(10, 549);
            textBox9.Margin = new Padding(0, 1, 0, 1);
            textBox9.Name = "textBox9";
            textBox9.Size = new Size(484, 34);
            textBox9.TabIndex = 27;
            // 
            // textBox10
            // 
            textBox10.BackColor = Color.Maroon;
            textBox10.Font = new Font("Segoe UI", 15F);
            textBox10.ForeColor = Color.White;
            textBox10.Location = new Point(10, 511);
            textBox10.Margin = new Padding(0, 1, 0, 1);
            textBox10.Name = "textBox10";
            textBox10.Size = new Size(484, 34);
            textBox10.TabIndex = 26;
            // 
            // textBox11
            // 
            textBox11.BackColor = Color.Maroon;
            textBox11.Font = new Font("Segoe UI", 15F);
            textBox11.ForeColor = Color.White;
            textBox11.Location = new Point(10, 473);
            textBox11.Margin = new Padding(0, 1, 0, 1);
            textBox11.Name = "textBox11";
            textBox11.Size = new Size(484, 34);
            textBox11.TabIndex = 25;
            // 
            // textBox12
            // 
            textBox12.BackColor = Color.Maroon;
            textBox12.Font = new Font("Segoe UI", 15F);
            textBox12.ForeColor = Color.White;
            textBox12.Location = new Point(681, 549);
            textBox12.Margin = new Padding(0, 1, 0, 1);
            textBox12.Name = "textBox12";
            textBox12.Size = new Size(484, 34);
            textBox12.TabIndex = 30;
            // 
            // textBox13
            // 
            textBox13.BackColor = Color.Maroon;
            textBox13.Font = new Font("Segoe UI", 15F);
            textBox13.ForeColor = Color.White;
            textBox13.Location = new Point(681, 511);
            textBox13.Margin = new Padding(0, 1, 0, 1);
            textBox13.Name = "textBox13";
            textBox13.Size = new Size(484, 34);
            textBox13.TabIndex = 29;
            // 
            // textBox14
            // 
            textBox14.BackColor = Color.Maroon;
            textBox14.Font = new Font("Segoe UI", 15F);
            textBox14.ForeColor = Color.White;
            textBox14.Location = new Point(681, 473);
            textBox14.Margin = new Padding(0, 1, 0, 1);
            textBox14.Name = "textBox14";
            textBox14.Size = new Size(484, 34);
            textBox14.TabIndex = 28;
            // 
            // AddPO
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.FromArgb(1, 0, 128);
            Controls.Add(textBox12);
            Controls.Add(textBox13);
            Controls.Add(textBox14);
            Controls.Add(textBox9);
            Controls.Add(textBox10);
            Controls.Add(textBox11);
            Controls.Add(textBox6);
            Controls.Add(textBox7);
            Controls.Add(textBox8);
            Controls.Add(textBox5);
            Controls.Add(textBox4);
            Controls.Add(textBox3);
            Controls.Add(label18);
            Controls.Add(label19);
            Controls.Add(label10);
            Controls.Add(label11);
            Controls.Add(label9);
            Controls.Add(label8);
            Controls.Add(label7);
            Controls.Add(label6);
            Controls.Add(textBox2);
            Controls.Add(textBox1);
            Controls.Add(delReqdInput);
            Controls.Add(shipDateInput);
            Controls.Add(orderDateInput);
            Controls.Add(label5);
            Controls.Add(label4);
            Controls.Add(label3);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(holdCheckBox);
            Controls.Add(brokerNameLabel);
            Controls.Add(brokerLabel);
            Controls.Add(pOHyphenLabel2);
            Controls.Add(pOHyphen1);
            Controls.Add(orderRevisionNumber);
            Controls.Add(purchaseOrderNumber);
            Controls.Add(salesPersonNumber);
            Controls.Add(pOLabel);
            Font = new Font("Segoe UI", 9F);
            ForeColor = Color.White;
            Name = "AddPO";
            Size = new Size(1290, 600);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label pOLabel;
        private TextBox salesPersonNumber;
        private TextBox purchaseOrderNumber;
        private TextBox orderRevisionNumber;
        private Label pOHyphen1;
        private Label pOHyphenLabel2;
        private Label brokerLabel;
        private Label brokerNameLabel;
        private CheckBox holdCheckBox;
        private Label label1;
        private Label label2;
        private Label label3;
        private Label label4;
        private Label label5;
        private TextBox orderDateInput;
        private TextBox shipDateInput;
        private TextBox delReqdInput;
        private TextBox textBox1;
        private TextBox textBox2;
        private Label label6;
        private Label label7;
        private Label label8;
        private Label label9;
        private Label label10;
        private Label label11;
        private Label label18;
        private Label label19;
        private TextBox textBox3;
        private TextBox textBox4;
        private TextBox textBox5;
        private TextBox textBox6;
        private TextBox textBox7;
        private TextBox textBox8;
        private TextBox textBox9;
        private TextBox textBox10;
        private TextBox textBox11;
        private TextBox textBox12;
        private TextBox textBox13;
        private TextBox textBox14;
    }
}
