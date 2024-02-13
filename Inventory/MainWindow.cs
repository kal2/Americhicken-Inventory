using Inventory.Services;
using Inventory.Programs.Utilities;
using System.Runtime.CompilerServices;
using static Inventory.Programs.Utilities.UserConfirmation;

namespace Inventory
{
    public partial class MainWindow : Form
    {
        private readonly ActiveControlManager _activeControlManager;
        private string _lastMenuDisplayed;

        public MainWindow()
        {
            InitializeComponent();

            _activeControlManager = new ActiveControlManager(this);
            _activeControlManager.SetActiveControl(new MenuList(this, _activeControlManager));

            Load += (s, e) => dateLabel.Text = DateTime.Now.Date.ToString("d");
        }

        public void DisplayControl(UserControl control)
        {
            splitContainer2.Panel1.Controls.Add(control);
            control.Visible = true;
            control.Dock = DockStyle.Fill;
            control.BorderStyle = BorderStyle.Fixed3D;
            control.BringToFront();
            splitContainer2.Panel1.Refresh();
        }

        public void DisposeControl(UserControl control)
        {
            splitContainer2.Panel1.Controls.Remove(control);
            control.Dispose();
        }

        public void DisplayLastMenu()
        {
            MenuList menuList = new(this, _activeControlManager);
            menuList.SetCurrentMenu(_lastMenuDisplayed);
            menuList.PerformAction(null);
            _activeControlManager.SetActiveControl(menuList);
        }

        public void AttachConfirmationEventListener(EventHandler<UserConfirmationEventArgs> handler)
        {
            mainUserConfirmation.UserChoice += handler;
        }

        public void DetachConfirmationEventListener(EventHandler<UserConfirmationEventArgs> handler)
        {
            mainUserConfirmation.UserChoice -= handler;
            HideUserConfirmation();
        }

        public void AskUserConfirmation(string? message)
        {
            DisplayUserConfirmation(message);
        }

        public void DisplayUserConfirmation(string? message)
        {
            userActionInputMain.Visible = false;
            mainUserConfirmation.Visible = true;

            if (message != null)
            {
                mainUserConfirmation.SetMessage(message);
            }
        }

        private void HideUserConfirmation()
        {
            mainUserConfirmation.Visible = false;
            userActionInputMain.Visible = true;
        }

        private void MainWindow_Shown(object sender, EventArgs e)
        {
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

        public void AttachTextBoxTextChangedHandler(EventHandler handler)
        {
            userActionInputMain.actionInput.TextChanged += handler;
        }

        public void DetachTextBoxTextChangedHandler(EventHandler handler)
        {
            userActionInputMain.actionInput.TextChanged -= handler;
        }

        public void AttachTextBoxKeyDownHandler(KeyEventHandler handler)
        {
            userActionInputMain.actionInput.KeyDown += handler;
        }

        public void DetachTextBoxKeyDownHandler(KeyEventHandler handler)
        {
            userActionInputMain.actionInput.KeyDown -= handler;
        }

        public void SetLastMenuDisplayed(string currentMenu)
        {
            _lastMenuDisplayed = currentMenu;
        }

        private void MainWindow_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.PageDown)
            {
                FocusTextBox();
            }
            else if (e.KeyCode == Keys.Down)
            {
                SendKeys.Send("{TAB}");
            }
            else if (e.KeyCode == Keys.Up)
            {
                SendKeys.Send("+{TAB}");
            }
        }
    }
}