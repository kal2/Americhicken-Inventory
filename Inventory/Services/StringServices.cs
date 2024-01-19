using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Inventory.Services
{
    internal static class StringServices
    {
        internal static string TrimOrNull(string text)
        {
            var trimmedText = text?.Trim();
            return string.IsNullOrEmpty(trimmedText) ? null : trimmedText;
        }
    }
}
