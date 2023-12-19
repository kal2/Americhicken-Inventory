using Inventory.Interfaces;
using Inventory.UI.Menu;
using Inventory.Views.UserControls;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;
using Inventory.Services;

namespace Inventory
{
    public partial class MenuList : UserControl, IActiveControlManager
    {
        //Stores reference to MainWindow
        private readonly MainWindow _mainWindow;
        private readonly ActiveControlManager _activeControlManager;
        //Contains the current menu that is displayed in main window
        string currentMenu = "main";
        public MenuList(MainWindow mainWindow, ActiveControlManager activeControlManager)
        {
            InitializeComponent();

            //Assigns passed MainWindow to local variable for use in this class
            _mainWindow = mainWindow;
            _activeControlManager = activeControlManager;
        }

        //-----------User Input-------------//

        public void SetProgramLabels()
        {
            _mainWindow.SetProgramLabel("Menu List");
        }
        public void PerformAction(string userInput)
        {
            string programName;
            string[] menuItems;

            //Pause painting in Menu Box while populates
            menuListBox.BeginUpdate();
            menuListBox.Items.Clear();

            //Passes currentMenu and userInput to Menu Selection method, returns appropriate menu list items
            menuItems = MenuUserSelection.UserMenuSelection(currentMenu, userInput);

            //Assigns currnetMenu to first array element that houses appropriate info
            currentMenu = menuItems[0];

            //Check if current menu is not a program listing, if it is call the program selector, otherwise continue with menu selection
            if (currentMenu != "program")
            {
                //Populates menu list with method's return
                menuListBox.Items.AddRange(menuItems[1..]);

                //Resumes paiting in Menu Box with the above changes made
                menuListBox.EndUpdate();
            }
            else
            {
                //Assigns programName to second array element that houses appropriate program info
                programName = menuItems[1];

                ProgramLoader programLoader = new(_mainWindow, _activeControlManager);

                programLoader.LoadProgram(programName);
            }
        }
    }
}
