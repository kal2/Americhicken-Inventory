namespace Inventory.UI.Data
{
    public static class ProgramLists
    {
        public static string[] PurchaseOrderAdd()
        {
            return
            [
                "program",
                "addPO"
            ];
        }

        public static string[] RemitToSupplier()
        {
            return
            [
                "program",
                "remitToSupplier"
            ];
        }

        public static string[] ShipFromSupplier()
        {
            return
            [
                "program",
                "shipFromSupplier"
            ];
        }
        public static string[] FreightCarrier()
        {
            return
            [
                "program",
                "freightCarrier"
            ];
        }

        public static string[] BillToCustomer()
        {
            return
            [
                "program",
                "bil_buy"
            ];
        }

        public static string[] ShipToCustomer()
        {
            return
            [
                "program",
                "buyer"
            ];
        }
    }
}
