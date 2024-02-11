using Inventory.Interfaces;
using Inventory.Models;
using Inventory.Services;
using System.Windows.Forms;
using static Inventory.Programs.Utilities.UserConfirmation;

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

            this.Load += (s, e) => freightNameTextBox.Focus();
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("VIEW/CHANGE/DELETE FREIGHT CARRIER INFORMATION");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Cancel    5. Save/Update Insurance");
        }

        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    UpdateFreightCarrierData(_freightData);
                    break;
                case "2":
                    freightNameTextBox.Focus();
                    break;
                case "3":
                    DeleteFreight(_freightData!);
                    break;
                case "4":
                    using (var _programLoader = new ProgramLoader(_mainWindow, _activeControlManager))
                    {
                        _mainWindow.DisposeControl(this);
                        _programLoader.LoadProgram("freight");
                    }
                    break;
                case "5":
                    SaveAndUpdateInsurance();
                    break;
                default:
                    MessageBox.Show("ERROR: Invalid input, please contact developer");
                    break;
            }
        }

        private void UpdateExistingFreight(freight freightData)
        {
            var existingFreight = dbContext.freight.Find(freightData.PK_freight);
            if (existingFreight != null)
            {
                SetFreightProperties(existingFreight);
                dbContext.SaveChanges();
            }
            else
            {
                MessageBox.Show("ERROR: Freight Carrier not found, please contact developer");
            }
        }

        private void CreateNewFreight()
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserConfirmation);
            _mainWindow.AskUserConfirmation("You are about to add a new freight carrier. Would you like to continue?   (Y/N)");
            
            void HandleUserConfirmation(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    freight newFreight = new();
                    SetFreightProperties(newFreight);
                    _freightData = newFreight;
                    dbContext.freight.Add(newFreight);
                    dbContext.SaveChanges();
                }
                else if (e.UserChoice == false)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong adding the freight carrier, please contact developer");
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserConfirmation);
            }
        }

        private void UpdateFreightCarrierData(freight freightData)
        {
            if (freightData != null)
            {
                if (IsDataModified(freightData))
                {
                    UpdateExistingFreight(freightData);
                }
            }
            else
            {
                CreateNewFreight();
            }
        }

        private void SaveAndUpdateInsurance()
        {
            UpdateFreightCarrierData(_freightData);
            FreightInsurance freightInsurance = new(_mainWindow, _activeControlManager);
            freightInsurance.GetFreightInsuranceData(_freightData);
            _mainWindow.DisposeControl(this);
            _activeControlManager.SetActiveControl(freightInsurance);
        }

        private void DeleteFreight(freight freightData)
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserInput);

            _mainWindow.AskUserConfirmation("You are about to delete a freight carrier. Would you like to continue?   (Y/N)");
            void HandleUserInput(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    var existingFreightData = dbContext.freight.Find(freightData.PK_freight);
                    if (existingFreightData != null)
                    {
                        dbContext.freight.Remove(existingFreightData);
                        dbContext.SaveChanges();
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Freight Carrier not found, please contact developer");
                    }
                }
                else if (e.UserChoice == false)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong deleting the freight carrier, please contact developer");
                }
            _mainWindow.DetachConfirmationEventListener(HandleUserInput);
            }
        }

        public void DisplayFreightCarrierData(freight freightData)
        {
            _freightData = freightData;
            freightNameTextBox.Text = _freightData.NAME;
            freightStreetTextBox.Text = _freightData.STREET;
            freightCityTextBox.Text = _freightData.CITY;
            freightStateTextBox.Text = _freightData.STATE;
            freightZipTextBox.Text = _freightData.ZIP;
            freightZip4TextBox.Text = _freightData.ZIP4;
            freightPhoneMaskedTextBox.Text = _freightData.AREA_CODE + _freightData.PHONE;
            freightFaxMaskedTextBox.Text = _freightData.FAX_AREA + _freightData.FAX_PHONE;
            contactTextBox.Text = _freightData.FRT_CONT;
            payNameTextBox.Text = _freightData.PAY_NAME;
            payAddressTextBox.Text = _freightData.PAY_STREET;
            payCityTextBox.Text = _freightData.PAY_CITY;
            payStateTextBox.Text = _freightData.PAY_STATE;
            payZipTextBox.Text = _freightData.PAY_ZIP;
            payZip4TextBox.Text = _freightData.PAY_ZIP4;
            payPhoneMaskedTextBox.Text = _freightData.PAY_AREA + _freightData.PAY_PHONE;
            payFaxMaskedTextBox.Text = _freightData.PAY_FAREA + _freightData.PAY_FPHONE;
            activeHoldTextBox.Text = _freightData.ACTIVE;
            noteTextBox.Text = _freightData.NOTE;
            aInsuranceTextBox.Text = _freightData.INS_CO1;
            bInsuranceTextBox.Text = _freightData.INS_CO2;
            cInsuranceTextBox.Text = _freightData.INS_CO3;
            dInsuranceTextBox.Text = _freightData.INS_CO4;
        }

        private void SetFreightProperties(freight freightData)
        {
            freightData.NAME = StringServices.TrimOrNull(freightNameTextBox.Text);
            freightData.STREET = StringServices.TrimOrNull(freightStreetTextBox.Text);
            freightData.CITY = StringServices.TrimOrNull(freightCityTextBox.Text);
            freightData.STATE = StringServices.TrimOrNull(freightStateTextBox.Text);
            freightData.ZIP = StringServices.TrimOrNull(freightZipTextBox.Text);
            freightData.ZIP4 = StringServices.TrimOrNull(freightZip4TextBox.Text);
            freightData.AREA_CODE = StringServices.TrimOrNull(freightPhoneMaskedTextBox.Text.Substring(0, 3));
            freightData.PHONE = StringServices.TrimOrNull(freightPhoneMaskedTextBox.Text.Substring(3, 7));
            freightData.FAX_AREA = StringServices.TrimOrNull(freightFaxMaskedTextBox.Text.Substring(0, 3));
            freightData.FAX_PHONE = StringServices.TrimOrNull(freightFaxMaskedTextBox.Text.Substring(3, 7));
            freightData.FRT_CONT = StringServices.TrimOrNull(contactTextBox.Text);
            freightData.PAY_NAME = StringServices.TrimOrNull(payNameTextBox.Text);
            freightData.PAY_STREET = StringServices.TrimOrNull(payAddressTextBox.Text);
            freightData.PAY_CITY = StringServices.TrimOrNull(payCityTextBox.Text);
            freightData.PAY_STATE = StringServices.TrimOrNull(payStateTextBox.Text);
            freightData.PAY_ZIP = StringServices.TrimOrNull(payZipTextBox.Text);
            freightData.PAY_ZIP4 = StringServices.TrimOrNull(payZip4TextBox.Text);
            freightData.PAY_AREA = StringServices.TrimOrNull(payPhoneMaskedTextBox.Text.Substring(0, 3));
            freightData.PAY_PHONE = StringServices.TrimOrNull(payPhoneMaskedTextBox.Text.Substring(3, 7));
            freightData.PAY_FAREA = StringServices.TrimOrNull(payFaxMaskedTextBox.Text.Substring(0, 3));
            freightData.PAY_FPHONE = StringServices.TrimOrNull(payFaxMaskedTextBox.Text.Substring(3, 7));
            freightData.ACTIVE = StringServices.TrimOrNull(activeHoldTextBox.Text);
            freightData.NOTE = StringServices.TrimOrNull(noteTextBox.Text);
            freightData.INS_CO1 = StringServices.TrimOrNull(aInsuranceTextBox.Text);
            freightData.INS_CO2 = StringServices.TrimOrNull(bInsuranceTextBox.Text);
            freightData.INS_CO3 = StringServices.TrimOrNull(cInsuranceTextBox.Text);
            freightData.INS_CO4 = StringServices.TrimOrNull(dInsuranceTextBox.Text);
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
    }
}
