using Inventory.Interfaces;
using Inventory.Models;
using Microsoft.EntityFrameworkCore.Query.Internal;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers
{
    public partial class RemitInsurance : UserControl, IActiveControlManager
    {
        // --- class variables --- //
        private readonly IActiveControlManager _activeControlHelper;
        private readonly MainWindow _mainWindow;
        private readonly AmerichickenContext dbContext;
        public RemitInsurance(MainWindow mainWindow, IActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _activeControlHelper = activeControlManager;
            _mainWindow = mainWindow;
            dbContext = new AmerichickenContext();
            
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Remit Insurance");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Cancel");
        }
        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //save
                    break;
                case "2":
                    //edit
                    break;
                case "3":
                    //cancel
                    break;
                default:
                    MessageBox.Show("Invalid input, please try again or contact developer");
                    break;
            }
        }
    }
}
