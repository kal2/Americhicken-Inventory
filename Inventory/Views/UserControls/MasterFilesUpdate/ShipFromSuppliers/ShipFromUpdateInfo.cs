using Inventory.Models;
using Microsoft.EntityFrameworkCore;
using System.DirectoryServices;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class ShipFromUpdateInfo : UserControl
    {
        //--------Class Variables--------//

        private object supplierData = null;
        private rem_sup remitToObject;
        private MainWindow _mainWindow;
        private AmerichickenContext dbContext;

        //--------Constructor--------//

        public ShipFromUpdateInfo(MainWindow mainWindow)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            dbContext = new AmerichickenContext();

            this.Disposed += (s, a) =>
            {
                _mainWindow.DetachTextBoxKeyDownHandler(actionInput_KeyDown);
            };

            DbSearch dbSearchInstance = new DbSearch(_mainWindow);
            dbSearchInstance.SetTable("supplier");
            dbSearchInstance.HideSearchPanel += HideSearchPanelHandler;
            dbSearchInstance.SearchCompleted += HandleSearchCompleted;
            dbSearchInstance.Dock = DockStyle.Fill;
            searchPanel.Controls.Add(dbSearchInstance);
            searchPanel.Visible = true;
            searchPanel.BringToFront();
        }

        //--------Methods--------//

        private void SetProgramLabels()
        {
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Cancel");
            _mainWindow.SetTextBoxLabel("ACTION:");
            _mainWindow.SetProgramLabel("View/Edit Ship From Supplier Info");
        }

        public void GetShipFromData(object shipFromData)
        {
            if (shipFromData is supplier supplierObject)
            {

                // If casting succeeded, and supplierObject is not null.
                // Assign all the appropriate object data to the corresponding fields to display/edit.
                supplierData = supplierObject;
                supnameTextBox.Text = supplierObject.name?.ToString().Trim() ?? "";
                phoneMaskTextBox.Text = (supplierObject.area_code?.ToString() + supplierObject.phone?.ToString()).Trim() ?? "";
                faxMaskTextBox.Text = supplierObject.fax?.ToString().Trim() ?? "";
                contactNameTextBox.Text = supplierObject.cont_name?.ToString().Trim() ?? "";
                contactPhoneMaskTextBox.Text = supplierObject.cont_phone?.ToString().Trim() ?? "";
                contactFaxMaskTextBox.Text = supplierObject.cont_fax?.ToString().Trim() ?? "";
                freightPhoneMaskTextBox.Text = supplierObject.freight_phone?.ToString().Trim() ?? "";
                freightEmailTextBox.Text = supplierObject.fright_email?.ToString().Trim() ?? "";
                shipFromStreetTextBox.Text = supplierObject.street?.ToString().Trim() ?? "";
                shipFromCityTextBox.Text = supplierObject.city?.ToString().Trim() ?? "";
                shipFromStateTextBox.Text = supplierObject.state?.ToString().Trim() ?? "";
                shipFromZipTextBox.Text = supplierObject.zip?.ToString().Trim() ?? "";
                noteTextBox.Text = supplierObject.note?.ToString().Trim() ?? "";

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
            else
            {
                // Handle the case where the cast failed or shipFromData is not of the correct type.
                // You can set a default value, log an error, or take other appropriate actions.
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
                        existingSupplier.area_code = phoneMaskTextBox.Text.Trim().Substring(0, 3);
                        existingSupplier.phone = phoneMaskTextBox.Text.Trim().Substring(3);
                        existingSupplier.fax = faxMaskTextBox.Text.Trim();
                        existingSupplier.cont_name = contactNameTextBox.Text.Trim();
                        existingSupplier.cont_phone = contactPhoneMaskTextBox.Text.Trim();
                        existingSupplier.cont_fax = contactFaxMaskTextBox.Text.Trim();
                        existingSupplier.freight_phone = freightPhoneMaskTextBox.Text.Trim();
                        existingSupplier.fright_email = freightEmailTextBox.Text.Trim();
                        existingSupplier.street = shipFromStreetTextBox.Text.Trim();
                        existingSupplier.city = shipFromCityTextBox.Text.Trim();
                        existingSupplier.state = shipFromStateTextBox.Text.ToUpper().Trim();
                        existingSupplier.zip = shipFromZipTextBox.Text.Trim();
                        existingSupplier.note = noteTextBox.Text.Trim();
                        existingSupplier.rsupcode = remitToObject.rsupcode;

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
                    supplier newSupplier = new supplier
                    {
                        name = supnameTextBox.Text.Trim(),
                        area_code = phoneMaskTextBox.Text.Trim().Substring(0, 3),
                        phone = phoneMaskTextBox.Text.Trim().Substring(3),
                        fax = faxMaskTextBox.Text.Trim(),
                        cont_name = contactNameTextBox.Text.Trim(),
                        cont_phone = contactPhoneMaskTextBox.Text.Trim(),
                        cont_fax = contactFaxMaskTextBox.Text.Trim(),
                        freight_phone = freightPhoneMaskTextBox.Text.Trim(),
                        fright_email = freightEmailTextBox.Text.Trim(),
                        street = shipFromStreetTextBox.Text.Trim(),
                        city = shipFromCityTextBox.Text.Trim(),
                        state = shipFromStateTextBox.Text.ToUpper().Trim(),
                        zip = shipFromZipTextBox.Text.Trim(),
                        note = noteTextBox.Text.Trim(),
                        rsupcode = remitToObject.rsupcode
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
                   freightEmailTextBox.Text != supplierData.fright_email ||
                   shipFromStreetTextBox.Text != supplierData.street ||
                   shipFromCityTextBox.Text != supplierData.city ||
                   shipFromStateTextBox.Text != supplierData.state ||
                   shipFromZipTextBox.Text != supplierData.zip ||
                   remitToObject.rsupcode != supplierData.rsupcode;
        }

        //--------Event Listeners--------//

        private void actionInput_KeyDown(object sender, KeyEventArgs e)
        {
            //Collects user input and format for processing
            string userInput = _mainWindow.GetTextBoxText().Trim();

            //Waits to execute code until enter key is pressed in input area
            if (e.KeyCode == Keys.Enter)
            {
                switch (userInput)
                {
                    //accepts the user's input and searches the db table selected from Program Switcher
                    case "1":
                        UpdateSupplier(supplierData as supplier);
                        break;

                    case "2":
                        supnameTextBox.Focus();
                        break;

                    case "3":
                        //delete supplier

                        DialogResult dialogResult = MessageBox.Show("Are you sure you want to delete this supplier?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);

                        if (dialogResult == DialogResult.Yes)
                        {

                        }
                        else if (dialogResult == DialogResult.No)
                        {

                        }
                        break;

                    //returns user to main menu
                    case "4":

                        _mainWindow.DisplayControl(new MenuList(_mainWindow));
                        _mainWindow.DetachTextBoxKeyDownHandler(actionInput_KeyDown);
                        break;

                    default:
                        MessageBox.Show("Invalid input. Please try again.");
                        _mainWindow.ClearTextBox();
                        break;
                }
            }
        }

        private void remitToNameTextBox_KeyDown(object sender, KeyEventArgs e)
        {

            //Waits to execute code until enter key is pressed in input area
            if (e.KeyCode == Keys.Enter)
            {
                _mainWindow.DetachTextBoxKeyDownHandler(actionInput_KeyDown);
                //Collects user input and format for processing
                string userInput = remitToNameTextBox.Text.Trim();
                DbSearch dbSearchInstance = new DbSearch(_mainWindow);
                dbSearchInstance.SearchCompleted += HandleSearchCompleted;
                dbSearchInstance.PerformSearch("remitTo", userInput);
                dbSearchInstance.Dispose();
            }
        }

        private void HideSearchPanelHandler()
        {
            // Method to hide the searchPanel
            searchPanel.Visible = false;
            searchPanel.SendToBack();
            supplierInfoPanel.BringToFront();
            supplierInfoPanel.Visible = true;
            SetProgramLabels();
        }

        //Store the search results along with the db table searched in order to load the appropriate program and pass the data to display/edit
        private void HandleSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
        {
            foreach (Control control in searchPanel.Controls)
            {
                control.Dispose();
            }

            MatchSelect matchSelectInstance = new MatchSelect(_mainWindow);

            if (e.TableSelected == "supplier")
            { 
                matchSelectInstance.SelectedSearchResult += HandleSelectedShipFromSearchResult;
                matchSelectInstance.SetMatchSelectLabel("Supplier");
            }
            else if (e.TableSelected == "remitTo")
            {
                matchSelectInstance.SelectedSearchResult += HandleSelectedRemitToSearchResult;
                matchSelectInstance.SetMatchSelectLabel("Remit To");
            }

            matchSelectInstance.DisplayResults(e.SearchResults, e.TableSelected);

            if (e.SearchResults.Count > 1)
            {
                searchPanel.Controls.Add(matchSelectInstance);
                searchPanel.Visible = true;
                searchPanel.BringToFront();
                searchPanel.Refresh();
            }
        }
        private void HandleSelectedShipFromSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
        {
            supplier selectedResult = e.SelectedResult as supplier;

            GetShipFromData(selectedResult); 
            searchPanel.Visible = false;
            foreach (Control control in searchPanel.Controls)
            {
                control.Dispose();
            }
            searchPanel.SendToBack();
            supplierInfoPanel.BringToFront();
            supplierInfoPanel.Visible = true;
            SetProgramLabels();
            _mainWindow.AttachTextBoxKeyDownHandler(actionInput_KeyDown);

        }
        private void HandleSelectedRemitToSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
        {
            rem_sup selectedResult = e.SelectedResult as rem_sup;

            searchPanel.Visible = false;
            foreach (Control control in searchPanel.Controls)
            {
                control.Dispose();
            }
            searchPanel.SendToBack();
            _mainWindow.AttachTextBoxKeyDownHandler(actionInput_KeyDown);
            SetProgramLabels();

            DisplayRemitData(selectedResult);
        }
    }
}