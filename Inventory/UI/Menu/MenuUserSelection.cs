using Inventory.UI.Data;

namespace Inventory.UI.Menu
{
    public static class MenuUserSelection
    {
        private static Dictionary<(string, string), Func<string[]>> menuSelections = new()
        {
            {("main", "1"), MenuItemLists.POMenuItems},
            {("main", "8"), MenuItemLists.FileMaintenenceMenuItems},
            {("purchase", "1"), ProgramLists.PurchaseOrderAdd},
            {("filemaintenence", "4"), MenuItemLists.MasterFileUpdateMenuItems},
            {("masterfileupdate", "1"), ProgramLists.RemitToSupplier},
            {("masterfileupdate", "2"), ProgramLists.ShipFromSupplier},
            {("masterfileupdate", "3"), ProgramLists.BillToCustomer},
            {("masterfileupdate", "4"), ProgramLists.ShipToCustomer},
            {("masterfileupdate", "5"), ProgramLists.FreightCarrier},
        };

        public static string[] UserMenuSelection(string currentMenu, string userSelection)
        {
            string[]? menuItems = MenuItemLists.MainMenu();

            if (menuSelections.TryGetValue((currentMenu, userSelection), out var menuSelection))
            {
                menuItems = menuSelection();
            }

            return menuItems;
        }
    }
}
