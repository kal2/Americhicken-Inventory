namespace Inventory.Purchase_Orders
{
    public partial class AddPO : UserControl
    {
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            //Change focus to desired field after User Control change.
            salesPersonNumber.Focus();
        }

        protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
        {

            // Call the base method for keys you did not handle
            return base.ProcessCmdKey(ref msg, keyData);
        }

        private MainWindow _mainWindow;
        public AddPO(MainWindow mainWindow)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
        }

        private void holdCheckBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                holdCheckBox.Checked = !holdCheckBox.Checked;
            }
        }

        //Action Input
        private void actionInput_KeyDown(object sender, KeyEventArgs e)
        {
            //Collects user input and format for processing
            string userInput = actionInput.Text.Trim();

            //Waits to execute code until enter key is pressed in input area
            if (e.KeyCode == Keys.Enter)
            {
                switch (userInput)
                {
                    case "3":
                    //    _mainWindow.ProgramSwitcher("menuList");
                        break;
                }
            }
        }
    }
}
