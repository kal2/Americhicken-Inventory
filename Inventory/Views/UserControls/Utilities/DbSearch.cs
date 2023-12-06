using Inventory.Models;
using Inventory.Views.UserControls;
using Inventory.Services;
using Microsoft.EntityFrameworkCore;
using System.DirectoryServices;

namespace Inventory.Views.UserControls
{
    public partial class DbSearch : UserControl
    {

        // -- Class Variables -- //

        private MainWindow _mainWindow;
        string selectedTable = string.Empty;
        string programLabel = string.Empty;

        // -- Event Handlers -- //

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
        public delegate void HideSearchPanelDelegate();
        public event HideSearchPanelDelegate HideSearchPanel;

        // -- Constructor -- //

        public DbSearch(MainWindow mainWindow)
        {
            InitializeComponent();
            _mainWindow = mainWindow;

            this.Disposed += (s, a) =>
            {
                _mainWindow.DetachTextBoxKeyDownHandler(actionInput_KeyDown);
            };
            //Attaches keydown event handler to user input field
            _mainWindow.AttachTextBoxKeyDownHandler(actionInput_KeyDown);

            _mainWindow.SetCommandsLabel("1. Continue    2. Edit    3. Cancel");
            _mainWindow.SetTextBoxLabel("ACTION:");
        }

        // -- Methods -- //

        public void SetTable(string tableName)
        {
            if (tableName == string.Empty)
            {
                MessageBox.Show("ERROR: No db table selected to search, please contact developer");
                return;
            }

            else if (tableName != "supplier" && tableName != "remitTo")
            {
                MessageBox.Show("ERROR: Invalid db table name, please contact developer");
                return;
            }

            else
            {
                selectedTable = tableName;

                if (selectedTable == "supplier")
                {
                    programLabel = "Supplier";
                }
                else if (selectedTable == "remitTo")
                {
                    programLabel = "Remit To";
                }
                else
                {
                    programLabel = "ERROR";
                }
                _mainWindow.SetProgramLabel("Search for " + programLabel);
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
                    OnHideSearchPanel();
                }
                else if (dialogResult == DialogResult.No)
                {
                    return;
                }
                else
                {
                    MessageBox.Show("ERROR: Something went wrong checking searchbox text, please contact developer");
                    return;
                }
            }

            else
            {
                searchInput = searchInput.Trim();

                using (var context = new AmerichickenContext())
                {
                    var searchResults = new List<object>();
                    switch (selectedTable)
                    {
                        case "supplier":
                            searchResults = context.supplier.Where(s => EF.Functions.Like(s.name, searchInput + "%")).ToList().Cast<object>().ToList();
                            break;

                        case "remitTo":
                            searchResults = context.rem_sup.Where(s => EF.Functions.Like(s.name, searchInput + "%")).ToList().Cast<object>().ToList();
                            break;

                        default:
                            break;
                    }
                    if (searchResults.Count == 0)
                    {
                        MessageBox.Show("No results found");
                        return;
                    }
                    else
                    {
                        //Sends search results to the SearchResultsEventArgs handler's listener
                        SearchCompleted?.Invoke(this, new SearchResultsEventArgs(searchResults, selectedTable));

                        //Removes keydown event handler from user input field
                        _mainWindow.DetachTextBoxKeyDownHandler(actionInput_KeyDown);
                    }
                }
            }
        }

        //For when the desired search query is already known, you can pass the db table and query directly to the method
        public void PerformSearch(string dbTable, string searchQuery)
        {
            SetTable(dbTable);
            SearchDatabase(searchQuery);
        }

        private void OnHideSearchPanel()
        {
            HideSearchPanel?.Invoke();
        }

        // -- Event Listeners -- //

        private void actionInput_KeyDown(object sender, KeyEventArgs e)
        {
            //Waits to execute code until enter key is pressed in input area
            if (e.KeyCode == Keys.Enter)
            {
                //Collects user input and format for processing
                string userInput = _mainWindow.GetTextBoxText().Trim();

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
                        _mainWindow.DisplayControl(new MenuList(_mainWindow));
                        _mainWindow.DetachTextBoxKeyDownHandler(actionInput_KeyDown);
                        break;

                    default:
                        MessageBox.Show("Invalid input. Please try again.");
                        _mainWindow.ClearTextBox();
                        break;
                }
            }
            _mainWindow.ClearTextBox();
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