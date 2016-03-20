<%@ Page Language="VB" %>
<%@ Import Namespace="System.IO" %>
<%
    Dim myResult As String
    Dim WebStream As StreamReader = New StreamReader(Request.InputStream)
    Dim strBody As String = WebStream.ReadToEnd
    Dim strHeader As String = HttpContext.Current.Server.MapPath(".\AvailabilityHeader.xml")
    Dim strDetail As String = HttpContext.Current.Server.MapPath(".\AvailabilityDetail.xml")
    Dim strTrace As String = HttpContext.Current.Server.MapPath(".\AvailabilityTrace.xml")
    Dim strSSHeader As String = HttpContext.Current.Server.MapPath(".\ServerSideTraceHeader.xml")
    Dim strSSDetail As String = HttpContext.Current.Server.MapPath(".\ServerSideTraceDetail.xml")
    Dim strHeaderTemplate As String = HttpContext.Current.Server.MapPath(".\TemplateAvailabilityHeader.xml")
    Dim strDetailTemplate As String = HttpContext.Current.Server.MapPath(".\TemplateAvailabilityDetail.xml")
    Dim strTraceTemplate As String = HttpContext.Current.Server.MapPath(".\TemplateAvailabilityTrace.xml")
    Dim strSSHeaderTemplate As String = HttpContext.Current.Server.MapPath(".\TemplateServerSideTraceHeader.xml")
    Dim strSSDetailTemplate As String = HttpContext.Current.Server.MapPath(".\TemplateServerSideTraceDetail.xml")

    If strBody = "Yes" Then
        Try
            If File.Exists(strHeader) Then File.Copy(strHeaderTemplate, strHeader, True)
            If File.Exists(strDetail) Then File.Copy(strDetailTemplate, strDetail, True)
            If File.Exists(strTrace) Then File.Copy(strTraceTemplate, strTrace, True)
            If File.Exists(strSSHeader) Then File.Copy(strSSHeaderTemplate, strTrace, True)
            If File.Exists(strSSDetail) Then File.Copy(strSSDetailTemplate, strTrace, True)
            myResult = "Good"
        Catch ex As Exception
            myResult = "Bad"
        End Try
    Else
        myResult = "Bad"
    End If
 %>
<%=myResult%>