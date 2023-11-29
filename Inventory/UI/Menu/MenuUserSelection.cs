using Inventory.UI.Data;

namespace Inventory.UI.Menu
{
    public class MenuUserSelection
    {
        public static string[] UserMenuSelection(string currentMenu, string userSelection)
        {
            // menuItems default to Main Menu so won't throw compile errors and return user to main after program error
            string[]? menuItems = MenuItemLists.MainMenu();

            //Check which menu is currently being displayed
            switch (currentMenu)
            {

                //-----------Main Menu-----------//

                case "main":

                    //See what menu item the user selected
                    switch (userSelection)
                    {
                        case "1":

                            //Assign PO's menu items to menuItems, stored in MenuItemLists.cs
                            menuItems = MenuItemLists.POMenuItems();
                            break;

                        case "8":
                            menuItems = MenuItemLists.MasterFileUpdateMenuItems();
                            break;
                    }
                    break;

                //-----------PO Menu----------//

                case "purchase":

                    switch (userSelection)
                    {
                        case "1":
                            //Assign Purchase Order Add menu items to menuItems, stored in ProgramLists.cs
                            //This will pass the program name to the parent, which will load the program
                            menuItems = ProgramLists.PurchaseOrderAdd();

                            break;
                    }
                    break;

                //-----------File Maintenance Menu----------//

                case "masterfileupdate":

                    switch (userSelection)
                    {
                        case "1":

                            menuItems = ProgramLists.RemitToSupplier();
                            break;

                        case "2":

                            menuItems = ProgramLists.ShipFromSupplier();
                            break;
                    }
                    break;
            }
            return menuItems;
        }
    }
}