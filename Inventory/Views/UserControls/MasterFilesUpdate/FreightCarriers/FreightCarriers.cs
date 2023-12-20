using Inventory.Interfaces;
using Inventory.Models;
using Microsoft.EntityFrameworkCore.Query.Internal;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Inventory.Services;
using Microsoft.EntityFrameworkCore;

namespace Inventory.Views.UserControls.MasterFilesUpdate.FreightCarriers
{
    public partial class FreightCarriers : UserControl, IActiveControlManager
    {
        //-- class variables --//
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private readonly DbContext dbContext;
        public FreightCarriers(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Freight Carrier");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Cancel    4. Main Menu");
        }
        public void PerformAction(string userInput)
        {
            switch(userInput)
            {
                case "1":
                    //SaveFreightCarrier
                    break;
                case "2":
                    //EditFreightCarrier
                    break;
                case "3":
                    //DeleteFreightCarrier
                    break;
                case "4":
                    //MainMenu
                    break;
                case "5":
                    //FeightInsurance
                    break;
                default:
                    MessageBox.Show("ERROR: Invalid input, please contact developer");
                    break;
            }
        }
        public void GetFreightCarrierData(freight freightData)
        {
            throw new NotImplementedException();
        }
    }
}
