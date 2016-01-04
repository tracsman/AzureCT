<%@ Page Language="VB" %>
<%@ Import Namespace="System.IO" %>

<%
    Dim myResult As String
    Dim strHeader As String = "C:\bin\Header.xml"
    Dim streamWeb As Stream = Request.InputStream

    ' Validate Body is valid xml and header element
    ' Validate that C:\bin path is there, create if it isn't

    If File.Exists(strHeader) Then File.Delete(strHeader)
    Using fs As FileStream = File.Create(strHeader)
        streamWeb.CopyTo(fs)
    End Using

    myResult = "Good"

 %>
<%=myResult%>
