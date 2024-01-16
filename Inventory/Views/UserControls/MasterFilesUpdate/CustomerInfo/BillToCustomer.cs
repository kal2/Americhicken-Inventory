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
        public void GetBillToData(bil_buy bil_Buy)
        {
            //TODO: Get data from database and populate fields
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
