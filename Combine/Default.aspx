<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CombineExample.Default" %>

<%@ Register TagPrefix="cc" Namespace="CustomControls.Controls" Assembly="CustomControls" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Script/CSS Combine Demo</title>
    <cc:CSSCombine ID="CSSCombiner" runat="server" CSSHandler="~/Handlers/CSSCombine.ashx">
        <CSSReferences>
            <cc:CSSReference TargetBrowser="All" Path="~/Styles/admin.css" /> <%--Will target all versions of all browsers--%>
            <cc:CSSReference Path="~/Styles/webTV.css" /> <%-- Will target all versions of all browsers --%>
            <cc:CSSReference TargetBrowser="IE" TargetVersion="8" Path="~/Styles/admin_old.css" /> <%-- Will target version 8 of IE --%>
            <cc:CSSReference TargetBrowser="FF" TargetVersion="2" Path="~/Styles/screen.css" /> <%-- Will target versions 2 of FireFox --%>
            <cc:CSSReference TargetBrowser="Chrome" Path="~/Styles/main.css" /> <%-- Will target all versions of Chrome --%>
            <cc:CSSReference TargetBrowser="Safari" Path="~/Styles/sifr.css" /> <%-- Will target all versions of Safari --%>
        </CSSReferences>
    </cc:CSSCombine>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <h1>
        </h1>
    </div>
    </form>
    <cc:ScriptCombine ID="ScriptCombiner" runat="server" ScriptHandler="~/Handlers/ScriptCombine.ashx">
        <Scripts>
            <cc:ScriptReference Path="~/Scripts/jquery-1.3.2.min.js" />
            <cc:ScriptReference Path="~/Scripts/ui.core.js" />
            <cc:ScriptReference Path="~/Scripts/ui.accordion.js" />
            <cc:ScriptReference Path="~/Scripts/ui.datepicker.js" />
            <cc:ScriptReference Path="~/Scripts/ui.progressbar.js" />
            <cc:ScriptReference Path="~/Scripts/ui.draggable.js" />
            <cc:ScriptReference Path="~/Scripts/ui.sortable.js" />
            <cc:ScriptReference Path="~/Scripts/ui.slider.js" />
            <cc:ScriptReference Path="~/Scripts/ui.resizable.js" />
            <cc:ScriptReference Path="~/Scripts/ui.draggable.js" />
            <cc:ScriptReference Path="~/Scripts/ui.selectable.js" />
            <cc:ScriptReference Path="~/Scripts/ui.droppable.js" />
        </Scripts>
    </cc:ScriptCombine>

    <script type="text/javascript">

        $(function()
        {
            $("h1").text("Script/CSS Combine Demo!");
        });
   
    </script>

</body>
</html>
