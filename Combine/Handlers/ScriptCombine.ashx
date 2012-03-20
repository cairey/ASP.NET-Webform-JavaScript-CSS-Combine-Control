<%@ WebHandler Language="C#" CodeBehind="ScriptCombine.ashx.cs" Class="ScriptCombine" %>


using System;
using System.Web;
using System.Text;
using System.IO;
using System.IO.Compression;


/// <summary>
/// Combine, Minify, Cache and Compress JavaScript
/// </summary>
/// <remarks>
/// Uses Query string parameters to configure its behaviour.
/// </remarks>

public class ScriptCombine : IHttpHandler
{

    private TimeSpan BrowserCacheDuraction { get; set; }
    private TimeSpan AppCacheDuraction { get; set; }
    private bool CanCompress { get; set; }
    private bool Compress { get; set; }
    private bool Minifiy { get; set; }
    private string CacheKey { get; set; }


    public void ProcessRequest(HttpContext context)
    {
        string scriptReferences = context.Request.QueryString["scr"]; ;
        this.BrowserCacheDuraction = TimeSpan.Parse(context.Request.QueryString["bdur"]);
        this.AppCacheDuraction = TimeSpan.Parse(context.Request.QueryString["adur"]);
        this.Compress = bool.Parse(context.Request.QueryString["com"]);
        this.Minifiy = bool.Parse(context.Request.QueryString["min"]);
        this.CanCompress = CanGZip(context.Request);
        this.AppCacheDuraction = (this.AppCacheDuraction >= TimeSpan.FromSeconds(5)) ? this.AppCacheDuraction : TimeSpan.FromSeconds(5);
        byte[] scriptBytes = null;
        scriptReferences = context.Server.UrlDecode(scriptReferences);

        WriteCacheKey(scriptReferences);

        if(context.Cache[CacheKey] == null)
        {
            scriptBytes = GetBytes(scriptReferences, context);
            context.Cache.Insert(this.CacheKey, scriptBytes, null, DateTime.Now.Add(this.AppCacheDuraction), TimeSpan.Zero);
        }

        scriptBytes = (byte[])context.Cache[CacheKey];
        WriteResponse(context, scriptBytes, (this.CanCompress && this.Compress));
    }

    private void WriteCacheKey(string scriptReferences)
    {
        StringBuilder cacheKey = new StringBuilder("ScriptCombine-");
        cacheKey.Append(scriptReferences);
        cacheKey.Append(this.BrowserCacheDuraction);
        cacheKey.Append(this.AppCacheDuraction);
        cacheKey.Append(this.Compress);
        cacheKey.Append(this.Minifiy);
        cacheKey.Append(this.CanCompress);
        this.CacheKey = cacheKey.ToString();
    }


    private byte[] GetBytes(string scriptReferences, HttpContext context)
    {
        string[] allScripts = scriptReferences.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);

        StringBuilder scripts =  new StringBuilder();
        foreach(string script in allScripts)
        {
            string path = context.Server.MapPath(script);
            scripts.Append(File.ReadAllText(path));
        }


        string minifiedScript = scripts.ToString();
        if(this.Minifiy) minifiedScript = MinifyScripts(scripts.ToString());


        byte[] scriptBytes = Encoding.UTF8.GetBytes(minifiedScript);
        using(MemoryStream ms = new MemoryStream())
        {
            using(Stream s = (this.CanCompress && this.Compress) ? (Stream)new GZipStream(ms, CompressionMode.Compress) : ms)
            {
                s.Write(scriptBytes, 0, scriptBytes.Length);
            }

            scriptBytes = ms.ToArray();
        }

        return scriptBytes;
    }


    private void WriteResponse(HttpContext context, byte[] scripts, bool isCompressed)
    {
        HttpResponse response = context.Response;

        response.AppendHeader("Content-Length", scripts.Length.ToString());
        response.ContentType = "text/javascript";

        if(isCompressed) response.AppendHeader("Content-Encoding", "gzip");
        else response.AppendHeader("Content-Encoding", "utf-8");

        response.Cache.SetCacheability(HttpCacheability.Public);
        response.Cache.SetExpires(DateTime.Now.Add(this.BrowserCacheDuraction));
        response.Cache.SetMaxAge(this.BrowserCacheDuraction);
        response.ContentEncoding = Encoding.Unicode;
        response.OutputStream.Write(scripts, 0, scripts.Length);

        response.Flush();
    }


    private bool CanGZip(HttpRequest request)
    {
        string acceptEncoding = request.Headers["Accept-Encoding"];

        if(!string.IsNullOrEmpty(acceptEncoding) &&
            (acceptEncoding.Contains("gzip") ||
             acceptEncoding.Contains("deflate")))

            return true;

        return false;
    }



    private string MinifyScripts(string scripts)
    {
        JavaScriptMinifier jsm = new JavaScriptMinifier();
        return jsm.Minify(scripts);
    }



    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}