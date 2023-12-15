using Inventory.Interfaces;
using Inventory.Views.UserControls;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;
using Inventory.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Inventory.Services
{
    public class ProgramLoader
    {
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;

        public ProgramLoader(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
        }

        public void LoadProgram(string programName)
        {
            switch (programName)
            {
                case "remitToSupplier":
                    LoadRemitToSupplier();
                    break;

                case "shipFromSupplier":
                    LoadShipFromSupplier();
                    break;
                default:
                    MessageBox.Show("ERROR: Invalid program name, please contact developer");
                    break;
            }
        }
    //Remit To Supplier
        public void LoadRemitToSupplier()
        {
            RemitToUpdateInfo remitToUpdateInfo = new (_mainWindow, _activeControlManager);
            DbSearch dbSearch = new (_mainWindow, _activeControlManager);
            dbSearch.SetTable("remitTo");
            dbSearch.SearchCompleted += HandleRemitToSearchCompleted;
            _activeControlManager.SetActiveControl(dbSearch);

            void HandleRemitToSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
            {
                if (e.SearchResults == null)
                {
                    _activeControlManager.SetActiveControl(remitToUpdateInfo);
                }
                else
                {
                    MatchSelect matchSelectInstance = new (_mainWindow, _activeControlManager);
                    matchSelectInstance.SelectedSearchResult += HandleSelectedRemitToSearchResult;
                    matchSelectInstance.SetMatchSelectLabel("Remit To");
                    matchSelectInstance.DisplayResults(e.SearchResults, e.TableSelected);
                    _activeControlManager.SetActiveControl(matchSelectInstance);
                }
            }

            void HandleSelectedRemitToSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                remitToUpdateInfo.GetRemitToData(e.SelectedResult as rem_sup);
                _mainWindow.DisposeControl(sender as UserControl);
                _activeControlManager.SetActiveControl(remitToUpdateInfo);
            }
        }
    //Ship From Supplier
        public void LoadShipFromSupplier()
        {
            ShipFromUpdateInfo shipFromUpdateInfo = new (_mainWindow, _activeControlManager);
            DbSearch dbSearch = new (_mainWindow, _activeControlManager);
            dbSearch.SetTable("supplier");
            dbSearch.SearchCompleted += HandleSupplierSearchCompleted;
            _activeControlManager.SetActiveControl(dbSearch);

            void HandleSupplierSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
            {
                if (e.SearchResults == null)
                {
                    _activeControlManager.SetActiveControl(shipFromUpdateInfo);
                }
                else
                {
                    MatchSelect matchSelectInstance = new (_mainWindow, _activeControlManager);
                    matchSelectInstance.SelectedSearchResult += HandleSelectedSupplierSearchResult;
                    matchSelectInstance.SetMatchSelectLabel("Supplier");
                    matchSelectInstance.DisplayResults(e.SearchResults, e.TableSelected);
                    _activeControlManager.SetActiveControl(matchSelectInstance);
                }
            }

            void HandleSelectedSupplierSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                shipFromUpdateInfo.GetShipFromData(e.SelectedResult as supplier);
                _mainWindow.DisposeControl(sender as UserControl);
                _activeControlManager.SetActiveControl(shipFromUpdateInfo);
            }
        }
    }
}
