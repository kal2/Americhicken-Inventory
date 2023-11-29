using Inventory.Interfaces;
using Inventory.UI.Menu;
using Inventory.Views.UserControls;
using Inventory.Views.UserControls.MasterFilesUpdate.RemitToSuppliers;

namespace Inventory
{
    public partial class MenuList : UserControl
    {
        //Stores reference to MainWindow
        private MainWindow _mainWindow;
        public MenuList(MainWindow mainWindow)
        {
            InitializeComponent();

            //Assigns passed MainWindow to local variable for use in this class
            _mainWindow = mainWindow;

            //Attaches keydown event handler to user input field
            _mainWindow.AttachTextBoxKeyDownHandler(userChoiceTextBox_KeyDown_1);
        }

        //Contains the current menu that should be displayed in main window, changes depending on menu displayed on screen, default is Main Menu
        string currentMenu = "main";

        //-----------User Input-------------//

        //Checks for keystrokes in user input field
        public void userChoiceTextBox_KeyDown_1(object sender, KeyEventArgs e)
        {
            string programName;
            //Collects user input and format for processing
            string userInput = _mainWindow.GetTextBoxText().Trim();

            //Waits to execute code until enter key is pressed in input area
            if (e.KeyCode == Keys.Enter)
            {
                //Var for storing and passing approprate menu listings
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
                    _mainWindow.SetTextBoxText("");
                }
                else
                {
                    //Detaches keydown event handler from user input field
                    _mainWindow.DetachTextBoxKeyDownHandler(userChoiceTextBox_KeyDown_1);

                    //Assigns programName to second array element that houses appropriate program info
                    programName = menuItems[1];
                    UserControl selectedControl = null;

                    //Check which program is being called and assign approprate control to selectedControl, passing MainWindow to the control as well
                    switch (programName)
                    {
                        case "addPO":
                            break;

                        case "matchSelect":
                            break;

                        case "menuList":
                            break;

                        case "remitToSupplierSearch":
                            break;

                        case "shipFromSupplierSearch":
                            selectedControl = new ShipFromUpdateInfo(_mainWindow);
                            break;

                        default:
                            throw new ArgumentException($"Unknown program: {programName}", nameof(programName));
                    }
                    //Passes selectedControl to MainWindow to be displayed
                    _mainWindow.DisplayControl(selectedControl);
                }
            }
        }
    }
}
