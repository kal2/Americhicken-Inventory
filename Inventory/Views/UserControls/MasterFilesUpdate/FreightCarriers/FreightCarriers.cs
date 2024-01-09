using Inventory.Interfaces;
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
using Microsoft.EntityFrameworkCore;

namespace Inventory.Views.UserControls.MasterFilesUpdate.FreightCarriers
{
    public partial class FreightCarriers : UserControl, IActiveControlManager
    {
        //-- class variables --//
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private readonly AmerichickenContext dbContext;
        private freight _freightData;
        public FreightCarriers(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager; 
            dbContext = new AmerichickenContext();

            //Focus on first textbox when form loads
            this.Load += (s, e) => freightNameTextBox.Focus();
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Freight Carrier");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Main Menu    5. Save/Update Insurance");
        }
        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //SaveFreightCarrier
                    UpdateFreightCarrierData(_freightData);
                    break;
                case "2":
                    //EditFreightCarrier
                    freightNameTextBox.Focus();
                    break;
                case "3":
                    //DeleteFreightCarrier
                    DialogResult dialogResult = MessageBox.Show("You are about to delete a freight carrier." + Environment.NewLine + "Would you like to continue?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
                        if (dialogResult == DialogResult.Yes)
                        {
                            DeleteFreight(_freightData!);
                        }
                        else if (dialogResult == DialogResult.No)
                        {
                            return;
                        }
                        else
                        {
                            MessageBox.Show("ERROR: Something went wrong deleting the freight carrier, please contact developer");
                        }
                    break;
                case "4":
                    //MainMenu
                    _mainWindow.DisposeControl(this);
                    _activeControlManager.SetActiveControl(new MenuList(_mainWindow, _activeControlManager));
                    break;
                case "5":
                    //FeightInsurance
                    UpdateFreightCarrierData(_freightData);
                    FreightInsurance freightInsurance = new(_mainWindow, _activeControlManager);
                    freightInsurance.GetFreightInsuranceData(_freightData);
                    _mainWindow.DisposeControl(this);
                    _activeControlManager.SetActiveControl(freightInsurance);
                    break;
                default:
                    MessageBox.Show("ERROR: Invalid input, please contact developer");
                    break;
            }
        }
        public void GetFreightCarrierData(freight freightData)
        {
            _freightData = freightData;
            //Display Freight Carrier Data
            freightNameTextBox.Text = _freightData.NAME?.Trim();
            freightStreetTextBox.Text = _freightData.STREET?.Trim();
            freightCityTextBox.Text = _freightData.CITY?.Trim();
            freightStateTextBox.Text = _freightData.STATE?.Trim();
            freightZipTextBox.Text = _freightData.ZIP?.Trim();
            freightZip4TextBox.Text = _freightData.ZIP4?.Trim();
            freightPhoneMaskedTextBox.Text = _freightData.AREA_CODE?.Trim() + _freightData.PHONE?.Trim();
            freightFaxMaskedTextBox.Text = _freightData.FAX_AREA?.Trim() + _freightData.FAX_PHONE?.Trim();
            contactTextBox.Text = _freightData.FRT_CONT?.Trim();
            payNameTextBox.Text = _freightData.PAY_NAME?.Trim();
            payAddressTextBox.Text = _freightData.PAY_STREET?.Trim();
            payCityTextBox.Text = _freightData.PAY_CITY?.Trim();
            payStateTextBox.Text = _freightData.PAY_STATE?.Trim();
            payZipTextBox.Text = _freightData.PAY_ZIP?.Trim();
            payZip4TextBox.Text = _freightData.PAY_ZIP4?.Trim();
            payPhoneMaskedTextBox.Text = _freightData.PAY_AREA?.Trim() + _freightData.PAY_PHONE?.Trim();
            payFaxMaskedTextBox.Text = _freightData.PAY_FAREA?.Trim() + _freightData.PAY_FPHONE?.Trim();
            activeHoldTextBox.Text = _freightData.ACTIVE?.Trim();
            noteTextBox.Text = _freightData.NOTE?.Trim();
            aInsuranceTextBox.Text = _freightData.INS_CO1?.Trim();
            bInsuranceTextBox.Text = _freightData.INS_CO2?.Trim();
            cInsuranceTextBox.Text = _freightData.INS_CO3?.Trim();
            dInsuranceTextBox.Text = _freightData.INS_CO4?.Trim();
        }
        private void UpdateFreightCarrierData(freight freightData)
        {
            if (freightData != null)
            {
                // Compare the modified values with the original values to detect changes, and only save if changes are detected
                if (IsDataModified(freightData))
                {
                    // Update the freight in the database
                    var existingFreight = dbContext.freight.Find(freightData.PK_freight);
                    if (existingFreight != null)
                    {
                        existingFreight.NAME = string.IsNullOrEmpty(freightNameTextBox.Text) ? null : freightNameTextBox.Text.Trim();
                        existingFreight.NAME = string.IsNullOrEmpty(freightNameTextBox.Text) ? null : freightNameTextBox.Text.Trim();
                        existingFreight.STREET = string.IsNullOrEmpty(freightStreetTextBox.Text) ? null : freightStreetTextBox.Text.Trim();
                        existingFreight.CITY = string.IsNullOrEmpty(freightCityTextBox.Text) ? null : freightCityTextBox.Text.Trim();
                        existingFreight.STATE = string.IsNullOrEmpty(freightStateTextBox.Text) ? null : freightStateTextBox.Text.Trim();
                        existingFreight.ZIP = string.IsNullOrEmpty(freightZipTextBox.Text) ? null : freightZipTextBox.Text.Trim();
                        existingFreight.ZIP4 = string.IsNullOrEmpty(freightZip4TextBox.Text) ? null : freightZip4TextBox.Text.Trim();
                        existingFreight.AREA_CODE = freightPhoneMaskedTextBox.Text.Length == 10 ? freightPhoneMaskedTextBox.Text.Substring(0, 3) : null;
                        existingFreight.PHONE = freightPhoneMaskedTextBox.Text.Length == 10 ? freightPhoneMaskedTextBox.Text.Substring(3, 7) : null;
                        existingFreight.FAX_AREA = freightFaxMaskedTextBox.Text.Length == 10 ? freightFaxMaskedTextBox.Text.Substring(0, 3) : null;
                        existingFreight.FAX_PHONE = freightFaxMaskedTextBox.Text.Length == 10 ? freightFaxMaskedTextBox.Text.Substring(3, 7) : null;
                        existingFreight.FRT_CONT = string.IsNullOrEmpty(contactTextBox.Text) ? null : contactTextBox.Text.Trim();
                        existingFreight.PAY_NAME = string.IsNullOrEmpty(payNameTextBox.Text) ? null : payNameTextBox.Text.Trim();
                        existingFreight.PAY_STREET = string.IsNullOrEmpty(payAddressTextBox.Text) ? null : payAddressTextBox.Text.Trim();
                        existingFreight.PAY_CITY = string.IsNullOrEmpty(payCityTextBox.Text) ? null : payCityTextBox.Text.Trim();
                        existingFreight.PAY_STATE = string.IsNullOrEmpty(payStateTextBox.Text) ? null : payStateTextBox.Text.Trim();
                        existingFreight.PAY_ZIP = string.IsNullOrEmpty(payZipTextBox.Text) ? null : payZipTextBox.Text.Trim();
                        existingFreight.PAY_ZIP4 = string.IsNullOrEmpty(payZip4TextBox.Text) ? null : payZip4TextBox.Text.Trim();
                        existingFreight.PAY_AREA = payPhoneMaskedTextBox.Text.Length == 10 ? payPhoneMaskedTextBox.Text.Substring(0, 3) : null;
                        existingFreight.PAY_PHONE = payPhoneMaskedTextBox.Text.Length == 10 ? payPhoneMaskedTextBox.Text.Substring(3, 7) : null;
                        existingFreight.PAY_FAREA = payFaxMaskedTextBox.Text.Length == 10 ? payFaxMaskedTextBox.Text.Substring(0, 3) : null;
                        existingFreight.PAY_FPHONE = payFaxMaskedTextBox.Text.Length == 10 ? payFaxMaskedTextBox.Text.Substring(3, 7) : null;
                        existingFreight.ACTIVE = activeHoldTextBox.Text.Trim().ToUpper();
                        existingFreight.NOTE = string.IsNullOrEmpty(noteTextBox.Text) ? null : noteTextBox.Text.Trim();
                        existingFreight.INS_CO1 = string.IsNullOrEmpty(aInsuranceTextBox.Text) ? null : aInsuranceTextBox.Text.Trim();
                        existingFreight.INS_CO2 = string.IsNullOrEmpty(bInsuranceTextBox.Text) ? null : bInsuranceTextBox.Text.Trim();
                        existingFreight.INS_CO3 = string.IsNullOrEmpty(cInsuranceTextBox.Text) ? null : cInsuranceTextBox.Text.Trim();
                        existingFreight.INS_CO4 = string.IsNullOrEmpty(dInsuranceTextBox.Text) ? null : dInsuranceTextBox.Text.Trim();

                        dbContext.SaveChanges();
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Freight Carrier not found, please contact developer");
                    }
                }
            }
            else
            {
                DialogResult dialogResult = MessageBox.Show("You are about to add a new freight carrier." + Environment.NewLine + "Would you like to continue?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
                if (dialogResult == DialogResult.Yes)
                {
                    freight newFreight = new()
                    {
                        NAME = string.IsNullOrEmpty(freightNameTextBox.Text) ? null : freightNameTextBox.Text.Trim(),
                        STREET = string.IsNullOrEmpty(freightStreetTextBox.Text) ? null : freightStreetTextBox.Text.Trim(),
                        CITY = string.IsNullOrEmpty(freightCityTextBox.Text) ? null : freightCityTextBox.Text.Trim(),
                        STATE = string.IsNullOrEmpty(freightStateTextBox.Text) ? null : freightStateTextBox.Text.Trim(),
                        ZIP = string.IsNullOrEmpty(freightZipTextBox.Text) ? null : freightZipTextBox.Text.Trim(),
                        ZIP4 = string.IsNullOrEmpty(freightZip4TextBox.Text) ? null : freightZip4TextBox.Text.Trim(),
                        AREA_CODE = freightPhoneMaskedTextBox.Text.Length == 10 ? freightPhoneMaskedTextBox.Text.Substring(0, 3) : null,
                        PHONE = freightPhoneMaskedTextBox.Text.Length == 10 ? freightPhoneMaskedTextBox.Text.Substring(3, 7) : null,
                        FAX_AREA = freightFaxMaskedTextBox.Text.Length == 10 ? freightFaxMaskedTextBox.Text.Substring(0, 3) : null,
                        FAX_PHONE = freightFaxMaskedTextBox.Text.Length == 10 ? freightFaxMaskedTextBox.Text.Substring(3, 7) : null,
                        FRT_CONT = string.IsNullOrEmpty(contactTextBox.Text) ? null : contactTextBox.Text.Trim(),
                        PAY_NAME = string.IsNullOrEmpty(payNameTextBox.Text) ? null : payNameTextBox.Text.Trim(),
                        PAY_STREET = string.IsNullOrEmpty(payAddressTextBox.Text) ? null : payAddressTextBox.Text.Trim(),
                        PAY_CITY = string.IsNullOrEmpty(payCityTextBox.Text) ? null : payCityTextBox.Text.Trim(),
                        PAY_STATE = string.IsNullOrEmpty(payStateTextBox.Text) ? null : payStateTextBox.Text.Trim(),
                        PAY_ZIP = string.IsNullOrEmpty(payZipTextBox.Text) ? null : payZipTextBox.Text.Trim(),
                        PAY_ZIP4 = string.IsNullOrEmpty(payZip4TextBox.Text) ? null : payZip4TextBox.Text.Trim(),
                        PAY_AREA = payPhoneMaskedTextBox.Text.Length == 10 ? payPhoneMaskedTextBox.Text.Substring(0, 3) : null,
                        PAY_PHONE = payPhoneMaskedTextBox.Text.Length == 10 ? payPhoneMaskedTextBox.Text.Substring(3, 7) : null,
                        PAY_FAREA = payFaxMaskedTextBox.Text.Length == 10 ? payFaxMaskedTextBox.Text.Substring(0, 3) : null,
                        PAY_FPHONE = payFaxMaskedTextBox.Text.Length == 10 ? payFaxMaskedTextBox.Text.Substring(3, 7) :null,
                        ACTIVE = string.IsNullOrEmpty(activeHoldTextBox.Text) ? null : activeHoldTextBox.Text.Trim(),
                        NOTE = string.IsNullOrEmpty(noteTextBox.Text) ? null : noteTextBox.Text.Trim(),
                        INS_CO1 = string.IsNullOrEmpty(aInsuranceTextBox.Text) ? null : aInsuranceTextBox.Text.Trim(),
                        INS_CO2 = string.IsNullOrEmpty(bInsuranceTextBox.Text) ? null : bInsuranceTextBox.Text.Trim(),
                        INS_CO3 = string.IsNullOrEmpty(cInsuranceTextBox.Text) ? null : cInsuranceTextBox.Text.Trim(),
                        INS_CO4 = string.IsNullOrEmpty(dInsuranceTextBox.Text) ? null : dInsuranceTextBox.Text.Trim(),
                    };
                    _freightData = newFreight;
                    dbContext.freight.Add(newFreight);
                    dbContext.SaveChanges();
                }
                else if (dialogResult == DialogResult.No)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong adding the freight carrier, please contact developer");
                }
            }
        }
        private bool IsDataModified(freight freightData)
        {

            return freightData == null || freightData.NAME != freightNameTextBox.Text ||
                   freightData.STREET != freightStreetTextBox.Text ||
                   freightData.CITY != freightCityTextBox.Text ||
                   freightData.STATE != freightStateTextBox.Text ||
                   freightData.ZIP != freightZipTextBox.Text ||
                   freightData.ZIP4 != freightZip4TextBox.Text ||
                   freightData.AREA_CODE + freightData.PHONE != freightPhoneMaskedTextBox.Text ||
                   freightData.FAX_AREA + freightData.FAX_PHONE != freightFaxMaskedTextBox.Text ||
                   freightData.FRT_CONT != contactTextBox.Text ||
                   freightData.PAY_NAME != payNameTextBox.Text ||
                   freightData.PAY_STREET != payAddressTextBox.Text ||
                   freightData.PAY_CITY != payCityTextBox.Text ||
                   freightData.PAY_STATE != payStateTextBox.Text ||
                   freightData.PAY_ZIP != payZipTextBox.Text ||
                   freightData.PAY_ZIP4 != payZip4TextBox.Text ||
                   freightData.PAY_AREA + freightData.PAY_PHONE != payPhoneMaskedTextBox.Text ||
                   freightData.PAY_FAREA + freightData.PAY_FPHONE != payFaxMaskedTextBox.Text ||
                   freightData.ACTIVE != activeHoldTextBox.Text ||
                   freightData.NOTE != noteTextBox.Text ||
                   freightData.INS_CO1 != aInsuranceTextBox.Text ||
                   freightData.INS_CO2 != bInsuranceTextBox.Text ||
                   freightData.INS_CO3 != cInsuranceTextBox.Text ||
                   freightData.INS_CO4 != dInsuranceTextBox.Text;
        }
        private void DeleteFreight(freight freightData)
        {
            if (freightData != null)
            {
                dbContext.freight.Remove(freightData);
                dbContext.SaveChanges();
            }
            else
            {
                MessageBox.Show("ERROR: Freight Carrier not found, please contact developer");
            }
        }
    }
}
