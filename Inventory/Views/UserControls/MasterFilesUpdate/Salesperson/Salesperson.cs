using Inventory.Services;
using Inventory.Interfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Inventory.Views.UserControls.MasterFilesUpdate.Salesperson
{
    public partial class Salesperson : UserControl, IActiveControlManager
    {
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private Salesperson _salesperson;

        public Salesperson(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;


        }
        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Salesperson");
            _mainWindow.SetTextBoxLabel("Action: ");
            _mainWindow.SetCommandsLabel("1. Save    2. Edit    3. Delete    4. Main Menu    5. Save/Update Insurance");
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
                    //delete
                    break;
                case "4":
                    //main menu
                    break;
                default:
                    //error
                    break;
            }
        }
    }
}
