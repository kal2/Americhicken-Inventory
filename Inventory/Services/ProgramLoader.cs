using Inventory.Views.UserControls;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Inventory.Services
{
    public class ProgramLoader
    {
        private MainWindow _mainWindow;
        private ActiveControlManager _activeControlManager;

        public ProgramLoader(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
        }

        public void LoadProgram(string programName)
        {
            switch (programName)
            {
                case "shipFromSupplierSearch":
                    ShipFromUpdateInfo shipFromUpdateInfo = new ShipFromUpdateInfo(_mainWindow, _activeControlManager);
                    DbSearch dbSearch = new DbSearch(_mainWindow, _activeControlManager);
                    dbSearch.SetTable("supplier");
                    dbSearch.SearchCompleted += shipFromUpdateInfo.HandleSearchCompleted;
                    _activeControlManager.SetActiveControl(dbSearch);
                    break;
                default:
                    MessageBox.Show("ERROR: Invalid program name, please contact developer");
                    break;
            }
        }
    }
}
