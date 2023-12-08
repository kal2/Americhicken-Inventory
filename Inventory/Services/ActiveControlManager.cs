using Inventory.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Inventory.Services
{
    internal class ActiveControlManager
    {
        // -- Class Variables -- //
        private MainWindow _mainWindow;
        private IActiveControlManager _activeControl;

        public ActiveControlManager(MainWindow mainWindow)
        {
            _mainWindow = mainWindow;
        }

        // -- Methods -- //
        public void AssignActionInput(IActiveControlManager activeControl)
        {
            if (_activeControl != null)
            {
                UnsubscribeFromActionInput(_activeControl as Control);
            }

            _activeControl = activeControl;

            if (_activeControl != null)
            {
                SubscribeToActionInput(_activeControl as Control);
            }

        }

        public void SubscribeToActionInput(Control control)
        {
            control.KeyDown += Control_KeyDown;
        }

        public void UnsubscribeFromActionInput(Control control)
        {
            control.KeyDown -= Control_KeyDown;
        }

        private void Control_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                HandleUserInput();
            }
        }

        private void HandleUserInput()
        {
            if (_activeControl != null)
            {
                _activeControl.AssignActionInput();

                _activeControl.SetProgramLabels();
            }
        }
    }
}