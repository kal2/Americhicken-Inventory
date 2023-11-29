using Inventory.Models;
using Inventory.Views.UserControls;
using Microsoft.EntityFrameworkCore;

namespace Inventory.Views.UserControls
{
    public partial class DbSearch : UserControl
    {
    
        // -- Class Variables -- //

        string selectedTable = string.Empty;
        private MainWindow _mainWindow;

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

        // -- Constructor -- //

        public DbSearch(MainWindow mainWindow)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            //Change focus to desired field after User Control change.
            searchQuereyTextBox.Focus();
        }

        // -- Methods -- //

        public void SetTable(string tableName)
        {
            selectedTable = tableName;
        }

        public void SearchDatabase(string searchInput)
        {
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
                //Sends search results to the SearchResultsEventArgs handler's listener
                SearchCompleted?.Invoke(this, new SearchResultsEventArgs(searchResults, selectedTable));
            }
        }

        //For when the desired search query is already known, you can pass the db table and query directly to the method
        public void PerformSearch(string dbTable, string searchQuery)
        {
            SetTable(dbTable);
            SearchDatabase(searchQuery);
        }

        // -- Event Listeners -- //

        private void actionInput_KeyDown(object sender, KeyEventArgs e)
        {
            //Collects user input and format for processing
            string userInput = actionInput.Text.Trim();

            //Waits to execute code until enter key is pressed in input area
            if (e.KeyCode == Keys.Enter)
            {
                switch (userInput)
                {
                    //accepts the user's input and searches the db table selected from Program Switcher
                    case "1":
                        SearchDatabase(searchQuereyTextBox.Text);
                        break;

                    //returns user to main menu
                    case "3":
                    //    _mainWindow.ProgramSwitcher("menuList");
                        break;
                }
            }
        }

        private void searchQueryTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            //Waits to execute code until enter key is pressed in input area
            if (e.KeyCode == Keys.Enter)
            {
                SearchDatabase(searchQuereyTextBox.Text);
            }
        }
    }
}