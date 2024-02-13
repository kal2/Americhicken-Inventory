using Inventory.Interfaces;
using Inventory.UI.Data;

namespace Inventory.Services
{
    public class ActiveControlManager
    {
        // -- Class Variables -- //
        private MainWindow _mainWindow;
        private IActiveControlManager _activeControl;

        // -- Constructor -- //
        public ActiveControlManager(MainWindow mainWindow)
        {
            _mainWindow = mainWindow;
            _mainWindow.AttachTextBoxTextChangedHandler(HandleUserInput);
            _mainWindow.AttachTextBoxKeyDownHandler(HandleEnterKeyPressed);
        }

        // -- Methods -- //
        public void SetActiveControl(IActiveControlManager activeControl)
        {
            _activeControl = activeControl;
            _mainWindow.DisplayControl(_activeControl as UserControl);
            _activeControl.SetProgramLabels();
        }

        private void HandleEnterKeyPressed(object sender, KeyEventArgs e)
        {
            if (_activeControl != null && e.KeyCode == Keys.Enter)
            {
                string userInput = _mainWindow.GetTextBoxText();
                if (!string.IsNullOrEmpty(userInput))
                {
                    _activeControl.PerformAction(userInput);
                    _mainWindow.ClearTextBox();
                }
            }
        }

        private void HandleUserInput(object sender, EventArgs e)
        {
            _mainWindow.SetCommandsLabel("");
            if (_activeControl != null)
            {
                string userInput = _mainWindow.GetTextBoxText();
                if (!string.IsNullOrEmpty(userInput))
                {
                    List<Action> matchingActions = new List<Action>();

                    foreach (var action in _activeControl.AvailableActions)
                    {
                        if (action.Key.ToUpper().Contains(userInput.ToUpper()))
                        {
                            matchingActions.Add(action.Value);
                        }
                    }

                    if (matchingActions.Count > 0)
                    {
                        //If there is only one match, perform the action, if there are multiple wait until enter key is pressed

                        if (matchingActions.Count > 1)
                        {
                            _mainWindow.SetCommandsLabel("Multiple commands found. Press enter to continue.");
                            // Perform the first matching action
                        }
                        else
                        {
                            // Perform the first matching action
                            _activeControl.PerformAction(userInput);

                            _mainWindow.ClearTextBox();
                        }
                    }
                }
            }
        }
    }
}