using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Inventory.Programs.Utilities
{

    public partial class UserConfirmation : UserControl
    {
        public event EventHandler<UserConfirmationEventArgs> UserChoice;

        public class UserConfirmationEventArgs : EventArgs
        {
            public bool UserChoice { get; }

            public UserConfirmationEventArgs(bool userChoice)
            {
                UserChoice = userChoice;
            }
        }

        public UserConfirmation()
        {
            InitializeComponent();

            this.VisibleChanged += (s, e) =>
            {
                if (this.Visible)
                {
                    confirmationInput.Focus();
                }
            };
        }

        public void SetMessage(string message)
        {
            warningLabel.Text = message;
        }

        private void confirmationInput_TextChanged(object sender, EventArgs e)
        {
            string userInput = confirmationInput.Text;
            if (userInput == "Y" || userInput == "N")
            {
                bool userChoice = userInput == "Y" ? true : false;
                UserChoice?.Invoke(this, new UserConfirmationEventArgs(userChoice));
            }
            else
            {
                MessageBox.Show("Invalid input. Please try again.");
                confirmationInput.Clear();
            }
        }
    }
}
