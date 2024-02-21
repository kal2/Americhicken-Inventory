using System.Globalization;
using Inventory.Interfaces;
using Inventory.Models;
using Inventory.Services;
using static Inventory.Programs.Utilities.UserConfirmation;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class RemitSupplier : UserControl, IActiveControlManager
    {
        // -- class variables -- //
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private rem_sup? _remitData;
        private readonly AmerichickenContext dbContext;

        public RemitSupplier(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
            dbContext = new AmerichickenContext();

            //wait for control to load then focus remitnametextbox
            this.Load += (s, e) => RemitNameTextBox.Focus();
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("VIEW/CHANGE/DELETE REMIT TO SUPPLIER INFORMATION");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Cancel    5. Save/Update Insurance");
            _mainWindow.SetTextBoxLabel("ACTION:");
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
                    {"1", () => UpdateRemitData(_remitData) },
                    {"2", () => RemitNameTextBox.Focus() },
                    {"3", () => DeleteRemitTo(_remitData) },
                    {"4", () => ExitProgram() },
                    {"5", () => LoadInsuranceProgram() },
                };
            }
        }
        public void UpdateRemitData(rem_sup? remitToData)
        {
            if (remitToData != null)
            {
                if (IsDataModified(remitToData))
                {
                    UpdateExistingRemitToSupplier(remitToData);
                }
            }
            else
            {
                AddNewRemitToSupplier();
            }
            ExitProgram();
        }

        public bool IsDataModified(rem_sup remitToData)
        {
            return remitToData == null ||
                remitToData.name != RemitNameTextBox.Text ||
                remitToData.phone != phoneMaskTextBox.Text ||
                remitToData.fax != faxMaskTextBox.Text ||
                remitToData.street != remitStreetTextBox.Text ||
                remitToData.city != remitCityTextBox.Text ||
                remitToData.state != remitStateTextBox.Text ||
                remitToData.zip != remitZipTextBox.Text ||
                remitToData.zip4 != remitZip4TextBox.Text ||
                remitToData.net_days != Converter.ParseInt(payNetDaysTextBox.Text) ||
                remitToData.indem_flg != indemnityContractTextBox.Text ||
                remitToData.active != activeTextBox.Text ||
                remitToData.indem_dt != Converter.ParseDateTime(contractDateMaskedBox.Text) ||
                remitToData.cred_lim != Converter.ParseInt(creditLimitTextBox.Text) ||
                remitToData.beg_date != Converter.ParseDateTime(beginDateMaskedBox.Text) ||
                remitToData.end_date != Converter.ParseDateTime(expireDateMaskedBox.Text) ||
                remitToData.guaran != guarantorTextBox.Text ||
                remitToData.note != noteTextBox.Text ||
                remitToData.ins_co1 != aInsuranceTextBox.Text ||
                remitToData.ins_co2 != bInsuranceTextBox.Text ||
                remitToData.ins_co3 != cInsuranceTextBox.Text ||
                remitToData.ins_co4 != dInsuranceTextBox.Text ||
                remitToData.ins_co5 != eInsuranceTextBox.Text;
        }

        public void UpdateExistingRemitToSupplier(rem_sup remitToData)
        {
            var existingRemData = dbContext.rem_sup.Find(remitToData.PK_rem_sup);
            if (existingRemData != null)
            {
                SetRemitToProperties(existingRemData);
                dbContext.SaveChanges();
            }
        }
        public void AddNewRemitToSupplier()
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserConfirmation);
            _mainWindow.AskUserConfirmation("You are about to add a new Remit To entry. Would you like to continue?  (Y/N)");

            void HandleUserConfirmation(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    rem_sup newRemitTo = new();
                    SetRemitToProperties(newRemitTo);
                    _remitData = newRemitTo;
                    dbContext.rem_sup.Add(newRemitTo);
                    dbContext.SaveChanges();
                }
                else if (e.UserChoice == false)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong. Please try again or contact developer.");
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserConfirmation);
            }
        }

        public void SetRemitToProperties(rem_sup existingRemData)
        {
            existingRemData.name = RemitNameTextBox.Text;
            existingRemData.phone = phoneMaskTextBox.Text;
            existingRemData.fax = faxMaskTextBox.Text;
            existingRemData.street = remitStreetTextBox.Text;
            existingRemData.city = remitCityTextBox.Text;
            existingRemData.state = remitStateTextBox.Text;
            existingRemData.zip = remitZipTextBox.Text;
            existingRemData.zip4 = remitZip4TextBox.Text;
            existingRemData.net_days = Converter.ParseInt(payNetDaysTextBox.Text);
            existingRemData.indem_flg = indemnityContractTextBox.Text;
            existingRemData.active = activeTextBox.Text;
            existingRemData.indem_dt = Converter.ParseDateTime(contractDateMaskedBox.Text);
            existingRemData.cred_lim = Converter.ParseInt(creditLimitTextBox.Text);
            existingRemData.let_crd = Converter.ParseInt(letterOfCreditTextBox.Text);
            existingRemData.beg_date = Converter.ParseDateTime(beginDateMaskedBox.Text);
            existingRemData.end_date = Converter.ParseDateTime(expireDateMaskedBox.Text);
            existingRemData.guaran = guarantorTextBox.Text;
            existingRemData.note = noteTextBox.Text;
            existingRemData.ins_co1 = aInsuranceTextBox.Text;
            existingRemData.ins_co2 = bInsuranceTextBox.Text;
            existingRemData.ins_co3 = cInsuranceTextBox.Text;
            existingRemData.ins_co4 = dInsuranceTextBox.Text;
            existingRemData.ins_co5 = eInsuranceTextBox.Text;
        }

        public void DeleteRemitTo(rem_sup? remitToData)
        {
            if (remitToData == null)
            {
                MessageBox.Show("ERROR: No Remit To data found. Please try again or contact developer.");
                return;
            }
            _mainWindow.AttachConfirmationEventListener(HandleUserConfirmation);
            _mainWindow.AskUserConfirmation("You are about to delete this Remit To entry. Would you like to continue?  (Y/N)");

            void HandleUserConfirmation(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
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
                _mainWindow.DetachConfirmationEventListener(HandleUserConfirmation);
            }
        }

        public void SetName(string name)
        {
            RemitNameTextBox.Text = name;
        }

        private void ExitProgram()
        {
            using (var _programLoader = new ProgramLoader(_mainWindow, _activeControlManager))
            {
                _mainWindow.DisposeControl(this);
                _programLoader.LoadProgram("rem_sup");
            }
        }

        private void LoadInsuranceProgram()
        {
            UpdateRemitData(_remitData);
            RemitInsuranceSupplier remitInsuranceInstance = new(_mainWindow, _activeControlManager);
            remitInsuranceInstance.DisplayRemitInsuranceData(_remitData);
            _mainWindow.DisposeControl(this);
            _activeControlManager.SetActiveControl(remitInsuranceInstance);
        }

        public void DisplayRemitToData(rem_sup remitToObject)
        {
            _remitData = remitToObject;
            RemitNameTextBox.Text = _remitData.name;
            phoneMaskTextBox.Text = _remitData.phone;
            faxMaskTextBox.Text = _remitData.fax;
            remitStreetTextBox.Text = _remitData.street;
            remitCityTextBox.Text = _remitData.city;
            remitStateTextBox.Text = _remitData.state;
            remitZipTextBox.Text = _remitData.zip;
            remitZip4TextBox.Text = _remitData.zip4;
            payNetDaysTextBox.Text = _remitData.net_days.ToString();
            indemnityContractTextBox.Text = _remitData.indem_flg;
            activeTextBox.Text = _remitData.active;
            contractDateMaskedBox.Text = _remitData.indem_dt?.ToString("MM/dd/yyyy");
            creditLimitTextBox.Text = _remitData.cred_lim?.ToString();
            letterOfCreditTextBox.Text = _remitData.let_crd?.ToString();
            beginDateMaskedBox.Text = _remitData.beg_date?.ToString("MM/dd/yyyy");
            expireDateMaskedBox.Text = _remitData.end_date?.ToString("MM/dd/yyyy");
            guarantorTextBox.Text = _remitData.guaran;
            noteTextBox.Text = _remitData.note;
            aInsuranceTextBox.Text = _remitData.ins_co1;
            bInsuranceTextBox.Text = _remitData.ins_co2;
            cInsuranceTextBox.Text = _remitData.ins_co3;
            dInsuranceTextBox.Text = _remitData.ins_co4;
            eInsuranceTextBox.Text = _remitData.ins_co5;
        }
    }
}
