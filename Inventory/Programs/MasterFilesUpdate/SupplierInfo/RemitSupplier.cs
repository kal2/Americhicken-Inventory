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
        private rem_sup _remitData;
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
        public void UpdateRemitData(rem_sup remitToData)
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
                remitToData.net_days != int.Parse(payNetDaysTextBox.Text) ||
                remitToData.indem_flg != indemnityContractTextBox.Text ||
                remitToData.active != activeTextBox.Text ||
                remitToData.indem_dt != DateTime.Parse(contractDateMaskedBox.Text, new CultureInfo("en-US")) ||
                remitToData.cred_lim != int.Parse(creditLimitTextBox.Text) ||
                remitToData.beg_date != DateTime.Parse(beginDateMaskedBox.Text, new CultureInfo("en-US")) ||
                remitToData.end_date != DateTime.Parse(expireDateMaskedBox.Text, new CultureInfo("en-US")) ||
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
            existingRemData.net_days = string.IsNullOrEmpty(payNetDaysTextBox.Text) ? null : int.TryParse(payNetDaysTextBox.Text, out var netDays) ? netDays : null;
            existingRemData.indem_flg = indemnityContractTextBox.Text;
            existingRemData.active = activeTextBox.Text;
            existingRemData.indem_dt = string.IsNullOrEmpty(contractDateMaskedBox.Text) ? null : DateTime.TryParse(contractDateMaskedBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var indemDt) ? indemDt : null;
            existingRemData.cred_lim = string.IsNullOrEmpty(creditLimitTextBox.Text) ? null : int.TryParse(creditLimitTextBox.Text, out var credLim) ? credLim : null;
            existingRemData.let_crd = string.IsNullOrEmpty(letterOfCreditTextBox.Text) ? null : int.TryParse(letterOfCreditTextBox.Text, out var letCrd) ? letCrd : null;
            existingRemData.beg_date = string.IsNullOrEmpty(beginDateMaskedBox.Text) ? null : DateTime.TryParse(beginDateMaskedBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var begDate) ? begDate : null;
            existingRemData.end_date = string.IsNullOrEmpty(expireDateMaskedBox.Text) ? null : DateTime.TryParse(expireDateMaskedBox.Text, new CultureInfo("en-US"), DateTimeStyles.None, out var endDate) ? endDate : null;
            existingRemData.guaran = guarantorTextBox.Text;
            existingRemData.note = noteTextBox.Text;
            existingRemData.ins_co1 = aInsuranceTextBox.Text;
            existingRemData.ins_co2 = bInsuranceTextBox.Text;
            existingRemData.ins_co3 = cInsuranceTextBox.Text;
            existingRemData.ins_co4 = dInsuranceTextBox.Text;
            existingRemData.ins_co5 = eInsuranceTextBox.Text;
        }
        public void DeleteRemitTo(rem_sup remitToData)
        {
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
                else if (e.UserChoice == false)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong. Please try again or contact developer.");
                }
            }
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
            RemitNameTextBox.Text = StringServices.TrimOrNull(_remitData.name);
            phoneMaskTextBox.Text = StringServices.TrimOrNull(_remitData.phone);
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
    }
}
