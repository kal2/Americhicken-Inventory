using Inventory.Models;
using Inventory.Views.UserControls;
using Inventory.Services;
using Microsoft.EntityFrameworkCore;
using System.DirectoryServices;
using Inventory.Interfaces;

namespace Inventory.Views.UserControls
{
    public partial class DbSearch : UserControl, IActiveControlManager
    {
        // -- Class Variables -- //

        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        string selectedTable = string.Empty;
        string programLabel = string.Empty;

        // -- Event Handlers -- //

        public event EventHandler<SearchResultsEventArgs> SearchCompleted;
        public class SearchResultsEventArgs(List<object> searchResults, string tableSelected) : EventArgs
        {
            public List<object> SearchResults { get; } = searchResults;
            public string TableSelected { get; } = tableSelected;
        }

        // -- Constructor -- //

        public DbSearch(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
        }

        // -- Methods -- //

        public void SetTable(string tableName)
        {
            if (tableName?.Length == 0)
            {
                MessageBox.Show("ERROR: No db table selected to search, please contact developer");
            }
            else if (tableName != "supplier" && tableName != "remitTo" && tableName != "freight")
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
                DialogResult dialogResult = MessageBox.Show("SearchBox is Empty. Do you want to add a new entry?", "Confirmation", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);

                if (dialogResult == DialogResult.Yes)
                {
                    //hide searchpanel
                    _mainWindow.DisposeControl(this);
                    //search completed event
                    SearchCompleted?.Invoke(this, new SearchResultsEventArgs(null!, selectedTable));
                }
                else if (dialogResult == DialogResult.No)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong checking searchbox text, please contact developer");
                }
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

                    default:
                        break;
                }
                if (searchResults.Count == 0)
                {
                    MessageBox.Show("No results found");
                }
                else
                {
                    //Sends search results to the SearchResultsEventArgs handler's listener
                    SearchCompleted?.Invoke(this, new SearchResultsEventArgs(searchResults, selectedTable));
                    _mainWindow.DisposeControl(this);
                }
            }
        }

        //For when the desired search query is already known, you can pass the db table and query directly to the method
        public void PerformSearch(string dbTable, string searchQuery)
        {
            SetTable(dbTable);
            SearchDatabase(searchQuery);
        }

        // -- Event Listeners -- //

        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                //accepts the user's input and searches the db table selected from Program Switcher
                case "1":
                    SearchDatabase(searchQuereyTextBox.Text);
                    break;

                case "2":
                    searchQuereyTextBox.Clear();
                    searchQuereyTextBox.Focus();
                    break;

                //returns user to main menu
                case "3":
                    _mainWindow.DisposeControl(this);
                    _activeControlManager.SetActiveControl(new MenuList(_mainWindow, _activeControlManager));
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

            if (selectedTable == "supplier")
            {
                programLabel = "Supplier";
            }
            else if (selectedTable == "remitTo")
            {
                programLabel = "Remit To";
            }
            else if (selectedTable == "freight")
            {
                programLabel = "Freight Carrier";
            }
            else
            {
                programLabel = "ERROR";
            }
            _mainWindow.SetProgramLabel("Search for " + programLabel);
        }

        private void searchQueryTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            //Waits to execute code until enter key is pressed in input area
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