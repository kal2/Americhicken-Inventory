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
        private rem_sup _remitData;
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
        public void DisplayRemitToData(rem_sup remitToObject)
        {
            _remitData = remitToObject;
            RemitNameTextBox.Text = StringServices.TrimOrNull(_remitData.name);
            phoneMaskTextBox.Text = StringServices.TrimOrNull(_remitData.area_code) + StringServices.TrimOrNull(_remitData.phone);
            faxMaskTextBox.Text = StringServices.TrimOrNull(_remitData.fax);
            remitStreetTextBox.Text = StringServices.TrimOrNull(_remitData.street);
            remitCityTextBox.Text = StringServices.TrimOrNull(_remitData.city);
            remitStateTextBox.Text = StringServices.TrimOrNull(_remitData.state);
            remitZipTextBox.Text = StringServices.TrimOrNull(_remitData.zip);
            remitZip4TextBox.Text = StringServices.TrimOrNull(_remitData.zip4);
            payNetDaysTextBox.Text = StringServices.TrimOrNull(_remitData.net_days.ToString());
            indemnityContractTextBox.Text = StringServices.TrimOrNull(_remitData.indem_flg);
            activeTextBox.Text = StringServices.TrimOrNull(_remitData.active);
            contractDateMaskedBox.Text = StringServices.TrimOrNull(_remitData.indem_dt?.ToString("MM/dd/yyyy"));
            creditLimitTextBox.Text = StringServices.TrimOrNull(_remitData.cred_lim?.ToString());
            letterOfCreditTextBox.Text = StringServices.TrimOrNull(_remitData.let_crd?.ToString());
            beginDateMaskedBox.Text = StringServices.TrimOrNull(_remitData.beg_date?.ToString("MM/dd/yyyy"));
            expireDateMaskedBox.Text = StringServices.TrimOrNull(_remitData.end_date?.ToString("MM/dd/yyyy"));
            guarantorTextBox.Text = StringServices.TrimOrNull(_remitData.guaran);
            noteTextBox.Text = StringServices.TrimOrNull(_remitData.note);
            aInsuranceTextBox.Text = StringServices.TrimOrNull(_remitData.ins_co1);
            bInsuranceTextBox.Text = StringServices.TrimOrNull(_remitData.ins_co2);
            cInsuranceTextBox.Text = StringServices.TrimOrNull(_remitData.ins_co3);
            dInsuranceTextBox.Text = StringServices.TrimOrNull(_remitData.ins_co4);
            eInsuranceTextBox.Text = StringServices.TrimOrNull(_remitData.ins_co5);
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
                        existingRemData.name = StringServices.TrimOrNull(RemitNameTextBox.Text);
                        existingRemData.area_code = phoneMaskTextBox.Text.Trim().Length >= 3 ? phoneMaskTextBox.Text.Trim()[..3] : null;
                        existingRemData.phone = phoneMaskTextBox.Text.Trim().Length >= 10 ? phoneMaskTextBox.Text.Trim()[3..] : null;
                        existingRemData.fax = StringServices.TrimOrNull(faxMaskTextBox.Text);
                        existingRemData.street = StringServices.TrimOrNull(remitStreetTextBox.Text);
                        existingRemData.city = StringServices.TrimOrNull(remitCityTextBox.Text);
                        existingRemData.state = StringServices.TrimOrNull(remitStateTextBox.Text);
                        existingRemData.zip = StringServices.TrimOrNull(remitZipTextBox.Text);
                        existingRemData.zip4 = StringServices.TrimOrNull(remitZip4TextBox.Text);
                        existingRemData.net_days = string.IsNullOrEmpty(payNetDaysTextBox.Text.Trim()) ? null : int.TryParse(payNetDaysTextBox.Text.Trim(), out var netDays) ? netDays : 0;
                        existingRemData.indem_flg = StringServices.TrimOrNull(indemnityContractTextBox.Text.ToUpper());
                        existingRemData.active = StringServices.TrimOrNull(activeTextBox.Text.ToUpper());
                        existingRemData.indem_dt = string.IsNullOrEmpty(contractDateMaskedBox.Text.Trim()) ? null : DateTime.TryParse(contractDateMaskedBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var indemDt) ? indemDt : null;
                        existingRemData.cred_lim = string.IsNullOrEmpty(creditLimitTextBox.Text.Trim()) ? null : int.TryParse(creditLimitTextBox.Text.Trim(), out var credLim) ? credLim : 0;
                        existingRemData.let_crd = string.IsNullOrEmpty(letterOfCreditTextBox.Text.Trim()) ? null : int.TryParse(letterOfCreditTextBox.Text.Trim(), out var letCrd) ? letCrd : 0;
                        existingRemData.beg_date = string.IsNullOrEmpty(beginDateMaskedBox.Text.Trim()) ? null : DateTime.TryParse(beginDateMaskedBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var begDate) ? begDate : null;
                        existingRemData.end_date = string.IsNullOrEmpty(expireDateMaskedBox.Text.Trim()) ? null : DateTime.TryParse(expireDateMaskedBox.Text.Trim(), new CultureInfo("en-US"), DateTimeStyles.None, out var endDate) ? endDate : null;
                        existingRemData.guaran = StringServices.TrimOrNull(guarantorTextBox.Text);
                        existingRemData.note = StringServices.TrimOrNull(noteTextBox.Text);
                        existingRemData.ins_co1 = StringServices.TrimOrNull(aInsuranceTextBox.Text);
                        existingRemData.ins_co2 = StringServices.TrimOrNull(bInsuranceTextBox.Text);
                        existingRemData.ins_co3 = StringServices.TrimOrNull(cInsuranceTextBox.Text);
                        existingRemData.ins_co4 = StringServices.TrimOrNull(dInsuranceTextBox.Text);
                        existingRemData.ins_co5 = StringServices.TrimOrNull(eInsuranceTextBox.Text);
                        dbContext.SaveChanges();
                        _remitData = existingRemData;
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
                    rem_sup newRemitEntry = new()
                    {
                        name = StringServices.TrimOrNull(RemitNameTextBox.Text),
                        area_code = phoneMaskTextBox.Text[..3],
                        phone = phoneMaskTextBox.Text.Substring(3, 7),
                        fax = StringServices.TrimOrNull(faxMaskTextBox.Text),
                        street = StringServices.TrimOrNull(remitStreetTextBox.Text),
                        city = StringServices.TrimOrNull(remitCityTextBox.Text),
                        state = StringServices.TrimOrNull(remitStateTextBox.Text),
                        zip = StringServices.TrimOrNull(remitZipTextBox.Text),
                        zip4 = StringServices.TrimOrNull(remitZip4TextBox.Text),
                        net_days = string.IsNullOrEmpty(payNetDaysTextBox.Text.Trim()) ? null : int.Parse(payNetDaysTextBox.Text),
                        indem_flg = StringServices.TrimOrNull(indemnityContractTextBox.Text),
                        active = StringServices.TrimOrNull(activeTextBox.Text),
                        indem_dt = string.IsNullOrEmpty(contractDateMaskedBox.Text.Trim()) ? null : DateTime.TryParse(contractDateMaskedBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var contrDate) ? contrDate : null,
                        cred_lim = string.IsNullOrEmpty(creditLimitTextBox.Text.Trim()) ? null : int.TryParse(creditLimitTextBox.Text, out var credLim) ? credLim : null,
                        let_crd = string.IsNullOrEmpty(letterOfCreditTextBox.Text.Trim()) ? null : int.TryParse(letterOfCreditTextBox.Text, out var lettCred) ? lettCred : null,
                        beg_date = string.IsNullOrEmpty(beginDateMaskedBox.Text.Trim()) ? null : DateTime.TryParse(beginDateMaskedBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var begDate) ? begDate : null,
                        end_date = string.IsNullOrEmpty(expireDateMaskedBox.Text.Trim()) ? null : DateTime.TryParse(expireDateMaskedBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var expireDate) ? expireDate : null,
                        guaran = StringServices.TrimOrNull(guarantorTextBox.Text),
                        note = StringServices.TrimOrNull(noteTextBox.Text),
                        ins_co1 = StringServices.TrimOrNull(aInsuranceTextBox.Text),
                        ins_co2 = StringServices.TrimOrNull(bInsuranceTextBox.Text),
                        ins_co3 = StringServices.TrimOrNull(cInsuranceTextBox.Text),
                        ins_co4 = StringServices.TrimOrNull(dInsuranceTextBox.Text),
                        ins_co5 = StringServices.TrimOrNull(eInsuranceTextBox.Text)

                    };
                    dbContext.rem_sup.Add(newRemitEntry);
                    dbContext.SaveChanges();
                    _remitData = newRemitEntry;
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
                    UpdateRemitData(_remitData);
                    break;
                case "2":
                    //edit
                    RemitNameTextBox.Focus();
                    break;
                case "3":
                    //delete
                    DeleteRemitTo(_remitData);
                    break;
                case "4":
                    //cancel
                    _mainWindow.DisposeControl(this);
                    _activeControlManager.SetActiveControl(new MenuList(_mainWindow, _activeControlManager));
                    break;
                case "5":
                    //save/update insurance
                    UpdateRemitData(_remitData);
                    _mainWindow.DisposeControl(this);
                    RemitInsurance remitInsuranceInstance = new(_mainWindow, _activeControlManager);
                    remitInsuranceInstance.DisplayRemitInsuranceData(_remitData);
                    _activeControlManager.SetActiveControl(remitInsuranceInstance);

                    break;
                default:
                    MessageBox.Show("ERROR: Invalid user input, please contact developer");
                    break;
            }
        }

        private void activeTextBox_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
