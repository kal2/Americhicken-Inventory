using Inventory.Interfaces;
using Inventory.Models;
using Inventory.Services;
using static Inventory.Programs.Utilities.UserConfirmation;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class ShipFromSupplier : UserControl, IActiveControlManager
    {
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private supplier? _supplierData;
        private rem_sup? remitToObject;
        private readonly AmerichickenContext dbContext;

        public ShipFromSupplier(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;

            dbContext = new AmerichickenContext();
            Load += (s, e) => supnameTextBox.Focus();
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("ADD/CHANGE/DELETE SHIPPED FROM SUPPLIER INFORMATION");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Cancel");
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
                    { "1", () => UpdateSupplier(_supplierData!) },
                    { "2", () => supnameTextBox.Focus() },
                    { "3", () => DeleteSupplier(_supplierData!) },
                    { "4", () => ExitProgram() }
                };
            }
        }
        private void UpdateSupplier(supplier supplierData)
        {
            if (supplierData != null)
            {
                if (IsDataModified(supplierData))
                {
                    UpdateExistingSupplier(supplierData);
                }
            }
            else
            {
                AddNewSupplier();
            }
        }

        private void UpdateExistingSupplier(supplier supplierData)
        {
            var existingSupplier = dbContext.supplier.Find(supplierData.PK_supplier);
            if(existingSupplier != null)
            {
                SetSupplierProperties(existingSupplier);
                dbContext.SaveChanges();
            }
            else
            {
                MessageBox.Show("ERROR: Supplier not found in database. Please try again or contact developer.");
            }
        }

        private void AddNewSupplier()
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserInput);
            _mainWindow.AskUserConfirmation("You are about to add a new supplier. Would you like to continue?  (Y/N)");
            void HandleUserInput(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    supplier newSupplier = new();
                    SetSupplierProperties(newSupplier);
                    _supplierData = newSupplier;
                    dbContext.supplier.Add(newSupplier);
                    dbContext.SaveChanges();
                }
                else if (e.UserChoice == false)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong adding a new supplier, please contact developer");
                    return;
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserInput);
            }
        }

        private void SetSupplierProperties(supplier existingSupplier)
        {
            existingSupplier.name = supnameTextBox.Text;
            existingSupplier.phone = phoneMaskTextBox.Text;
            existingSupplier.fax = faxMaskTextBox.Text;
            existingSupplier.cont_name = contactNameTextBox.Text;
            existingSupplier.cont_phone = contactPhoneMaskTextBox.Text;
            existingSupplier.cont_fax = contactFaxMaskTextBox.Text;
            existingSupplier.freight_phone = freightPhoneMaskTextBox.Text;
            existingSupplier.freight_email = freightEmailTextBox.Text;
            existingSupplier.street = shipFromStreetTextBox.Text;
            existingSupplier.city = shipFromCityTextBox.Text;
            existingSupplier.state = shipFromStateTextBox.Text;
            existingSupplier.zip = shipFromZipTextBox.Text;
            existingSupplier.note = noteTextBox.Text;
            existingSupplier.rsupcode = remitToObject?.rsupcode;
        }

        private void DeleteSupplier(supplier supplierData)
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserInput);
            _mainWindow.AskUserConfirmation("You are about to delete this supplier. Would you like to continue?  (Y/N)");

            void HandleUserInput(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    var existingSupplier = dbContext.supplier.Find(supplierData.PK_supplier);
                    if (existingSupplier != null)
                    {
                        dbContext.supplier.Remove(existingSupplier);
                        dbContext.SaveChanges();
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Supplier not found in database. Please try again or contact developer.");
                    }
                }
                else if (e.UserChoice == false)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong deleting the supplier, please contact developer");
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserInput);
            }
        }

        private void ExitProgram()
        {
            using (var _programLoader = new ProgramLoader(_mainWindow, _activeControlManager))
            {
                _mainWindow.DisplayControl(this);
                _programLoader.LoadProgram("supplier");
            }
        }

        private bool IsDataModified(supplier supplierData)
        {
            return supplierData == null || supnameTextBox.Text != supplierData.name ||
                   phoneMaskTextBox.Text != supplierData.phone ||
                   faxMaskTextBox.Text != supplierData.fax ||
                   contactNameTextBox.Text != supplierData.cont_name ||
                   contactPhoneMaskTextBox.Text != supplierData.cont_phone ||
                   contactFaxMaskTextBox.Text != supplierData.cont_fax ||
                   freightPhoneMaskTextBox.Text != supplierData.freight_phone ||
                   freightEmailTextBox.Text != supplierData.freight_email ||
                   shipFromStreetTextBox.Text != supplierData.street ||
                   shipFromCityTextBox.Text != supplierData.city ||
                   shipFromStateTextBox.Text != supplierData.state ||
                   shipFromZipTextBox.Text != supplierData.zip ||
                   remitToObject!.rsupcode != supplierData.rsupcode;
        }

        private void RemitToNameTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                if (remitToNameTextBox.Text.Length != 0)
                {
                    string userInput = remitToNameTextBox.Text;
                    DbSearch dbSearchInstance = new(_mainWindow, _activeControlManager);
                    dbSearchInstance.SearchCompleted += (f, f2) => HandleSearchCompleted(f!, f2);
                    dbSearchInstance.PerformSearch("rem_sup", userInput);
                    dbSearchInstance.Dispose();
                }
                else
                {
                    MessageBox.Show("Please enter a remit to name.");
                }
                e.Handled = true;
            }
        }

        public void HandleSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
        {
            MatchSelect matchSelectInstance = new (_mainWindow, _activeControlManager);
            matchSelectInstance.SelectedSearchResult += (f, f2) => HandleSelectedRemitToSearchResult(f!, f2);
            matchSelectInstance.SetMatchSelectLabel("Remit To");
            matchSelectInstance.GetResults(e.SearchResults, e.TableSelected);

            if (e.SearchResults.Count > 1)
            {
                _activeControlManager.SetActiveControl(matchSelectInstance);
            }
            else
            {
                _mainWindow.DisposeControl(matchSelectInstance);
                _activeControlManager.SetActiveControl(this);
            }
        }

        private void HandleSelectedRemitToSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
        {
            rem_sup? selectedResult = e.SelectedResult as rem_sup;

            DisplayRemitData(selectedResult!);
            _activeControlManager.SetActiveControl(this);
        }

        public void GetShipFromData(supplier supplierObject)
        {
            _supplierData = supplierObject;
            supnameTextBox.Text = supplierObject.name;
            phoneMaskTextBox.Text = supplierObject.phone;
            faxMaskTextBox.Text = supplierObject.fax;
            contactNameTextBox.Text = supplierObject.cont_name;
            contactPhoneMaskTextBox.Text = supplierObject.cont_phone;
            contactFaxMaskTextBox.Text = supplierObject.cont_fax;
            freightPhoneMaskTextBox.Text = supplierObject.freight_phone;
            freightEmailTextBox.Text = supplierObject.freight_email;
            shipFromStreetTextBox.Text = supplierObject.street;
            shipFromCityTextBox.Text = supplierObject.city;
            shipFromStateTextBox.Text = supplierObject.state;
            shipFromZipTextBox.Text = supplierObject.zip;
            noteTextBox.Text = supplierObject.note;

            if (supplierObject.rsupcode != null)
            {
                remitToObject = dbContext.rem_sup.SingleOrDefault(s => s.rsupcode == supplierObject.rsupcode);

                if (remitToObject != null)
                {
                    DisplayRemitData(remitToObject);
                }
            }
        }

        private void DisplayRemitData(rem_sup remData)
        {
            remitToObject = remData;
            if (remitToObject != null)
            {
                remitToNameTextBox.Text = remitToObject.name;
                remitToStreetLabel.Text = remitToObject.street;
                remitToCityStateZipLabel.Text = remitToObject.city + ", " + remitToObject.state + " " + remitToObject.zip;
            }
        }
    }
}