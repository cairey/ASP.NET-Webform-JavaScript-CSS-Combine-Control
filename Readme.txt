Date: 27/05/2009
Author: Chris Airey
email: cairey01@hotmail.com

See the Default.aspx page for example of using this control.


Read below for JavScript Control settings.


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
    /// The default in no override is "30" days.
    /// 
    /// Setting "AppCacheDuration" to "0"
    /// will result in no application caching. This does not effect any other setting.
    /// Setting "AppCacheDuration" to "30"
    /// will result in application caching for 30 days.
    /// The default in no override is "30" days.
    /// </remarks>