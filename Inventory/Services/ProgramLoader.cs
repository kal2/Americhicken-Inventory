using Inventory.Views.UserControls;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;
using Inventory.Views.UserControls.MasterFilesUpdate.FreightCarriers;
using Inventory.Models;
using Inventory.Views.UserControls.MasterFilesUpdate.CustomerInfo;

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

                case "shipFromSupplier":
                    LoadShipFromSupplier();
                    break;

                case "freightCarrier":
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
            RemitSupplier remitToUpdateInfo = new (_mainWindow, _activeControlManager);
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
                    matchSelectInstance.GetResults(e.SearchResults, e.TableSelected);
                    _activeControlManager.SetActiveControl(matchSelectInstance);
                }
            }

            void HandleSelectedRemitToSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                remitToUpdateInfo.DisplayRemitToData((rem_sup)e!.SelectedResult);
                _activeControlManager.SetActiveControl(remitToUpdateInfo);
            }
        }
    //Ship From Supplier
        public void LoadShipFromSupplier()
        {
            ShipFromSupplier shipFromUpdateInfo = new (_mainWindow, _activeControlManager);
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
                    matchSelectInstance.GetResults(e.SearchResults, e.TableSelected);
                    _activeControlManager.SetActiveControl(matchSelectInstance);
                }
            }

            void HandleSelectedSupplierSearchResult(object sender, MatchSelect.SelectedSearchResultEventArgs e)
            {
                shipFromUpdateInfo.GetShipFromData((supplier)e!.SelectedResult);
                _activeControlManager.SetActiveControl(shipFromUpdateInfo);
            }
        }
    //Freight Carrier
        public void LoadFreightCarrier()
        {
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
            ShipToCustomer shipToCustomer = new (_mainWindow, _activeControlManager);
            DbSearch dbSearch = new (_mainWindow, _activeControlManager);
            dbSearch.SetTable("buyer");
            dbSearch.SearchCompleted += (f3, f4) => HandleBuyerSearchCompleted(f3!, f4);
            _activeControlManager.SetActiveControl(dbSearch);

            void HandleBuyerSearchCompleted(object sender, DbSearch.SearchResultsEventArgs e)
            {
                if (e.SearchResults == null)
                {
                    _activeControlManager.SetActiveControl(shipToCustomer);
                }
                else
                {
                    MatchSelect matchSelectInstance = new (_mainWindow, _activeControlManager);
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
                    shipToCustomer.DisplayShipToCustomerData((buyer)e!.SelectedResult);
                }
                _activeControlManager.SetActiveControl(shipToCustomer);
            }
        }
        //Bill To Customer
        public void LoadBillToCustomer()
        {
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