using Inventory.Interfaces;

namespace Inventory.Services
{
    public class ActiveControlManager
    {
        private MainWindow _mainWindow;
        private IActiveControlManager _activeControl;

        public ActiveControlManager(MainWindow mainWindow)
        {
            _mainWindow = mainWindow;
            _mainWindow.AttachTextBoxKeyDownHandler(HandleUserInput);
        }

        public void SetActiveControl(IActiveControlManager activeControl)
        {
            _activeControl = activeControl;
            _mainWindow.DisplayControl(_activeControl as UserControl);
            _activeControl.SetProgramLabels();
        }

        private void HandleUserInput(object sender, KeyEventArgs e)
        {
            if (_activeControl != null)
            {
                if (e.KeyCode == Keys.Enter)
                {
                    _activeControl.PerformAction(_mainWindow.GetTextBoxText());

                    _mainWindow.ClearTextBox();
                }
            }
        }
    }
}