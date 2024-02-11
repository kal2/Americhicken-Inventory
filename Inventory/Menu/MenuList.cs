using Inventory.Interfaces;
using Inventory.UI.Menu;
using Inventory.Services;
using Inventory.UI.Data;

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

        public void SetCurrentMenu(string menu)
        {
            _currentMenu = menu;
        }

        public void PerformAction(string? userInput)
        {
            menuListBox.BeginUpdate();
            menuListBox.Items.Clear();

            string[] menuItems;

            if (userInput == null)
            {
                switch (_currentMenu)
                {
                    case "main":
                        menuItems = MenuItemLists.MainMenu();
                        break;
                    case "filemaintenence":
                        menuItems = MenuItemLists.FileMaintenenceMenuItems();
                        break;
                    case "masterfileupdate":
                        menuItems = MenuItemLists.MasterFileUpdateMenuItems();
                        break;
                    default:
                        menuItems = MenuItemLists.MainMenu();
                        break;
                }
            }
            else
            {
                menuItems = MenuUserSelection.UserMenuSelection(_currentMenu, userInput);
                _currentMenu = menuItems[0];

               
            }
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
            using (var programLoader = new ProgramLoader(_mainWindow, _activeControlManager))
            {
                programLoader.LoadProgram(programName);
            }
        }
    }
}

