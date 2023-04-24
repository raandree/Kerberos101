<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="TestSite2._Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <asp:Label ID="labCredentials" runat="server" 
            Text="Who are we going to be today? (UPN required)"></asp:Label>
        <asp:TextBox ID="txtCredentials" runat="server" Width="196px"></asp:TextBox>
    
        <asp:Button ID="btnGo" runat="server" Text="Go" onclick="btnGo_Click" />
    
    </div>
    <p>
        <asp:Label ID="labResult" runat="server"></asp:Label>
    </p>
    <p>
        <asp:Label ID="labRecordsRead" runat="server"></asp:Label>
    </p>
    </form>
</body>
</html>
