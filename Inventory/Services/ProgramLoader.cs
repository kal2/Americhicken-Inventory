using Inventory.Views.UserControls;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;
using Inventory.Views.UserControls.MasterFilesUpdate.FreightCarriers;
using Inventory.Models;
using Inventory.Views.UserControls.MasterFilesUpdate.CustomerInfo;

namespace Inventory.Services
{
    public class ProgramLoader(MainWindow _mainWindow, ActiveControlManager _activeControlManager) : IDisposable
    {
        public void Dispose()
        {
            
        }
        public void LoadProgram(string programName)
        {
            switch (programName)
            {
                case "rem_sup":
                    LoadRemitToSupplier();
                    break;

                case "supplier":
                    LoadShipFromSupplier();
                    break;

                case "freight":
                    LoadFreightCarrier();
                    break;

                case "bil_buy":
                    LoadBillToCustomer();
                    break;

                case "buyer":
                    LoadShipToCustomer();
                    break;

                default:
                    MessageBox.Show("ERROR: Invalid program name, please contact developer");
                    break;
            }
        }
        //Remit To Supplier
        public void LoadRemitToSupplier()
        {
            _mainWindow.SetLastMenuDisplayed("masterfileupdate");
            RemitSupplier remitToUpdateInstance = new(_mainWindow, _activeControlManager);
            DbSearch dbSearch = new(_mainWindow, _activeControlManager);
            dbSearch.SetTable("rem_sup");
            dbSearch.SearchCompleted += (f3, f4) => HandleRemitToSearchCompleted(f3!, f4);
            _activeControlManager.SetActiveControl(dbSearch);

            void HandleRemitToSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
            {
                if (e.SearchResults == null)
                {
                    _activeControlManager.SetActiveControl(remitToUpdateInstance);
                }
                else
                {
                    MatchSelect matchSelectInstance = new(_mainWindow, _activeControlManager);
                    matchSelectInstance.SelectedSearchResult += (f, f2) => HandleSelectedRemitToSearchResult(f!, f2);
                    matchSelectInstance.SetMatchSelectLabel("Remit To");
                    matchSelectInstance.GetResults(e.SearchResults, e.TableSelected);
                    if (e.SearchResults.Count > 1)
                    {
                        _activeControlManager.SetActiveControl(matchSelectInstance);
                    }
                }
            }

            void HandleSelectedRemitToSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                if (e.SelectedResult != null)
                {
                    remitToUpdateInstance.DisplayRemitToData((rem_sup)e!.SelectedResult);
                }
                _activeControlManager.SetActiveControl(remitToUpdateInstance);
            }
        }
        //Ship From Supplier
        public void LoadShipFromSupplier()
        {
            _mainWindow.SetLastMenuDisplayed("masterfileupdate");
            ShipFromSupplier shipFromUpdateInstance = new(_mainWindow, _activeControlManager);
            DbSearch dbSearch = new(_mainWindow, _activeControlManager);
            dbSearch.SetTable("supplier");
            dbSearch.SearchCompleted += (f3, f4) => HandleSupplierSearchCompleted(f3!, f4);
            _activeControlManager.SetActiveControl(dbSearch);

            void HandleSupplierSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
            {
                if (e.SearchResults == null)
                {
                    _activeControlManager.SetActiveControl(shipFromUpdateInstance);
                }
                else
                {
                    MatchSelect matchSelectInstance = new(_mainWindow, _activeControlManager);
                    matchSelectInstance.SelectedSearchResult += (f, f2) => HandleSelectedSupplierSearchResult(f!, f2);
                    matchSelectInstance.SetMatchSelectLabel("Supplier");
                    matchSelectInstance.GetResults(e.SearchResults, e.TableSelected);
                    if (e.SearchResults.Count > 1)
                    {
                        _activeControlManager.SetActiveControl(matchSelectInstance);
                    }
                }
            }

            void HandleSelectedSupplierSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                if (e.SelectedResult != null)
                {
                    shipFromUpdateInstance.GetShipFromData((supplier)e!.SelectedResult);
                }
                _activeControlManager.SetActiveControl(shipFromUpdateInstance);
            }
        }
        //Freight Carrier
        public void LoadFreightCarrier()
        {
            _mainWindow.SetLastMenuDisplayed("masterfileupdate");
            FreightCarriers freightCarrierInstance = new (_mainWindow, _activeControlManager);
            DbSearch dbSearch = new (_mainWindow, _activeControlManager);
            dbSearch.SetTable("freight");
            dbSearch.SearchCompleted += (f3, f4) => HandleFreightCarrierSearchCompleted(f3!, f4);
            _activeControlManager.SetActiveControl(dbSearch);

            void HandleFreightCarrierSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
            {
                if (e.SearchResults == null)
                {
                    _activeControlManager.SetActiveControl(freightCarrierInstance);
                }
                else
                {
                    MatchSelect matchSelectInstance = new (_mainWindow, _activeControlManager);
                    matchSelectInstance.SelectedSearchResult += (f, f2) => HandleSelectedFreightCarrierSearchResult(f!, f2);
                    matchSelectInstance.SetMatchSelectLabel("Freight Carrier");
                    matchSelectInstance.GetResults(e.SearchResults, e.TableSelected);
                    if (e.SearchResults.Count > 1)
                    {
                        _activeControlManager.SetActiveControl(matchSelectInstance);
                    }
                }
            }

            void HandleSelectedFreightCarrierSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                if (e.SelectedResult != null)
                {
                    freightCarrierInstance.DisplayFreightCarrierData((freight)e!.SelectedResult);
                }
                _activeControlManager.SetActiveControl(freightCarrierInstance);
            }
        }
        //Ship To Customer
        public void LoadShipToCustomer()
        {
            _mainWindow.SetLastMenuDisplayed("masterfileupdate");
            ShipToCustomer shipToCustomerInstance = new(_mainWindow, _activeControlManager);
            DbSearch dbSearch = new(_mainWindow, _activeControlManager);
            dbSearch.SetTable("buyer");
            dbSearch.SearchCompleted += (f3, f4) => HandleBuyerSearchCompleted(f3!, f4);
            _activeControlManager.SetActiveControl(dbSearch);

            void HandleBuyerSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
            {
                if (e.SearchResults == null)
                {
                    _activeControlManager.SetActiveControl(shipToCustomerInstance);
                }
                else
                {
                    MatchSelect matchSelectInstance = new(_mainWindow, _activeControlManager);
                    matchSelectInstance.SelectedSearchResult += (f, f2) => HandleSelectedBuyerSearchResult(f!, f2);
                    matchSelectInstance.SetMatchSelectLabel("Buyer");
                    matchSelectInstance.GetResults(e.SearchResults, e.TableSelected);
                    if (e.SearchResults.Count > 1)
                    {
                        _activeControlManager.SetActiveControl(matchSelectInstance);
                    }
                }
            }

            void HandleSelectedBuyerSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                if (e.SelectedResult != null)
                {
                    shipToCustomerInstance.DisplayShipToCustomerData((buyer)e!.SelectedResult);
                }
                _activeControlManager.SetActiveControl(shipToCustomerInstance);
            }
        }
        //Bill To Customer
        public void LoadBillToCustomer()
        {
            _mainWindow.SetLastMenuDisplayed("masterfileupdate");
            BillToCustomer billToCustomerInstance  = new (_mainWindow, _activeControlManager);
            DbSearch dbSearch = new (_mainWindow, _activeControlManager);
            dbSearch.SetTable("bil_buy");
            dbSearch.SearchCompleted += (f3, f4) => HandleBillToSearchCompleted(f3!, f4);
            _activeControlManager.SetActiveControl(dbSearch);

            void HandleBillToSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
            {
                if (e.SearchResults == null)
                {
                    _activeControlManager.SetActiveControl(billToCustomerInstance);
                }
                else
                {
                    MatchSelect matchSelectInstance = new (_mainWindow, _activeControlManager);
                    matchSelectInstance.SelectedSearchResult += (f, f2) => HandleSelectedBillToSearchResult(f!, f2);
                    matchSelectInstance.SetMatchSelectLabel("Bill To");
                    matchSelectInstance.GetResults(e.SearchResults, e.TableSelected);
                    if (e.SearchResults.Count > 1)
                    {
                        _activeControlManager.SetActiveControl(matchSelectInstance);
                    }
                }
            }

            void HandleSelectedBillToSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                if (e.SelectedResult != null)
                {
                    billToCustomerInstance.DisplayBillToData((bil_buy)e!.SelectedResult);
                }
                _activeControlManager.SetActiveControl(billToCustomerInstance);
            }
        }
    }
}