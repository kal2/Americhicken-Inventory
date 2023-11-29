using Inventory.Models;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;

namespace Inventory.Views.UserControls
{
    public partial class MatchSelect : UserControl
    {
        // -- Class Variables -- //

        private MainWindow _mainWindow;

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

        public MatchSelect(MainWindow mainWindow)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
        }
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            //Change focus to desired field after User Control change.
            selectedItemNumber.Focus();
        }

        // -- Methods -- //

        public void DisplayResults(List<object> results, string selectedTable)
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

        // -- Event Listeners -- //

        private void textBox2_KeyDown(object sender, KeyEventArgs e)
        {
            //Collects user input and format for processing
            string userInput = actionInput.Text.Trim();

            //Waits to execute code until enter key is pressed in input area
            if (e.KeyCode == Keys.Enter)
            {
                switch (userInput)
                {
                    case "5":
                        //_mainWindow.ProgramSwitcher(_mainWindow.MainPanel, "menuList");
                        break;
                }
            }
        }

        private void selectedItemNumber_TextChanged(object sender, EventArgs e)
        {
            int userInput;
            if (int.TryParse(selectedItemNumber.Text, out userInput) && userInput >= 1 && userInput <= resultSelectionListView.Items.Count)
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
                    // Retrieve the selected object from the Tag property
                    Panel currentPanel = this.Parent as Panel;
                    object selectedObject = resultSelectionListView.SelectedItems[0].Tag;

                    SelectedSearchResult?.Invoke(this, new SelectedSearchResultEventArgs(selectedObject));
                }
            }
        }
    }
}