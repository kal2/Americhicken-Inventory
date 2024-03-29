﻿namespace Inventory.Views.UserControls.MasterFilesUpdate.CustomerInfo
{
    partial class BillToCustomer
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
            customerNameTextBox = new TextBox();
            label1 = new Label();
            regNameTextBox = new TextBox();
            label2 = new Label();
            phoneMaskedTextBox = new MaskedTextBox();
            label6 = new Label();
            extensionTextBox = new TextBox();
            label3 = new Label();
            activeTextBox = new TextBox();
            label4 = new Label();
            internationalTextBox = new TextBox();
            label5 = new Label();
            faxMaskedTextBox = new MaskedTextBox();
            label7 = new Label();
            label8 = new Label();
            label9 = new Label();
            streetTextBox = new TextBox();
            label10 = new Label();
            cityTextBox = new TextBox();
            label11 = new Label();
            stateTextBox = new TextBox();
            label12 = new Label();
            zip4TextBox = new TextBox();
            zipTextBox = new TextBox();
            label13 = new Label();
            iLine1TextBox = new TextBox();
            label14 = new Label();
            iLine2TextBox = new TextBox();
            label15 = new Label();
            iLine3TextBox = new TextBox();
            label16 = new Label();
            label28 = new Label();
            creditLimitTextBox = new TextBox();
            label17 = new Label();
            label18 = new Label();
            termDaysDisplayLabel = new Label();
            label19 = new Label();
            fstSaleDisplayLabel = new Label();
            lastSaleDisplayLabel = new Label();
            label21 = new Label();
            dateReviewedMaskBox = new MaskedTextBox();
            label22 = new Label();
            label23 = new Label();
            credRqsTextBox = new TextBox();
            federatedCustomerTextBox = new TextBox();
            label20 = new Label();
            pOMessageTextBox = new TextBox();
            label24 = new Label();
            noteTextBox = new TextBox();
            label25 = new Label();
            note2TextBox = new TextBox();
            incentiveSalesTextBox = new TextBox();
            label26 = new Label();
            label27 = new Label();
            creditAppTextBox = new TextBox();
            label29 = new Label();
            creditAppDateMaskedTextBox = new MaskedTextBox();
            financialDateMaskedTextBox = new MaskedTextBox();
            financialStatementTextBox = new TextBox();
            label30 = new Label();
            maskedTextBox3 = new MaskedTextBox();
            dAndBReportTextBox = new TextBox();
            label31 = new Label();
            credDateMaskedTextBox = new MaskedTextBox();
            letterOfCredTextBox = new TextBox();
            label32 = new Label();
            label33 = new Label();
            label34 = new Label();
            label35 = new Label();
            label36 = new Label();
            label37 = new Label();
            label38 = new Label();
            highBalanceDisplayLabel = new Label();
            label40 = new Label();
            label42 = new Label();
            currentBalanceDisplayLabel = new Label();
            label44 = new Label();
            label45 = new Label();
            prevSixMonthAvgPayDisplayLabel = new Label();
            prev25DaysDisplayLabel = new Label();
            SuspendLayout();
            // 
            // customerNameTextBox
            // 
            customerNameTextBox.BackColor = Color.Maroon;
            customerNameTextBox.BorderStyle = BorderStyle.None;
            customerNameTextBox.Font = new Font("Segoe UI", 15F);
            customerNameTextBox.ForeColor = Color.White;
            customerNameTextBox.Location = new Point(228, 7);
            customerNameTextBox.Margin = new Padding(0);
            customerNameTextBox.MaxLength = 40;
            customerNameTextBox.Name = "customerNameTextBox";
            customerNameTextBox.Size = new Size(550, 27);
            customerNameTextBox.TabIndex = 1;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI", 16F);
            label1.ForeColor = Color.White;
            label1.Location = new Point(39, 9);
            label1.Name = "label1";
            label1.Size = new Size(186, 30);
            label1.TabIndex = 0;
            label1.Text = "BILL NAME (DBA):";
            // 
            // regNameTextBox
            // 
            regNameTextBox.BackColor = Color.Maroon;
            regNameTextBox.BorderStyle = BorderStyle.None;
            regNameTextBox.Font = new Font("Segoe UI", 15F);
            regNameTextBox.ForeColor = Color.White;
            regNameTextBox.Location = new Point(228, 41);
            regNameTextBox.Margin = new Padding(0);
            regNameTextBox.MaxLength = 40;
            regNameTextBox.Name = "regNameTextBox";
            regNameTextBox.Size = new Size(550, 27);
            regNameTextBox.TabIndex = 2;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Segoe UI", 16F);
            label2.ForeColor = Color.White;
            label2.Location = new Point(8, 43);
            label2.Name = "label2";
            label2.Size = new Size(217, 30);
            label2.TabIndex = 136;
            label2.Text = "REGISTER/CORP NM:";
            // 
            // phoneMaskedTextBox
            // 
            phoneMaskedTextBox.BackColor = Color.Maroon;
            phoneMaskedTextBox.BorderStyle = BorderStyle.None;
            phoneMaskedTextBox.CutCopyMaskFormat = MaskFormat.ExcludePromptAndLiterals;
            phoneMaskedTextBox.Font = new Font("Segoe UI", 15F);
            phoneMaskedTextBox.ForeColor = Color.White;
            phoneMaskedTextBox.Location = new Point(228, 75);
            phoneMaskedTextBox.Mask = "(999) 000-0000";
            phoneMaskedTextBox.Name = "phoneMaskedTextBox";
            phoneMaskedTextBox.Size = new Size(174, 27);
            phoneMaskedTextBox.TabIndex = 3;
            phoneMaskedTextBox.TextMaskFormat = MaskFormat.ExcludePromptAndLiterals;
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Segoe UI", 16F);
            label6.ForeColor = Color.White;
            label6.Location = new Point(135, 77);
            label6.Name = "label6";
            label6.Size = new Size(90, 30);
            label6.TabIndex = 145;
            label6.Text = "PHONE:";
            // 
            // extensionTextBox
            // 
            extensionTextBox.BackColor = Color.Maroon;
            extensionTextBox.BorderStyle = BorderStyle.None;
            extensionTextBox.Font = new Font("Segoe UI", 15F);
            extensionTextBox.ForeColor = Color.White;
            extensionTextBox.Location = new Point(465, 75);
            extensionTextBox.Margin = new Padding(0);
            extensionTextBox.MaxLength = 5;
            extensionTextBox.Name = "extensionTextBox";
            extensionTextBox.Size = new Size(75, 27);
            extensionTextBox.TabIndex = 4;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Segoe UI", 16F);
            label3.ForeColor = Color.White;
            label3.Location = new Point(408, 77);
            label3.Name = "label3";
            label3.Size = new Size(54, 30);
            label3.TabIndex = 146;
            label3.Text = "EXT:";
            // 
            // activeTextBox
            // 
            activeTextBox.BackColor = Color.Maroon;
            activeTextBox.BorderStyle = BorderStyle.None;
            activeTextBox.Font = new Font("Segoe UI", 15F);
            activeTextBox.ForeColor = Color.White;
            activeTextBox.Location = new Point(1242, 7);
            activeTextBox.Margin = new Padding(0);
            activeTextBox.MaxLength = 1;
            activeTextBox.Name = "activeTextBox";
            activeTextBox.Size = new Size(41, 27);
            activeTextBox.TabIndex = 6;
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Segoe UI", 16F);
            label4.ForeColor = Color.White;
            label4.Location = new Point(991, 9);
            label4.Name = "label4";
            label4.Size = new Size(248, 30);
            label4.TabIndex = 148;
            label4.Text = "ACTIVE/INACTIVE (Y/N):";
            // 
            // internationalTextBox
            // 
            internationalTextBox.BackColor = Color.Maroon;
            internationalTextBox.BorderStyle = BorderStyle.None;
            internationalTextBox.Font = new Font("Segoe UI", 15F);
            internationalTextBox.ForeColor = Color.White;
            internationalTextBox.Location = new Point(1242, 41);
            internationalTextBox.Margin = new Padding(0);
            internationalTextBox.MaxLength = 1;
            internationalTextBox.Name = "internationalTextBox";
            internationalTextBox.Size = new Size(41, 27);
            internationalTextBox.TabIndex = 7;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Segoe UI", 16F);
            label5.ForeColor = Color.White;
            label5.Location = new Point(884, 41);
            label5.Name = "label5";
            label5.Size = new Size(355, 30);
            label5.TabIndex = 150;
            label5.Text = "INTERNATIONAL CUSTOMER (Y/N):";
            // 
            // faxMaskedTextBox
            // 
            faxMaskedTextBox.BackColor = Color.Maroon;
            faxMaskedTextBox.BorderStyle = BorderStyle.None;
            faxMaskedTextBox.CutCopyMaskFormat = MaskFormat.ExcludePromptAndLiterals;
            faxMaskedTextBox.Font = new Font("Segoe UI", 15F);
            faxMaskedTextBox.ForeColor = Color.White;
            faxMaskedTextBox.Location = new Point(604, 75);
            faxMaskedTextBox.Mask = "(999) 000-0000";
            faxMaskedTextBox.Name = "faxMaskedTextBox";
            faxMaskedTextBox.Size = new Size(174, 27);
            faxMaskedTextBox.TabIndex = 5;
            faxMaskedTextBox.TextMaskFormat = MaskFormat.ExcludePromptAndLiterals;
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Segoe UI", 16F);
            label7.ForeColor = Color.White;
            label7.Location = new Point(543, 77);
            label7.Name = "label7";
            label7.Size = new Size(55, 30);
            label7.TabIndex = 153;
            label7.Text = "FAX:";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Font = new Font("Segoe UI", 16F);
            label8.ForeColor = Color.White;
            label8.Location = new Point(145, 112);
            label8.Name = "label8";
            label8.Size = new Size(261, 30);
            label8.TabIndex = 154;
            label8.Text = "UNITED STATES ADDRESS";
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Font = new Font("Segoe UI", 16F);
            label9.ForeColor = Color.White;
            label9.Location = new Point(873, 112);
            label9.Name = "label9";
            label9.Size = new Size(272, 30);
            label9.TabIndex = 155;
            label9.Text = "INTERNATIONAL ADDRESS";
            // 
            // streetTextBox
            // 
            streetTextBox.BackColor = Color.Maroon;
            streetTextBox.BorderStyle = BorderStyle.None;
            streetTextBox.Font = new Font("Segoe UI", 15F);
            streetTextBox.ForeColor = Color.White;
            streetTextBox.Location = new Point(100, 140);
            streetTextBox.Margin = new Padding(0);
            streetTextBox.MaxLength = 40;
            streetTextBox.Name = "streetTextBox";
            streetTextBox.Size = new Size(530, 27);
            streetTextBox.TabIndex = 8;
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Font = new Font("Segoe UI", 16F);
            label10.ForeColor = Color.White;
            label10.Location = new Point(8, 142);
            label10.Name = "label10";
            label10.Size = new Size(89, 30);
            label10.TabIndex = 156;
            label10.Text = "STREET:";
            // 
            // cityTextBox
            // 
            cityTextBox.BackColor = Color.Maroon;
            cityTextBox.BorderStyle = BorderStyle.None;
            cityTextBox.Font = new Font("Segoe UI", 15F);
            cityTextBox.ForeColor = Color.White;
            cityTextBox.Location = new Point(100, 174);
            cityTextBox.Margin = new Padding(0);
            cityTextBox.MaxLength = 20;
            cityTextBox.Name = "cityTextBox";
            cityTextBox.Size = new Size(530, 27);
            cityTextBox.TabIndex = 9;
            // 
            // label11
            // 
            label11.AutoSize = true;
            label11.Font = new Font("Segoe UI", 16F);
            label11.ForeColor = Color.White;
            label11.Location = new Point(35, 176);
            label11.Name = "label11";
            label11.Size = new Size(62, 30);
            label11.TabIndex = 158;
            label11.Text = "CITY:";
            // 
            // stateTextBox
            // 
            stateTextBox.BackColor = Color.Maroon;
            stateTextBox.BorderStyle = BorderStyle.None;
            stateTextBox.Font = new Font("Segoe UI", 15F);
            stateTextBox.ForeColor = Color.White;
            stateTextBox.Location = new Point(100, 208);
            stateTextBox.Margin = new Padding(0);
            stateTextBox.MaxLength = 2;
            stateTextBox.Name = "stateTextBox";
            stateTextBox.Size = new Size(58, 27);
            stateTextBox.TabIndex = 10;
            // 
            // label12
            // 
            label12.AutoSize = true;
            label12.Font = new Font("Segoe UI", 16F);
            label12.ForeColor = Color.White;
            label12.Location = new Point(22, 210);
            label12.Name = "label12";
            label12.Size = new Size(75, 30);
            label12.TabIndex = 160;
            label12.Text = "STATE:";
            // 
            // zip4TextBox
            // 
            zip4TextBox.BackColor = Color.Maroon;
            zip4TextBox.BorderStyle = BorderStyle.None;
            zip4TextBox.Font = new Font("Segoe UI", 15F);
            zip4TextBox.ForeColor = Color.White;
            zip4TextBox.Location = new Point(309, 208);
            zip4TextBox.Margin = new Padding(0);
            zip4TextBox.MaxLength = 4;
            zip4TextBox.Name = "zip4TextBox";
            zip4TextBox.Size = new Size(59, 27);
            zip4TextBox.TabIndex = 12;
            // 
            // zipTextBox
            // 
            zipTextBox.BackColor = Color.Maroon;
            zipTextBox.BorderStyle = BorderStyle.None;
            zipTextBox.Font = new Font("Segoe UI", 15F);
            zipTextBox.ForeColor = Color.White;
            zipTextBox.Location = new Point(228, 208);
            zipTextBox.Margin = new Padding(0);
            zipTextBox.MaxLength = 5;
            zipTextBox.Name = "zipTextBox";
            zipTextBox.Size = new Size(72, 27);
            zipTextBox.TabIndex = 11;
            // 
            // label13
            // 
            label13.AutoSize = true;
            label13.Font = new Font("Segoe UI", 16F);
            label13.ForeColor = Color.White;
            label13.Location = new Point(175, 210);
            label13.Name = "label13";
            label13.Size = new Size(49, 30);
            label13.TabIndex = 184;
            label13.Text = "ZIP:";
            // 
            // iLine1TextBox
            // 
            iLine1TextBox.BackColor = Color.Maroon;
            iLine1TextBox.BorderStyle = BorderStyle.None;
            iLine1TextBox.Font = new Font("Segoe UI", 15F);
            iLine1TextBox.ForeColor = Color.White;
            iLine1TextBox.Location = new Point(753, 140);
            iLine1TextBox.Margin = new Padding(0);
            iLine1TextBox.MaxLength = 35;
            iLine1TextBox.Name = "iLine1TextBox";
            iLine1TextBox.Size = new Size(530, 27);
            iLine1TextBox.TabIndex = 13;
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Font = new Font("Segoe UI", 16F);
            label14.ForeColor = Color.White;
            label14.Location = new Point(678, 142);
            label14.Name = "label14";
            label14.Size = new Size(72, 30);
            label14.TabIndex = 187;
            label14.Text = "ADR1:";
            // 
            // iLine2TextBox
            // 
            iLine2TextBox.BackColor = Color.Maroon;
            iLine2TextBox.BorderStyle = BorderStyle.None;
            iLine2TextBox.Font = new Font("Segoe UI", 15F);
            iLine2TextBox.ForeColor = Color.White;
            iLine2TextBox.Location = new Point(753, 174);
            iLine2TextBox.Margin = new Padding(0);
            iLine2TextBox.MaxLength = 35;
            iLine2TextBox.Name = "iLine2TextBox";
            iLine2TextBox.Size = new Size(530, 27);
            iLine2TextBox.TabIndex = 14;
            // 
            // label15
            // 
            label15.AutoSize = true;
            label15.Font = new Font("Segoe UI", 16F);
            label15.ForeColor = Color.White;
            label15.Location = new Point(678, 176);
            label15.Name = "label15";
            label15.Size = new Size(72, 30);
            label15.TabIndex = 189;
            label15.Text = "ADR2:";
            // 
            // iLine3TextBox
            // 
            iLine3TextBox.BackColor = Color.Maroon;
            iLine3TextBox.BorderStyle = BorderStyle.None;
            iLine3TextBox.Font = new Font("Segoe UI", 15F);
            iLine3TextBox.ForeColor = Color.White;
            iLine3TextBox.Location = new Point(753, 208);
            iLine3TextBox.Margin = new Padding(0);
            iLine3TextBox.MaxLength = 35;
            iLine3TextBox.Name = "iLine3TextBox";
            iLine3TextBox.Size = new Size(530, 27);
            iLine3TextBox.TabIndex = 15;
            // 
            // label16
            // 
            label16.AutoSize = true;
            label16.Font = new Font("Segoe UI", 16F);
            label16.ForeColor = Color.White;
            label16.Location = new Point(678, 210);
            label16.Name = "label16";
            label16.Size = new Size(72, 30);
            label16.TabIndex = 191;
            label16.Text = "ADR3:";
            // 
            // label28
            // 
            label28.BorderStyle = BorderStyle.Fixed3D;
            label28.Font = new Font("Segoe UI", 16F);
            label28.ForeColor = Color.White;
            label28.Location = new Point(20, 306);
            label28.Name = "label28";
            label28.Size = new Size(1250, 1);
            label28.TabIndex = 193;
            label28.UseMnemonic = false;
            // 
            // creditLimitTextBox
            // 
            creditLimitTextBox.BackColor = Color.Maroon;
            creditLimitTextBox.BorderStyle = BorderStyle.None;
            creditLimitTextBox.Font = new Font("Segoe UI", 15F);
            creditLimitTextBox.ForeColor = Color.White;
            creditLimitTextBox.Location = new Point(171, 326);
            creditLimitTextBox.Margin = new Padding(0);
            creditLimitTextBox.MaxLength = 7;
            creditLimitTextBox.Name = "creditLimitTextBox";
            creditLimitTextBox.Size = new Size(86, 27);
            creditLimitTextBox.TabIndex = 17;
            // 
            // label17
            // 
            label17.AutoSize = true;
            label17.Font = new Font("Segoe UI", 16F);
            label17.ForeColor = Color.White;
            label17.Location = new Point(19, 328);
            label17.Name = "label17";
            label17.Size = new Size(149, 30);
            label17.TabIndex = 194;
            label17.Text = "CREDIT LIMIT:";
            // 
            // label18
            // 
            label18.AutoSize = true;
            label18.Font = new Font("Segoe UI", 16F);
            label18.ForeColor = Color.White;
            label18.Location = new Point(287, 328);
            label18.Name = "label18";
            label18.Size = new Size(130, 30);
            label18.TabIndex = 196;
            label18.Text = "TERM DAYS:";
            // 
            // termDaysDisplayLabel
            // 
            termDaysDisplayLabel.AutoSize = true;
            termDaysDisplayLabel.Font = new Font("Segoe UI", 16F);
            termDaysDisplayLabel.ForeColor = Color.White;
            termDaysDisplayLabel.Location = new Point(423, 328);
            termDaysDisplayLabel.Name = "termDaysDisplayLabel";
            termDaysDisplayLabel.Size = new Size(39, 30);
            termDaysDisplayLabel.TabIndex = 197;
            termDaysDisplayLabel.Text = "##";
            // 
            // label19
            // 
            label19.AutoSize = true;
            label19.Font = new Font("Segoe UI", 16F);
            label19.ForeColor = Color.White;
            label19.Location = new Point(19, 362);
            label19.Name = "label19";
            label19.Size = new Size(119, 30);
            label19.TabIndex = 198;
            label19.Text = "SALES: 1ST";
            // 
            // fstSaleDisplayLabel
            // 
            fstSaleDisplayLabel.AutoSize = true;
            fstSaleDisplayLabel.Font = new Font("Segoe UI", 16F);
            fstSaleDisplayLabel.ForeColor = Color.White;
            fstSaleDisplayLabel.Location = new Point(144, 362);
            fstSaleDisplayLabel.Name = "fstSaleDisplayLabel";
            fstSaleDisplayLabel.Size = new Size(122, 30);
            fstSaleDisplayLabel.TabIndex = 199;
            fstSaleDisplayLabel.Text = "##/##/###";
            // 
            // lastSaleDisplayLabel
            // 
            lastSaleDisplayLabel.AutoSize = true;
            lastSaleDisplayLabel.Font = new Font("Segoe UI", 16F);
            lastSaleDisplayLabel.ForeColor = Color.White;
            lastSaleDisplayLabel.Location = new Point(355, 362);
            lastSaleDisplayLabel.Name = "lastSaleDisplayLabel";
            lastSaleDisplayLabel.Size = new Size(122, 30);
            lastSaleDisplayLabel.TabIndex = 201;
            lastSaleDisplayLabel.Text = "##/##/###";
            // 
            // label21
            // 
            label21.AutoSize = true;
            label21.Font = new Font("Segoe UI", 16F);
            label21.ForeColor = Color.White;
            label21.Location = new Point(287, 362);
            label21.Name = "label21";
            label21.Size = new Size(62, 30);
            label21.TabIndex = 200;
            label21.Text = "LAST";
            // 
            // dateReviewedMaskBox
            // 
            dateReviewedMaskBox.BackColor = Color.Maroon;
            dateReviewedMaskBox.BorderStyle = BorderStyle.None;
            dateReviewedMaskBox.Font = new Font("Segoe UI", 15F);
            dateReviewedMaskBox.ForeColor = Color.White;
            dateReviewedMaskBox.Location = new Point(200, 395);
            dateReviewedMaskBox.Mask = "00/00/0000";
            dateReviewedMaskBox.Name = "dateReviewedMaskBox";
            dateReviewedMaskBox.Size = new Size(124, 27);
            dateReviewedMaskBox.TabIndex = 18;
            dateReviewedMaskBox.ValidatingType = typeof(DateTime);
            // 
            // label22
            // 
            label22.AutoSize = true;
            label22.Font = new Font("Segoe UI", 16F);
            label22.ForeColor = Color.White;
            label22.Location = new Point(19, 397);
            label22.Name = "label22";
            label22.Size = new Size(175, 30);
            label22.TabIndex = 330;
            label22.Text = "DATE REVIEWED:";
            // 
            // label23
            // 
            label23.AutoSize = true;
            label23.Font = new Font("Segoe UI", 16F);
            label23.ForeColor = Color.White;
            label23.Location = new Point(19, 432);
            label23.Name = "label23";
            label23.Size = new Size(242, 30);
            label23.TabIndex = 331;
            label23.Text = "CREDIT REQUESTED BY:";
            // 
            // credRqsTextBox
            // 
            credRqsTextBox.BackColor = Color.Maroon;
            credRqsTextBox.BorderStyle = BorderStyle.None;
            credRqsTextBox.Font = new Font("Segoe UI", 15F);
            credRqsTextBox.ForeColor = Color.White;
            credRqsTextBox.Location = new Point(19, 462);
            credRqsTextBox.Margin = new Padding(0);
            credRqsTextBox.MaxLength = 32;
            credRqsTextBox.Name = "credRqsTextBox";
            credRqsTextBox.Size = new Size(530, 27);
            credRqsTextBox.TabIndex = 19;
            // 
            // federatedCustomerTextBox
            // 
            federatedCustomerTextBox.BackColor = Color.Maroon;
            federatedCustomerTextBox.BorderStyle = BorderStyle.None;
            federatedCustomerTextBox.Font = new Font("Segoe UI", 15F);
            federatedCustomerTextBox.ForeColor = Color.White;
            federatedCustomerTextBox.Location = new Point(327, 496);
            federatedCustomerTextBox.Margin = new Padding(0);
            federatedCustomerTextBox.MaxLength = 1;
            federatedCustomerTextBox.Name = "federatedCustomerTextBox";
            federatedCustomerTextBox.Size = new Size(41, 27);
            federatedCustomerTextBox.TabIndex = 20;
            // 
            // label20
            // 
            label20.AutoSize = true;
            label20.Font = new Font("Segoe UI", 16F);
            label20.ForeColor = Color.White;
            label20.Location = new Point(19, 498);
            label20.Name = "label20";
            label20.Size = new Size(305, 30);
            label20.TabIndex = 333;
            label20.Text = "FEDERATED CUSTOMER (Y/N):";
            // 
            // pOMessageTextBox
            // 
            pOMessageTextBox.BackColor = Color.Maroon;
            pOMessageTextBox.BorderStyle = BorderStyle.None;
            pOMessageTextBox.Font = new Font("Segoe UI", 15F);
            pOMessageTextBox.ForeColor = Color.White;
            pOMessageTextBox.Location = new Point(116, 568);
            pOMessageTextBox.Margin = new Padding(0);
            pOMessageTextBox.MaxLength = 20;
            pOMessageTextBox.Name = "pOMessageTextBox";
            pOMessageTextBox.Size = new Size(530, 27);
            pOMessageTextBox.TabIndex = 21;
            // 
            // label24
            // 
            label24.AutoSize = true;
            label24.Font = new Font("Segoe UI", 16F);
            label24.ForeColor = Color.White;
            label24.Location = new Point(13, 570);
            label24.Name = "label24";
            label24.Size = new Size(100, 30);
            label24.TabIndex = 335;
            label24.Text = "PO MSG:";
            // 
            // noteTextBox
            // 
            noteTextBox.BackColor = Color.Maroon;
            noteTextBox.BorderStyle = BorderStyle.None;
            noteTextBox.Font = new Font("Segoe UI", 15F);
            noteTextBox.ForeColor = Color.White;
            noteTextBox.Location = new Point(116, 602);
            noteTextBox.Margin = new Padding(0);
            noteTextBox.MaxLength = 20;
            noteTextBox.Name = "noteTextBox";
            noteTextBox.Size = new Size(1128, 27);
            noteTextBox.TabIndex = 22;
            // 
            // label25
            // 
            label25.AutoSize = true;
            label25.Font = new Font("Segoe UI", 16F);
            label25.ForeColor = Color.White;
            label25.Location = new Point(28, 604);
            label25.Name = "label25";
            label25.Size = new Size(85, 30);
            label25.TabIndex = 337;
            label25.Text = "NOTES:";
            // 
            // note2TextBox
            // 
            note2TextBox.BackColor = Color.Maroon;
            note2TextBox.BorderStyle = BorderStyle.None;
            note2TextBox.Font = new Font("Segoe UI", 15F);
            note2TextBox.ForeColor = Color.White;
            note2TextBox.Location = new Point(116, 636);
            note2TextBox.Margin = new Padding(0);
            note2TextBox.MaxLength = 20;
            note2TextBox.Name = "note2TextBox";
            note2TextBox.Size = new Size(1128, 27);
            note2TextBox.TabIndex = 23;
            // 
            // incentiveSalesTextBox
            // 
            incentiveSalesTextBox.BackColor = Color.Maroon;
            incentiveSalesTextBox.BorderStyle = BorderStyle.None;
            incentiveSalesTextBox.Font = new Font("Segoe UI", 15F);
            incentiveSalesTextBox.ForeColor = Color.White;
            incentiveSalesTextBox.Location = new Point(870, 250);
            incentiveSalesTextBox.Margin = new Padding(0);
            incentiveSalesTextBox.MaxLength = 20;
            incentiveSalesTextBox.Name = "incentiveSalesTextBox";
            incentiveSalesTextBox.Size = new Size(338, 27);
            incentiveSalesTextBox.TabIndex = 16;
            // 
            // label26
            // 
            label26.AutoSize = true;
            label26.Font = new Font("Segoe UI", 16F);
            label26.ForeColor = Color.White;
            label26.Location = new Point(678, 252);
            label26.Name = "label26";
            label26.Size = new Size(189, 30);
            label26.TabIndex = 340;
            label26.Text = "INCENTIVE SALES:";
            // 
            // label27
            // 
            label27.AutoSize = true;
            label27.Font = new Font("Segoe UI", 16F);
            label27.ForeColor = Color.White;
            label27.Location = new Point(740, 290);
            label27.Name = "label27";
            label27.Size = new Size(398, 30);
            label27.TabIndex = 342;
            label27.Text = "FILE DOCUMENTS:     (Y,N,R)          DATE";
            // 
            // creditAppTextBox
            // 
            creditAppTextBox.BackColor = Color.Maroon;
            creditAppTextBox.BorderStyle = BorderStyle.None;
            creditAppTextBox.Font = new Font("Segoe UI", 15F);
            creditAppTextBox.ForeColor = Color.White;
            creditAppTextBox.Location = new Point(962, 324);
            creditAppTextBox.Margin = new Padding(0);
            creditAppTextBox.MaxLength = 1;
            creditAppTextBox.Name = "creditAppTextBox";
            creditAppTextBox.Size = new Size(41, 27);
            creditAppTextBox.TabIndex = 24;
            // 
            // label29
            // 
            label29.AutoSize = true;
            label29.Font = new Font("Segoe UI", 16F);
            label29.ForeColor = Color.White;
            label29.Location = new Point(794, 324);
            label29.Name = "label29";
            label29.Size = new Size(133, 30);
            label29.TabIndex = 343;
            label29.Text = "CREDIT APP:";
            // 
            // creditAppDateMaskedTextBox
            // 
            creditAppDateMaskedTextBox.BackColor = Color.Maroon;
            creditAppDateMaskedTextBox.BorderStyle = BorderStyle.None;
            creditAppDateMaskedTextBox.Font = new Font("Segoe UI", 15F);
            creditAppDateMaskedTextBox.ForeColor = Color.White;
            creditAppDateMaskedTextBox.Location = new Point(1041, 324);
            creditAppDateMaskedTextBox.Mask = "00/00/0000";
            creditAppDateMaskedTextBox.Name = "creditAppDateMaskedTextBox";
            creditAppDateMaskedTextBox.Size = new Size(124, 27);
            creditAppDateMaskedTextBox.TabIndex = 25;
            creditAppDateMaskedTextBox.ValidatingType = typeof(DateTime);
            // 
            // financialDateMaskedTextBox
            // 
            financialDateMaskedTextBox.BackColor = Color.Maroon;
            financialDateMaskedTextBox.BorderStyle = BorderStyle.None;
            financialDateMaskedTextBox.Font = new Font("Segoe UI", 15F);
            financialDateMaskedTextBox.ForeColor = Color.White;
            financialDateMaskedTextBox.Location = new Point(1041, 358);
            financialDateMaskedTextBox.Mask = "00/00/0000";
            financialDateMaskedTextBox.Name = "financialDateMaskedTextBox";
            financialDateMaskedTextBox.Size = new Size(124, 27);
            financialDateMaskedTextBox.TabIndex = 27;
            financialDateMaskedTextBox.ValidatingType = typeof(DateTime);
            // 
            // financialStatementTextBox
            // 
            financialStatementTextBox.BackColor = Color.Maroon;
            financialStatementTextBox.BorderStyle = BorderStyle.None;
            financialStatementTextBox.Font = new Font("Segoe UI", 15F);
            financialStatementTextBox.ForeColor = Color.White;
            financialStatementTextBox.Location = new Point(962, 358);
            financialStatementTextBox.Margin = new Padding(0);
            financialStatementTextBox.MaxLength = 1;
            financialStatementTextBox.Name = "financialStatementTextBox";
            financialStatementTextBox.Size = new Size(41, 27);
            financialStatementTextBox.TabIndex = 26;
            // 
            // label30
            // 
            label30.AutoSize = true;
            label30.Font = new Font("Segoe UI", 16F);
            label30.ForeColor = Color.White;
            label30.Location = new Point(740, 358);
            label30.Name = "label30";
            label30.Size = new Size(187, 30);
            label30.TabIndex = 346;
            label30.Text = "FINANCIAL STMT:";
            // 
            // maskedTextBox3
            // 
            maskedTextBox3.BackColor = Color.Maroon;
            maskedTextBox3.BorderStyle = BorderStyle.None;
            maskedTextBox3.Font = new Font("Segoe UI", 15F);
            maskedTextBox3.ForeColor = Color.White;
            maskedTextBox3.Location = new Point(1041, 391);
            maskedTextBox3.Mask = "00/00/0000";
            maskedTextBox3.Name = "maskedTextBox3";
            maskedTextBox3.Size = new Size(124, 27);
            maskedTextBox3.TabIndex = 29;
            maskedTextBox3.ValidatingType = typeof(DateTime);
            // 
            // dAndBReportTextBox
            // 
            dAndBReportTextBox.BackColor = Color.Maroon;
            dAndBReportTextBox.BorderStyle = BorderStyle.None;
            dAndBReportTextBox.Font = new Font("Segoe UI", 15F);
            dAndBReportTextBox.ForeColor = Color.White;
            dAndBReportTextBox.Location = new Point(962, 391);
            dAndBReportTextBox.Margin = new Padding(0);
            dAndBReportTextBox.MaxLength = 1;
            dAndBReportTextBox.Name = "dAndBReportTextBox";
            dAndBReportTextBox.Size = new Size(41, 27);
            dAndBReportTextBox.TabIndex = 28;
            // 
            // label31
            // 
            label31.AutoSize = true;
            label31.Font = new Font("Segoe UI", 16F);
            label31.ForeColor = Color.White;
            label31.Location = new Point(780, 391);
            label31.Name = "label31";
            label31.Size = new Size(147, 30);
            label31.TabIndex = 349;
            label31.Text = "D&&B REPORT:";
            // 
            // credDateMaskedTextBox
            // 
            credDateMaskedTextBox.BackColor = Color.Maroon;
            credDateMaskedTextBox.BorderStyle = BorderStyle.None;
            credDateMaskedTextBox.Font = new Font("Segoe UI", 15F);
            credDateMaskedTextBox.ForeColor = Color.White;
            credDateMaskedTextBox.Location = new Point(1041, 424);
            credDateMaskedTextBox.Mask = "00/00/0000";
            credDateMaskedTextBox.Name = "credDateMaskedTextBox";
            credDateMaskedTextBox.Size = new Size(124, 27);
            credDateMaskedTextBox.TabIndex = 31;
            credDateMaskedTextBox.ValidatingType = typeof(DateTime);
            // 
            // letterOfCredTextBox
            // 
            letterOfCredTextBox.BackColor = Color.Maroon;
            letterOfCredTextBox.BorderStyle = BorderStyle.None;
            letterOfCredTextBox.Font = new Font("Segoe UI", 15F);
            letterOfCredTextBox.ForeColor = Color.White;
            letterOfCredTextBox.Location = new Point(962, 424);
            letterOfCredTextBox.Margin = new Padding(0);
            letterOfCredTextBox.MaxLength = 1;
            letterOfCredTextBox.Name = "letterOfCredTextBox";
            letterOfCredTextBox.Size = new Size(41, 27);
            letterOfCredTextBox.TabIndex = 30;
            // 
            // label32
            // 
            label32.AutoSize = true;
            label32.Font = new Font("Segoe UI", 16F);
            label32.ForeColor = Color.White;
            label32.Location = new Point(747, 426);
            label32.Name = "label32";
            label32.Size = new Size(180, 30);
            label32.TabIndex = 352;
            label32.Text = "LETTER OF CRED:";
            label32.TextAlign = ContentAlignment.TopRight;
            // 
            // label33
            // 
            label33.BorderStyle = BorderStyle.Fixed3D;
            label33.Font = new Font("Segoe UI", 16F);
            label33.ForeColor = Color.White;
            label33.Location = new Point(708, 321);
            label33.Name = "label33";
            label33.Size = new Size(500, 1);
            label33.TabIndex = 355;
            label33.UseMnemonic = false;
            // 
            // label34
            // 
            label34.BorderStyle = BorderStyle.Fixed3D;
            label34.Font = new Font("Segoe UI", 16F);
            label34.ForeColor = Color.White;
            label34.Location = new Point(708, 500);
            label34.Name = "label34";
            label34.Size = new Size(500, 1);
            label34.TabIndex = 357;
            label34.UseMnemonic = false;
            // 
            // label35
            // 
            label35.AutoSize = true;
            label35.Font = new Font("Segoe UI", 16F);
            label35.ForeColor = Color.White;
            label35.Location = new Point(728, 470);
            label35.Name = "label35";
            label35.Size = new Size(199, 30);
            label35.TabIndex = 356;
            label35.Text = "PERS GUARANTOR:";
            // 
            // label36
            // 
            label36.AutoSize = true;
            label36.Font = new Font("Segoe UI", 16F);
            label36.ForeColor = Color.White;
            label36.Location = new Point(809, 500);
            label36.Name = "label36";
            label36.Size = new Size(118, 30);
            label36.TabIndex = 358;
            label36.Text = "BALANCES";
            // 
            // label37
            // 
            label37.AutoSize = true;
            label37.Font = new Font("Segoe UI", 16F);
            label37.ForeColor = Color.White;
            label37.Location = new Point(1038, 540);
            label37.Name = "label37";
            label37.Size = new Size(0, 30);
            label37.TabIndex = 362;
            // 
            // label38
            // 
            label38.AutoSize = true;
            label38.Font = new Font("Segoe UI", 16F);
            label38.ForeColor = Color.White;
            label38.Location = new Point(965, 535);
            label38.Name = "label38";
            label38.Size = new Size(129, 30);
            label38.TabIndex = 361;
            label38.Text = "PREV 6 MO:";
            // 
            // highBalanceDisplayLabel
            // 
            highBalanceDisplayLabel.AutoSize = true;
            highBalanceDisplayLabel.Font = new Font("Segoe UI", 16F);
            highBalanceDisplayLabel.ForeColor = Color.White;
            highBalanceDisplayLabel.Location = new Point(842, 534);
            highBalanceDisplayLabel.Name = "highBalanceDisplayLabel";
            highBalanceDisplayLabel.Size = new Size(85, 30);
            highBalanceDisplayLabel.TabIndex = 360;
            highBalanceDisplayLabel.Text = "$$$$$$";
            // 
            // label40
            // 
            label40.AutoSize = true;
            label40.Font = new Font("Segoe UI", 16F);
            label40.ForeColor = Color.White;
            label40.Location = new Point(758, 534);
            label40.Name = "label40";
            label40.Size = new Size(71, 30);
            label40.TabIndex = 359;
            label40.Text = "HIGH:";
            // 
            // label42
            // 
            label42.AutoSize = true;
            label42.Font = new Font("Segoe UI", 16F);
            label42.ForeColor = Color.White;
            label42.Location = new Point(940, 570);
            label42.Name = "label42";
            label42.Size = new Size(154, 30);
            label42.TabIndex = 365;
            label42.Text = "PREV 25 DAYS:";
            // 
            // currentBalanceDisplayLabel
            // 
            currentBalanceDisplayLabel.AutoSize = true;
            currentBalanceDisplayLabel.Font = new Font("Segoe UI", 16F);
            currentBalanceDisplayLabel.ForeColor = Color.White;
            currentBalanceDisplayLabel.Location = new Point(842, 569);
            currentBalanceDisplayLabel.Name = "currentBalanceDisplayLabel";
            currentBalanceDisplayLabel.Size = new Size(85, 30);
            currentBalanceDisplayLabel.TabIndex = 364;
            currentBalanceDisplayLabel.Text = "$$$$$$";
            // 
            // label44
            // 
            label44.AutoSize = true;
            label44.Font = new Font("Segoe UI", 16F);
            label44.ForeColor = Color.White;
            label44.Location = new Point(717, 569);
            label44.Name = "label44";
            label44.Size = new Size(112, 30);
            label44.TabIndex = 363;
            label44.Text = "CURRENT:";
            // 
            // label45
            // 
            label45.AutoSize = true;
            label45.Font = new Font("Segoe UI", 16F);
            label45.ForeColor = Color.White;
            label45.Location = new Point(1059, 501);
            label45.Name = "label45";
            label45.Size = new Size(149, 30);
            label45.TabIndex = 367;
            label45.Text = "AVG PAY DAYS";
            // 
            // prevSixMonthAvgPayDisplayLabel
            // 
            prevSixMonthAvgPayDisplayLabel.AutoSize = true;
            prevSixMonthAvgPayDisplayLabel.Font = new Font("Segoe UI", 16F);
            prevSixMonthAvgPayDisplayLabel.ForeColor = Color.White;
            prevSixMonthAvgPayDisplayLabel.Location = new Point(1100, 535);
            prevSixMonthAvgPayDisplayLabel.Name = "prevSixMonthAvgPayDisplayLabel";
            prevSixMonthAvgPayDisplayLabel.Size = new Size(85, 30);
            prevSixMonthAvgPayDisplayLabel.TabIndex = 368;
            prevSixMonthAvgPayDisplayLabel.Text = "$$$$$$";
            // 
            // prev25DaysDisplayLabel
            // 
            prev25DaysDisplayLabel.AutoSize = true;
            prev25DaysDisplayLabel.Font = new Font("Segoe UI", 16F);
            prev25DaysDisplayLabel.ForeColor = Color.White;
            prev25DaysDisplayLabel.Location = new Point(1100, 570);
            prev25DaysDisplayLabel.Name = "prev25DaysDisplayLabel";
            prev25DaysDisplayLabel.Size = new Size(85, 30);
            prev25DaysDisplayLabel.TabIndex = 369;
            prev25DaysDisplayLabel.Text = "$$$$$$";
            // 
            // BillToCustomer
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.FromArgb(1, 0, 128);
            Controls.Add(prev25DaysDisplayLabel);
            Controls.Add(prevSixMonthAvgPayDisplayLabel);
            Controls.Add(label45);
            Controls.Add(label42);
            Controls.Add(currentBalanceDisplayLabel);
            Controls.Add(label44);
            Controls.Add(label37);
            Controls.Add(label38);
            Controls.Add(highBalanceDisplayLabel);
            Controls.Add(label40);
            Controls.Add(label36);
            Controls.Add(label34);
            Controls.Add(label35);
            Controls.Add(label33);
            Controls.Add(credDateMaskedTextBox);
            Controls.Add(letterOfCredTextBox);
            Controls.Add(label32);
            Controls.Add(maskedTextBox3);
            Controls.Add(dAndBReportTextBox);
            Controls.Add(label31);
            Controls.Add(financialDateMaskedTextBox);
            Controls.Add(financialStatementTextBox);
            Controls.Add(label30);
            Controls.Add(creditAppDateMaskedTextBox);
            Controls.Add(creditAppTextBox);
            Controls.Add(label29);
            Controls.Add(label27);
            Controls.Add(incentiveSalesTextBox);
            Controls.Add(label26);
            Controls.Add(note2TextBox);
            Controls.Add(noteTextBox);
            Controls.Add(label25);
            Controls.Add(pOMessageTextBox);
            Controls.Add(label24);
            Controls.Add(federatedCustomerTextBox);
            Controls.Add(label20);
            Controls.Add(credRqsTextBox);
            Controls.Add(label23);
            Controls.Add(label22);
            Controls.Add(dateReviewedMaskBox);
            Controls.Add(lastSaleDisplayLabel);
            Controls.Add(label21);
            Controls.Add(fstSaleDisplayLabel);
            Controls.Add(label19);
            Controls.Add(termDaysDisplayLabel);
            Controls.Add(label18);
            Controls.Add(creditLimitTextBox);
            Controls.Add(label17);
            Controls.Add(label28);
            Controls.Add(iLine3TextBox);
            Controls.Add(label16);
            Controls.Add(iLine2TextBox);
            Controls.Add(label15);
            Controls.Add(iLine1TextBox);
            Controls.Add(label14);
            Controls.Add(zip4TextBox);
            Controls.Add(zipTextBox);
            Controls.Add(label13);
            Controls.Add(stateTextBox);
            Controls.Add(label12);
            Controls.Add(cityTextBox);
            Controls.Add(label11);
            Controls.Add(streetTextBox);
            Controls.Add(label10);
            Controls.Add(label9);
            Controls.Add(label8);
            Controls.Add(faxMaskedTextBox);
            Controls.Add(label7);
            Controls.Add(internationalTextBox);
            Controls.Add(label5);
            Controls.Add(activeTextBox);
            Controls.Add(label4);
            Controls.Add(extensionTextBox);
            Controls.Add(label3);
            Controls.Add(phoneMaskedTextBox);
            Controls.Add(label6);
            Controls.Add(regNameTextBox);
            Controls.Add(label2);
            Controls.Add(customerNameTextBox);
            Controls.Add(label1);
            Name = "BillToCustomer";
            Size = new Size(1290, 688);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private TextBox customerNameTextBox;
        private Label label1;
        private TextBox regNameTextBox;
        private Label label2;
        private MaskedTextBox phoneMaskedTextBox;
        private Label label6;
        private TextBox extensionTextBox;
        private Label label3;
        private TextBox activeTextBox;
        private Label label4;
        private TextBox internationalTextBox;
        private Label label5;
        private MaskedTextBox faxMaskedTextBox;
        private Label label7;
        private Label label8;
        private Label label9;
        private TextBox streetTextBox;
        private Label label10;
        private TextBox cityTextBox;
        private Label label11;
        private TextBox stateTextBox;
        private Label label12;
        private TextBox zip4TextBox;
        private TextBox zipTextBox;
        private Label label13;
        private TextBox iLine1TextBox;
        private Label label14;
        private TextBox iLine2TextBox;
        private Label label15;
        private TextBox iLine3TextBox;
        private Label label16;
        private Label label28;
        private TextBox creditLimitTextBox;
        private Label label17;
        private Label label18;
        private Label termDaysDisplayLabel;
        private Label label19;
        private Label fstSaleDisplayLabel;
        private Label lastSaleDisplayLabel;
        private Label label21;
        private MaskedTextBox dateReviewedMaskBox;
        private Label label22;
        private Label label23;
        private TextBox credRqsTextBox;
        private TextBox federatedCustomerTextBox;
        private Label label20;
        private TextBox pOMessageTextBox;
        private Label label24;
        private TextBox noteTextBox;
        private Label label25;
        private TextBox note2TextBox;
        private TextBox incentiveSalesTextBox;
        private Label label26;
        private Label label27;
        private TextBox creditAppTextBox;
        private Label label29;
        private MaskedTextBox creditAppDateMaskedTextBox;
        private MaskedTextBox financialDateMaskedTextBox;
        private TextBox financialStatementTextBox;
        private Label label30;
        private MaskedTextBox maskedTextBox3;
        private TextBox dAndBReportTextBox;
        private Label label31;
        private MaskedTextBox credDateMaskedTextBox;
        private TextBox letterOfCredTextBox;
        private Label label32;
        private Label label33;
        private Label label34;
        private Label label35;
        private Label label36;
        private Label label37;
        private Label label38;
        private Label highBalanceDisplayLabel;
        private Label label40;
        private Label label42;
        private Label currentBalanceDisplayLabel;
        private Label label44;
        private Label label45;
        private Label prevSixMonthAvgPayDisplayLabel;
        private Label prev25DaysDisplayLabel;
    }
}
