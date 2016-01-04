<%@ Page Language="VB" %>
<%@ Import Namespace="System.IO" %>

<%
    Dim myResult As String
    Dim strDetail As String = "C:\bin\Detail.xml"
    Dim streamWeb As Stream = Request.InputStream

    ' Validate Body is valid xml and header element
    ' Validate that C:\bin path is there, create if it isn't

    If File.Exists(strDetail) Then File.Delete(strDetail)
    Using fs As FileStream = File.Create(strDetail)
        streamWeb.CopyTo(fs)
    End Using

    myResult = "Good"

 %>
<%=myResult%>
