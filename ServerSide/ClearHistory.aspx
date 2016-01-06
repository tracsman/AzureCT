<%@ Page Language="VB" %>
<%@ Import Namespace="System.IO" %>
<%
    Dim myResult As String
    Dim WebStream As StreamReader = New StreamReader(Request.InputStream)
    Dim strBody As String = WebStream.ReadToEnd
    Dim strHeader As String = "c:\inetpub\DiagJobHeader.xml"
    Dim strDetail As String = "c:\inetpub\DiagJobDetail.xml"
    If strBody = "Yes" Then
        Try
            If File.Exists(strHeader) Then File.Delete(strHeader)
            If File.Exists(strDetail) Then File.Delete(strDetail)
            myResult = "Good"
        Catch ex As Exception
            myResult = "Bad"
        End Try
    Else
        myResult = "Bad"
    End If
 %>
<%=myResult%>