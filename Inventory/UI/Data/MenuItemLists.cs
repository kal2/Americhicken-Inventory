namespace Inventory.UI.Data
{
    public static class MenuItemLists
    {
        //Passes menu items to caller
        public static string[] MainMenu()
        {
            string[] items =
            {
                "main",
                "1 - PURCHASE ORDERS",
                "2 - CUSTOMER INVOICES",
                "3 - DISBURSEMENTS / SUPPLIER INVOICES",
                "4 - RECEIPTS",
                "5 - JOURNAL/LEDGER POSTING",
                "6 - REPORTS",
                "7 - INVENTORY - REPORTS/VIEW ACTIVITY",
                "8 - FILE MAINTENANCE",
                "9 - EXIT"
            };
            return items;
        }
        public static string[] POMenuItems()
        {
            string[] items =
            {
                "purchase",
                "1 - ADD PURCHASE ORDER(S)",
                "2 - CHANGE PURCHASE ORDER(S)",
                "3 - VIEW PURCHASE ORDER(S)",
                "4 - DELETE/VOID PURCHASE ORDER",
                "-----------",
                "5 - ENTER PURCHASE ORDER SHORTWEIGHTS",
                "-----------",
                "6 - VIEW ALL PO'S FOR CUSTOMER/SUPPLIER/FRIGHT",
                "7 - VIEW PO LEDGER HISTORY",
                "-----------",
                "P - PRINT COPY OF ORDER",
                "-----------",
                "A - PRINT ORDER CONFIRMATIONS",
                "B - PRINT ORDER MARGIN SUMMARY",
                "D - PRINT DAILY ORDERS ENTERED",
                "H - DISPLAY/PRINT ORDERS ON HOLD",
                "-----------",
                "F - VIEW ALL FREIGHT FOR SHIPMENT",
                "R - RELEASE ORDERS FROM HOLD",
                "S - DAILY SAMPLE REQUEST REPORT",
                "T - LIST PO PRICE CHANGES FOR LOT",
                "W - WHITE BOARD REPORT"
            };
            return items;
        }
        public static string[] FileMaintenenceMenuItems()
        {
            string[] items =
            {
                "filemaintenence",
                "1 - REINDEX SELECTED MAIN FILES (Normally use this to Reindex)",
                "2 - REINDEX ALL/SPECIFIC DATA FILES",
                "3 - CREATE SUPPLEMENTAL CUST/SUP/FRT INQUIRY FILES",
                "4 - UPDATE MASTER FILES (CUSTOMERS, SUPPLIERS, PRODUCTS, ETC.)",
                "5 - coming soon...",
                "6 - CALCULATE AGING DAYS/OUTSTANDING BALANCES FOR BILL TO CUSTOMERS",
                "7 - UPDATE NEXT INVOICE/CHECK/WIRE/DEBIT&CREDIT NBR TO USED",
                "8 - CHANGE TO NEW POSTING MONTH",
                "9 - RETURN TO MAIN MENU"
            };
            return items;
        }
        public static string[] MasterFileUpdateMenuItems()
        {
            string[] items =
            {
                "masterfileupdate",
                "1 - REMIT TO SUPPLIERS",
                "2 - SHIPPED FROM SUPPLIERS",
                "3 - BILL TO CUSTOMERS",
                "4 - SHIP TO CUSTOMERS",
                "5 - FREIGHT CARRIERS",
                "6 - SALESPERSONS",
                "7 - THIRD PARTY COMMISION PAYEES",
                "12 - UNIT PACK (BOX SIZES)",
                "13 - PRODUCT DESCRIPTIONS",
                "15 - CHART OF ACCOUNTS",
                "16 - ADD/UPDATE BROKER/BILLBACKS BY CUSTOMER",
                "17 - BROKERAGE FEES FOR 3RD PARTY COMM/PROGRAM BILLBACKS",
                "18 - NATIONAL PRICING MASTER",
                "19 - SUPPLIER/CUSTOMER PRICING MASTER",
                "99 - RETURN TO MAINTENANCE MENU"
            };
            return items;
        }
    }
}