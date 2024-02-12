using Inventory.Models;
using System.Collections.Generic;

namespace Inventory.UI.Data
{
    public static class MenuItemLists
    {
        public static List<MenuItem> MainMenu()
        {
            return new List<MenuItem>
            {
                new MenuItem(null, "main", null),
                new MenuItem(null, "Main Menu", null),
                new MenuItem("1", "PURCHASE ORDERS", null),
                new MenuItem("2", "CUSTOMER INVOICES", null),
                new MenuItem("3", "DISBURSEMENTS / SUPPLIER INVOICES", null),
                new MenuItem("4", "RECEIPTS", null),
                new MenuItem("5", "JOURNAL/LEDGER POSTING", null),
                new MenuItem("6", "REPORTS", null),
                new MenuItem("7", "INVENTORY - REPORTS/VIEW ACTIVITY", null),
                new MenuItem("8", "FILE MAINTENANCE", null),
                new MenuItem("9", "EXIT", null)
            };
        }

        public static List<MenuItem> POMenuItems()
        {
            return new List<MenuItem>
            {
                new MenuItem(null, "purchase", null),
                new MenuItem(null, "Purchase Orders Menu", null),
                new MenuItem("1", "ADD PURCHASE ORDER(S)", null),
                new MenuItem("2", "CHANGE PURCHASE ORDER(S)", null),
                new MenuItem("3", "VIEW PURCHASE ORDER(S)", null),
                new MenuItem("4", "DELETE/VOID PURCHASE ORDER", null),
                new MenuItem("5", "ENTER PURCHASE ORDER SHORTWEIGHTS", null),
                new MenuItem("6", "VIEW ALL PO'S FOR CUSTOMER/SUPPLIER/FRIGHT", null),
                new MenuItem("7", "VIEW PO LEDGER HISTORY", null),
                new MenuItem("P", "PRINT COPY OF ORDER", null),
                new MenuItem("A", "PRINT ORDER CONFIRMATIONS", null),
                new MenuItem("B", "PRINT ORDER MARGIN SUMMARY", null),
                new MenuItem("D", "PRINT DAILY ORDERS ENTERED", null),
                new MenuItem("H", "DISPLAY/PRINT ORDERS ON HOLD", null),
                new MenuItem("F", "VIEW ALL FREIGHT FOR SHIPMENT", null),
                new MenuItem("R", "RELEASE ORDERS FROM HOLD", null),
                new MenuItem("S", "DAILY SAMPLE REQUEST REPORT", null),
                new MenuItem("T", "LIST PO PRICE CHANGES FOR LOT", null),
                new MenuItem("W", "WHITE BOARD REPORT", null)
            };
        }

        public static List<MenuItem> FileMaintenenceMenuItems()
        {
            return new List<MenuItem>
            {
                new MenuItem(null, "filemaintenence", null),
                new MenuItem(null, "File Maintenance Menu", null),
                new MenuItem("1", "REINDEX SELECTED MAIN FILES (Normally use this to Reindex)", null),
                new MenuItem("2", "REINDEX ALL/SPECIFIC DATA FILES", null),
                new MenuItem("3", "CREATE SUPPLEMENTAL CUST/SUP/FRT INQUIRY FILES", null),
                new MenuItem("4", "UPDATE MASTER FILES (CUSTOMERS, SUPPLIERS, PRODUCTS, ETC.)", null),
                new MenuItem("6", "CALCULATE AGING DAYS/OUTSTANDING BALANCES FOR BILL TO CUSTOMERS", null),
                new MenuItem("7", "UPDATE NEXT INVOICE/CHECK/WIRE/DEBIT&CREDIT NBR TO USED", null),
                new MenuItem("8", "CHANGE TO NEW POSTING MONTH", null),
                new MenuItem("9", "RETURN TO MAIN MENU", null)
            };
        }

        public static List<MenuItem> MasterFileUpdateMenuItems()
        {
            return new List<MenuItem>
            {
                new MenuItem(null, "masterfileupdate", null),
                new MenuItem(null, "Master File Update Menu", null),
                new MenuItem("1", "REMIT TO SUPPLIERS", "rem_sup"),
                new MenuItem("2", "SHIPPED FROM SUPPLIERS", "supplier"),
                new MenuItem("3", "BILL TO CUSTOMERS", "bil_buy"),
                new MenuItem("4", "SHIP TO CUSTOMERS", "buyer"),
                new MenuItem("5", "FREIGHT CARRIERS", "freight"),
                new MenuItem("6", "SALESPERSONS", null),
                new MenuItem("7", "THIRD PARTY COMMISION PAYEES", null),
                new MenuItem("12", "UNIT PACK (BOX SIZES)", null),
                new MenuItem("13", "PRODUCT DESCRIPTIONS", null),
                new MenuItem("15", "CHART OF ACCOUNTS", null),
                new MenuItem("16", "ADD/UPDATE BROKER/BILLBACKS BY CUSTOMER", null),
                new MenuItem("17", "BROKERAGE FEES FOR 3RD PARTY COMM/PROGRAM BILLBACKS", null),
                new MenuItem("18", "NATIONAL PRICING MASTER", null),
                new MenuItem("19", "SUPPLIER/CUSTOMER PRICING MASTER", null),
                new MenuItem("99", "RETURN TO MAINTENANCE MENU", null)
            };
        }
    }

    public class MenuItem
    {
        public string Key { get; set; }
        public string Description { get; set; }
        public string LoadProgram { get; set; }

        public MenuItem(string key, string description, string loadProgram)
        {
            Key = key;
            Description = description;
            LoadProgram = loadProgram;
        }
    }
}