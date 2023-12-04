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

            DbSearch dbSearchInstance = new DbSearch(_mainWindow);
            dbSearchInstance.SetTable("supplier");
            dbSearchInstance.SearchCompleted += HandleSearchCompleted;
            dbSearchInstance.Dock = DockStyle.Fill;
            searchPanel.Controls.Add(dbSearchInstance);
            searchPanel.Visible = true;
            searchPanel.BringToFront();
        }

        //--------Methods--------//

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
            if (supplierData == null)
            {
                return false; // Nothing to compare
            }
            rem_sup remitToClass = null;

            if (supplierData.rsupcode != null)
            {
                remitToClass = remitToObject;
            }

            // Compare the user interface values with the original data, return true if differences are detected
            return supnameTextBox.Text != supplierData.name ||
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
                   remitToClass.rsupcode != supplierData.rsupcode;
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
                      //  _mainWindow.ProgramSwitcher("menuList");
                        break;
                }
            }
        }

        private void remitToNameTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            //Collects user input and format for processing
            string userInput = remitToNameTextBox.Text.Trim();

            //Waits to execute code until enter key is pressed in input area
            if (e.KeyCode == Keys.Enter)
            {
                DbSearch dbSearchInstance = new DbSearch(_mainWindow);
                dbSearchInstance.SearchCompleted += HandleSearchCompleted;
                dbSearchInstance.PerformSearch("remitTo", userInput);
                dbSearchInstance.Dispose();
            }
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
                matchSelectInstance.DisplayResults(e.SearchResults, e.TableSelected);
                searchPanel.Controls.Add(matchSelectInstance);
                searchPanel.Refresh();
            }
            else if (e.TableSelected == "remitTo")
            {
                matchSelectInstance.SelectedSearchResult += HandleSelectedRemitToSearchResult;
                matchSelectInstance.SetMatchSelectLabel("Remit To");
                matchSelectInstance.DisplayResults(e.SearchResults, e.TableSelected);
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
            _mainWindow.SetProgramLabel("View/Edit Ship From Supplier Info");

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
            _mainWindow.SetProgramLabel("View/Edit Ship From Supplier Info");

            DisplayRemitData(selectedResult);
        }
    }
}