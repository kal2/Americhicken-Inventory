using Inventory.Models;
using Inventory.Purchase_Orders;
using Inventory.Views.UserControls;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;
using System.DirectoryServices;
using Inventory.Interfaces;

namespace Inventory
{
    public partial class MainWindow : Form, IUserActionInput
    {
        // -- Constructor -- //

        public MainWindow()
        {
            InitializeComponent();

            //Sets the initial control to the MenuList
            UserControl initialControl = new MenuList(this);
            initialControl.Dock = DockStyle.Fill;
            splitContainer2.Panel1.Controls.Add(initialControl);
        }

        // -- Methods -- //

        //Displays passed control in the main window
        public void DisplayControl(UserControl control)
        {
            control.Visible = true;
            control.Dock = DockStyle.Fill;
            splitContainer2.Panel1.Controls.Add(control);
            control.BringToFront();
            splitContainer2.Panel1.Refresh();
        }

        // -- UserActionInput Interface Methods -- //

        public void SetTextBoxText(string text)
        {
            userActionInputMain.actionInput.Text = text;
        }

        public string GetTextBoxText()
        {
            return userActionInputMain.actionInput.Text;
        }

        public void AttachTextBoxKeyDownHandler(KeyEventHandler handler)
        {
            userActionInputMain.actionInput.KeyDown += handler;
        }

        public void DetachTextBoxKeyDownHandler(KeyEventHandler handler)
        {
            userActionInputMain.actionInput.KeyDown -= handler;
        }

        // -- Event Listeners -- //

        private void Form1_Load(object sender, EventArgs e)
        {
            //Passes current date to dateLabel
            dateLabel.Text = DateTime.Now.Date.ToString("d");
        }
    }
}