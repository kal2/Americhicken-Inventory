﻿namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    partial class RemitSupplier
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
            RemitNameTextBox = new TextBox();
            faxMaskTextBox = new MaskedTextBox();
            phoneMaskTextBox = new MaskedTextBox();
            label17 = new Label();
            label2 = new Label();
            label12 = new Label();
            remitZipTextBox = new TextBox();
            remitStateTextBox = new TextBox();
            remitCityTextBox = new TextBox();
            remitStreetTextBox = new TextBox();
            label11 = new Label();
            label10 = new Label();
            label9 = new Label();
            label8 = new Label();
            payNetDaysTextBox = new TextBox();
            label3 = new Label();
            indemnityContractTextBox = new TextBox();
            label4 = new Label();
            activeTextBox = new TextBox();
            label5 = new Label();
            label6 = new Label();
            creditLimitTextBox = new TextBox();
            label7 = new Label();
            letterOfCreditTextBox = new TextBox();
            label13 = new Label();
            label14 = new Label();
            guarantorTextBox = new TextBox();
            label16 = new Label();
            noteTextBox = new TextBox();
            label18 = new Label();
            label20 = new Label();
            label21 = new Label();
            aInsuranceTextBox = new TextBox();
            label22 = new Label();
            bInsuranceTextBox = new TextBox();
            label23 = new Label();
            dInsuranceTextBox = new TextBox();
            label24 = new Label();
            cInsuranceTextBox = new TextBox();
            label25 = new Label();
            eInsuranceTextBox = new TextBox();
            label26 = new Label();
            label19 = new Label();
            label29 = new Label();
            remitZip4TextBox = new TextBox();
            contractDateMaskedBox = new MaskedTextBox();
            beginDateMaskedBox = new MaskedTextBox();
            label15 = new Label();
            expireDateMaskedBox = new MaskedTextBox();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI", 16F);
            label1.ForeColor = Color.White;
            label1.Location = new Point(185, 9);
            label1.Name = "label1";
            label1.Size = new Size(211, 30);
            label1.TabIndex = 101;
            label1.Text = "SUPPLIER REMIT TO:";
            // 
            // RemitNameTextBox
            // 
            RemitNameTextBox.BackColor = Color.Maroon;
            RemitNameTextBox.BorderStyle = BorderStyle.None;
            RemitNameTextBox.Font = new Font("Segoe UI", 15F);
            RemitNameTextBox.ForeColor = Color.White;
            RemitNameTextBox.Location = new Point(399, 6);
            RemitNameTextBox.Margin = new Padding(0);
            RemitNameTextBox.MaxLength = 40;
            RemitNameTextBox.Name = "RemitNameTextBox";
            RemitNameTextBox.Size = new Size(707, 27);
            RemitNameTextBox.TabIndex = 0;
            // 
            // faxMaskTextBox
            // 
            faxMaskTextBox.BackColor = Color.Maroon;
            faxMaskTextBox.BorderStyle = BorderStyle.None;
            faxMaskTextBox.CutCopyMaskFormat = MaskFormat.ExcludePromptAndLiterals;
            faxMaskTextBox.Font = new Font("Segoe UI", 15F);
            faxMaskTextBox.ForeColor = Color.White;
            faxMaskTextBox.Location = new Point(641, 43);
            faxMaskTextBox.Mask = "(999) 000-0000";
            faxMaskTextBox.Name = "faxMaskTextBox";
            faxMaskTextBox.Size = new Size(174, 27);
            faxMaskTextBox.TabIndex = 3;
            faxMaskTextBox.TextMaskFormat = MaskFormat.ExcludePromptAndLiterals;
            // 
            // phoneMaskTextBox
            // 
            phoneMaskTextBox.BackColor = Color.Maroon;
            phoneMaskTextBox.BorderStyle = BorderStyle.None;
            phoneMaskTextBox.CutCopyMaskFormat = MaskFormat.ExcludePromptAndLiterals;
            phoneMaskTextBox.Font = new Font("Segoe UI", 15F);
            phoneMaskTextBox.ForeColor = Color.White;
            phoneMaskTextBox.Location = new Point(399, 43);
            phoneMaskTextBox.Mask = "(999) 000-0000";
            phoneMaskTextBox.Name = "phoneMaskTextBox";
            phoneMaskTextBox.Size = new Size(174, 27);
            phoneMaskTextBox.TabIndex = 2;
            phoneMaskTextBox.TextMaskFormat = MaskFormat.ExcludePromptAndLiterals;
            // 
            // label17
            // 
            label17.AutoSize = true;
            label17.Font = new Font("Segoe UI", 16F);
            label17.ForeColor = Color.White;
            label17.Location = new Point(579, 46);
            label17.Name = "label17";
            label17.Size = new Size(55, 30);
            label17.TabIndex = 118;
            label17.Text = "FAX:";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Segoe UI", 16F);
            label2.ForeColor = Color.White;
            label2.Location = new Point(209, 46);
            label2.Name = "label2";
            label2.Size = new Size(184, 30);
            label2.TabIndex = 117;
            label2.Text = "PHONE NUMBER:";
            // 
            // label12
            // 
            label12.AutoSize = true;
            label12.Font = new Font("Segoe UI", 16F);
            label12.ForeColor = Color.White;
            label12.Location = new Point(61, 89);
            label12.Name = "label12";
            label12.Size = new Size(75, 30);
            label12.TabIndex = 128;
            label12.Text = "REMIT";
            // 
            // remitZipTextBox
            // 
            remitZipTextBox.BackColor = Color.Maroon;
            remitZipTextBox.BorderStyle = BorderStyle.None;
            remitZipTextBox.Font = new Font("Segoe UI", 15F);
            remitZipTextBox.ForeColor = Color.White;
            remitZipTextBox.Location = new Point(959, 122);
            remitZipTextBox.Margin = new Padding(0);
            remitZipTextBox.MaxLength = 5;
            remitZipTextBox.Name = "remitZipTextBox";
            remitZipTextBox.Size = new Size(66, 27);
            remitZipTextBox.TabIndex = 7;
            // 
            // remitStateTextBox
            // 
            remitStateTextBox.BackColor = Color.Maroon;
            remitStateTextBox.BorderStyle = BorderStyle.None;
            remitStateTextBox.Font = new Font("Segoe UI", 15F);
            remitStateTextBox.ForeColor = Color.White;
            remitStateTextBox.Location = new Point(859, 122);
            remitStateTextBox.Margin = new Padding(0);
            remitStateTextBox.MaxLength = 2;
            remitStateTextBox.Name = "remitStateTextBox";
            remitStateTextBox.Size = new Size(45, 27);
            remitStateTextBox.TabIndex = 6;
            // 
            // remitCityTextBox
            // 
            remitCityTextBox.BackColor = Color.Maroon;
            remitCityTextBox.BorderStyle = BorderStyle.None;
            remitCityTextBox.Font = new Font("Segoe UI", 15F);
            remitCityTextBox.ForeColor = Color.White;
            remitCityTextBox.Location = new Point(399, 122);
            remitCityTextBox.Margin = new Padding(0);
            remitCityTextBox.MaxLength = 20;
            remitCityTextBox.Name = "remitCityTextBox";
            remitCityTextBox.Size = new Size(345, 27);
            remitCityTextBox.TabIndex = 5;
            // 
            // remitStreetTextBox
            // 
            remitStreetTextBox.BackColor = Color.Maroon;
            remitStreetTextBox.BorderStyle = BorderStyle.None;
            remitStreetTextBox.Font = new Font("Segoe UI", 15F);
            remitStreetTextBox.ForeColor = Color.White;
            remitStreetTextBox.Location = new Point(399, 85);
            remitStreetTextBox.Margin = new Padding(0);
            remitStreetTextBox.MaxLength = 40;
            remitStreetTextBox.Name = "remitStreetTextBox";
            remitStreetTextBox.Size = new Size(707, 27);
            remitStreetTextBox.TabIndex = 4;
            // 
            // label11
            // 
            label11.AutoSize = true;
            label11.Font = new Font("Segoe UI", 16F);
            label11.ForeColor = Color.White;
            label11.Location = new Point(907, 124);
            label11.Name = "label11";
            label11.Size = new Size(49, 30);
            label11.TabIndex = 136;
            label11.Text = "ZIP:";
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Font = new Font("Segoe UI", 16F);
            label10.ForeColor = Color.White;
            label10.Location = new Point(781, 124);
            label10.Name = "label10";
            label10.Size = new Size(75, 30);
            label10.TabIndex = 135;
            label10.Text = "STATE:";
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Font = new Font("Segoe UI", 16F);
            label9.ForeColor = Color.White;
            label9.Location = new Point(334, 124);
            label9.Name = "label9";
            label9.Size = new Size(62, 30);
            label9.TabIndex = 134;
            label9.Text = "CITY:";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Font = new Font("Segoe UI", 16F);
            label8.ForeColor = Color.White;
            label8.Location = new Point(307, 88);
            label8.Name = "label8";
            label8.Size = new Size(89, 30);
            label8.TabIndex = 133;
            label8.Text = "STREET:";
            // 
            // payNetDaysTextBox
            // 
            payNetDaysTextBox.BackColor = Color.Maroon;
            payNetDaysTextBox.BorderStyle = BorderStyle.None;
            payNetDaysTextBox.Font = new Font("Segoe UI", 15F);
            payNetDaysTextBox.ForeColor = Color.White;
            payNetDaysTextBox.Location = new Point(399, 163);
            payNetDaysTextBox.Margin = new Padding(0);
            payNetDaysTextBox.MaxLength = 3;
            payNetDaysTextBox.Name = "payNetDaysTextBox";
            payNetDaysTextBox.Size = new Size(48, 27);
            payNetDaysTextBox.TabIndex = 9;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Segoe UI", 16F);
            label3.ForeColor = Color.White;
            label3.Location = new Point(176, 166);
            label3.Name = "label3";
            label3.Size = new Size(212, 30);
            label3.TabIndex = 138;
            label3.Text = "PAYMENT NET DAYS:";
            // 
            // indemnityContractTextBox
            // 
            indemnityContractTextBox.BackColor = Color.Maroon;
            indemnityContractTextBox.BorderStyle = BorderStyle.None;
            indemnityContractTextBox.Font = new Font("Segoe UI", 15F);
            indemnityContractTextBox.ForeColor = Color.White;
            indemnityContractTextBox.Location = new Point(1058, 164);
            indemnityContractTextBox.Margin = new Padding(0);
            indemnityContractTextBox.MaxLength = 1;
            indemnityContractTextBox.Name = "indemnityContractTextBox";
            indemnityContractTextBox.Size = new Size(48, 27);
            indemnityContractTextBox.TabIndex = 11;
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Segoe UI", 16F);
            label4.ForeColor = Color.White;
            label4.Location = new Point(745, 167);
            label4.Name = "label4";
            label4.Size = new Size(306, 30);
            label4.TabIndex = 140;
            label4.Text = "INDEMNITY CONTRACT (Y/N):";
            // 
            // activeTextBox
            // 
            activeTextBox.BackColor = Color.Maroon;
            activeTextBox.BorderStyle = BorderStyle.None;
            activeTextBox.Font = new Font("Segoe UI", 15F);
            activeTextBox.ForeColor = Color.White;
            activeTextBox.Location = new Point(399, 201);
            activeTextBox.Margin = new Padding(0);
            activeTextBox.MaxLength = 1;
            activeTextBox.Name = "activeTextBox";
            activeTextBox.Size = new Size(48, 27);
            activeTextBox.TabIndex = 10;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Segoe UI", 16F);
            label5.ForeColor = Color.White;
            label5.Location = new Point(155, 204);
            label5.Name = "label5";
            label5.Size = new Size(240, 30);
            label5.TabIndex = 142;
            label5.Text = "ACTIVE/INACTIVE (A/I):";
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Segoe UI", 16F);
            label6.ForeColor = Color.White;
            label6.Location = new Point(786, 204);
            label6.Name = "label6";
            label6.Size = new Size(184, 30);
            label6.TabIndex = 144;
            label6.Text = "CONTRACT DATE:";
            // 
            // creditLimitTextBox
            // 
            creditLimitTextBox.BackColor = Color.Maroon;
            creditLimitTextBox.BorderStyle = BorderStyle.None;
            creditLimitTextBox.Font = new Font("Segoe UI", 15F);
            creditLimitTextBox.ForeColor = Color.White;
            creditLimitTextBox.Location = new Point(399, 239);
            creditLimitTextBox.Margin = new Padding(0);
            creditLimitTextBox.MaxLength = 7;
            creditLimitTextBox.Name = "creditLimitTextBox";
            creditLimitTextBox.Size = new Size(154, 27);
            creditLimitTextBox.TabIndex = 13;
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Segoe UI", 16F);
            label7.ForeColor = Color.White;
            label7.Location = new Point(248, 242);
            label7.Name = "label7";
            label7.Size = new Size(149, 30);
            label7.TabIndex = 146;
            label7.Text = "CREDIT LIMIT:";
            // 
            // letterOfCreditTextBox
            // 
            letterOfCreditTextBox.BackColor = Color.Maroon;
            letterOfCreditTextBox.BorderStyle = BorderStyle.None;
            letterOfCreditTextBox.Font = new Font("Segoe UI", 15F);
            letterOfCreditTextBox.ForeColor = Color.White;
            letterOfCreditTextBox.Location = new Point(399, 278);
            letterOfCreditTextBox.Margin = new Padding(0);
            letterOfCreditTextBox.MaxLength = 7;
            letterOfCreditTextBox.Name = "letterOfCreditTextBox";
            letterOfCreditTextBox.Size = new Size(154, 27);
            letterOfCreditTextBox.TabIndex = 14;
            // 
            // label13
            // 
            label13.AutoSize = true;
            label13.Font = new Font("Segoe UI", 16F);
            label13.ForeColor = Color.White;
            label13.Location = new Point(147, 281);
            label13.Name = "label13";
            label13.Size = new Size(250, 30);
            label13.TabIndex = 148;
            label13.Text = "LETTER OF CREDIT AMT:";
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Font = new Font("Segoe UI", 16F);
            label14.ForeColor = Color.White;
            label14.Location = new Point(594, 280);
            label14.Name = "label14";
            label14.Size = new Size(134, 30);
            label14.TabIndex = 150;
            label14.Text = "DATE BEGIN:";
            // 
            // guarantorTextBox
            // 
            guarantorTextBox.BackColor = Color.Maroon;
            guarantorTextBox.BorderStyle = BorderStyle.None;
            guarantorTextBox.Font = new Font("Segoe UI", 15F);
            guarantorTextBox.ForeColor = Color.White;
            guarantorTextBox.Location = new Point(399, 317);
            guarantorTextBox.Margin = new Padding(0);
            guarantorTextBox.MaxLength = 20;
            guarantorTextBox.Name = "guarantorTextBox";
            guarantorTextBox.Size = new Size(329, 27);
            guarantorTextBox.TabIndex = 17;
            // 
            // label16
            // 
            label16.AutoSize = true;
            label16.Font = new Font("Segoe UI", 16F);
            label16.ForeColor = Color.White;
            label16.Location = new Point(251, 319);
            label16.Name = "label16";
            label16.Size = new Size(145, 30);
            label16.TabIndex = 154;
            label16.Text = "GUARANTOR:";
            // 
            // noteTextBox
            // 
            noteTextBox.BackColor = Color.Maroon;
            noteTextBox.BorderStyle = BorderStyle.None;
            noteTextBox.Font = new Font("Segoe UI", 15F);
            noteTextBox.ForeColor = Color.White;
            noteTextBox.Location = new Point(227, 357);
            noteTextBox.Margin = new Padding(0);
            noteTextBox.MaxLength = 60;
            noteTextBox.Name = "noteTextBox";
            noteTextBox.Size = new Size(915, 27);
            noteTextBox.TabIndex = 18;
            // 
            // label18
            // 
            label18.AutoSize = true;
            label18.Font = new Font("Segoe UI", 16F);
            label18.ForeColor = Color.White;
            label18.Location = new Point(149, 360);
            label18.Name = "label18";
            label18.Size = new Size(73, 30);
            label18.TabIndex = 156;
            label18.Text = "NOTE:";
            // 
            // label20
            // 
            label20.AutoSize = true;
            label20.Font = new Font("Segoe UI", 16F);
            label20.ForeColor = Color.White;
            label20.Location = new Point(365, 398);
            label20.Name = "label20";
            label20.Size = new Size(573, 30);
            label20.TabIndex = 158;
            label20.Text = "I N S U R A N C E   C O V E R A G E   I N F O R M A T I O N";
            // 
            // label21
            // 
            label21.BorderStyle = BorderStyle.Fixed3D;
            label21.Font = new Font("Segoe UI", 16F);
            label21.ForeColor = Color.White;
            label21.Location = new Point(19, 428);
            label21.Name = "label21";
            label21.Size = new Size(1250, 1);
            label21.TabIndex = 157;
            label21.UseMnemonic = false;
            // 
            // aInsuranceTextBox
            // 
            aInsuranceTextBox.BackColor = Color.Maroon;
            aInsuranceTextBox.BorderStyle = BorderStyle.None;
            aInsuranceTextBox.Font = new Font("Segoe UI", 15F);
            aInsuranceTextBox.ForeColor = Color.White;
            aInsuranceTextBox.Location = new Point(399, 435);
            aInsuranceTextBox.Margin = new Padding(0);
            aInsuranceTextBox.MaxLength = 20;
            aInsuranceTextBox.Name = "aInsuranceTextBox";
            aInsuranceTextBox.Size = new Size(705, 27);
            aInsuranceTextBox.TabIndex = 19;
            // 
            // label22
            // 
            label22.AutoSize = true;
            label22.Font = new Font("Segoe UI", 16F);
            label22.ForeColor = Color.White;
            label22.Location = new Point(229, 438);
            label22.Name = "label22";
            label22.Size = new Size(168, 30);
            label22.TabIndex = 160;
            label22.Text = "A. Insurance Co:";
            // 
            // bInsuranceTextBox
            // 
            bInsuranceTextBox.BackColor = Color.Maroon;
            bInsuranceTextBox.BorderStyle = BorderStyle.None;
            bInsuranceTextBox.Font = new Font("Segoe UI", 15F);
            bInsuranceTextBox.ForeColor = Color.White;
            bInsuranceTextBox.Location = new Point(400, 477);
            bInsuranceTextBox.Margin = new Padding(0);
            bInsuranceTextBox.MaxLength = 20;
            bInsuranceTextBox.Name = "bInsuranceTextBox";
            bInsuranceTextBox.Size = new Size(705, 27);
            bInsuranceTextBox.TabIndex = 20;
            // 
            // label23
            // 
            label23.AutoSize = true;
            label23.Font = new Font("Segoe UI", 16F);
            label23.ForeColor = Color.White;
            label23.Location = new Point(230, 480);
            label23.Name = "label23";
            label23.Size = new Size(167, 30);
            label23.TabIndex = 162;
            label23.Text = "B. Insurance Co:";
            // 
            // dInsuranceTextBox
            // 
            dInsuranceTextBox.BackColor = Color.Maroon;
            dInsuranceTextBox.BorderStyle = BorderStyle.None;
            dInsuranceTextBox.Font = new Font("Segoe UI", 15F);
            dInsuranceTextBox.ForeColor = Color.White;
            dInsuranceTextBox.Location = new Point(401, 561);
            dInsuranceTextBox.Margin = new Padding(0);
            dInsuranceTextBox.MaxLength = 20;
            dInsuranceTextBox.Name = "dInsuranceTextBox";
            dInsuranceTextBox.Size = new Size(705, 27);
            dInsuranceTextBox.TabIndex = 22;
            // 
            // label24
            // 
            label24.AutoSize = true;
            label24.Font = new Font("Segoe UI", 16F);
            label24.ForeColor = Color.White;
            label24.Location = new Point(231, 564);
            label24.Name = "label24";
            label24.Size = new Size(169, 30);
            label24.TabIndex = 166;
            label24.Text = "D. Insurance Co:";
            // 
            // cInsuranceTextBox
            // 
            cInsuranceTextBox.BackColor = Color.Maroon;
            cInsuranceTextBox.BorderStyle = BorderStyle.None;
            cInsuranceTextBox.Font = new Font("Segoe UI", 15F);
            cInsuranceTextBox.ForeColor = Color.White;
            cInsuranceTextBox.Location = new Point(400, 519);
            cInsuranceTextBox.Margin = new Padding(0);
            cInsuranceTextBox.MaxLength = 20;
            cInsuranceTextBox.Name = "cInsuranceTextBox";
            cInsuranceTextBox.Size = new Size(705, 27);
            cInsuranceTextBox.TabIndex = 21;
            // 
            // label25
            // 
            label25.AutoSize = true;
            label25.Font = new Font("Segoe UI", 16F);
            label25.ForeColor = Color.White;
            label25.Location = new Point(230, 522);
            label25.Name = "label25";
            label25.Size = new Size(168, 30);
            label25.TabIndex = 164;
            label25.Text = "C. Insurance Co:";
            // 
            // eInsuranceTextBox
            // 
            eInsuranceTextBox.BackColor = Color.Maroon;
            eInsuranceTextBox.BorderStyle = BorderStyle.None;
            eInsuranceTextBox.Font = new Font("Segoe UI", 15F);
            eInsuranceTextBox.ForeColor = Color.White;
            eInsuranceTextBox.Location = new Point(401, 603);
            eInsuranceTextBox.Margin = new Padding(0);
            eInsuranceTextBox.MaxLength = 20;
            eInsuranceTextBox.Name = "eInsuranceTextBox";
            eInsuranceTextBox.Size = new Size(705, 27);
            eInsuranceTextBox.TabIndex = 23;
            // 
            // label26
            // 
            label26.AutoSize = true;
            label26.Font = new Font("Segoe UI", 16F);
            label26.ForeColor = Color.White;
            label26.Location = new Point(231, 606);
            label26.Name = "label26";
            label26.Size = new Size(165, 30);
            label26.TabIndex = 168;
            label26.Text = "E. Insurance Co:";
            // 
            // label19
            // 
            label19.AutoSize = true;
            label19.Font = new Font("Segoe UI", 16F);
            label19.ForeColor = Color.White;
            label19.Location = new Point(45, 119);
            label19.Name = "label19";
            label19.Size = new Size(105, 30);
            label19.TabIndex = 169;
            label19.Text = "ADDRESS";
            // 
            // label29
            // 
            label29.AutoSize = true;
            label29.Font = new Font("Segoe UI", 16F, FontStyle.Italic);
            label29.ForeColor = Color.White;
            label29.Location = new Point(1026, 124);
            label29.Name = "label29";
            label29.Size = new Size(22, 30);
            label29.TabIndex = 172;
            label29.Text = "-";
            // 
            // remitZip4TextBox
            // 
            remitZip4TextBox.BackColor = Color.Maroon;
            remitZip4TextBox.BorderStyle = BorderStyle.None;
            remitZip4TextBox.Font = new Font("Segoe UI", 15F);
            remitZip4TextBox.ForeColor = Color.White;
            remitZip4TextBox.Location = new Point(1051, 122);
            remitZip4TextBox.Margin = new Padding(0);
            remitZip4TextBox.MaxLength = 4;
            remitZip4TextBox.Name = "remitZip4TextBox";
            remitZip4TextBox.Size = new Size(55, 27);
            remitZip4TextBox.TabIndex = 8;
            // 
            // contractDateMaskedBox
            // 
            contractDateMaskedBox.BackColor = Color.Maroon;
            contractDateMaskedBox.BorderStyle = BorderStyle.None;
            contractDateMaskedBox.Font = new Font("Segoe UI", 15F);
            contractDateMaskedBox.ForeColor = Color.White;
            contractDateMaskedBox.Location = new Point(982, 202);
            contractDateMaskedBox.Mask = "00/00/0000";
            contractDateMaskedBox.Name = "contractDateMaskedBox";
            contractDateMaskedBox.Size = new Size(124, 27);
            contractDateMaskedBox.TabIndex = 12;
            contractDateMaskedBox.ValidatingType = typeof(DateTime);
            // 
            // beginDateMaskedBox
            // 
            beginDateMaskedBox.BackColor = Color.Maroon;
            beginDateMaskedBox.BorderStyle = BorderStyle.None;
            beginDateMaskedBox.Font = new Font("Segoe UI", 15F);
            beginDateMaskedBox.ForeColor = Color.White;
            beginDateMaskedBox.Location = new Point(736, 277);
            beginDateMaskedBox.Mask = "00/00/0000";
            beginDateMaskedBox.Name = "beginDateMaskedBox";
            beginDateMaskedBox.Size = new Size(124, 27);
            beginDateMaskedBox.TabIndex = 15;
            beginDateMaskedBox.ValidatingType = typeof(DateTime);
            // 
            // label15
            // 
            label15.AutoSize = true;
            label15.Font = new Font("Segoe UI", 16F);
            label15.ForeColor = Color.White;
            label15.Location = new Point(891, 278);
            label15.Name = "label15";
            label15.Size = new Size(84, 30);
            label15.TabIndex = 152;
            label15.Text = "EXPIRE:";
            // 
            // expireDateMaskedBox
            // 
            expireDateMaskedBox.BackColor = Color.Maroon;
            expireDateMaskedBox.BorderStyle = BorderStyle.None;
            expireDateMaskedBox.Font = new Font("Segoe UI", 15F);
            expireDateMaskedBox.ForeColor = Color.White;
            expireDateMaskedBox.Location = new Point(982, 277);
            expireDateMaskedBox.Mask = "00/00/0000";
            expireDateMaskedBox.Name = "expireDateMaskedBox";
            expireDateMaskedBox.Size = new Size(124, 27);
            expireDateMaskedBox.TabIndex = 16;
            expireDateMaskedBox.ValidatingType = typeof(DateTime);
            // 
            // RemitSupplier
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.FromArgb(1, 0, 128);
            Controls.Add(expireDateMaskedBox);
            Controls.Add(beginDateMaskedBox);
            Controls.Add(contractDateMaskedBox);
            Controls.Add(remitZip4TextBox);
            Controls.Add(label29);
            Controls.Add(label12);
            Controls.Add(label19);
            Controls.Add(eInsuranceTextBox);
            Controls.Add(label26);
            Controls.Add(dInsuranceTextBox);
            Controls.Add(label24);
            Controls.Add(cInsuranceTextBox);
            Controls.Add(label25);
            Controls.Add(bInsuranceTextBox);
            Controls.Add(label23);
            Controls.Add(aInsuranceTextBox);
            Controls.Add(label22);
            Controls.Add(label20);
            Controls.Add(label21);
            Controls.Add(noteTextBox);
            Controls.Add(label18);
            Controls.Add(guarantorTextBox);
            Controls.Add(label16);
            Controls.Add(label15);
            Controls.Add(label14);
            Controls.Add(letterOfCreditTextBox);
            Controls.Add(label13);
            Controls.Add(creditLimitTextBox);
            Controls.Add(label7);
            Controls.Add(label6);
            Controls.Add(activeTextBox);
            Controls.Add(label5);
            Controls.Add(indemnityContractTextBox);
            Controls.Add(label4);
            Controls.Add(payNetDaysTextBox);
            Controls.Add(label3);
            Controls.Add(remitZipTextBox);
            Controls.Add(remitStateTextBox);
            Controls.Add(remitCityTextBox);
            Controls.Add(remitStreetTextBox);
            Controls.Add(label11);
            Controls.Add(label10);
            Controls.Add(label9);
            Controls.Add(label8);
            Controls.Add(faxMaskTextBox);
            Controls.Add(phoneMaskTextBox);
            Controls.Add(label17);
            Controls.Add(label2);
            Controls.Add(RemitNameTextBox);
            Controls.Add(label1);
            ForeColor = Color.White;
            Name = "RemitSupplier";
            Size = new Size(1290, 637);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private TextBox RemitNameTextBox;
        private MaskedTextBox faxMaskTextBox;
        private MaskedTextBox phoneMaskTextBox;
        private Label label17;
        private Label label2;
        private Label label12;
        private TextBox remitZipTextBox;
        private TextBox remitStateTextBox;
        private TextBox remitCityTextBox;
        private TextBox remitStreetTextBox;
        private Label label11;
        private Label label10;
        private Label label9;
        private Label label8;
        private TextBox payNetDaysTextBox;
        private Label label3;
        private TextBox indemnityContractTextBox;
        private Label label4;
        private TextBox activeTextBox;
        private Label label5;
        private Label label6;
        private TextBox creditLimitTextBox;
        private Label label7;
        private TextBox letterOfCreditTextBox;
        private Label label13;
        private Label label14;
        private TextBox guarantorTextBox;
        private Label label16;
        private TextBox noteTextBox;
        private Label label18;
        private Label label20;
        private Label label21;
        private TextBox aInsuranceTextBox;
        private Label label22;
        private TextBox bInsuranceTextBox;
        private Label label23;
        private TextBox dInsuranceTextBox;
        private Label label24;
        private TextBox cInsuranceTextBox;
        private Label label25;
        private TextBox eInsuranceTextBox;
        private Label label26;
        private Label label19;
        private Label label29;
        private TextBox remitZip4TextBox;
        private MaskedTextBox contractDateMaskedBox;
        private MaskedTextBox beginDateMaskedBox;
        private Label label15;
        private MaskedTextBox expireDateMaskedBox;
    }
}
