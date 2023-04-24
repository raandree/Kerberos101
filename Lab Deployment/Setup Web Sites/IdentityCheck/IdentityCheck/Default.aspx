<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="TestSite1._Default" EnableViewStateMac="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div style="height: 471px">
    
        Thread Identity:
        <asp:Label ID="labThreadIdentity" runat="server" Text="Label"></asp:Label>
    
        <br />
        <br />
        WindowsIdentity:
        <asp:Label ID="labWindowsIdentity" runat="server" Text="Label"></asp:Label>
        <br />
        <br />
        WhoAmI:
        <asp:Label ID="labWhoAmI" runat="server" Text="Label"></asp:Label>
    
        <br />
        <br />
        <br />
        <asp:TextBox ID="txtGroups" runat="server" Height="313px" TextMode="MultiLine" Width="875px"></asp:TextBox>
    
    </div>
    <p>
        <asp:Button ID="btnAccessFolder" runat="server" onclick="btnAccessFolder_Click" 
            Text="Access Folder" />
        <asp:TextBox ID="txtFolderPath" runat="server" Width="401px"></asp:TextBox>
    </p>
    <p>
        <asp:Label ID="labAccessFolderMessage" runat="server"></asp:Label>
    </p>
    </form>
</body>
</html>
