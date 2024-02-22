using Inventory.Interfaces;
using Inventory.Models;
using Inventory.Services;
using static Inventory.Programs.Utilities.UserConfirmation;

namespace Inventory.Views.UserControls.MasterFilesUpdate.FreightCarriers
{
    public partial class FreightCarriers : UserControl, IActiveControlManager
    {
        //-- class variables --//
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private freight _freightData;
        public FreightCarriers(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;

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
            if (AvailableActions.TryGetValue(userInput, out var action))
            {
                action();
            }
            else
            {
                MessageBox.Show("ERROR: Invalid input, please try again or contact developer");
            }
        }

        public Dictionary<string, Action> AvailableActions
        {
            get
            {
                return new Dictionary<string, Action>
                {
                    { "1", () => UpdateFreightCarrierData(_freightData) },
                    { "2", () => freightNameTextBox.Focus() },
                    { "3", () => DeleteFreight(_freightData!) },
                    { "4", () => ExitProgram() },
                    { "5", () => SaveAndUpdateInsurance() }
                };
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
                AddNewFreight();
            }
        }

        private bool IsDataModified(freight freightData)
        {

            return freightData == null || 
                freightData.NAME != freightNameTextBox.Text ||
                freightData.STREET != freightStreetTextBox.Text ||
                freightData.CITY != freightCityTextBox.Text ||
                freightData.STATE != freightStateTextBox.Text ||
                freightData.ZIP != freightZipTextBox.Text ||
                freightData.ZIP4 != freightZip4TextBox.Text ||
                freightData.PHONE != freightPhoneMaskedTextBox.Text ||
                freightData.FAX_PHONE != freightFaxMaskedTextBox.Text ||
                freightData.FRT_CONT != contactTextBox.Text ||
                freightData.PAY_NAME != payNameTextBox.Text ||
                freightData.PAY_STREET != payAddressTextBox.Text ||
                freightData.PAY_CITY != payCityTextBox.Text ||
                freightData.PAY_STATE != payStateTextBox.Text ||
                freightData.PAY_ZIP != payZipTextBox.Text ||
                freightData.PAY_ZIP4 != payZip4TextBox.Text ||
                freightData.PAY_PHONE != payPhoneMaskedTextBox.Text ||
                freightData.PAY_FPHONE != payFaxMaskedTextBox.Text ||
                freightData.ACTIVE != activeHoldTextBox.Text ||
                freightData.NOTE != noteTextBox.Text ||
                freightData.INS_CO1 != aInsuranceTextBox.Text ||
                freightData.INS_CO2 != bInsuranceTextBox.Text ||
                freightData.INS_CO3 != cInsuranceTextBox.Text ||
                freightData.INS_CO4 != dInsuranceTextBox.Text;
        }

        private void UpdateExistingFreight(freight freightData)
        {
            using (AmerichickenContext dbContext = new())
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
        }

        private void AddNewFreight()
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserConfirmation);
            _mainWindow.AskUserConfirmation("You are about to add a new freight carrier. Would you like to continue?   (Y/N)");

            void HandleUserConfirmation(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    using (AmerichickenContext dbContext = new())
                    {
                        freight newFreight = new();
                        SetFreightProperties(newFreight);
                        _freightData = newFreight;
                        dbContext.freight.Add(newFreight);
                        dbContext.SaveChanges();
                    }
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserConfirmation);
            }
        }

        private void SetFreightProperties(freight freightData)
        {
            freightData.NAME = freightNameTextBox.Text;
            freightData.STREET = freightStreetTextBox.Text;
            freightData.CITY = freightCityTextBox.Text;
            freightData.STATE = freightStateTextBox.Text;
            freightData.ZIP = freightZipTextBox.Text;
            freightData.ZIP4 = freightZip4TextBox.Text;
            freightData.PHONE = freightPhoneMaskedTextBox.Text;
            freightData.FAX_PHONE = freightFaxMaskedTextBox.Text;
            freightData.FRT_CONT = contactTextBox.Text;
            freightData.PAY_NAME = payNameTextBox.Text;
            freightData.PAY_STREET = payAddressTextBox.Text;
            freightData.PAY_CITY = payCityTextBox.Text;
            freightData.PAY_STATE = payStateTextBox.Text;
            freightData.PAY_ZIP = payZipTextBox.Text;
            freightData.PAY_ZIP4 = payZip4TextBox.Text;
            freightData.PAY_PHONE = payPhoneMaskedTextBox.Text;
            freightData.PAY_FPHONE = payFaxMaskedTextBox.Text;
            freightData.ACTIVE = activeHoldTextBox.Text;
            freightData.NOTE = noteTextBox.Text;
            freightData.INS_CO1 = aInsuranceTextBox.Text;
            freightData.INS_CO2 = bInsuranceTextBox.Text;
            freightData.INS_CO3 = cInsuranceTextBox.Text;
            freightData.INS_CO4 = dInsuranceTextBox.Text;
        }

        private void DeleteFreight(freight freightData)
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserInput);
            _mainWindow.AskUserConfirmation("You are about to delete a freight carrier. Would you like to continue?   (Y/N)");
            void HandleUserInput(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    using (AmerichickenContext dbContext = new())
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
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserInput);
            }
        }

        public void SetName(string name)
        {
            freightNameTextBox.Text = name;
        }

        private void ExitProgram()
        {
            using (var _programLoader = new ProgramLoader(_mainWindow, _activeControlManager))
            {
                _mainWindow.DisposeControl(this);
                _programLoader.LoadProgram("freight");
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

        public void DisplayFreightCarrierData(freight freightData)
        {
            _freightData = freightData;

            freightNameTextBox.Text = _freightData.NAME;
            freightStreetTextBox.Text = _freightData.STREET;
            freightCityTextBox.Text = _freightData.CITY;
            freightStateTextBox.Text = _freightData.STATE;
            freightZipTextBox.Text = _freightData.ZIP;
            freightZip4TextBox.Text = _freightData.ZIP4;
            freightPhoneMaskedTextBox.Text = _freightData.PHONE;
            freightFaxMaskedTextBox.Text = _freightData.FAX_PHONE;
            contactTextBox.Text = _freightData.FRT_CONT;
            payNameTextBox.Text = _freightData.PAY_NAME;
            payAddressTextBox.Text = _freightData.PAY_STREET;
            payCityTextBox.Text = _freightData.PAY_CITY;
            payStateTextBox.Text = _freightData.PAY_STATE;
            payZipTextBox.Text = _freightData.PAY_ZIP;
            payZip4TextBox.Text = _freightData.PAY_ZIP4;
            payPhoneMaskedTextBox.Text = _freightData.PAY_PHONE;
            payFaxMaskedTextBox.Text = _freightData.PAY_FPHONE;
            activeHoldTextBox.Text = _freightData.ACTIVE;
            noteTextBox.Text = _freightData.NOTE;
            aInsuranceTextBox.Text = _freightData.INS_CO1;
            bInsuranceTextBox.Text = _freightData.INS_CO2;
            cInsuranceTextBox.Text = _freightData.INS_CO3;
            dInsuranceTextBox.Text = _freightData.INS_CO4;
        }
    }
}
