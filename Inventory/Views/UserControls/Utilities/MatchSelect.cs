using Inventory.Models;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;
using Inventory.Services;
using Inventory.Interfaces;

namespace Inventory.Views.UserControls
{
    public partial class MatchSelect : UserControl, IActiveControlManager
    {
        // -- Class Variables -- //

        private MainWindow _mainWindow;
        private ActiveControlManager _activeControlManager;
        private string matchSelectLabel = string.Empty;

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
        }
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            //Change focus to desired field after User Control change.
            selectedItemNumber.Focus();
        }

        // -- Methods -- //

        public void SetMatchSelectLabel(string label)
        {
            matchSelectLabel = label;
        }

        public void DisplayResults(List<object> results, string selectedTable)
        {
            if (results == null)
            {
                MessageBox.Show("ERROR: Search results are null, please contact developer");
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
                results = results.ToList();
                selectedTable = selectedTable.Trim();

                resultSelectionListView.Items.Clear();

                for (int i = 0; i < results.Count; i++)
                {
                    var item = results[i];
                    if (item != null)
                    {
                        switch (selectedTable)
                        {
                            case "supplier":
                                var supResult = item as supplier;

                                ListViewItem supSelectionChoice = new ListViewItem((i + 1).ToString());
                                supSelectionChoice.SubItems.Add(supResult.name);
                                supSelectionChoice.SubItems.Add(supResult.city);
                                supSelectionChoice.SubItems.Add(supResult.state);

                                supSelectionChoice.Tag = supResult;

                                resultSelectionListView.Items.Add(supSelectionChoice);
                                break;

                            case "remitTo":
                                var remitResult = item as rem_sup;

                                ListViewItem remitSelectionChoice = new ListViewItem((i + 1).ToString());
                                remitSelectionChoice.SubItems.Add(remitResult.name);
                                remitSelectionChoice.SubItems.Add(remitResult.city);
                                remitSelectionChoice.SubItems.Add(remitResult.state);
                                remitSelectionChoice.SubItems.Add(remitResult.street);

                                remitSelectionChoice.Tag = remitResult;
                                resultSelectionListView.Items.Add(remitSelectionChoice);
                                break;

                            default:
                                MessageBox.Show("oops");
                                break;
                        }
                    }
                }
            }
        }

        // -- Event Listeners -- //

        public void PerformAction(string userInput)
        {
            switch (userInput)
            {
                case "1":
                    //next page
                    break;

                case "2":
                    //previous page
                    break;

                case "3":
                    //first page
                    break;

                case "4":
                    //add new (add label through the calling user control to customize verbiage)
                    break;

                case "5":
                    //cancel
                    break;
            }
            _mainWindow.ClearTextBox();
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetCommandsLabel("1. Next Pg    2. Previous Pg    3. First Pg    4. Add " + matchSelectLabel + "    5. Cancel");
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
                    _mainWindow.DisposeControl(this);
                }
            }
        }
    }
}