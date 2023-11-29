namespace Inventory.UI.Data
{
    public class ProgramLists
    {
        public static string[] PurchaseOrderAdd()
        {
            string[] items =
            {
                //The first item tells the parent that it needs to load the second item, in this case the program named "addPO"
                "program",
                "addPO"
            };
            return items;
        }

        public static string[] RemitToSupplier()
        {
            string[] items =
            {
                "program",
                "remitToSupplier"
            };
            return items;
        }

        public static string[] ShipFromSupplier()
        {
            string[] items =
            {
                "program",
                "shipFromSupplierSearch"
            };
            return items;
        }
    }
}
