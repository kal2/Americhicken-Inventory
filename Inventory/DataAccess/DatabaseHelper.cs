using Microsoft.Data.SqlClient;

namespace Inventory.DataAccess
{
    public static class DatabaseHelper
    {
        private static readonly string ConnectionString = @"Data Source=MIRACLE\MSSQLSERVER01;Initial Catalog=Americhicken;Integrated Security=True";

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(ConnectionString);
        }
    }
}
