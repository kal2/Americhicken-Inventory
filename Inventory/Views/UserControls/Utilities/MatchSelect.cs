using Inventory.Models;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;
using Inventory.Services;
using Inventory.Interfaces;

namespace Inventory.Views.UserControls
{
    public partial class MatchSelect : UserControl, IActiveControlManager
    {
        // -- Class Variables -- //

        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private string matchSelectLabel = string.Empty;
        private List<object> _results = [];
        private string _selectedTable = string.Empty;
        private int i = 0;
        private readonly int _pageSize = 11;
        private int _currentPage = 1;

        // -- Event Handlers -- //

        public event EventHandler<SelectedSearchResultEventArgs> SelectedSearchResult;

        public class SelectedSearchResultEventArgs : EventArgs
        {
            public object SelectedResult { get; }

            public SelectedSearchResultEventArgs(object selectedResult)
            {
                SelectedResult = selectedResult;
            }
        }

        // -- Constructor -- //

        public MatchSelect(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager; 
            Load += (s, e) => selectedItemNumber.Focus();
        }

        // -- Methods -- //

        public void SetMatchSelectLabel(string label)
        {
            matchSelectLabel = label;
        }

        public void GetResults(List<object> results, string selectedTable)
        {
            if (results == null)
            {
                MessageBox.Show("ERROR: 'results' is null, please contact developer");
                return;
            }
            else if (selectedTable == null)
            {
                MessageBox.Show("ERROR: 'selectedTable' able is null, please contact developer");
                return;
            }
            else if (results.Count == 0)
            {
                MessageBox.Show("No results found");
                return;
            }
            else if (results.Count == 1)
            {
                SelectedSearchResult?.Invoke(this, new SelectedSearchResultEventArgs(results[0]));
                _mainWindow.DisposeControl(this);
                return;
            }
            else
            {
                _results = results;
                _selectedTable = selectedTable;
                DisplayResults(results, selectedTable);
            }
        }

        private void DisplayResults(List<object> results, string selectedTable)
        {
            resultSelectionListView.Items.Clear();

            Dictionary<string, Func<object, ListViewItem>> displayHandlers = new Dictionary<string, Func<object, ListViewItem>>()
            {
                { "supplier", item => CreateListViewItem(item as supplier) },
                { "remitTo", item => CreateListViewItem(item as rem_sup) },
                { "freight", item => CreateListViewItem(item as freight) }
            };

            if (!displayHandlers.ContainsKey(selectedTable.Trim()))
            {
                MessageBox.Show("Invalid table selection: " + selectedTable);
                return;
            }

            int startIndex = (_currentPage - 1) * _pageSize;
            int endIndex = Math.Min(startIndex + _pageSize, results.Count);

            for (int i = startIndex; i < endIndex; i++)
            {
                var item = results[i];
                if (item != null)
                {
                    ListViewItem listViewItem = displayHandlers[selectedTable.Trim()](item);
                    listViewItem.Text = (i+1).ToString();
                    resultSelectionListView.Items.Add(listViewItem);
                }
            }
        }

        private ListViewItem CreateListViewItem(supplier supResult)
        {
            ListViewItem supSelectionChoice = new ListViewItem();
            supSelectionChoice.SubItems.Add(supResult?.name);
            supSelectionChoice.SubItems.Add(supResult?.city);
            supSelectionChoice.SubItems.Add(supResult?.state);

            supSelectionChoice.Tag = supResult;

            return supSelectionChoice;
        }

        private ListViewItem CreateListViewItem(rem_sup remitResult)
        {
            ListViewItem remitSelectionChoice = new ListViewItem();
            remitSelectionChoice.SubItems.Add(remitResult?.name);
            remitSelectionChoice.SubItems.Add(remitResult?.city);
            remitSelectionChoice.SubItems.Add(remitResult?.state);
            remitSelectionChoice.SubItems.Add(remitResult?.street);

            remitSelectionChoice.Tag = remitResult;

            return remitSelectionChoice;
        }

        private ListViewItem CreateListViewItem(freight freightResult)
        {
            ListViewItem freightSelectionChoice = new ListViewItem();
            freightSelectionChoice.SubItems.Add(freightResult?.NAME);
            freightSelectionChoice.SubItems.Add(freightResult?.CITY);
            freightSelectionChoice.SubItems.Add(freightResult?.STATE);

            freightSelectionChoice.Tag = freightResult;

            return freightSelectionChoice;
        }



        // -- Event Listeners -- //

        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //next page
                    if (_currentPage < Math.Ceiling((double)_results.Count / _pageSize))
                    {
                        _currentPage++;
                        DisplayResults(_results, _selectedTable);  // Reuse DisplayResults with pagination
                    }
                    break;

                case "2":
                    //previous page
                    if (_currentPage > 1)
                    {
                        _currentPage--;
                        DisplayResults(_results, _selectedTable);  // Reuse DisplayResults with pagination
                    }
                    break;

                case "3":
                    //first page
                    _currentPage = 1;
                    DisplayResults(_results, _selectedTable);  // Reuse DisplayResults with pagination
                    break;

                case "4":
                    //add new
                    _mainWindow.DisposeControl(this);
                    SelectedSearchResult?.Invoke(this, new SelectedSearchResultEventArgs(null));
                    break;

                case "5":
                    //Main Menu
                    _mainWindow.DisposeControl(this);
                    _activeControlManager.SetActiveControl(new MenuList(_mainWindow, _activeControlManager));
                    break;
            }
            _mainWindow.ClearTextBox();
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetCommandsLabel("1. Next Pg    2. Previous Pg    3. First Pg    4. Add " + matchSelectLabel + "    5. Main Menu");
            _mainWindow.SetTextBoxLabel("ACTION:");
            _mainWindow.SetProgramLabel(matchSelectLabel + " Match Select");
        }

        private void selectedItemNumber_TextChanged(object sender, EventArgs e)
        {
            if (int.TryParse(selectedItemNumber.Text, out int userInput) && userInput >= 1 && userInput <= resultSelectionListView.Items.Count)
            {
                int selectedIndex = userInput - 1;
                resultSelectionListView.SelectedItems.Clear();
                resultSelectionListView.Items[selectedIndex].Selected = true;
                resultSelectionListView.EnsureVisible(selectedIndex); // Scrolls to the selected item if it's not visible
            }
        }

        private void selectedItemNumber_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                if (resultSelectionListView.SelectedItems.Count > 0)
                {
                    object selectedObject = resultSelectionListView.SelectedItems[0].Tag;

                    SelectedSearchResult?.Invoke(this, new SelectedSearchResultEventArgs(selectedObject));
                }
            }
        }
    }
}