﻿using Inventory.Interfaces;
using Inventory.Models;
using Microsoft.EntityFrameworkCore.Query.Internal;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Inventory.Services;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class RemitInsurance : UserControl, IActiveControlManager
    {
        // --- class variables --- //
        private readonly ActiveControlManager _activeControlHelper;
        private readonly MainWindow _mainWindow;
        private readonly AmerichickenContext dbContext;
        private rem_sup? remitData;
        public RemitInsurance(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _activeControlHelper = activeControlManager;
            _mainWindow = mainWindow;
            dbContext = new AmerichickenContext();
            insTp1TextBox.Focus();
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Remit Insurance");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Cancel    4. Main Menu");
        }

        public void GetRemitInsuranceData(rem_sup remitToObject)
        {
            remitData = remitToObject;
            insTp1TextBox.Text = remitToObject.ins_tp1?.Trim() ?? "";
            insTp2TextBox.Text = remitToObject.ins_tp2?.Trim() ?? "";
            insTp3TextBox.Text = remitToObject.ins_tp3?.Trim() ?? "";
            insTp4TextBox.Text = remitToObject.ins_tp4?.Trim() ?? "";
            insTp5TextBox.Text = remitToObject.ins_tp5?.Trim() ?? "";
            policy1TextBox.Text = remitToObject.policy1?.Trim() ?? "";
            genBeginDateMaskBox.Text = remitToObject.gen_beg?.ToString("MM/dd/yyyy").Trim() ?? "";
            genEndDateMaskBox.Text = remitToObject.gen_end?.ToString("MM/dd/yyyy").Trim() ?? "";
            genLetterSentDateMaskBox.Text = remitToObject.gen_let?.ToString("MM/dd/yyyy").Trim() ?? "";
            genCov1TextBox.Text = remitToObject.gen_cov1?.ToString().Trim() ?? "";
            genCov2TextBox.Text = remitToObject.gen_cov2?.ToString().Trim() ?? "";
            genCov3TextBox.Text = remitToObject.gen_cov3?.ToString().Trim() ?? "";
            genCov4TextBox.Text = remitToObject.gen_cov4?.ToString().Trim() ?? "";
            genCov5TextBox.Text = remitToObject.gen_cov5?.ToString().Trim() ?? "";
            genCov6TextBox.Text = remitToObject.gen_cov6?.ToString().Trim() ?? "";
            policy2TextBox.Text = remitToObject.policy2?.Trim() ?? "";
            autoBeginDateMaskBox.Text = remitToObject.auto_beg?.ToString("MM/dd/yyyy").Trim() ?? "";
            autoEndDateMaskBox.Text = remitToObject.auto_end?.ToString("MM/dd/yyyy").Trim() ?? "";
            autoLetterSentDateMaskBox.Text = remitToObject.auto_let?.ToString("MM/dd/yyyy").Trim() ?? "";
            autoCov1TextBox.Text = remitToObject.auto_cov1?.ToString().Trim() ?? "";
            autoCov2TextBox.Text = remitToObject.auto_cov2?.ToString().Trim() ?? "";
            autoCov3TextBox.Text = remitToObject.auto_cov3?.ToString().Trim() ?? "";
            autoCov4TextBox.Text = remitToObject.auto_cov4?.ToString().Trim() ?? "";
            policy3TextBox.Text = remitToObject.policy3?.Trim() ?? "";
            excessBeginDateMaskBox.Text = remitToObject.exces_beg?.ToString("MM/dd/yyyy").Trim() ?? "";
            excessEndDateMaskBox.Text = remitToObject.exces_end?.ToString("MM/dd/yyyy").Trim() ?? "";
            excessLetterSentDateMaskBox.Text = remitToObject.exces_let?.ToString("MM/dd/yyyy").Trim() ?? "";
            excessCov1TextBox.Text = remitToObject.exce_cov1?.ToString().Trim() ?? "";
            excessCov2TextBox.Text = remitToObject.exce_cov2?.ToString().Trim() ?? "";
            policy4TextBox.Text = remitToObject.policy4?.Trim() ?? "";
            workBeginDateMaskBox.Text = remitToObject.work_beg?.ToString("MM/dd/yyyy").Trim() ?? "";
            workEndDateMaskBox.Text = remitToObject.work_end?.ToString("MM/dd/yyyy").Trim() ?? "";
            workLetterSentDateMaskBox.Text = remitToObject.work_let?.ToString("MM/dd/yyyy").Trim() ?? "";
            workCov1TextBox.Text = remitToObject.work_cov1?.ToString().Trim() ?? "";
            workCov2TextBox.Text = remitToObject.work_cov2?.ToString().Trim() ?? "";
            workCov3TextBox.Text = remitToObject.work_cov3?.ToString().Trim() ?? "";
            policy5TextBox.Text = remitToObject.policy5?.Trim() ?? "";
            recallBeginDateMaskBox.Text = remitToObject.recal_beg?.ToString("MM/dd/yyyy").Trim() ?? "";
            recallEndDateMaskBox.Text = remitToObject.recal_end?.ToString("MM/dd/yyyy").Trim() ?? "";
            recallLetterSentDateMaskBox.Text = remitToObject.recal_let?.ToString("MM/dd/yyyy").Trim() ?? "";
            recallCov1TextBox.Text = remitToObject.reca_cov1?.ToString().Trim() ?? "";
            cancellationTextBox.Text = remitToObject.cancel?.ToString().Trim() ?? "";
        }
        public void UpdateRemitInsuranceData(rem_sup remitToData)
        {
            if (remitToData != null)
            {
                if (IsDataModified(remitToData))
                {
                    var existingRemData = dbContext.rem_sup.Find(remitToData.PK_rem_sup);
                    if (existingRemData != null)
                    {
                        remitData.ins_tp1 = insTp1TextBox.Text.Trim();
                        remitData.ins_tp2 = insTp2TextBox.Text.Trim();
                        remitData.ins_tp3 = insTp3TextBox.Text.Trim();
                        remitData.ins_tp4 = insTp4TextBox.Text.Trim();
                        remitData.ins_tp5 = insTp5TextBox.Text.Trim();
                        remitData.policy1 = policy1TextBox.Text.Trim();
                        remitData.gen_beg = DateTime.Parse(genBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.gen_end = DateTime.Parse(genEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.gen_let = DateTime.Parse(genLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.gen_cov1 = decimal.Parse(genCov1TextBox.Text.Trim());
                        remitData.gen_cov2 = decimal.Parse(genCov2TextBox.Text.Trim());
                        remitData.gen_cov3 = decimal.Parse(genCov3TextBox.Text.Trim());
                        remitData.gen_cov4 = decimal.Parse(genCov4TextBox.Text.Trim());
                        remitData.gen_cov5 = decimal.Parse(genCov5TextBox.Text.Trim());
                        remitData.gen_cov6 = decimal.Parse(genCov6TextBox.Text.Trim());
                        remitData.policy2 = policy2TextBox.Text.Trim();
                        remitData.auto_beg = DateTime.Parse(autoBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.auto_end = DateTime.Parse(autoEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.auto_let = DateTime.Parse(autoLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.auto_cov1 = decimal.Parse(autoCov1TextBox.Text.Trim());
                        remitData.auto_cov2 = decimal.Parse(autoCov2TextBox.Text.Trim());
                        remitData.auto_cov3 = decimal.Parse(autoCov3TextBox.Text.Trim());
                        remitData.auto_cov4 = decimal.Parse(autoCov4TextBox.Text.Trim());
                        remitData.policy3 = policy3TextBox.Text.Trim();
                        remitData.exces_beg = DateTime.Parse(excessBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.exces_end = DateTime.Parse(excessEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.exces_let = DateTime.Parse(excessLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.exce_cov1 = decimal.Parse(excessCov1TextBox.Text.Trim());
                        remitData.exce_cov2 = decimal.Parse(excessCov2TextBox.Text.Trim());
                        remitData.policy4 = policy4TextBox.Text.Trim();
                        remitData.work_beg = DateTime.Parse(workBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.work_end = DateTime.Parse(workEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.work_let = DateTime.Parse(workLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.work_cov1 = decimal.Parse(workCov1TextBox.Text.Trim());
                        remitData.work_cov2 = decimal.Parse(workCov2TextBox.Text.Trim());
                        remitData.work_cov3 = decimal.Parse(workCov3TextBox.Text.Trim());
                        remitData.policy5 = policy5TextBox.Text.Trim();
                        remitData.recal_beg = DateTime.Parse(recallBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.recal_end = DateTime.Parse(recallEndDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.recal_let = DateTime.Parse(recallLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US"));
                        remitData.reca_cov1 = decimal.Parse(recallCov1TextBox.Text.Trim());
                        remitData.cancel = decimal.Parse(cancellationTextBox.Text.Trim());
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Remit Data not found in database. Please try again or contact developer.");
                    }
                }
            }
            else
            {
                MessageBox.Show("ERROR: Remit Data is null trying to update insurance info. Please try again or contact developer.");
            }

        }
        public bool IsDataModified(rem_sup remitToData)
        {
            return remitToData == null || remitToData.ins_tp1 != insTp1TextBox.Text.Trim() ||
                   remitToData.ins_tp2 != insTp2TextBox.Text.Trim() ||
                   remitToData.ins_tp3 != insTp3TextBox.Text.Trim() ||
                   remitToData.ins_tp4 != insTp4TextBox.Text.Trim() ||
                   remitToData.ins_tp5 != insTp5TextBox.Text.Trim() ||
                   remitToData.policy1 != policy1TextBox.Text.Trim() ||
                   remitToData.gen_beg != DateTime.Parse(genBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.gen_end != DateTime.Parse(genEndDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.gen_let != DateTime.Parse(genLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.gen_cov1 != decimal.Parse(genCov1TextBox.Text.Trim()) ||
                   remitToData.gen_cov2 != decimal.Parse(genCov2TextBox.Text.Trim()) ||
                   remitToData.gen_cov3 != decimal.Parse(genCov3TextBox.Text.Trim()) ||
                   remitToData.gen_cov4 != decimal.Parse(genCov4TextBox.Text.Trim()) ||
                   remitToData.gen_cov5 != decimal.Parse(genCov5TextBox.Text.Trim()) ||
                   remitToData.gen_cov6 != decimal.Parse(genCov6TextBox.Text.Trim()) ||
                   remitToData.policy2 != policy2TextBox.Text.Trim() ||
                   remitToData.auto_beg != DateTime.Parse(autoBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.auto_end != DateTime.Parse(autoEndDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.auto_let != DateTime.Parse(autoLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US")) ||
                   remitToData.auto_cov1 != decimal.Parse(autoCov1TextBox.Text.Trim()) ||
                   remitToData.auto_cov2 != decimal.Parse(autoCov2TextBox.Text.Trim()) ||
                   remitToData.auto_cov3 != decimal.Parse(autoCov3TextBox.Text.Trim()) ||
                   remitToData.auto_cov4 != decimal.Parse(autoCov4TextBox.Text.Trim()) ||
                   remitToData.policy3 != policy3TextBox.Text.Trim() ||
                   remitToData.exces_beg != DateTime.Parse(excessBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US")) || remitToData.exces_end != DateTime.Parse(excessEndDateMaskBox.Text.Trim(), new CultureInfo("en-US")) || remitToData.exces_let != DateTime.Parse(excessLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US")) || remitToData.exce_cov1 != decimal.Parse(excessCov1TextBox.Text.Trim()) || remitToData.exce_cov2 != decimal.Parse(excessCov2TextBox.Text.Trim()) || remitToData.policy4 != policy4TextBox.Text.Trim() || remitToData.work_beg != DateTime.Parse(workBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US")) || remitToData.work_end != DateTime.Parse(workEndDateMaskBox.Text.Trim(), new CultureInfo("en-US")) || remitToData.work_let != DateTime.Parse(workLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US")) || remitToData.work_cov1 != decimal.Parse(workCov1TextBox.Text.Trim()) || remitToData.work_cov2 != decimal.Parse(workCov2TextBox.Text.Trim()) || remitToData.work_cov3 != decimal.Parse(workCov3TextBox.Text.Trim()) || remitToData.policy5 != policy5TextBox.Text.Trim() || remitToData.recal_beg != DateTime.Parse(recallBeginDateMaskBox.Text.Trim(), new CultureInfo("en-US")) || remitToData.recal_end != DateTime.Parse(recallEndDateMaskBox.Text.Trim(), new CultureInfo("en-US")) || remitToData.recal_let != DateTime.Parse(recallLetterSentDateMaskBox.Text.Trim(), new CultureInfo("en-US")) || remitToData.reca_cov1 != decimal.Parse(recallCov1TextBox.Text.Trim()) || remitToData.cancel != decimal.Parse(cancellationTextBox.Text.Trim());
        }
        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //save
                    UpdateRemitInsuranceData(remitData);
                    break;
                case "2":
                    //edit
                    insTp1TextBox.Focus();
                    break;
                case "3":
                    //cancel
                    RemitToUpdateInfo remitInstance = new(_mainWindow, _activeControlHelper);
                    remitInstance.GetRemitToData(remitData);
                    _mainWindow.DisposeControl(this);
                    _activeControlHelper.SetActiveControl(remitInstance);

                    break;
                case "4":
                    //main menu
                    _mainWindow.DisposeControl(this);
                    _activeControlHelper.SetActiveControl(new MenuList(_mainWindow, _activeControlHelper));
                    break;
                default:
                    MessageBox.Show("Invalid input, please try again or contact developer");
                    break;  
            }
        }
    }
}