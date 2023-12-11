using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Inventory.Interfaces
{
    public interface IActiveControlManager
    {
        void PerformAction(string userInput);
        void SetProgramLabels();
    }
}
