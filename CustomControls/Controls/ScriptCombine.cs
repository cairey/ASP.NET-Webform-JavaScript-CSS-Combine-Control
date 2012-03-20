using System;
using System.Collections.Generic;
using System.Web.UI;
using System.ComponentModel;
using System.Text;

namespace CustomControls.Controls
{
    public class ScriptReference
    {
        public string Path { get; set; }
    }


    /// <summary>
    /// Combine, Minify, Cache and Compress JavaScript
    /// </summary>
    /// <remarks>
    /// 
    /// Setting "ScriptHandler" to "~/Handlers/ScriptCombine.ashx"
    /// will reference the script handler.
    /// 
    /// Setting "Combine" to "False"
    /// will result in no script combining. No compression, cache or minfications will be
    /// made except for any broswer defaults.
    /// Setting "Combine" to "True"
    /// will result in script combining.
    /// The default in no override is "True".
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
    [Description("Combine, Minify, Cache and Compress JavaScript")]
    [ToolboxData("<{0}:ScriptCombine runat=server></{0}:ScriptCombine>")]
    public class ScriptCombine: Control, INamingContainer
    {
        public string ScriptHandler { get; set; }
        public bool Combine { get; set; }
        public bool Minify { get; set; }
        public bool Compress { get; set; }
        public TimeSpan BrowserCacheDuration { get; set; }
        public TimeSpan AppCacheDuration { get; set; }
        
        private string ScriptHandlerUrl { get; set; }

        [NotifyParentProperty(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [MergableProperty(false)]
        public List<ScriptReference> Scripts { get; set; }


        public ScriptCombine()
        {
            this.BrowserCacheDuration = new TimeSpan(365, 0, 0, 0, 0);
            this.AppCacheDuration = new TimeSpan(365, 0, 0, 0, 0);
            this.Combine = true;
            this.Compress = true;
            this.Minify = true;
            
            this.Init += new EventHandler(ScriptCombine_Init);
        }

        
        protected override void Render(HtmlTextWriter writer)
        {
            base.Render(writer);

            if(this.Combine)
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Type, "text/javascript");
                writer.AddAttribute(HtmlTextWriterAttribute.Src, ResolveUrl(this.ScriptHandlerUrl));
                writer.RenderBeginTag(HtmlTextWriterTag.Script);
                writer.RenderEndTag();
            }
            else
            {
                foreach(ScriptReference script in Scripts)
                {
                    writer.AddAttribute(HtmlTextWriterAttribute.Type, "text/javascript");
                    writer.AddAttribute(HtmlTextWriterAttribute.Src, ResolveUrl(script.Path));
                    writer.RenderBeginTag(HtmlTextWriterTag.Script);
                    writer.RenderEndTag();
                }
            }
        }



        private void ScriptCombine_Init(object sender, EventArgs e)
        {
            if(!this.Combine) return;


            StringBuilder scripts =  new StringBuilder();
            scripts.Append(ResolveUrl(this.ScriptHandler));
            scripts.Append("?scr=");

            string seperator = Context.Server.UrlEncode(";");
            foreach(ScriptReference script in Scripts)
            {
                scripts.Append(Context.Server.UrlEncode(script.Path));
                scripts.Append(seperator);
            }

            scripts.Append("&bdur=");
            scripts.Append(this.BrowserCacheDuration.ToString());

            scripts.Append("&adur=");
            scripts.Append(this.AppCacheDuration.ToString());

            scripts.Append("&com=");
            scripts.Append(this.Compress.ToString());

            scripts.Append("&min=");
            scripts.Append(this.Minify.ToString());

            this.ScriptHandlerUrl = scripts.ToString();
        }
    }
}
