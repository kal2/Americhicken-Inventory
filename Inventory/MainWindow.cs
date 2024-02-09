using Inventory.Services;
using Inventory.Programs.Utilities;

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

        public void DisplayLastMenu()
        {
            MenuList menuList = new(this, _activeControlManager);
            menuList.SetCurrentMenu(_lastMenuDisplayed);
            menuList.PerformAction(null);
            _activeControlManager.SetActiveControl(menuList);
        }

        public bool AskUserConfirmation(string? message)
        {
            bool _confirmation = false;
            bool _userAnswered = false;

            UserConfirmation _userConfirmation = new UserConfirmation();
            _userConfirmation.UserChoice += (s, e) =>

            DisplayUserConfirmation(_userConfirmation, message);


        }

        //NEED TO SEPERATE THIS INTO "DISPLAY > PROCESS > DISPOSE > RETURN" METHODS SO THAT THIS MIGHT ACTUALLY WORK
        public void DisplayUserConfirmation(UserConfirmation userConfirmation, string? message)
        {
            userActionInputMain.Visible = false;

            if (message != null)
            {
                userConfirmation.SetMessage(message);
            }

            splitContainer2.Panel2.Controls.Add(userConfirmation);
            userConfirmation.Dock = DockStyle.Fill;
            userConfirmation.BringToFront();
            splitContainer2.Panel2.Refresh();
        }

        public void DisposeControl(UserControl control)
        {
            splitContainer2.Panel1.Controls.Remove(control);
            control.Dispose();
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
        }
    }
}