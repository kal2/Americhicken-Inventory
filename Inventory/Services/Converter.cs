using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Inventory.Services
{
    internal static class Converter
    {
        internal static string TrimOrNull(string text)
        {
            var trimmedText = text?.Trim();
            return string.IsNullOrEmpty(trimmedText) ? null : trimmedText;
        }
        internal static DateTime? ParseDateTime(string input)
        {
            if (string.IsNullOrEmpty(input))
            {
                return null;
            }
            else
            {
                DateTime date;

                bool success = DateTime.TryParse(input, new CultureInfo("en-US"), DateTimeStyles.None, out date);
                if (success)
                {
                    return date;
                }
                else
                {
                    return null;
                }
            }
        }
        internal static decimal? ParseDecimal(string input)
        {
            if (string.IsNullOrEmpty(input))
            {
                return null;
            }
            else
            {
                decimal number;

                bool success = decimal.TryParse(input, out number);
                if (success)
                {
                    return number;
                }
                else
                {
                    return null;
                }
            }
        }
        internal static int? ParseInt(string input)
        {
            if (string.IsNullOrEmpty(input))
            {
                return null;
            }
            else
            {
                int number;

                bool success = int.TryParse(input, out number);
                if (success)
                {
                    return number;
                }
                else
                {
                    return null;
                }
            }
        }
    }
}
