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
        private string currentMenu = "main";

        public MenuList(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
        }

        public void SetProgramLabels()
        {
            _mainWindow.SetTextBoxLabel("CHOICE: ");
            _mainWindow.SetCommandsLabel("");
        }

        public void SetCurrentMenu(string menu)
        {
                currentMenu = menu;
        }

        public void DisplayCurrentMenu(string? userInput)
        {
            menuListBox.BeginUpdate();
            menuListBox.Items.Clear();
            List<MenuItem> menuItems;
            if (userInput != null)
            {
                menuItems = MenuUserSelection.UserMenuSelection(currentMenu, userInput);
            }
            else
            {
                menuItems = GetMenuItemsBasedOnCurrentMenu();
            }
            PopulateMenuList(menuItems);
            currentMenu = menuItems[0].Description;
            _mainWindow.SetProgramLabel(menuItems[1].Description);

            menuListBox.EndUpdate();
        }

        private List<MenuItem> GetMenuItemsBasedOnCurrentMenu()
        {
            switch (currentMenu)
            {
                case "main":
                    return MenuItemLists.MainMenu();
                case "filemaintenence":
                    return MenuItemLists.FileMaintenenceMenuItems();
                case "masterfileupdate":
                    return MenuItemLists.MasterFileUpdateMenuItems();
                default:
                    return MenuItemLists.MainMenu();
            }
        }

        public Dictionary<string, Action> GetAvailableActions()
        {
            return null;
        }

        public void PerformAction(string? userInput)
        {
            List<MenuItem> menuOptions = GetMenuItemsBasedOnCurrentMenu();
            
            bool userInputFound = menuOptions.Any(item => item.Key == userInput);
            
            if (userInputFound)
            {
                MenuItem? selectedMenuItem = menuOptions.Find(item => item.Key == userInput);
                if (selectedMenuItem?.LoadProgram == null)
                {
                    DisplayCurrentMenu(userInput);
                }
                else
                {
                    LoadProgram(selectedMenuItem.LoadProgram);
                }
            }
        }

        private void PopulateMenuList(List<MenuItem> menuItems)
        {
            foreach (var menuItem in menuItems.GetRange(2, menuItems.Count - 2))
            {
                menuListBox.Items.Add($"{menuItem.Key} - {menuItem.Description}");
            }
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



//Keeping old menu list for reference/rollback
//public void PerformAction(string? userInput)
//{
//    menuListBox.BeginUpdate();
//    menuListBox.Items.Clear();

//    List<MenuItem> menuItems;

//    if (userInput == null)
//    {
//        switch (_currentMenu)
//        {
//            case "main":
//                menuItems = MenuItemLists.MainMenu();
//                break;
//            case "filemaintenence":
//                menuItems = MenuItemLists.FileMaintenenceMenuItems();
//                break;
//            case "masterfileupdate":
//                menuItems = MenuItemLists.MasterFileUpdateMenuItems();
//                break;
//            default:
//                menuItems = MenuItemLists.MainMenu();
//                break;
//        }
//    }
//    else
//    {
//        menuItems = MenuUserSelection.UserMenuSelection(_currentMenu, userInput);
//        _currentMenu = menuItems[0].Description;
//    }

//    bool userInputFound = menuItems.Any(item => item.Key == userInput);

//    if (userInputFound)
//    {
//        MenuItem selectedMenuItem = menuItems.Find(item => item.Key == userInput);

//        if (selectedMenuItem.LoadProgram == null)
//        {
//            _mainWindow.SetProgramLabel(menuItems[1].Description);
//            PopulateMenuList(menuItems);
//        }
//        else
//        {
//            LoadProgram(selectedMenuItem.LoadProgram);
//        }
//    }
//}