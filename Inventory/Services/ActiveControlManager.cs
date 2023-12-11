using Inventory.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

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
            _mainWindow.AttachTextBoxKeyDownHandler(HandleUserInput);
        }

        // -- Methods -- //
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