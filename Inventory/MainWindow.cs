using Inventory.Services;

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
            control.Anchor = AnchorStyles.Top | AnchorStyles.Left;
            control.BorderStyle = BorderStyle.Fixed3D;
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

        public void DisplayLastMenu()
        {
            MenuList menuList = new(this, _activeControlManager);
            menuList.SetCurrentMenu(_lastMenuDisplayed);
            menuList.PerformAction(null);
            _activeControlManager.SetActiveControl(menuList);
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