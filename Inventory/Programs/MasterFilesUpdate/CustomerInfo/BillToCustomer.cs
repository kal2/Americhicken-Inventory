using Inventory.Models;
using Inventory.Services;
using Inventory.Interfaces;
using static Inventory.Programs.Utilities.UserConfirmation;

namespace Inventory.Views.UserControls.MasterFilesUpdate.CustomerInfo
{
    public partial class BillToCustomer : UserControl, IActiveControlManager
    {
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private readonly AmerichickenContext dbContext;
        private bil_buy? _bil_Buy = null;
        public BillToCustomer(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
            dbContext = new AmerichickenContext();

            Load += (s, e) => customerNameTextBox.Focus();
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("VIEW/CHANGE/DELETE BILL TO CUSTOMER INFORMATION");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Cancel");
        }

        private void ExitProgram()
        {
            using (var _programLoader = new ProgramLoader(_mainWindow, _activeControlManager))
            {
                _mainWindow.DisposeControl(this);
                _programLoader.LoadProgram("bil_buy");
            }
        }

        public Dictionary<string, Action> AvailableActions
        {
            get
            {
                return new Dictionary<string, Action>
                {
                    { "1", () => UpdateBillToData(_bil_Buy) },
                    { "2", () => customerNameTextBox.Focus() },
                    { "3", () => DeleteBillToData(_bil_Buy) },
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

        public void DisplayBillToData(bil_buy bil_Buy)
        {
            _bil_Buy = bil_Buy;

            customerNameTextBox.Text = StringServices.TrimOrNull(bil_Buy.name);
            regNameTextBox.Text = StringServices.TrimOrNull(bil_Buy.reg_name);
            phoneMaskedTextBox.Text = StringServices.TrimOrNull(bil_Buy.area_code + bil_Buy.phone);
            faxMaskedTextBox.Text = StringServices.TrimOrNull(bil_Buy.fax);
            activeTextBox.Text = StringServices.TrimOrNull(bil_Buy.active);
            internationalTextBox.Text = StringServices.TrimOrNull(bil_Buy.internat);
            streetTextBox.Text = StringServices.TrimOrNull(bil_Buy.street);
            cityTextBox.Text = StringServices.TrimOrNull(bil_Buy.city);
            stateTextBox.Text = StringServices.TrimOrNull(bil_Buy.state);
            zipTextBox.Text = StringServices.TrimOrNull(bil_Buy.zip);
            zip4TextBox.Text = StringServices.TrimOrNull(bil_Buy.zip4);
            iLine1TextBox.Text = StringServices.TrimOrNull(bil_Buy.iline1);
            iLine2TextBox.Text = StringServices.TrimOrNull(bil_Buy.iline2);
            iLine3TextBox.Text = StringServices.TrimOrNull(bil_Buy.iline3);

            //ToDo: Make search for incentive sales
            //incentiveSalesTextBox.Text = StringServices.TrimOrNull(bil_Buy.incen_cd);

            creditLimitTextBox.Text = StringServices.TrimOrNull(bil_Buy.cred_lim.ToString());
            dateReviewedMaskBox.Text = StringServices.TrimOrNull(bil_Buy.date_rvwd.ToString());
            credRqsTextBox.Text = StringServices.TrimOrNull(bil_Buy.cred_rqst);
            federatedCustomerTextBox.Text = StringServices.TrimOrNull(bil_Buy.fed_cust);
            pOMessageTextBox.Text = StringServices.TrimOrNull(bil_Buy.po_warn);
            noteTextBox.Text = StringServices.TrimOrNull(bil_Buy.note);
            note2TextBox.Text = StringServices.TrimOrNull(bil_Buy.note2);
            creditAppTextBox.Text = StringServices.TrimOrNull(bil_Buy.credit_ap);
            creditAppDateMaskedTextBox.Text = bil_Buy.credap_dt.ToString();
            financialStatementTextBox.Text = StringServices.TrimOrNull(bil_Buy.fin_prov);
            financialDateMaskedTextBox.Text = bil_Buy.date_fin.ToString();
            dAndBReportTextBox.Text = StringServices.TrimOrNull(bil_Buy.db_rpt);
            credDateMaskedTextBox.Text = bil_Buy.db_dt.ToString();
            letterOfCredTextBox.Text = bil_Buy.let_crd.ToString();
            //ToDO: Figure out where the credit date is, going to use my best guess for the time being
            credDateMaskedTextBox.Text = bil_Buy.date_rqst.ToString();
        }
        private bool IsDataModified(bil_buy bil_Buy)
        {
            return bil_Buy == null || !customerNameTextBox.Text.Equals(bil_Buy.name) ||
                   !regNameTextBox.Text.Equals(bil_Buy.reg_name) ||
                   !phoneMaskedTextBox.Text.Equals(bil_Buy.area_code + bil_Buy.phone) ||
                   !faxMaskedTextBox.Text.Equals(bil_Buy.fax) ||
                   !activeTextBox.Text.Equals(bil_Buy.active) ||
                   !internationalTextBox.Text.Equals(bil_Buy.internat) ||
                   !streetTextBox.Text.Equals(bil_Buy.street) ||
                   !cityTextBox.Text.Equals(bil_Buy.city) ||
                   !stateTextBox.Text.Equals(bil_Buy.state) ||
                   !zipTextBox.Text.Equals(bil_Buy.zip) ||
                   !zip4TextBox.Text.Equals(bil_Buy.zip4) ||
                   !iLine1TextBox.Text.Equals(bil_Buy.iline1) ||
                   !iLine2TextBox.Text.Equals(bil_Buy.iline2) ||
                   !iLine3TextBox.Text.Equals(bil_Buy.iline3) ||
                   !creditLimitTextBox.Text.Equals(bil_Buy.cred_lim.ToString()) ||
                   !dateReviewedMaskBox.Text.Equals(bil_Buy.date_rvwd.ToString()) ||
                   !credRqsTextBox.Text.Equals(bil_Buy.cred_rqst) ||
                   !federatedCustomerTextBox.Text.Equals(bil_Buy.fed_cust) ||
                   !pOMessageTextBox.Text.Equals(bil_Buy.po_warn) ||
                   !noteTextBox.Text.Equals(bil_Buy.note) ||
                   !note2TextBox.Text.Equals(bil_Buy.note2) ||
                   !creditAppTextBox.Text.Equals(bil_Buy.credit_ap) ||
                   !creditAppDateMaskedTextBox.Text.Equals(bil_Buy.credap_dt.ToString()) ||
                   !financialStatementTextBox.Text.Equals(bil_Buy.fin_prov) ||
                   !financialDateMaskedTextBox.Text.Equals(bil_Buy.date_fin.ToString()) ||
                   !dAndBReportTextBox.Text.Equals(bil_Buy.db_rpt) ||
                   !credDateMaskedTextBox.Text.Equals(bil_Buy.db_dt.ToString()) ||
                   !letterOfCredTextBox.Text.Equals(bil_Buy.let_crd.ToString()) ||
                   !credDateMaskedTextBox.Text.Equals(bil_Buy.date_rqst.ToString());
        }

        private void SetBillToProperties(bil_buy existingBillTo)
        {
            _bil_Buy = existingBillTo;
            existingBillTo.name = StringServices.TrimOrNull(customerNameTextBox.Text);
            existingBillTo.reg_name = StringServices.TrimOrNull(regNameTextBox.Text);
            existingBillTo.area_code = StringServices.TrimOrNull(phoneMaskedTextBox.Text.Substring(0, 3));
            existingBillTo.phone = StringServices.TrimOrNull(phoneMaskedTextBox.Text.Substring(3, 7));
            existingBillTo.fax = StringServices.TrimOrNull(faxMaskedTextBox.Text);
            existingBillTo.active = StringServices.TrimOrNull(activeTextBox.Text);
            existingBillTo.internat = StringServices.TrimOrNull(internationalTextBox.Text);
            existingBillTo.street = StringServices.TrimOrNull(streetTextBox.Text);
            existingBillTo.city = StringServices.TrimOrNull(cityTextBox.Text);
            existingBillTo.state = StringServices.TrimOrNull(stateTextBox.Text);
            existingBillTo.zip = StringServices.TrimOrNull(zipTextBox.Text);
            existingBillTo.zip4 = StringServices.TrimOrNull(zip4TextBox.Text);
            existingBillTo.iline1 = StringServices.TrimOrNull(iLine1TextBox.Text);
            existingBillTo.iline2 = StringServices.TrimOrNull(iLine2TextBox.Text);
            existingBillTo.iline3 = StringServices.TrimOrNull(iLine3TextBox.Text);

            //ToDo: Make search for incentive sales
            //existingBillTo.incen_cd = StringServices.TrimOrNull(incentiveSalesTextBox.Text);

            existingBillTo.cred_lim = Convert.ToDecimal(creditLimitTextBox.Text);
            existingBillTo.date_rvwd = Convert.ToDateTime(dateReviewedMaskBox.Text);
            existingBillTo.cred_rqst = StringServices.TrimOrNull(credRqsTextBox.Text);
            existingBillTo.fed_cust = StringServices.TrimOrNull(federatedCustomerTextBox.Text);
            existingBillTo.po_warn = StringServices.TrimOrNull(pOMessageTextBox.Text);
            existingBillTo.note = StringServices.TrimOrNull(noteTextBox.Text);
            existingBillTo.note2 = StringServices.TrimOrNull(note2TextBox.Text);
            existingBillTo.credit_ap = StringServices.TrimOrNull(creditAppTextBox.Text);
            existingBillTo.credap_dt = Convert.ToDateTime(creditAppDateMaskedTextBox.Text);
            existingBillTo.fin_prov = StringServices.TrimOrNull(financialStatementTextBox.Text);
            existingBillTo.date_fin = Convert.ToDateTime(financialDateMaskedTextBox.Text);
            existingBillTo.db_rpt = StringServices.TrimOrNull(dAndBReportTextBox.Text);
            existingBillTo.db_dt = Convert.ToDateTime(credDateMaskedTextBox.Text);
            existingBillTo.let_crd = Convert.ToDecimal(letterOfCredTextBox.Text);
            existingBillTo.date_rqst = Convert.ToDateTime(credDateMaskedTextBox.Text);
        }

        private void UpdateExistingBillToData(bil_buy bil_Buy)
        {
            var existingBillTo = dbContext.bil_buy.Find(bil_Buy.PK_bil_buy);
            if (existingBillTo != null)
            {
                SetBillToProperties(existingBillTo);

                dbContext.SaveChanges();
            }
            else
            {
                MessageBox.Show("ERROR: Freight Carrier not found, please contact developer");
            }
            
        }

        private void CreateNewBillTo()
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserInput);

            _mainWindow.AskUserConfirmation("You Are About to Make a New Bill To Customer. Would you like to continue?  (Y/N)");

            void HandleUserInput(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    bil_buy bil_Buy = new();
                    SetBillToProperties(bil_Buy);
                    _bil_Buy = bil_Buy;
                    dbContext.bil_buy.Add(bil_Buy);
                    dbContext.SaveChanges();
                }
                else if (e.UserChoice == false)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong, please contact developer");
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserInput);
            }
        }

        private void UpdateBillToData(bil_buy bil_Buy)
        {
            if (bil_Buy != null)
            {
                if (IsDataModified(bil_Buy))
                {
                    UpdateExistingBillToData(bil_Buy);
                }
            }
            else
            {
                CreateNewBillTo();
            }
        }

        private void DeleteBillToData(bil_buy bil_Buy)
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserConfirmation);
            _mainWindow.AskUserConfirmation("You are about to delete a this entry. Would you like to continue?  (Y/N)");

            void HandleUserConfirmation(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    var existingBillTo = dbContext.bil_buy.Find(bil_Buy.PK_bil_buy);
                    dbContext.bil_buy.Remove(existingBillTo!);
                    dbContext.SaveChanges();
                }
                else if (e.UserChoice == false)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong, please contact developer");
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserConfirmation);
            }
        }
    }
}