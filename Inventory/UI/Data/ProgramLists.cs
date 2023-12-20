namespace Inventory.UI.Data
{
    public static class ProgramLists
    {
        public static string[] PurchaseOrderAdd()
        {
            return [
                //The first item tells the parent that it needs to load the second item, in this case the program named "addPO"
                "program",
                "addPO"
            ];
        }

        public static string[] RemitToSupplier()
        {
            return [
                "program",
                "remitToSupplier"
            ];
        }

        public static string[] ShipFromSupplier()
        {
            return [
                "program",
                "shipFromSupplier"
            ];
        }
        public static string[] FreightCarrier()
        {
            return [
                "program",
                "freightCarrier"
            ];
        }
    }
}
