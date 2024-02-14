using Inventory.Interfaces;
using Inventory.Models;
using Inventory.Services;
using static Inventory.Programs.Utilities.UserConfirmation;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class ShipFromSupplier : UserControl, IActiveControlManager
    {private readonly MainWindow _mainWindow;
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
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("VIEW/CHANGE/DELETE SHIPPED FROM SUPPLIER INFORMATION");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Cancel");
            _mainWindow.SetTextBoxLabel("ACTION:");
        }

        public void GetShipFromData(supplier supplierObject)
        {
            _supplierData = supplierObject;
            supnameTextBox.Text = supplierObject.name?.ToString().Trim();
            phoneMaskTextBox.Text = supplierObject.phone?.ToString().Trim();
            faxMaskTextBox.Text = supplierObject.fax?.ToString().Trim();
            contactNameTextBox.Text = supplierObject.cont_name?.ToString().Trim();
            contactPhoneMaskTextBox.Text = supplierObject.cont_phone?.ToString().Trim();
            contactFaxMaskTextBox.Text = supplierObject.cont_fax?.ToString().Trim();
            freightPhoneMaskTextBox.Text = supplierObject.freight_phone?.ToString().Trim();
            freightEmailTextBox.Text = supplierObject.freight_email?.ToString().Trim();
            shipFromStreetTextBox.Text = supplierObject.street?.ToString().Trim();
            shipFromCityTextBox.Text = supplierObject.city?.ToString().Trim();
            shipFromStateTextBox.Text = supplierObject.state?.ToString().Trim();
            shipFromZipTextBox.Text = supplierObject.zip?.ToString().Trim();
            noteTextBox.Text = supplierObject.note?.ToString().Trim();

            if (supplierObject.rsupcode != null)
            {
                remitToObject = dbContext.rem_sup.SingleOrDefault(s => s.rsupcode == supplierObject.rsupcode);

                if (remitToObject != null)
                {
                    DisplayRemitData(remitToObject);
                }
            }
        }

        private void UpdateSupplier(supplier supplierData)
        {
            if (supplierData != null)
            {
                if (IsDataModified(supplierData))
                {
                    var existingSupplier = dbContext.supplier.Find(supplierData.PK_supplier);
                    if (existingSupplier != null)
                    {
                        existingSupplier.name = supnameTextBox.Text.Trim();
                        existingSupplier.phone = phoneMaskTextBox.Text.Trim();
                        existingSupplier.fax = faxMaskTextBox.Text.Trim();
                        existingSupplier.cont_name = contactNameTextBox.Text.Trim();
                        existingSupplier.cont_phone = contactPhoneMaskTextBox.Text.Trim();
                        existingSupplier.cont_fax = contactFaxMaskTextBox.Text.Trim();
                        existingSupplier.freight_phone = freightPhoneMaskTextBox.Text.Trim();
                        existingSupplier.freight_email = freightEmailTextBox.Text.Trim();
                        existingSupplier.street = shipFromStreetTextBox.Text.Trim();
                        existingSupplier.city = shipFromCityTextBox.Text.Trim();
                        existingSupplier.state = shipFromStateTextBox.Text.ToUpper().Trim();
                        existingSupplier.zip = shipFromZipTextBox.Text.Trim();
                        existingSupplier.note = noteTextBox.Text.Trim();
                        existingSupplier.rsupcode = remitToObject!.rsupcode;

                        dbContext.SaveChanges();
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Supplier not found in database. Please try again or contact developer.");
                    }
                }
            }
            else
            {
                _mainWindow.AttachConfirmationEventListener(HandleUserInput);
                _mainWindow.AskUserConfirmation("You are about to add a new supplier. Would you like to continue?  (Y/N)");
                void HandleUserInput(object sender, UserConfirmationEventArgs e)
                {
                    if (e.UserChoice == true)
                    {
                        supplier newSupplier = new()
                        {
                            name = supnameTextBox.Text.Trim(),
                            phone = phoneMaskTextBox.Text.Trim(),
                            fax = faxMaskTextBox.Text.Trim(),
                            cont_name = contactNameTextBox.Text.Trim(),
                            cont_phone = contactPhoneMaskTextBox.Text.Trim(),
                            cont_fax = contactFaxMaskTextBox.Text.Trim(),
                            freight_phone = freightPhoneMaskTextBox.Text.Trim(),
                            freight_email = freightEmailTextBox.Text.Trim(),
                            street = shipFromStreetTextBox.Text.Trim(),
                            city = shipFromCityTextBox.Text.Trim(),
                            state = shipFromStateTextBox.Text.ToUpper().Trim(),
                            zip = shipFromZipTextBox.Text.Trim(),
                            note = noteTextBox.Text.Trim(),
                            rsupcode = remitToObject!.rsupcode
                        };
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

        private void DisplayRemitData(rem_sup remData)
        {
            remitToObject = remData;
            if (remitToObject != null)
            {
                remitToNameTextBox.Text = remitToObject.name.Trim();
                remitToStreetLabel.Text = remitToObject.street.Trim();
                remitToCityStateZipLabel.Text = remitToObject.city.Trim() + ", " + remitToObject.state.Trim() + " " + remitToObject.zip.Trim();
            }
            else
            {
                //something
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

        private void ExitProgram()
        {
            using (var _programLoader = new ProgramLoader(_mainWindow, _activeControlManager))
            {
                _mainWindow.DisplayControl(this);
                _programLoader.LoadProgram("supplier");
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

        private void RemitToNameTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                if (remitToNameTextBox.Text.Length != 0)
                {
                    string userInput = remitToNameTextBox.Text.Trim();
                    DbSearch dbSearchInstance = new(_mainWindow, _activeControlManager);
                    dbSearchInstance.SearchCompleted += (f, f2) => HandleSearchCompleted(f!, f2);
                    dbSearchInstance.PerformSearch("remitTo", userInput);
                    dbSearchInstance.Dispose();
                }
                else
                {
                    MessageBox.Show("Please enter a remit to name.");
                }
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
    }
}