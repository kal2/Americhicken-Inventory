using Inventory.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Client;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.Configuration;

namespace Inventory
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            ApplicationConfiguration.Initialize();
            var host = CreateHostBuilder(args).Build();
            host.RunAsync();
            Application.Run(new MainWindow());
        }
        public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureServices((hostContext, services) =>
            {
                //Retrieve connection string from App.config
                string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

                services.AddDbContext<AmerichickenContext>(
                options => options.UseSqlServer(connectionString));

                // Add other services or configurations here if needed
            });
    }
}