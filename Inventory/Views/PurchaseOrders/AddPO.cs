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
    }
}
