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
using Inventory.Models;
using Inventory.Services;

namespace Inventory.Views.UserControls.MasterFilesUpdate.FreightCarriers
{
    public partial class FreightInsurance : UserControl, IActiveControlManager
    {
        //-- class variables --//
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        public FreightInsurance(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Freight Insurance");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Cancel    4. Main Menu");
        }
        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //Save/Return
                    break;
                case "2":
                    //Edit
                    break;
                case "3":
                    //Main Menu
                    break;
                default:
                    MessageBox.Show("ERROR: Invalid input, please contact developer");
                    break;
            }
        }
        public void GetFreightInsurance(freight freightData)
        {
            //Display Freight Insurance Data

        }
    }
}
