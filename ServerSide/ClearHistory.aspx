<%@ Page Language="VB" %>
<%@ Import Namespace="System.IO" %>
<%
    Dim myResult As String
    Dim WebStream As StreamReader = New StreamReader(Request.InputStream)
    Dim strBody As String = WebStream.ReadToEnd
    Dim strHeader As String = "c:\bin\DiagJobHeader.xml"
    Dim strDetail As String = "c:\bin\DiagJobDetail.xml"
    If strBody = "Yes" Then
        Try
            If File.Exists(strHeader) Then File.Delete(strHeader)
            If File.Exists(strDetail) Then File.Delete(strDetail)
            myResult = "Good"
        Catch ex As Exception
            MsgBox("Got a err")
            myResult = "Fail"
        End Try
    Else
        myResult = "Fail"
    End If
 %>

<%=myResult%>