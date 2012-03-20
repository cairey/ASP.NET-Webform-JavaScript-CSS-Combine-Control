<%@ WebHandler Language="C#" CodeBehind="CSSCombine.ashx.cs" Class="CSSCombine" %>


using System;
using System.Web;
using System.Text;
using System.IO;
using System.IO.Compression;
using CustomControls.Utils;

/// <summary>
/// Combine, Minify, Cache and Compress CSS
/// </summary>
/// <remarks>
/// Uses Query string parameters to configure its behaviour.
/// </remarks>

public class CSSCombine : IHttpHandler
{

    private TimeSpan BrowserCacheDuraction { get; set; }
    private TimeSpan AppCacheDuraction { get; set; }
    private bool CanCompress { get; set; }
    private bool Compress { get; set; }
    private bool Minifiy { get; set; }
    private string CacheKey { get; set; }


    public void ProcessRequest(HttpContext context)
    {
        string cssReferences = context.Request.QueryString["css"]; ;
        this.BrowserCacheDuraction = TimeSpan.Parse(context.Request.QueryString["bdur"]);
        this.AppCacheDuraction = TimeSpan.Parse(context.Request.QueryString["adur"]);
        this.Compress = bool.Parse(context.Request.QueryString["com"]);
        this.Minifiy = bool.Parse(context.Request.QueryString["min"]);
        this.CanCompress = CanGZip(context.Request);
        this.AppCacheDuraction = (this.AppCacheDuraction >= TimeSpan.FromSeconds(5)) ? this.AppCacheDuraction : TimeSpan.FromSeconds(5);
        byte[] cssBytes = null;
        cssReferences = context.Server.UrlDecode(cssReferences);

        WriteCacheKey(cssReferences);

        if(context.Cache[CacheKey] == null)
        {
            cssBytes = GetBytes(cssReferences, context);
            context.Cache.Insert(this.CacheKey, cssBytes, null, DateTime.Now.Add(this.AppCacheDuraction), TimeSpan.Zero);
        }

        cssBytes = (byte[])context.Cache[CacheKey];
        WriteResponse(context, cssBytes, (this.CanCompress && this.Compress));
    }

    private void WriteCacheKey(string cssReferences)
    {
        StringBuilder cacheKey = new StringBuilder("CSSCombine-");
        cacheKey.Append(cssReferences);
        cacheKey.Append(this.BrowserCacheDuraction);
        cacheKey.Append(this.AppCacheDuraction);
        cacheKey.Append(this.Compress);
        cacheKey.Append(this.Minifiy);
        cacheKey.Append(this.CanCompress);
        this.CacheKey = cacheKey.ToString();
    }


    private byte[] GetBytes(string cssReferences, HttpContext context)
    {
        string[] allCSS = cssReferences.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);

        StringBuilder styles =  new StringBuilder();
        foreach(string css in allCSS)
        {
            string path = context.Server.MapPath(css);
            styles.Append(File.ReadAllText(path));
        }

        string minifiedCSS = styles.ToString();
        if(this.Minifiy) minifiedCSS = MinifyCSS(styles.ToString());


        byte[] cssBytes = Encoding.UTF8.GetBytes(minifiedCSS);
        using(MemoryStream ms = new MemoryStream())
        {
            using(Stream s = (this.CanCompress && this.Compress) ? (Stream)new GZipStream(ms, CompressionMode.Compress) : ms)
            {
                s.Write(cssBytes, 0, cssBytes.Length);
            }

            cssBytes = ms.ToArray();
        }

        return cssBytes;
    }


    private void WriteResponse(HttpContext context, byte[] css, bool isCompressed)
    {
        HttpResponse response = context.Response;

        response.AppendHeader("Content-Length", css.Length.ToString());
        response.ContentType = "text/css";

        if(isCompressed) response.AppendHeader("Content-Encoding", "gzip");
        else response.AppendHeader("Content-Encoding", "utf-8");

        response.Cache.SetCacheability(HttpCacheability.Public);
        response.Cache.SetExpires(DateTime.Now.Add(this.BrowserCacheDuraction));
        response.Cache.SetMaxAge(this.BrowserCacheDuraction);
        response.ContentEncoding = Encoding.Unicode;
        response.OutputStream.Write(css, 0, css.Length);

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



    private string MinifyCSS(string css)
    {
        CSSMinifier cssMin = new CSSMinifier();
        return cssMin.Compress(css, 0);
    }



    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}