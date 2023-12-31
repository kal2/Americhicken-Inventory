﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Inventory.Interfaces;
using Inventory.Models;
using Inventory.Services;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class RemitToUpdateInfo : UserControl, IActiveControlManager
    {
        // -- class variables -- //
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private rem_sup remitData;
        private readonly AmerichickenContext dbContext;

        public RemitToUpdateInfo(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
            dbContext = new AmerichickenContext();

            //wait for control to load then focus remitnametextbox
            this.Load += (s, e) => RemitNameTextBox.Focus();
        }

        // -- methods -- //
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Remit To Update Info");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Cancel    5. Save/Update Insurance");
            _mainWindow.SetTextBoxLabel("ACTION:");
        }
        public void GetRemitToData(rem_sup remitToObject)
        {
            remitData = remitToObject;
            RemitNameTextBox.Text = remitData.name?.Trim();
            phoneMaskTextBox.Text = remitData.area_code + remitData.phone;
            faxMaskTextBox.Text = remitData.fax?.Trim();
            remitStreetTextBox.Text = remitData.street?.Trim();
            remitCityTextBox.Text = remitData.city?.Trim();
            remitStateTextBox.Text = remitData.state?.Trim();
            remitZipTextBox.Text = remitData.zip?.Trim();
            remitZip4TextBox.Text = remitData.zip4?.Trim();
            payNetDaysTextBox.Text = remitData.net_days.ToString();
            indemnityContractTextBox.Text = remitData.indem_flg?.Trim();
            activeTextBox.Text = remitData.active?.Trim();
            contractDateMaskedBox.Text = remitData.indem_dt?.ToString("MM/dd/yyyy").Trim();
            creditLimitTextBox.Text = remitData.cred_lim?.ToString().Trim();
            beginDateMaskedBox.Text = remitData.beg_date?.ToString("MM/dd/yyyy").Trim();
            expireDateMaskedBox.Text = remitData.end_date?.ToString("MM/dd/yyyy").Trim();
            guarantorTextBox.Text = remitData.guaran?.Trim();
            noteTextBox.Text = remitData.note?.Trim();
            aInsuranceTextBox.Text = remitData.ins_co1?.Trim();
            bInsuranceTextBox.Text = remitData.ins_co2?.Trim();
            cInsuranceTextBox.Text = remitData.ins_co3?.Trim();
            dInsuranceTextBox.Text = remitData.ins_co4?.Trim();
            eInsuranceTextBox.Text = remitData.ins_co5?.Trim();
        }
        public void UpdateRemitData(rem_sup remitToData)
        {
            if (remitToData != null)
            {
                if (IsDataModified(remitToData))
                {
                    var existingRemData = dbContext.rem_sup.Find(remitToData.PK_rem_sup);
                    if (existingRemData != null)
                    {
                        existingRemData.name = RemitNameTextBox.Text.Trim();
                        existingRemData.area_code = phoneMaskTextBox.Text.Trim().Length >= 3 ? phoneMaskTextBox.Text.Trim()[..3] : null;
                        existingRemData.phone = phoneMaskTextBox.Text.Trim().Length >= 10 ? phoneMaskTextBox.Text.Trim()[3..] : null;
                        existingRemData.fax = faxMaskTextBox.Text.Trim();
                        existingRemData.street = remitStreetTextBox.Text.Trim();
                        existingRemData.city = remitCityTextBox.Text.Trim();
                        existingRemData.state = remitStateTextBox.Text.Trim();
                        existingRemData.zip = remitZipTextBox.Text.Trim();
                        existingRemData.zip4 = remitZip4TextBox.Text.Trim();
                        existingRemData.net_days = string.IsNullOrEmpty(payNetDaysTextBox.Text.Trim()) ? null : int.TryParse(payNetDaysTextBox.Text.Trim(), out var netDays) ? netDays : 0;
                        existingRemData.indem_flg = indemnityContractTextBox.Text.ToUpper().Trim();
                        existingRemData.active = activeTextBox.Text.ToUpper().Trim();
                        existingRemData.indem_dt = string.IsNullOrEmpty(contractDateMaskedBox.Text.Trim()) ? null : DateTime.TryParse(contractDateMaskedBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var indemDt) ? indemDt : DateTime.MinValue;
                        existingRemData.cred_lim = string.IsNullOrEmpty(creditLimitTextBox.Text.Trim()) ? null : decimal.TryParse(creditLimitTextBox.Text.Trim(), out var credLim) ? credLim : 0;
                        existingRemData.beg_date = string.IsNullOrEmpty(beginDateMaskedBox.Text.Trim()) ? null : DateTime.TryParse(beginDateMaskedBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var begDate) ? begDate : DateTime.MinValue;
                        existingRemData.end_date = string.IsNullOrEmpty(expireDateMaskedBox.Text.Trim()) ? null : DateTime.TryParse(expireDateMaskedBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var endDate) ? endDate : DateTime.MinValue;
                        existingRemData.guaran = guarantorTextBox.Text.Trim();
                        existingRemData.note = noteTextBox.Text.Trim();
                        existingRemData.ins_co1 = aInsuranceTextBox.Text.Trim();
                        existingRemData.ins_co2 = bInsuranceTextBox.Text.Trim();
                        existingRemData.ins_co3 = cInsuranceTextBox.Text.Trim();
                        existingRemData.ins_co4 = dInsuranceTextBox.Text.Trim();
                        existingRemData.ins_co5 = eInsuranceTextBox.Text.Trim();
                        dbContext.SaveChanges();
                        remitData = existingRemData;
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Remit Data not found in database. Please try again or contact developer.");
                    }
                }
            }
            else
            {
                DialogResult dialogResult = MessageBox.Show("You are about to add a new Remit To entry." + Environment.NewLine + "Would you like to continue?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
                if (dialogResult == DialogResult.Yes)
                {
                    rem_sup newRemitEntry = new ()
                    {
                        name = RemitNameTextBox.Text.Trim(),
                        area_code = phoneMaskTextBox.Text[..3],
                        phone = phoneMaskTextBox.Text.Substring(3, 7),
                        fax = faxMaskTextBox.Text.Trim(),
                        street = remitStreetTextBox.Text.Trim(),
                        city = remitCityTextBox.Text.Trim(),
                        state = remitStateTextBox.Text.Trim(),
                        zip = remitZipTextBox.Text.Trim(),
                        zip4 = remitZip4TextBox.Text.Trim(),
                        net_days = string.IsNullOrEmpty(payNetDaysTextBox.Text.Trim()) ? null: int.Parse(payNetDaysTextBox.Text),
                        indem_flg = indemnityContractTextBox.Text.Trim(),
                        active = activeTextBox.Text.Trim(),
                        indem_dt = string.IsNullOrEmpty(contractDateMaskedBox.Text.Trim()) ? null : DateTime.Parse(contractDateMaskedBox.Text, new CultureInfo("en-US")),
                        cred_lim = string.IsNullOrEmpty(creditLimitTextBox.Text.Trim()) ? null : int.Parse(creditLimitTextBox.Text),
                        beg_date = string.IsNullOrEmpty(beginDateMaskedBox.Text.Trim()) ? null : DateTime.Parse(beginDateMaskedBox.Text, new CultureInfo("en-US")),
                        end_date = string.IsNullOrEmpty(expireDateMaskedBox.Text.Trim()) ? null : DateTime.Parse(expireDateMaskedBox.Text, new CultureInfo("en-US")),
                        guaran = guarantorTextBox.Text.Trim(),
                        note = noteTextBox.Text.Trim(),
                        ins_co1 = aInsuranceTextBox.Text.Trim(),
                        ins_co2 = bInsuranceTextBox.Text.Trim(),
                        ins_co3 = cInsuranceTextBox.Text.Trim(),
                        ins_co4 = dInsuranceTextBox.Text.Trim(),
                        ins_co5 = eInsuranceTextBox.Text.Trim()
                    };
                    dbContext.rem_sup.Add(newRemitEntry);
                    dbContext.SaveChanges();
                    remitData = newRemitEntry;
                }
            }
        }
        public bool IsDataModified(rem_sup remitToData)
        {
            return remitToData == null || remitToData.name != RemitNameTextBox.Text || remitToData.area_code + remitToData.phone != phoneMaskTextBox.Text || remitToData.fax != faxMaskTextBox.Text || remitToData.street != remitStreetTextBox.Text || remitToData.city != remitCityTextBox.Text || remitToData.state != remitStateTextBox.Text || remitToData.zip != remitZipTextBox.Text || remitToData.zip4 != remitZip4TextBox.Text || remitToData.net_days != int.Parse(payNetDaysTextBox.Text) || remitToData.indem_flg != indemnityContractTextBox.Text || remitToData.active != activeTextBox.Text || remitToData.indem_dt != DateTime.Parse(contractDateMaskedBox.Text, new CultureInfo("en-US")) || remitToData.cred_lim != int.Parse(creditLimitTextBox.Text) || remitToData.beg_date != DateTime.Parse(beginDateMaskedBox.Text, new CultureInfo("en-US")) || remitToData.end_date != DateTime.Parse(expireDateMaskedBox.Text, new CultureInfo("en-US")) || remitToData.guaran != guarantorTextBox.Text || remitToData.note != noteTextBox.Text || remitToData.ins_co1 != aInsuranceTextBox.Text || remitToData.ins_co2 != bInsuranceTextBox.Text || remitToData.ins_co3 != cInsuranceTextBox.Text || remitToData.ins_co4 != dInsuranceTextBox.Text || remitToData.ins_co5 != eInsuranceTextBox.Text;
        }
        public void DeleteRemitTo(rem_sup remitToData)
        {
            if (remitToData != null)
            {
                var existingRemData = dbContext.rem_sup.Find(remitToData.PK_rem_sup);
                if (existingRemData != null)
                {
                    dbContext.rem_sup.Remove(existingRemData);
                    dbContext.SaveChanges();
                }
                else
                {
                    MessageBox.Show("ERROR: Remit Data not found in database. Please try again or contact developer.");
                }
            }
            else
            {
                   MessageBox.Show("ERROR: Remit Data is null. Please try again or contact developer.");
            }
        }

        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //save
                    UpdateRemitData(remitData);
                    break;
                case "2":
                    //edit
                    RemitNameTextBox.Focus();
                    break;
                case "3":
                    //delete
                    DeleteRemitTo(remitData);
                    break;
                case "4":
                    //cancel
                    _mainWindow.DisposeControl(this);
                    _activeControlManager.SetActiveControl(new MenuList(_mainWindow, _activeControlManager));
                    break;
                case "5":
                    //save/update insurance
                    UpdateRemitData(remitData);
                    _mainWindow.DisposeControl(this);
                    RemitInsurance remitInsuranceInstance = new (_mainWindow, _activeControlManager);
                    remitInsuranceInstance.GetRemitInsuranceData(remitData);
                    _activeControlManager.SetActiveControl(remitInsuranceInstance);

                    break;
                default:
                    MessageBox.Show("ERROR: Invalid user input, please contact developer");
                    break;
            }
        }
    }
}
