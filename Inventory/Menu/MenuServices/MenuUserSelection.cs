using Inventory.UI.Data;

namespace Inventory.UI.Menu
{
    public static class MenuUserSelection
    {
        private static Dictionary<(string, string), Func<List<MenuItem>>> menuSelections = new()
        {
            {("main", "1"), MenuItemLists.POMenuItems},
            {("main", "8"), MenuItemLists.FileMaintenenceMenuItems},
            {("filemaintenence", "4"), MenuItemLists.MasterFileUpdateMenuItems},
        };

        public static List<MenuItem> UserMenuSelection(string currentMenu, string userSelection)
        {
            List<MenuItem>? menuItems = MenuItemLists.MainMenu();

            if (menuSelections.TryGetValue((currentMenu, userSelection), out var menuSelection))
            {
                menuItems = menuSelection();
            }

            return menuItems;
        }
    }
}
