using Inventory.Interfaces;
using Inventory.UI.Data;
using System.Diagnostics.Eventing.Reader;

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
            AttachKeyPressEventHandlers(_activeControl as UserControl);
        }

        private void HandleUserInput(object sender, EventArgs e)
        {
            if (_activeControl != null)
            {
                string userInput = _mainWindow.GetTextBoxText();
                if (!string.IsNullOrEmpty(userInput))
                {
                    var actionsCopy = new Dictionary<string, Action>(_activeControl.AvailableActions);

                    foreach (var action in actionsCopy)
                    {
                        if (action.Key == userInput) // Check for exact match
                        {
                            _mainWindow.SetCommandsLabel("");
                            _activeControl.PerformAction(userInput);
                            _mainWindow.ClearTextBox();
                        }
                        else if (action.Key.StartsWith(userInput))
                        {
                            _mainWindow.SetCommandsLabel("Close match or multiple matches found. Press ENTER to submit choice.");
                        }
                    }
                }
            }
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





        private void AttachKeyPressEventHandlers(Control control)
        {
            foreach (Control c in control.Controls)
            {
                if (c is TextBox)
                {
                    ((TextBox)c).KeyPress += TextBox_KeyPress;
                }
                else if (c.Controls.Count > 0)
                {
                    AttachKeyPressEventHandlers(c);
                }
            }
        }

        private void TextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            e.KeyChar = Char.ToUpperInvariant(e.KeyChar);
        }









    }
}