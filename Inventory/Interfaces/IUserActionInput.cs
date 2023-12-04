using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Inventory.Interfaces
{
    public interface IUserActionInput
    {
        void FocusTextBox();
        void SetTextBoxText(string text);
        string GetTextBoxText();
        void ClearTextBox();
        void SetTextBoxLabel(string text);
        void SetCommandsLabel(string text);
        void AttachTextBoxKeyDownHandler(KeyEventHandler handler);
        void DetachTextBoxKeyDownHandler(KeyEventHandler handler);
    }
}
