using Inventory.Models;
using Inventory.Services;
using Inventory.Interfaces;
using static Inventory.Programs.Utilities.UserConfirmation;

namespace Inventory.Views.UserControls.MasterFilesUpdate.CustomerInfo
{
    public partial class ShipToCustomer : UserControl, IActiveControlManager
    {
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private buyer? buyer;
        private bil_buy? billBuyer;

        public ShipToCustomer(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;

            Load += (s, e) => customerShipToTextBox.Focus();
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("VIEW/CHANGE/DELETE SHIP TO CUSTOMER INFORMATION");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Cancel");
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
                    { "1", () => UpdateShipToCustomer(buyer) },
                    { "2", () => customerShipToTextBox.Focus() },
                    { "3", () => DeleteShipToCustomer(buyer) },
                    { "4", () => ExitProgram() }
                };
            }
        }

        private void UpdateShipToCustomer(buyer buyer)
        {
            if (buyer != null)
            {
                if (IsDataModified(buyer))
                {
                    UpdateExistingShipToCustomer(buyer);
                }
            }
            else
            {
                AddNewShipToCustomer();
            }
        }

        private bool IsDataModified(buyer buyer)
        {
            return buyer == null || buyer.name != customerShipToTextBox.Text ||
                buyer.phone != phoneNumberMaskedTextBox.Text ||
                buyer.fax != faxNumberMaskedTextBox.Text ||
                buyer.cont_name != contactName1TextBox.Text ||
                buyer.cont_nam2 != contactName2TextBox.Text ||
                buyer.cont_ph != contactPhoneMaskedTextBox.Text ||
                buyer.cont_fax != contactFaxMaskedTextBox.Text ||
                buyer.frt_ph != freightContactPhoneMaskedTextBox.Text ||
                buyer.del_ph != deliveryPhoneMaskedTextBox.Text ||
                buyer.del_mail != deliveryEmailTextBox.Text ||
                buyer.del_time != receivingHoursTextBox.Text ||
                buyer.mon_recv != receivingMondayTextBox.Text ||
                buyer.tue_recv != receivingTuesdayTextBox.Text ||
                buyer.wed_recv != receivingWednesdayTextBox.Text ||
                buyer.thu_recv != receivingThursdayTextBox.Text ||
                buyer.fri_recv != receivingFridayTextBox.Text ||
                buyer.sat_recv != receivingSaturdayTextBox.Text ||
                buyer.sun_recv != receivingSundayTextBox.Text ||
                buyer.street != shipToAddressTextBox.Text ||
                buyer.city != shipToCityTextBox.Text ||
                buyer.state != shipToStateTextBox.Text ||
                buyer.zip != shipToZipTextBox.Text ||
                buyer.zip4 != shipToZip4TextBox.Text ||
                buyer.note != noteTextBox.Text ||
                buyer.grp_code != groupCodeTextBox.Text ||
                buyer.grp_desc != groupDescriptionTextBox.Text ||
                buyer.bbuycode != billBuyer?.PK_bil_buy.ToString();
        }

        private void UpdateExistingShipToCustomer(buyer buyerData)
        {
            using (AmerichickenContext dbContext = new())
            {
                var existingBuyer = dbContext.buyer.Find(buyerData.PK_buyer);
                if (existingBuyer != null)
                {
                    SetShipToCustomerProperties(existingBuyer);
                    dbContext.SaveChanges();
                    ExitProgram();
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong updating customer shipping info, please contact developer");
                }
            }
        }

        private void AddNewShipToCustomer()
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserInput);
            _mainWindow.AskUserConfirmation("You are about to add a new customer. Would you like to continue? (Y/N)");

            void HandleUserInput(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    using (AmerichickenContext dbContext = new())
                    {
                        buyer buyer = new();
                        SetShipToCustomerProperties(buyer);
                        dbContext.buyer.Add(buyer);
                        dbContext.SaveChanges();
                        ExitProgram();
                    }
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserInput);
            }
        }

        private void SetShipToCustomerProperties(buyer buyerObject)
        {
            buyerObject.name = customerShipToTextBox.Text;
            buyerObject.phone = phoneNumberMaskedTextBox.Text;
            buyerObject.fax = faxNumberMaskedTextBox.Text;
            buyerObject.cont_name = contactName1TextBox.Text;
            buyerObject.cont_nam2 = contactName2TextBox.Text;
            buyerObject.cont_ph = contactPhoneMaskedTextBox.Text;
            buyerObject.cont_fax = contactFaxMaskedTextBox.Text;
            buyerObject.frt_ph = freightContactPhoneMaskedTextBox.Text;
            buyerObject.del_ph = deliveryPhoneMaskedTextBox.Text;
            buyerObject.del_mail = deliveryEmailTextBox.Text;
            buyerObject.del_time = receivingHoursTextBox.Text;
            buyerObject.mon_recv = receivingMondayTextBox.Text;
            buyerObject.tue_recv = receivingTuesdayTextBox.Text;
            buyerObject.wed_recv = receivingWednesdayTextBox.Text;
            buyerObject.thu_recv = receivingThursdayTextBox.Text;
            buyerObject.fri_recv = receivingFridayTextBox.Text;
            buyerObject.sat_recv = receivingSaturdayTextBox.Text;
            buyerObject.sun_recv = receivingSundayTextBox.Text;
            buyerObject.street = shipToAddressTextBox.Text;
            buyerObject.city = shipToCityTextBox.Text;
            buyerObject.state = shipToStateTextBox.Text;
            buyerObject.zip = shipToZipTextBox.Text;
            buyerObject.zip4 = shipToZip4TextBox.Text;
            buyerObject.note = noteTextBox.Text;
            buyerObject.grp_code = groupCodeTextBox.Text;
            buyerObject.grp_desc = groupDescriptionTextBox.Text;
            buyerObject.bbuycode = billBuyer?.PK_bil_buy.ToString();
            
            buyer = buyerObject;
        }

        private void DeleteShipToCustomer(buyer buyer)
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserInput);
            _mainWindow.AskUserConfirmation("You are about to delete this customer shipping info. Would you like to continue? (Y/N)");
            void HandleUserInput(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    using (AmerichickenContext dbContext = new())
                    {
                        var existingBuyer = dbContext.buyer.Find(buyer.PK_buyer);
                        if (existingBuyer != null)
                        {
                            dbContext.buyer.Remove(existingBuyer);
                            dbContext.SaveChanges();
                            ExitProgram();
                        }
                        else
                        {
                            MessageBox.Show("ERROR: Something went wrong deleting customer shipping info, please contact developer");
                        }
                    }
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserInput);
            }
        }

        public void SetName(string name)
        {
            customerShipToTextBox.Text = name;
        }

        private void ExitProgram()
        {
            using (var _programLoader = new ProgramLoader(_mainWindow, _activeControlManager))
            {
                _mainWindow.DisposeControl(this);
                _programLoader.LoadProgram("buyer");
            }
        }

        private void PrincipalBillToNameTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                if (principalBillToNameTextBox.Text.Length != 0)
                {
                    string userInput = principalBillToNameTextBox.Text;
                    DbSearch dbSearchInstance = new(_mainWindow, _activeControlManager); 
                    dbSearchInstance.SearchCompleted += (f, f2) => HandleSearchCompleted(f!, f2);
                    dbSearchInstance.PerformSearch("bil_buy", userInput);
                    dbSearchInstance.Dispose();
                    dbSearchInstance.SearchCompleted -= HandleSearchCompleted;
                }
                else
                {
                    MessageBox.Show("ERROR: Please enter a valid bill to name");
                }
                e.Handled = true;
            }
        }

        public void HandleSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
        {
            if (e.SearchResults.Count == 0)
            {
                _activeControlManager.SetActiveControl(this);
            }
            else
            {
                MatchSelect matchSelectInstance = new(_mainWindow, _activeControlManager);
                matchSelectInstance.SelectedSearchResult += (f, f2) => HandleSelectedBillToSearchResult(f!, f2);
                matchSelectInstance.SetMatchSelectLabel("Bill To");
                matchSelectInstance.GetResults(e.SearchResults, e.TableSelected);
                if (e.SearchResults.Count > 1)
                {
                    _activeControlManager.SetActiveControl(matchSelectInstance);
                }
                else
                {
                    _mainWindow.DisposeControl(matchSelectInstance);
                    matchSelectInstance.SelectedSearchResult -= HandleSelectedBillToSearchResult;
                    _activeControlManager.SetActiveControl(this);
                }
            }
        }

        private void HandleSelectedBillToSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
        {
            bil_buy? selectedResult = e.SelectedResult as bil_buy;

            DisplayRemitToData(selectedResult!);
            _activeControlManager.SetActiveControl(this);
        }

        public void DisplayShipToCustomerData(buyer buyerData)
        {
            buyer = buyerData;

            customerShipToTextBox.Text = buyer.name;
            phoneNumberMaskedTextBox.Text = buyer.phone;
            faxNumberMaskedTextBox.Text = buyer.fax;
            contactName1TextBox.Text = buyer.cont_name;
            contactName2TextBox.Text = buyer.cont_nam2;
            contactPhoneMaskedTextBox.Text = buyer.cont_ph;
            contactFaxMaskedTextBox.Text = buyer.cont_fax;
            freightContactPhoneMaskedTextBox.Text = buyer.frt_ph;
            deliveryPhoneMaskedTextBox.Text = buyer.del_ph;
            deliveryEmailTextBox.Text = buyer.del_mail;
            receivingHoursTextBox.Text = buyer.del_time;
            receivingMondayTextBox.Text = buyer.mon_recv;
            receivingTuesdayTextBox.Text = buyer.tue_recv;
            receivingWednesdayTextBox.Text = buyer.wed_recv;
            receivingThursdayTextBox.Text = buyer.thu_recv;
            receivingFridayTextBox.Text = buyer.fri_recv;
            receivingSaturdayTextBox.Text = buyer.sat_recv;
            receivingSundayTextBox.Text = buyer.sun_recv;
            shipToAddressTextBox.Text = buyer.street;
            shipToCityTextBox.Text = buyer.city;
            shipToStateTextBox.Text = buyer.state;
            shipToZipTextBox.Text = buyer.zip;
            shipToZip4TextBox.Text = buyer.zip4;
            noteTextBox.Text = buyer.note;
            groupCodeTextBox.Text = buyer.grp_code;
            groupDescriptionTextBox.Text = buyer.grp_desc;

           if (buyer.bbuycode != null)
           {
                using (AmerichickenContext dbContext = new())
                {
                    billBuyer = dbContext.bil_buy.SingleOrDefault(s => s.bbuycode == buyer.bbuycode || s.PK_bil_buy.ToString() == buyer.bbuycode);
                }
                if (billBuyer != null)
                {
                    DisplayRemitToData(billBuyer);
                }
           }
        }

        private void DisplayRemitToData(bil_buy billBuyerData)
        {
            billBuyer = billBuyerData;
            if (billBuyer != null)
            {
                principalBillToNameTextBox.Text = billBuyerData.name;
                principalStreetDisplayLabel.Text = billBuyerData.street;
                principalCityStateDisplayLabel.Text = billBuyerData.city + ", " + billBuyerData.state + " " + billBuyerData.zip;
            }
        }
    }
}
