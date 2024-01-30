using Inventory.Interfaces;
using Inventory.Models;
using Inventory.Services;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class ShipFromUpdateInfo : UserControl, IActiveControlManager
    {
        //--------Class Variables--------//

        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private supplier? _supplierData;
        private rem_sup? remitToObject;
        private readonly AmerichickenContext dbContext;

        //--------Constructor--------//

        public ShipFromUpdateInfo(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;

            dbContext = new AmerichickenContext();
        }

        //--------Methods--------//

        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("VIEW/CHANGE/DELETE SHIPPED FROM SUPPLIER INFORMATION");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Cancel");
            _mainWindow.SetTextBoxLabel("ACTION:");
        }

        public void GetShipFromData(supplier supplierObject)
        {
            // If casting succeeded, and supplierObject is not null.
            // Assign all the appropriate object data to the corresponding fields to display/edit.
            _supplierData = supplierObject;
            supnameTextBox.Text = supplierObject.name?.ToString().Trim();
            phoneMaskTextBox.Text = $"{supplierObject.area_code?.ToString().Trim() + supplierObject.phone?.ToString().Trim()}";
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

            // If the supplier has a remit to code, get the remit to data and display it
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
                // Compare the modified values with the original values to detect changes, and only save if changes are detected
                if (IsDataModified(supplierData))
                {
                    // Update the supplier in the database
                    var existingSupplier = dbContext.supplier.Find(supplierData.PK_supplier);
                    if (existingSupplier != null)
                    {
                        // Update the properties with the modified values
                        existingSupplier.name = supnameTextBox.Text.Trim();
                        existingSupplier.area_code = phoneMaskTextBox.Text.Trim()[..3];
                        existingSupplier.phone = phoneMaskTextBox.Text.Trim()[3..];
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

                        dbContext.SaveChanges(); // Save changes to the database
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Supplier not found in database. Please try again or contact developer.");
                    }
                }
            }
            else
            {
                DialogResult dialogResult = MessageBox.Show("You are about to add a new supplier." + Environment.NewLine + "Would you like to continue?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
                if (dialogResult == DialogResult.Yes)
                {
                    //Grab user inputs and save to new supplier in db table
                    supplier newSupplier = new()
                    {
                        name = supnameTextBox.Text.Trim(),
                        area_code = phoneMaskTextBox.Text.Trim()[..3],
                        phone = phoneMaskTextBox.Text.Trim()[3..],
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
                else if (dialogResult == DialogResult.No)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong adding a new supplier, please contact developer");
                    return;
                }
            }
        }

        private void DeleteSupplier(supplier supplierData)
        {
            if (supplierData != null)
            {
                // Delete the supplier from the database
                var existingSupplier = dbContext.supplier.Find(supplierData.PK_supplier);
                if (existingSupplier != null)
                {
                    dbContext.supplier.Remove(existingSupplier);
                    dbContext.SaveChanges(); // Save changes to the database
                }
                else
                {
                    MessageBox.Show("ERROR: Supplier not found in database. Please try again or contact developer.");
                }
            }
            else
            {
                MessageBox.Show("ERROR: Supplier not found on client side. Please try again or contact developer.");
            }
        }

        private void DisplayRemitData(rem_sup remData)
        {
            // Display the remit to data if one is associated with the supplier
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
            // Compare the user interface values with the original data, return true if differences are detected
            return supplierData == null || supnameTextBox.Text != supplierData.name ||
                   phoneMaskTextBox.Text != supplierData.area_code + supplierData.phone ||
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

        //--------Event Listeners--------//

        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //add or update supplier
                    UpdateSupplier(_supplierData!);
                    break;

                case "2":
                    //return to edit supplier info
                    supnameTextBox.Focus();
                    break;

                case "3":
                    //delete supplier
                    DialogResult dialogResult = MessageBox.Show("Are you sure you want to delete this supplier?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);

                    if (dialogResult == DialogResult.Yes)
                    {
                        DeleteSupplier(_supplierData!);
                    }
                    else if (dialogResult == DialogResult.No)
                    {
                        return;
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Something went wrong deleting the supplier, please contact developer");
                    }
                    break;

                case "4":
                    //returns user to main menu
                    _mainWindow.DisposeControl(this);
                    _activeControlManager.SetActiveControl(new MenuList(_mainWindow, _activeControlManager));
                    break;

                default:
                    MessageBox.Show("Invalid input. Please try again.");
                    break;
            }
            _mainWindow.ClearTextBox();
        }

        private void RemitToNameTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            //Waits to execute code until enter key is pressed in input area
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

        //Store the search results along with the db table searched in order to load the appropriate program and pass the data to display/edit
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