using Inventory.Models;
using Inventory.Services;
using Microsoft.EntityFrameworkCore;
using Inventory.Interfaces;
using static Inventory.Programs.Utilities.UserConfirmation;

namespace Inventory.Views.UserControls
{
    public partial class DbSearch : UserControl, IActiveControlManager
    {
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private string selectedTable = string.Empty;
        private string programLabel = string.Empty;

        public event EventHandler<SearchResultsEventArgs> SearchCompleted;

        public class SearchResultsEventArgs : EventArgs
        {
            public List<object> SearchResults { get; }
            public string TableSelected { get; }
            public string NewEntryName { get; }

            public SearchResultsEventArgs(List<object> searchResults, string tableSelected, string newEntryName)
            {
                SearchResults = searchResults;
                TableSelected = tableSelected;
                NewEntryName = newEntryName;
            }
        }

        public DbSearch(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;

            Load += (s, e) => searchQuereyTextBox.Focus();
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetCommandsLabel("1. Continue    2. Edit    3. Cancel");
            _mainWindow.SetTextBoxLabel("ACTION:");

            switch (selectedTable)
            {
                case "supplier":
                    programLabel = "SUPPLIER";
                    break;

                case "remitTo":
                    programLabel = "REMIT TO";
                    break;

                case "freight":
                    programLabel = "FREIGHT CARRIER";
                    break;

                case "bil_buy":
                    programLabel = "CUSTOMER";
                    break;

                case "buyer":
                    programLabel = "CUSTOMER";
                    break;

                default:
                    programLabel = "ERROR";
                    break;
            }

            _mainWindow.SetProgramLabel("SEARCH FOR " + programLabel);
        }

        public void PerformAction(string userInput)
        {
            if (AvailableActions.TryGetValue(userInput, out var action))
            {
                action();
            }
            else
            {
                MessageBox.Show("ERROR: Invalid input, please try again or contact developer");
            }
        }

        public Dictionary<string, Action> AvailableActions
        {
            get
            {
                return new Dictionary<string, Action>
                {
                    { "1", () => SearchDatabase(searchQuereyTextBox.Text, true) },
                    { "2", () => searchQuereyTextBox.Clear() },
                    { "3", () => ExitControl() }
                };
            }
        }

        public void SetTable(string tableName)
        {
            if (string.IsNullOrEmpty(tableName))
            {
                MessageBox.Show("ERROR: No db table selected to search, please contact developer");
            }
            else if (tableName != "supplier" && tableName != "rem_sup" && tableName != "freight" && tableName != "bil_buy" && tableName != "buyer")
            {
                MessageBox.Show("ERROR: Invalid db table name, please contact developer");
            }
            else
            {
                selectedTable = tableName;
            }
        }

        public void SearchDatabase(string searchInput, bool addNewPrompt)
        {
            if (ValidationHelper.IsEmpty(searchInput))
            {
                _mainWindow.DisposeControl(this);
                _mainWindow.DisplayLastMenu();
            }
            else
            {
                searchInput = searchInput.Trim();
                var searchResults = new List<object>();
                using (var context = new AmerichickenContext())
                {
                    switch (selectedTable)
                    {
                        case "supplier":
                            searchResults = context.supplier.Where(s => EF.Functions.Like(s.name, searchInput + "%")).ToList().Cast<object>().ToList();
                            break;

                        case "rem_sup":
                            searchResults = context.rem_sup.Where(s => EF.Functions.Like(s.name, searchInput + "%")).ToList().Cast<object>().ToList();
                            break;

                        case "freight":
                            searchResults = context.freight.Where(s => EF.Functions.Like(s.NAME, searchInput + "%")).ToList().Cast<object>().ToList();
                            break;

                        case "bil_buy":
                            searchResults = context.bil_buy.Where(s => EF.Functions.Like(s.name, searchInput + "%")).ToList().Cast<object>().ToList();
                            break;

                        case "buyer":
                            searchResults = context.buyer.Where(s => EF.Functions.Like(s.name, searchInput + "%")).ToList().Cast<object>().ToList();
                            break;

                        default:
                            break;
                    }
                }
                if (searchResults.Count == 0)
                {
                    if (addNewPrompt == false)
                    {
                        MessageBox.Show("No results found.");
                        return;
                    }
                    else
                    {
                        _mainWindow.AttachConfirmationEventListener(AddNewEntry);
                        _mainWindow.AskUserConfirmation("No results found. Would you like to add a new entry? (Y/N)");

                        void AddNewEntry(object sender, UserConfirmationEventArgs e)
                        {
                            if (e.UserChoice == true)
                            {
                                SearchCompleted?.Invoke(this, new SearchResultsEventArgs(null!, selectedTable, searchInput));
                            }
                            else
                            {
                                ExitControl();
                            }
                            _mainWindow.DetachConfirmationEventListener(AddNewEntry);
                        }
                    }

                }
                else
                {
                    SearchCompleted?.Invoke(this, new SearchResultsEventArgs(searchResults, selectedTable, null!));
                    _mainWindow.DisposeControl(this);
                }
                
            }
        }

        public void PerformSearch(string dbTable, string searchQuery)
        {
            SetTable(dbTable);
            SearchDatabase(searchQuery, false);
        }

        private void ExitControl()
        {
            _mainWindow.DisposeControl(this); 
            _mainWindow.DisplayLastMenu();
        }

        private void searchQueryTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                SearchDatabase(searchQuereyTextBox.Text, true);
                e.Handled = true;
            }
        }
    }
}