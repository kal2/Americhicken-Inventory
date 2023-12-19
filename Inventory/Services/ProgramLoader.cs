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
    public class ProgramLoader(MainWindow _mainWindow, ActiveControlManager _activeControlManager)
    {

        public void LoadProgram(string programName)
        {
            switch (programName)
            {
                case "remitToSupplier":
                    LoadRemitToSupplier();
                    break;

                case "shipFromSupplierSearch":
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
            dbSearch.SearchCompleted += (f3, f4) => HandleRemitToSearchCompleted(f3!, f4);
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
                    matchSelectInstance.SelectedSearchResult += (f, f2) => HandleSelectedRemitToSearchResult(f!, f2);
                    matchSelectInstance.SetMatchSelectLabel("Remit To");
                    matchSelectInstance.DisplayResults(e.SearchResults, e.TableSelected);
                    _activeControlManager.SetActiveControl(matchSelectInstance);
                }
            }

            void HandleSelectedRemitToSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                remitToUpdateInfo.GetRemitToData((rem_sup)e!.SelectedResult);
                _mainWindow.DisposeControl((UserControl)sender!);
                _activeControlManager.SetActiveControl(remitToUpdateInfo);
            }
        }
    //Ship From Supplier
        public void LoadShipFromSupplier()
        {
            ShipFromUpdateInfo shipFromUpdateInfo = new (_mainWindow, _activeControlManager);
            DbSearch dbSearch = new (_mainWindow, _activeControlManager);
            dbSearch.SetTable("supplier");
            dbSearch.SearchCompleted += (f3, f4) => HandleSupplierSearchCompleted(f3!, f4);
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
                    matchSelectInstance.SelectedSearchResult += (f, f2) => HandleSelectedSupplierSearchResult(f!, f2);
                    matchSelectInstance.SetMatchSelectLabel("Supplier");
                    matchSelectInstance.DisplayResults(e.SearchResults, e.TableSelected);
                    _activeControlManager.SetActiveControl(matchSelectInstance);
                }
            }

            void HandleSelectedSupplierSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                shipFromUpdateInfo.GetShipFromData((supplier)e!.SelectedResult);
                _mainWindow.DisposeControl((UserControl)sender!);
                _activeControlManager.SetActiveControl(shipFromUpdateInfo);
            }
        }
    }
}
