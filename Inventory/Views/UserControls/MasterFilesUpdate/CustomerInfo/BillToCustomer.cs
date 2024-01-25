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
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Main Menu    5. Save/Update Insurance");
        }
        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    break;
                case "2":
                    break;
                case "3":
                    break;
                case "4":
                    break;
                case "5":
                    break;
                default:
                    MessageBox.Show("ERROR: Invalid input, please contact developer");
                    break;
            }
        }
        public void DisplayBillToData(bil_buy bil_Buy)
        {
            //TODO: Get data from passed object and populate fields
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
        private void IsDataModified(bil_buy bil_Buy)
        {
            //TODO: Check if data has been modified
        }
        private void UpdateBillTo(bil_buy bil_Buy)
        {
            //ToDo: Update data in database
        }
    }
}
