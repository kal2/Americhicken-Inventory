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
                "rem_sup"
            ];
        }

        public static string[] ShipFromSupplier()
        {
            return
            [
                "program",
                "supplier"
            ];
        }
        public static string[] FreightCarrier()
        {
            return
            [
                "program",
                "freight"
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
