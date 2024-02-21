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
        private buyer _buyer;

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
                    { "1", () => UpdateShipToCustomer(_buyer) },
                    { "2", () => customerShipToTextBox.Focus() },
                    { "3", () => DeleteShipToCustomer(_buyer) },
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
                buyer.grp_desc != groupDescriptionTextBox.Text;
               // buyer.bbuycode != principalBillToNameTextBox.Text;
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
                    }
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserInput);
            }
        }

        private void SetShipToCustomerProperties(buyer buyer)
        {
            buyer.name = customerShipToTextBox.Text;
            buyer.phone = phoneNumberMaskedTextBox.Text;
            buyer.fax = faxNumberMaskedTextBox.Text;
            buyer.cont_name = contactName1TextBox.Text;
            buyer.cont_nam2 = contactName2TextBox.Text;
            buyer.cont_ph = contactPhoneMaskedTextBox.Text;
            buyer.cont_fax = contactFaxMaskedTextBox.Text;
            buyer.frt_ph = freightContactPhoneMaskedTextBox.Text;
            buyer.del_ph = deliveryPhoneMaskedTextBox.Text;
            buyer.del_mail = deliveryEmailTextBox.Text;
            buyer.del_time = receivingHoursTextBox.Text;
            buyer.mon_recv = receivingMondayTextBox.Text;
            buyer.tue_recv = receivingTuesdayTextBox.Text;
            buyer.wed_recv = receivingWednesdayTextBox.Text;
            buyer.thu_recv = receivingThursdayTextBox.Text;
            buyer.fri_recv = receivingFridayTextBox.Text;
            buyer.sat_recv = receivingSaturdayTextBox.Text;
            buyer.sun_recv = receivingSundayTextBox.Text;
            buyer.street = shipToAddressTextBox.Text;
            buyer.city = shipToCityTextBox.Text;
            buyer.state = shipToStateTextBox.Text;
            buyer.zip = shipToZipTextBox.Text;
            buyer.zip4 = shipToZip4TextBox.Text;
            buyer.note = noteTextBox.Text;
            buyer.grp_code = groupCodeTextBox.Text;
            buyer.grp_desc = groupDescriptionTextBox.Text;
           // buyer.bbuycode = principalBillToNameTextBox.Text;
            _buyer = buyer;
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

        public void DisplayShipToCustomerData(buyer buyer)
        {
            _buyer = buyer;

            customerShipToTextBox.Text = _buyer.name;
            phoneNumberMaskedTextBox.Text = _buyer.phone;
            faxNumberMaskedTextBox.Text = _buyer.fax;
            contactName1TextBox.Text = _buyer.cont_name;
            contactName2TextBox.Text = _buyer.cont_nam2;
            contactPhoneMaskedTextBox.Text = _buyer.cont_ph;
            contactFaxMaskedTextBox.Text = _buyer.cont_fax;
            freightContactPhoneMaskedTextBox.Text = _buyer.frt_ph;
            deliveryPhoneMaskedTextBox.Text = _buyer.del_ph;
            deliveryEmailTextBox.Text = _buyer.del_mail;
            receivingHoursTextBox.Text = _buyer.del_time;
            receivingMondayTextBox.Text = _buyer.mon_recv;
            receivingTuesdayTextBox.Text = _buyer.tue_recv;
            receivingWednesdayTextBox.Text = _buyer.wed_recv;
            receivingThursdayTextBox.Text = _buyer.thu_recv;
            receivingFridayTextBox.Text = _buyer.fri_recv;
            receivingSaturdayTextBox.Text = _buyer.sat_recv;
            receivingSundayTextBox.Text = _buyer.sun_recv;
            shipToAddressTextBox.Text = _buyer.street;
            shipToCityTextBox.Text = _buyer.city;
            shipToStateTextBox.Text = _buyer.state;
            shipToZipTextBox.Text = _buyer.zip;
            shipToZip4TextBox.Text = _buyer.zip4;
            noteTextBox.Text = _buyer.note;
            groupCodeTextBox.Text = _buyer.grp_code;
            groupDescriptionTextBox.Text = _buyer.grp_desc;

            //TODO: Add logic to display data from other tables
           // principalBillToNameTextBox.Text = _buyer.bbuycode;

        }
    }
}
