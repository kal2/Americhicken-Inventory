using Inventory.Models;
using Inventory.Purchase_Orders;
using Inventory.Views.UserControls;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;
using System.DirectoryServices;
using Inventory.Interfaces;
using Inventory.Services;
using System.Windows.Forms.VisualStyles;

namespace Inventory
{
    public partial class MainWindow : Form
    {
        // -- Class Variables -- //
        private readonly ActiveControlManager _activeControlManager;

        public MainWindow()
        {
            InitializeComponent();

            _activeControlManager = new ActiveControlManager(this);

            //Sets the initial control to the MenuList
            _activeControlManager.SetActiveControl(new MenuList(this, _activeControlManager));

            Load += (s, e) => dateLabel.Text = DateTime.Now.Date.ToString("d");
        }

        //Displays passed control in the main window
        public void DisplayControl(UserControl control)
        {
            splitContainer2.Panel1.Controls.Add(control);
            control.Visible = true;
            control.Dock = DockStyle.Fill;
            control.Anchor = AnchorStyles.Top | AnchorStyles.Left;
            control.BringToFront();
            splitContainer2.Panel1.Refresh();
        }

        public void DisposeControl(UserControl control)
        {
            splitContainer2.Panel1.Controls.Remove(control);
            control.Dispose();
        }

        private void MainWindow_Shown(object sender, EventArgs e)
        {
            //Sets focus to user input field
            userActionInputMain.actionInput.Focus();
        }

        // -- Utility Methods -- //
        public void SetProgramLabel(string title)
        {
            programLabel.Text = title;
        }

        public void FocusTextBox()
        {
            userActionInputMain.actionInput.Focus();
        }

        public void SetTextBoxText(string text)
        {
            userActionInputMain.actionInput.Text = text;
        }

        public string GetTextBoxText()
        {
            return userActionInputMain.actionInput.Text;
        }

        public void ClearTextBox()
        {
            userActionInputMain.actionInput.Clear();
        }

        public void SetTextBoxLabel(string text)
        {
            userActionInputMain.textBoxLabel.Text = text;
        }

        public void SetCommandsLabel(string text)
        {
            userActionInputMain.userActionCommandsLabel.Text = text;
        }

        public void AttachTextBoxKeyDownHandler(KeyEventHandler handler)
        {
            userActionInputMain.actionInput.KeyDown += handler;
        }

        public void DetachTextBoxKeyDownHandler(KeyEventHandler handler)
        {
            userActionInputMain.actionInput.KeyDown -= handler;
        }

        private void MainWindow_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.PageDown)
            {
                FocusTextBox();
            }
        }
    }
}