<%@ Page Language="VB" %>
<%@ Import Namespace="System.IO" %>
<%
    Dim myResult As String
    Dim WebStream As StreamReader = New StreamReader(Request.InputStream)
    Dim strBody As String = WebStream.ReadToEnd
    Dim strHeader As String = HttpContext.Current.Server.MapPath(".\AvailabilityHeader.xml")
    Dim strDetail As String = HttpContext.Current.Server.MapPath(".\AvailabilityDetail.xml")
    Dim strHeaderTemplate As String = HttpContext.Current.Server.MapPath(".\TemplateAvailabilityHeader.xml")
    Dim strDetailTemplate As String = HttpContext.Current.Server.MapPath(".\TemplateAvailabilityDetail.xml")
    If strBody = "Yes" Then
        Try
            If File.Exists(strHeader) Then File.Copy(strHeaderTemplate, strHeader, True)
            If File.Exists(strDetail) Then File.Copy(strDetailTemplate, strDetail, True)
            myResult = "Good"
        Catch ex As Exception
            myResult = "Bad"
        End Try
    Else
        myResult = "Bad"
    End If
 %>
<%=myResult%>