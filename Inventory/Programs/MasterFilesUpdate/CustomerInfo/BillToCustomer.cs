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
        private bil_buy? _bil_Buy = null;
        public BillToCustomer(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;

            Load += (s, e) => customerNameTextBox.Focus();
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("ADD/CHANGE/DELETE BILL TO CUSTOMER INFORMATION");
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
                    { "1", () => UpdateBillToData(_bil_Buy) },
                    { "2", () => customerNameTextBox.Focus() },
                    { "3", () => DeleteBillToData(_bil_Buy) },
                    { "4", () => ExitProgram() }
                };
            }
        }

        private void UpdateBillToData(bil_buy bil_Buy)
        {
            if (bil_Buy != null)
            {
                if (IsDataModified(bil_Buy))
                {
                    UpdateExistingBillTo(bil_Buy);
                }
            }
            else
            {
                AddNewBillTo();
            }
        }
        private bool IsDataModified(bil_buy bil_Buy)
        {
            return bil_Buy == null ||
                    bil_Buy.name != customerNameTextBox.Text ||
                    bil_Buy.reg_name != regNameTextBox.Text ||
                    bil_Buy.phone != phoneMaskedTextBox.Text ||
                    bil_Buy.fax != faxMaskedTextBox.Text ||
                    bil_Buy.active != activeTextBox.Text ||
                    bil_Buy.internat != internationalTextBox.Text ||
                    bil_Buy.street != streetTextBox.Text ||
                    bil_Buy.city != cityTextBox.Text ||
                    bil_Buy.state != stateTextBox.Text ||
                    bil_Buy.zip != zipTextBox.Text ||
                    bil_Buy.zip4 != zip4TextBox.Text ||
                    bil_Buy.iline1 != iLine1TextBox.Text ||
                    bil_Buy.iline2 != iLine2TextBox.Text ||
                    bil_Buy.iline3 != iLine3TextBox.Text ||
                    bil_Buy.cred_lim != Converter.ParseDecimal(creditLimitTextBox.Text) ||
                    bil_Buy.date_rvwd != Converter.ParseDateTime(dateReviewedMaskBox.Text) ||
                    bil_Buy.cred_rqst != credRqsTextBox.Text ||
                    bil_Buy.fed_cust != federatedCustomerTextBox.Text ||
                    bil_Buy.po_warn != pOMessageTextBox.Text ||
                    bil_Buy.note != noteTextBox.Text ||
                    bil_Buy.note2 != note2TextBox.Text ||
                    bil_Buy.credit_ap != creditAppTextBox.Text ||
                    bil_Buy.credap_dt != Converter.ParseDateTime(creditAppDateMaskedTextBox.Text) ||
                    bil_Buy.fin_prov != financialStatementTextBox.Text ||
                    bil_Buy.date_fin != Converter.ParseDateTime(financialDateMaskedTextBox.Text) ||
                    bil_Buy.db_rpt != dAndBReportTextBox.Text ||
                    bil_Buy.db_dt != Converter.ParseDateTime(credDateMaskedTextBox.Text) ||
                    bil_Buy.let_crd != Converter.ParseDecimal(letterOfCredTextBox.Text) ||
                    bil_Buy.date_rqst != Converter.ParseDateTime(credDateMaskedTextBox.Text);
        }

        private void UpdateExistingBillTo(bil_buy bil_Buy)
        {
            using (AmerichickenContext dbContext = new())
            {
                var existingBillTo = dbContext.bil_buy.Find(bil_Buy.PK_bil_buy);
                if (existingBillTo != null)
                {
                    SetBillToProperties(existingBillTo);

                    dbContext.SaveChanges();
                    ExitProgram();
                }
                else
                {
                    MessageBox.Show("ERROR: Customer not found, please contact developer");
                }
            }
        }

        private void AddNewBillTo()
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserInput);
            _mainWindow.AskUserConfirmation("You Are About to Make a New Bill To Customer. Would you like to continue?  (Y/N)");

            void HandleUserInput(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    using (AmerichickenContext dbContext = new())
                    {
                        bil_buy bil_Buy = new();
                        SetBillToProperties(bil_Buy);
                        _bil_Buy = bil_Buy;
                        dbContext.bil_buy.Add(bil_Buy);
                        dbContext.SaveChanges();
                        ExitProgram();
                    }
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserInput);
            }
        }

        private void SetBillToProperties(bil_buy existingBillTo)
        {
            _bil_Buy = existingBillTo;
            existingBillTo.name = customerNameTextBox.Text;
            existingBillTo.reg_name = regNameTextBox.Text;
            existingBillTo.phone = phoneMaskedTextBox.Text;
            existingBillTo.fax = faxMaskedTextBox.Text;
            existingBillTo.active = activeTextBox.Text;
            existingBillTo.internat = internationalTextBox.Text;
            existingBillTo.street = streetTextBox.Text;
            existingBillTo.city = cityTextBox.Text;
            existingBillTo.state = stateTextBox.Text;
            existingBillTo.zip = zipTextBox.Text;
            existingBillTo.zip4 = zip4TextBox.Text;
            existingBillTo.iline1 = iLine1TextBox.Text;
            existingBillTo.iline2 = iLine2TextBox.Text;
            existingBillTo.iline3 = iLine3TextBox.Text;

            //ToDo: Make search for incentive sales
            //existingBillTo.incen_cd = StringServices.TrimOrNull(incentiveSalesTextBox.Text);

            existingBillTo.cred_lim = Converter.ParseDecimal(creditLimitTextBox.Text);
            existingBillTo.date_rvwd = Converter.ParseDateTime(dateReviewedMaskBox.Text);
            existingBillTo.cred_rqst = credRqsTextBox.Text;
            existingBillTo.fed_cust = federatedCustomerTextBox.Text;
            existingBillTo.po_warn = pOMessageTextBox.Text;
            existingBillTo.note = noteTextBox.Text;
            existingBillTo.note2 = note2TextBox.Text;
            existingBillTo.credit_ap = creditAppTextBox.Text;
            existingBillTo.credap_dt = Converter.ParseDateTime(creditAppDateMaskedTextBox.Text);
            existingBillTo.fin_prov = financialStatementTextBox.Text;
            existingBillTo.date_fin = Converter.ParseDateTime(financialDateMaskedTextBox.Text);
            existingBillTo.db_rpt = dAndBReportTextBox.Text;
            existingBillTo.db_dt = Converter.ParseDateTime(credDateMaskedTextBox.Text);
            existingBillTo.let_crd = Converter.ParseDecimal(letterOfCredTextBox.Text);
            existingBillTo.date_rqst = Converter.ParseDateTime(credDateMaskedTextBox.Text);
        }

        private void DeleteBillToData(bil_buy bil_Buy)
        {
            _mainWindow.AttachConfirmationEventListener(HandleUserConfirmation);
            _mainWindow.AskUserConfirmation("You are about to delete a this entry. Would you like to continue?  (Y/N)");

            void HandleUserConfirmation(object sender, UserConfirmationEventArgs e)
            {
                if (e.UserChoice == true)
                {
                    using (AmerichickenContext dbContext = new())
                    {
                        var existingBillTo = dbContext.bil_buy.Find(bil_Buy.PK_bil_buy);
                        dbContext.bil_buy.Remove(existingBillTo!);
                        dbContext.SaveChanges();
                        ExitProgram();
                    }
                }
                _mainWindow.DetachConfirmationEventListener(HandleUserConfirmation);
            }
        }

        public void SetName(string name)
        {
            customerNameTextBox.Text = name;
        }

        private void ExitProgram()
        {
            using (var _programLoader = new ProgramLoader(_mainWindow, _activeControlManager))
            {
                _mainWindow.DisposeControl(this);
                _programLoader.LoadProgram("bil_buy");
            }
        }

        public void DisplayBillToData(bil_buy bil_Buy)
        {
            _bil_Buy = bil_Buy;

            customerNameTextBox.Text = bil_Buy.name;
            regNameTextBox.Text = bil_Buy.reg_name;
            phoneMaskedTextBox.Text = bil_Buy.phone;
            faxMaskedTextBox.Text = bil_Buy.fax;
            activeTextBox.Text = bil_Buy.active;
            internationalTextBox.Text = bil_Buy.internat;
            streetTextBox.Text = bil_Buy.street;
            cityTextBox.Text = bil_Buy.city;
            stateTextBox.Text = bil_Buy.state;
            zipTextBox.Text = bil_Buy.zip;
            zip4TextBox.Text = bil_Buy.zip4;
            iLine1TextBox.Text = bil_Buy.iline1;
            iLine2TextBox.Text = bil_Buy.iline2;
            iLine3TextBox.Text = bil_Buy.iline3;

            //ToDo: Make search for incentive sales
            //incentiveSalesTextBox.Text = StringServices.TrimOrNull(bil_Buy.incen_cd);

            creditLimitTextBox.Text = bil_Buy.cred_lim.ToString();
            dateReviewedMaskBox.Text = bil_Buy.date_rvwd.ToString();
            credRqsTextBox.Text = bil_Buy.cred_rqst;
            federatedCustomerTextBox.Text = bil_Buy.fed_cust;
            pOMessageTextBox.Text = bil_Buy.po_warn;
            noteTextBox.Text = bil_Buy.note;
            note2TextBox.Text = bil_Buy.note2;
            creditAppTextBox.Text = bil_Buy.credit_ap;
            creditAppDateMaskedTextBox.Text = bil_Buy.credap_dt.ToString();
            financialStatementTextBox.Text = bil_Buy.fin_prov;
            financialDateMaskedTextBox.Text = bil_Buy.date_fin.ToString();
            dAndBReportTextBox.Text = bil_Buy.db_rpt;
            credDateMaskedTextBox.Text = bil_Buy.db_dt.ToString();
            letterOfCredTextBox.Text = bil_Buy.let_crd.ToString();
            //ToDO: Figure out where the credit date is, going to use my best guess for the time being
            credDateMaskedTextBox.Text = bil_Buy.date_rqst.ToString();
        }
    }
}