using Inventory.Models;
using Inventory.Services;
using Microsoft.EntityFrameworkCore;
using Inventory.Interfaces;

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

            public SearchResultsEventArgs(List<object> searchResults, string tableSelected)
            {
                SearchResults = searchResults;
                TableSelected = tableSelected;
            }
        }

        public DbSearch(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
        }

        public void SetTable(string tableName)
        {
            if (string.IsNullOrEmpty(tableName))
            {
                MessageBox.Show("ERROR: No db table selected to search, please contact developer");
            }
            else if (tableName != "supplier" && tableName != "remitTo" && tableName != "freight" && tableName != "bil_buy" && tableName != "buyer")
            {
                MessageBox.Show("ERROR: Invalid db table name, please contact developer");
            }
            else
            {
                selectedTable = tableName;
            }
        }

        public void SearchDatabase(string searchInput)
        {
            if (ValidationHelper.IsEmpty(searchInput))
            {
                _mainWindow.DisposeControl(this);
                _mainWindow.DisplayLastMenu();
            }
            else
            {
                searchInput = searchInput.Trim();

                using var context = new AmerichickenContext();
                var searchResults = new List<object>();

                switch (selectedTable)
                {
                    case "supplier":
                        searchResults = context.supplier.Where(s => EF.Functions.Like(s.name, searchInput + "%")).ToList().Cast<object>().ToList();
                        break;

                    case "remitTo":
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

                if (searchResults.Count == 0)
                {
                    //No Results Found. Woud you like to add a new entry?

                    SearchCompleted?.Invoke(this, new SearchResultsEventArgs(null!, selectedTable));
                }
                else
                {
                    SearchCompleted?.Invoke(this, new SearchResultsEventArgs(searchResults, selectedTable));
                    _mainWindow.DisposeControl(this);
                }
            }
        }

        public void PerformSearch(string dbTable, string searchQuery)
        {
            SetTable(dbTable);
            SearchDatabase(searchQuery);
        }

        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    SearchDatabase(searchQuereyTextBox.Text);
                    break;

                case "2":
                    searchQuereyTextBox.Clear();
                    searchQuereyTextBox.Focus();
                    break;

                case "3":
                    _mainWindow.DisposeControl(this);
                    _mainWindow.DisplayLastMenu();
                    break;

                default:
                    MessageBox.Show("Invalid input. Please try again.");
                    _mainWindow.ClearTextBox();
                    break;
            }
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

        private void searchQueryTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                SearchDatabase(searchQuereyTextBox.Text);
            }
        }

        private void DbSearch_Load(object sender, EventArgs e)
        {
            BeginInvoke(() => searchQuereyTextBox.Focus());
        }
    }
}