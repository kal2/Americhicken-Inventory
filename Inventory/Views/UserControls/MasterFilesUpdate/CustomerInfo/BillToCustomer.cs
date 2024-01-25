using Inventory.Models;
using Inventory.Services;
using Inventory.Views.UserControls.MasterFilesUpdate.FreightCarriers;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Inventory.Interfaces;

namespace Inventory.Views.UserControls.MasterFilesUpdate.CustomerInfo
{
    public partial class BillToCustomer : UserControl, IActiveControlManager
    {
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private readonly AmerichickenContext dbContext;
        private bil_buy _bil_Buy = new();
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
            _mainWindow.SetProgramLabel("Freight Carrier");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Main Menu");
        }
        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    UpdateBillToData(_bil_Buy);
                    break;
                case "2":
                    customerNameTextBox.Focus();
                    break;
                case "3":
                    DeleteBillToData(_bil_Buy);
                    break;
                case "4":
                    _mainWindow.DisposeControl(this);
                    _activeControlManager.SetActiveControl(new MenuList(_mainWindow, _activeControlManager));
                    break;
                default:
                    MessageBox.Show("ERROR: Invalid input, please try again or contact developer");
                    break;
            }
        }
        public void DisplayBillToData(bil_buy bil_Buy)
        {
            _bil_Buy = bil_Buy;

            customerNameTextBox.Text = bil_Buy.name;
            regNameTextBox.Text = bil_Buy.reg_name;
            phoneMaskedTextBox.Text = bil_Buy.area_code + bil_Buy.phone;
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
            incentiveSalesTextBox.Text = bil_Buy.incen_cd;
            creditLimitTextBox.Text = bil_Buy.cred_lim.ToString();
            dateReviewedMaskBox.Text = bil_Buy.date_rvwd.ToString();
            credRqsTextBox.Text = bil_Buy.cred_rqst;
            federatedCustomerTextBox.Text = bil_Buy.fed_cust;
            pOMessageTextBox.Text = bil_Buy.po_warn;
            noteTextBox.Text = bil_Buy.note;
            note2TextBox.Text = bil_Buy.note2;
            creditAppTextBox.Text = bil_Buy.credit_ap;
            creditAppDateMaskedTextBox.Text = bil_Buy.credap_dt.ToString();
            financialDateMaskedTextBox.Text = bil_Buy.fin_prov;
            financialDateMaskedTextBox.Text = bil_Buy.date_fin.ToString();
            dAndBReportTextBox.Text = bil_Buy.db_rpt;
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
                   !incentiveSalesTextBox.Text.Equals(bil_Buy.incen_cd) ||
                   !creditLimitTextBox.Text.Equals(bil_Buy.cred_lim.ToString()) ||
                   !dateReviewedMaskBox.Text.Equals(bil_Buy.date_rvwd.ToString()) ||
                   !credRqsTextBox.Text.Equals(bil_Buy.cred_rqst) ||
                   !federatedCustomerTextBox.Text.Equals(bil_Buy.fed_cust) ||
                   !pOMessageTextBox.Text.Equals(bil_Buy.po_warn) ||
                   !noteTextBox.Text.Equals(bil_Buy.note) ||
                   !note2TextBox.Text.Equals(bil_Buy.note2) ||
                   !creditAppTextBox.Text.Equals(bil_Buy.credit_ap) ||
                   !creditAppDateMaskedTextBox.Text.Equals(bil_Buy.credap_dt.ToString()) ||
                   !financialDateMaskedTextBox.Text.Equals(bil_Buy.fin_prov) ||
                   !financialDateMaskedTextBox.Text.Equals(bil_Buy.date_fin.ToString()) ||
                   !dAndBReportTextBox.Text.Equals(bil_Buy.db_rpt) ||
                   !credDateMaskedTextBox.Text.Equals(bil_Buy.db_dt.ToString()) ||
                   !letterOfCredTextBox.Text.Equals(bil_Buy.let_crd.ToString()) ||
                   !credDateMaskedTextBox.Text.Equals(bil_Buy.date_rqst.ToString());
        }
        private void SetBillToProperties(bil_buy existingBillTo)
        {
            _bil_Buy = existingBillTo;
            existingBillTo.name = customerNameTextBox.Text;
            existingBillTo.reg_name = regNameTextBox.Text;
            existingBillTo.area_code = phoneMaskedTextBox.Text.Substring(0, 3);
            existingBillTo.phone = phoneMaskedTextBox.Text.Substring(3, 7);
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
            existingBillTo.incen_cd = incentiveSalesTextBox.Text;
            existingBillTo.cred_lim = Convert.ToDecimal(creditLimitTextBox.Text);
            existingBillTo.date_rvwd = Convert.ToDateTime(dateReviewedMaskBox.Text);
            existingBillTo.cred_rqst = credRqsTextBox.Text;
            existingBillTo.fed_cust = federatedCustomerTextBox.Text;
            existingBillTo.po_warn = pOMessageTextBox.Text;
            existingBillTo.note = noteTextBox.Text;
            existingBillTo.note2 = note2TextBox.Text;
            existingBillTo.credit_ap = creditAppTextBox.Text;
            existingBillTo.credap_dt = Convert.ToDateTime(creditAppDateMaskedTextBox.Text);
            existingBillTo.fin_prov = financialDateMaskedTextBox.Text;
            existingBillTo.date_fin = Convert.ToDateTime(financialDateMaskedTextBox.Text);
            existingBillTo.db_rpt = dAndBReportTextBox.Text;
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
            DialogResult dialogResult = MessageBox.Show("You are about to add a new freight carrier." + Environment.NewLine + "Would you like to continue?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            if (dialogResult == DialogResult.Yes)
            {
                bil_buy bil_Buy = new();
                SetBillToProperties(bil_Buy);
                _bil_Buy = bil_Buy;
                dbContext.bil_buy.Add(bil_Buy);
                dbContext.SaveChanges();
            }
            else if (dialogResult == DialogResult.No)
            {
                return;
            }
            else
            {
                MessageBox.Show("ERROR: Something went wrong, please contact developer");
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
            DialogResult dialogResult = MessageBox.Show("You are about to delete a this entry." + Environment.NewLine + "Would you like to continue?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            if (dialogResult == DialogResult.Yes)
            {
                var existingBillTo = dbContext.bil_buy.Find(bil_Buy.PK_bil_buy);
                dbContext.bil_buy.Remove(existingBillTo!);
                dbContext.SaveChanges();
            }
            else if (dialogResult == DialogResult.No)
            {
                return;
            }
            else
            {
                MessageBox.Show("ERROR: Something went wrong, please contact developer");
            }
        }
    }
}
