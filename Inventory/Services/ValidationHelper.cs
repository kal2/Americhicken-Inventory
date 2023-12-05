using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Inventory.Services
{
    internal static class ValidationHelper
    {
        //checks if textboxes are empty
        public static bool IsEmpty(string input)
        {
            if (input == string.Empty)
            {
                return true;
            }
            return false;
        }
        
    }
}
