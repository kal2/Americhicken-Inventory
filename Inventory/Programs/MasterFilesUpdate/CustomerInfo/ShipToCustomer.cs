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
        private readonly AmerichickenContext dbContext;
        private buyer? _buyer = null;

        public ShipToCustomer(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
            dbContext = new AmerichickenContext();

            Load += (s, e) => customerShipToTextBox.Focus();
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("VIEW/CHANGE/DELETE SHIP TO CUSTOMER INFORMATION");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Cancel");
        }
        private void ExitProgram()
        {
            using (var _programLoader = new ProgramLoader(_mainWindow, _activeControlManager))
            {
                _mainWindow.DisposeControl(this);
                _programLoader.LoadProgram("buyer");
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

        public void DisplayShipToCustomerData(buyer buyer)
        {
            _buyer = buyer;

            customerShipToTextBox.Text = Converter.TrimOrNull(_buyer.name);
            phoneNumberMaskedTextBox.Text = Converter.TrimOrNull(_buyer.phone);
            faxNumberMaskedTextBox.Text = Converter.TrimOrNull(_buyer.fax);
            contactName1TextBox.Text = Converter.TrimOrNull(_buyer.cont_name);
            contactName2TextBox.Text = Converter.TrimOrNull(_buyer.cont_nam2);
            contactPhoneMaskedTextBox.Text = Converter.TrimOrNull(_buyer.cont_ph);
            contactFaxMaskedTextBox.Text = Converter.TrimOrNull(_buyer.cont_fax);
            freightContactPhoneMaskedTextBox.Text = Converter.TrimOrNull(_buyer.frt_ph);
            deliveryPhoneMaskedTextBox.Text = Converter.TrimOrNull(_buyer.del_ph);
            deliveryEmailTextBox.Text = Converter.TrimOrNull(_buyer.del_mail);
            receivingHoursTextBox.Text = Converter.TrimOrNull(_buyer.del_time);
            receivingMondayTextBox.Text = Converter.TrimOrNull(_buyer.mon_recv);
            receivingTuesdayTextBox.Text = Converter.TrimOrNull(_buyer.tue_recv);
            receivingWednesdayTextBox.Text = Converter.TrimOrNull(_buyer.wed_recv);
            receivingThursdayTextBox.Text = Converter.TrimOrNull(_buyer.thu_recv);
            receivingFridayTextBox.Text = Converter.TrimOrNull(_buyer.fri_recv);
            receivingSaturdayTextBox.Text = Converter.TrimOrNull(_buyer.sat_recv);
            receivingSundayTextBox.Text = Converter.TrimOrNull(_buyer.sun_recv);
            shipToAddressTextBox.Text = Converter.TrimOrNull(_buyer.street);
            shipToCityTextBox.Text = Converter.TrimOrNull(_buyer.city);
            shipToStateTextBox.Text = Converter.TrimOrNull(_buyer.state);
            shipToZipTextBox.Text = Converter.TrimOrNull(_buyer.zip);
            shipToZip4TextBox.Text = Converter.TrimOrNull(_buyer.zip4);
            noteTextBox.Text = Converter.TrimOrNull(_buyer.note);
            groupCodeTextBox.Text = Converter.TrimOrNull(_buyer.grp_code);
            groupDescriptionTextBox.Text = Converter.TrimOrNull(_buyer.grp_desc);

            //TODO: Add logic to display data from other tables
            principalBillToNameTextBox.Text = _buyer.bbuycode;

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
                buyer.bbuycode != principalBillToNameTextBox.Text;
        }
        private void SetShipToCustomerData(buyer buyer)
        {
            buyer.name = Converter.TrimOrNull(customerShipToTextBox.Text);
            buyer.phone = phoneNumberMaskedTextBox.Text;
            buyer.fax = Converter.TrimOrNull(faxNumberMaskedTextBox.Text);
            buyer.cont_name = Converter.TrimOrNull(contactName1TextBox.Text);
            buyer.cont_nam2 = Converter.TrimOrNull(contactName2TextBox.Text);
            buyer.cont_ph = Converter.TrimOrNull(contactPhoneMaskedTextBox.Text);
            buyer.cont_fax = Converter.TrimOrNull(contactFaxMaskedTextBox.Text);
            buyer.frt_ph = Converter.TrimOrNull(freightContactPhoneMaskedTextBox.Text);
            buyer.del_ph = Converter.TrimOrNull(deliveryPhoneMaskedTextBox.Text);
            buyer.del_mail = Converter.TrimOrNull(deliveryEmailTextBox.Text);
            buyer.del_time = Converter.TrimOrNull(receivingHoursTextBox.Text);
            buyer.mon_recv = Converter.TrimOrNull(receivingMondayTextBox.Text);
            buyer.tue_recv = Converter.TrimOrNull(receivingTuesdayTextBox.Text);
            buyer.wed_recv = Converter.TrimOrNull(receivingWednesdayTextBox.Text);
            buyer.thu_recv = Converter.TrimOrNull(receivingThursdayTextBox.Text);
            buyer.fri_recv = Converter.TrimOrNull(receivingFridayTextBox.Text);
            buyer.sat_recv = Converter.TrimOrNull(receivingSaturdayTextBox.Text);
            buyer.sun_recv = Converter.TrimOrNull(receivingSundayTextBox.Text);
            buyer.street = Converter.TrimOrNull(shipToAddressTextBox.Text);
            buyer.city = Converter.TrimOrNull(shipToCityTextBox.Text);
            buyer.state = Converter.TrimOrNull(shipToStateTextBox.Text);
            buyer.zip = Converter.TrimOrNull(shipToZipTextBox.Text);
            buyer.zip4 = Converter.TrimOrNull(shipToZip4TextBox.Text);
            buyer.note = Converter.TrimOrNull(noteTextBox.Text);
            buyer.grp_code = Converter.TrimOrNull(groupCodeTextBox.Text);
            buyer.grp_desc = Converter.TrimOrNull(groupDescriptionTextBox.Text);
            buyer.bbuycode = Converter.TrimOrNull(principalBillToNameTextBox.Text);
            _buyer = buyer;
        }
        private void CreateNewShipToCustomer()
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserInput);
            _mainWindow.AskUserConfirmation("You are about to add a new freight carrier. Would you like to continue?");

            void HandleUserInput(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    buyer buyer = new();
                    SetShipToCustomerData(buyer);
                    dbContext.buyer.Add(buyer);
                    dbContext.SaveChanges();
                }
                else if (e.UserChoice == false)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong creating new customer shipping info, please contact developer");
                }

            }
            _mainWindow.DetachConfirmationEventListener(HandleUserInput);
        }

        private void UpdateExistingShipToCustomer(buyer buyerData)
        {
            var existingBuyer = dbContext.buyer.Find(buyerData.PK_buyer);
            if (existingBuyer != null)
            {
                SetShipToCustomerData(existingBuyer);
                dbContext.SaveChanges();
            }
            else
            {
                MessageBox.Show("ERROR: Something went wrong updating customer shipping info, please contact developer");
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
                CreateNewShipToCustomer();
            }
        }

        private void DeleteShipToCustomer(buyer buyer)
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserInput);
            _mainWindow.AskUserConfirmation("You are about to delete this customer shipping info. Would you like to continue?");
            void HandleUserInput(object sender, UserConfirmationEventArgs e)
            {
                var existingBuyer = dbContext.buyer.Find(buyer.PK_buyer);
                if (existingBuyer != null)
                {
                    if (e.UserChoice == true)
                    {
                        dbContext.buyer.Remove(existingBuyer);
                        dbContext.SaveChanges();
                    }
                    else if (e.UserChoice == false)
                    {
                        return;
                    }
                    else
                    {
                        MessageBox.Show("ERROR: Something went wrong deleting customer shipping info, please contact developer");
                    }
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong deleting customer shipping info, please contact developer");
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserInput);
            }
            
        }
    }
}
