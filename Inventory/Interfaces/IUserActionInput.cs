using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Inventory.Interfaces
{
    public interface IUserActionInput
    {
        void SetTextBoxText(string text);
        string GetTextBoxText();
        void AttachTextBoxKeyDownHandler(KeyEventHandler handler);
        void DetachTextBoxKeyDownHandler(KeyEventHandler handler);
    }
}
