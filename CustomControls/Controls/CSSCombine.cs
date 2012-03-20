using System;
using System.Collections.Generic;
using System.Web.UI;
using System.ComponentModel;
using System.Text;
using CustomControls.Utils;
using CustomControls.Utils.Extentions;

namespace CustomControls.Controls
{

    public class CSSReference
    {
        public string Path { get; set; }
        public Browsers TargetBrowser { get; set; }
        public int TargetVersion { get; set; }
    }


    /// <summary>
    /// Combine, Minify, Cache and Compress CSS
    /// </summary>
    /// <remarks>
    /// 
    /// Setting "CSSHandler" to "~/Handlers/CSSCombine.ashx"
    /// will reference the script handler.
    /// 
    /// Setting "Minify" to "False"
    /// will result in no minification. This does not effect any other setting.
    /// Setting "Minify" to "True"
    /// will result in script minifying.
    /// The default in no override is "True".
    /// 
    /// Setting "Compress" to "False"
    /// will result in no compression. This does not effect any other setting.
    /// Setting "Compress" to "True"
    /// will result in script GZip compression if supported by the browser.
    /// If no compression is supported by the browser, it will fall back to standard.
    /// The default in no override is "True".
    /// 
    /// Setting "BrowserCacheDuration" to "0"
    /// will result in no browser caching. This does not effect any other setting.
    /// Setting "BrowserCacheDuration" to "30"
    /// will result in browser caching for 30 days.
    /// The default in no override is "365" days.
    /// 
    /// Setting "AppCacheDuration" to "0"
    /// will result in no application caching. This does not effect any other setting.
    /// Setting "AppCacheDuration" to "30"
    /// will result in application caching for 30 days.
    /// The default in no override is "365" days.
    /// </remarks>


    [ParseChildren(true)]
    [PersistChildren(false)]
    [Description("Combine, Minify, Cache and Compress CSS")]
    [ToolboxData("<{0}:CSSCombine runat=server></{0}:CSSCombine>")]
    public class CSSCombine : Control, INamingContainer
    {
        public string CSSHandler { get; set; }
        public bool Minify { get; set; }
        public bool Compress { get; set; }
        public TimeSpan BrowserCacheDuration { get; set; }
        public TimeSpan AppCacheDuration { get; set; }
        
        private string CSSHandlerUrl { get; set; }

        [NotifyParentProperty(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [MergableProperty(false)]
        public List<CSSReference> CSSReferences { get; set; }


        public CSSCombine()
        {
            this.BrowserCacheDuration = new TimeSpan(365, 0, 0, 0, 0);
            this.AppCacheDuration = new TimeSpan(365, 0, 0, 0, 0);
            this.Compress = true;
            this.Minify = true;

            this.Init += new EventHandler(CSSCombine_Init);
        }


        protected override void Render(HtmlTextWriter writer)
        {
            base.Render(writer);

            writer.AddAttribute(HtmlTextWriterAttribute.Type, "text/css");
            writer.AddAttribute(HtmlTextWriterAttribute.Href, ResolveUrl(this.CSSHandlerUrl));
            writer.AddAttribute(HtmlTextWriterAttribute.Rel, "stylesheet");
            writer.RenderBeginTag(HtmlTextWriterTag.Link);
            writer.RenderEndTag();
        }



        private void CSSCombine_Init(object sender, EventArgs e)
        {
            Browsers clientBrowser = Context.Request.Browser.IdentifyClientBrowser(Context);
            int clientVersion = Context.Request.Browser.IdentifyClientBrowserVersion(Context);

            StringBuilder styles = new StringBuilder();
            styles.Append(ResolveUrl(this.CSSHandler));
            styles.Append("?css=");


            string seperator = Context.Server.UrlEncode(";");
            foreach(CSSReference css in CSSReferences)
            {
                if(css.TargetBrowser == Browsers.All)
                {
                    styles.Append(Context.Server.UrlEncode(css.Path));
                    styles.Append(seperator);
                }
                else if(css.TargetBrowser == clientBrowser
                        && (css.TargetVersion == clientVersion || css.TargetVersion == 0 ))
                {
                    styles.Append(Context.Server.UrlEncode(css.Path));
                    styles.Append(seperator);
                }
            }

            styles.Append("&bdur=");
            styles.Append(this.BrowserCacheDuration.ToString());

            styles.Append("&adur=");
            styles.Append(this.AppCacheDuration.ToString());

            styles.Append("&com=");
            styles.Append(this.Compress.ToString());

            styles.Append("&min=");
            styles.Append(this.Minify.ToString());

            this.CSSHandlerUrl = styles.ToString();
        }
    }
}
