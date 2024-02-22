using Inventory.Interfaces;
using Inventory.UI.Data;
using Inventory.Views.UserControls;
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
            _mainWindow.AttachActionInputTextChangedHandler(HandleActionUserInput);
            _mainWindow.AttachActionInputKeyDownHandler(HandleActionInputEnterKeyPressed);
        }

        // -- Methods -- //
        public void SetActiveControl(IActiveControlManager activeControl)
        {
            _activeControl = activeControl;
            _mainWindow.DisplayControl(_activeControl as UserControl);
            _activeControl.SetProgramLabels();
            AttachKeyPressEventHandlers(_activeControl as UserControl);
            AttachGotFocusEventToTextBoxes(_activeControl as UserControl);
        }

        private void HandleActionUserInput(object sender, EventArgs e)
        {
            if (_activeControl != null)
            {
                string userInput = _mainWindow.GetTextBoxText();
                if (!string.IsNullOrEmpty(userInput))
                {
                    var actionsCopy = new Dictionary<string, Action>(_activeControl.AvailableActions);
                    int i=0;
                    foreach (var action in actionsCopy)
                    {
                        if (action.Key.StartsWith(userInput))
                        {
                            i++;
                        }
                    }
                    if (i > 1)
                    {
                        _mainWindow.SetCommandsLabel("Close match or multiple matches found. Press ENTER to submit choice.");
                    }
                    else if (actionsCopy.ContainsKey(userInput))
                    {
                        _mainWindow.DetachActionInputChangedHandler(HandleActionUserInput);
                        _activeControl.PerformAction(userInput);
                        _mainWindow.ClearTextBox();
                        _mainWindow.AttachActionInputTextChangedHandler(HandleActionUserInput);
                    }
                }
            }
        }

        private void HandleActionInputEnterKeyPressed(object sender, KeyEventArgs e)
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
            if (control.GetType() == typeof(DbSearch) || control.GetType() == typeof(MatchSelect)) // Skip DbSearchControl
            {
                return;
            }
            foreach (Control c in control.Controls)
            {
                if (c is TextBoxBase)
                {
                    ((TextBoxBase)c).KeyPress += TextBox_KeyPress;
                }
                else if (c.Controls.Count > 0)
                {
                    AttachKeyPressEventHandlers(c);
                }
            }
        }

        private void TextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true; // Prevent the enter key from being processed by the TextBox
                        SendKeys.Send("{TAB}"); // Send a tab key press
            }
        }

        private void AttachGotFocusEventToTextBoxes(Control control)
        {
            foreach (Control c in control.Controls)
            {
                if (c is TextBox || c is MaskedTextBox) // Include MaskedTextBox
                {
                    if (c is TextBox)
                    {
                        ((TextBox)c).GotFocus += TextBox_GotFocus;
                    }
                    else if (c is MaskedTextBox) // Handle MaskedTextBox separately
                    {
                        ((MaskedTextBox)c).GotFocus += TextBox_GotFocus;
                    }
                }
                else
                {
                    AttachGotFocusEventToTextBoxes(c);
                }
            }
        }

        private void TextBox_GotFocus(object sender, EventArgs e)
        {
            TextBoxBase textBox = (TextBoxBase)sender;
            textBox.SelectionStart = 0;
        }

    }
}