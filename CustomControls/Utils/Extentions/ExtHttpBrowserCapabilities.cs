/*
   Last Modified: 30/05/2009
*/


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace CustomControls.Utils.Extentions
{
    public static class ExtHttpBrowserCapabilities
    {
        /// <summary>
        /// Identify the Clients Browser.
        /// </summary>
        /// <param name="browserCap">The current instance of the HttpBrowserCapabilities object.</param>
        /// <param name="context">The current instance of the HttpContext object.</param>
        /// <returns>Return the Enum of the current browser.</returns>
        public static Browsers IdentifyClientBrowser(this HttpBrowserCapabilities browserCap, HttpContext context)
        {
            string ua = context.Request.UserAgent.ToLower();

            if(ua.Contains("ie")) return Browsers.IE;
            else if(ua.Contains("firefox")) return Browsers.FF;
            else if(ua.Contains("chrome")) return Browsers.Chrome; // Detect Chrome before Safari
            else if(ua.Contains("safari")) return Browsers.Safari;
            else if(ua.Contains("opera")) return Browsers.Opera;
            else return Browsers.IE;
        }


        /// <summary>
        /// Identify the Clients Browser Major Version.
        /// </summary>
        /// <param name="browserCap">The current instance of the HttpBrowserCapabilities object.</param>
        /// <param name="context">The current instance of the HttpContext object.</param>
        /// <returns>Returns the browser Major Version.</returns>
        public static int IdentifyClientBrowserVersion(this HttpBrowserCapabilities browserCap, HttpContext context)
        {
            Browsers browser = context.Request.Browser.IdentifyClientBrowser(context);

            if(browser == Browsers.IE || browser == Browsers.FF || browser == Browsers.Opera) return browserCap.MajorVersion;
            else if(browser == Browsers.Chrome)
            {
                try
                {
                    string ua = context.Request.UserAgent.ToLower();
                    int pos = ua.LastIndexOf("chrome/");
                    string version = ua.Substring(pos + 7, 1);
                    return int.Parse(version);
                }
                catch
                {
#if DEBUG
                    throw new Exception("Unable to detect Chrome version.");
#endif
                }
            }
            else if(browser == Browsers.Safari)
            {
                try
                {
                    string ua = context.Request.UserAgent.ToLower();
                    int pos = ua.LastIndexOf("version/");
                    string version = ua.Substring(pos + 8, 1);
                    return int.Parse(version);
                }
                catch
                {
#if DEBUG
                    throw new Exception("Unable to detect Safari version.");
#endif
                }
            }


            return 0;
        }
    }
}
