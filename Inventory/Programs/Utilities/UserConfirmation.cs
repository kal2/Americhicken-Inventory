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
        }

        public void SetMessage(string message)
        {
            warningLabel.Text = message;
        }

        private void confirmationInput_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                if (confirmationInput.Text.ToUpper() == "Y")
                {
                    UserChoice?.Invoke(this, new UserConfirmationEventArgs(true));
                }
                else if (confirmationInput.Text.ToUpper() == "N")
                {
                    UserChoice?.Invoke(this, new UserConfirmationEventArgs(false));
                }
                else
                {
                    MessageBox.Show("Invalid input. Please try again.");
                    confirmationInput.Clear();
                }
            }
        }
    }
}
