using Inventory.Interfaces;
using Inventory.UI.Menu;
using Inventory.Services;

namespace Inventory
{
    public partial class MenuList : UserControl, IActiveControlManager
    {
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        private string _currentMenu = "main";

        public MenuList(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Menu List");
        }

        public void PerformAction(string userInput)
        {
            menuListBox.BeginUpdate();
            menuListBox.Items.Clear();

            var menuItems = MenuUserSelection.UserMenuSelection(_currentMenu, userInput);
            _currentMenu = menuItems[0];

            if (_currentMenu != "program")
            {
                _mainWindow.SetProgramLabel(menuItems[1]);
                PopulateMenuList(menuItems);
            }
            else
            {
                LoadProgram(menuItems[1]);
            }
        }

        private void PopulateMenuList(string[] menuItems)
        {
            menuListBox.Items.AddRange(menuItems[2..]);
            menuListBox.EndUpdate();
        }

        private void LoadProgram(string programName)
        {
            var programLoader = new ProgramLoader(_mainWindow, _activeControlManager);
            programLoader.LoadProgram(programName);
        }
    }
}

