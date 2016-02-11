<%@ Page Language="VB" %>
<%@ Import Namespace="System.XML" %>
<%
    Dim myResult As String = "Bad"
    Dim strFileID As String
    Dim strXMLNode As String
    Dim strFileCurrent As String
    Dim strFileHeader As String = "AvailabilityHeader.xml"
    Dim strFileDetail As String = "AvailabilityDetail.xml"
    Dim strFileTrace As String = "AvailabilityTrace.xml"

    Dim xmlOutput As XmlDocument
    Dim xmlInput As XmlDocument
    Dim xmlTemp As XmlDocumentFragment

    Try
        strFileID = Request.Headers.GetValues("FileID").First

        Select Case strFileID
            Case "Header"
                strFileCurrent = HttpContext.Current.Server.MapPath(".\" & strFileHeader)
                strXMLNode = ".//Jobs/Job"
            Case "Detail"
                strFileCurrent = HttpContext.Current.Server.MapPath(".\" & strFileDetail)
                strXMLNode = ".//JobRecords/JobRecord"
            Case "Trace"
                strFileCurrent = HttpContext.Current.Server.MapPath(".\" & strFileTrace)
                strXMLNode = ".//TraceRecords/TraceRecord"
            Case Else
                Throw New System.Exception("An exception has occurred.")
        End Select

        xmlInput = New XmlDocument
        xmlInput.Load(Request.InputStream)
        xmlOutput = New XmlDocument
        xmlOutput.Load(strFileCurrent)

        Dim nodelist As XmlNodeList = xmlInput.SelectNodes(strXMLNode)
        For Each node As XmlNode In nodelist
            If node.FirstChild.InnerText <> "" Then
                xmlTemp = xmlOutput.CreateDocumentFragment()
                xmlTemp.InnerXml = node.OuterXml
                xmlOutput.DocumentElement.AppendChild(xmlTemp)
            End If
        Next
        xmlOutput.Save(strFileCurrent)
        myResult = "Good"

    Catch ex As Exception
        myResult = "Bad"
    End Try
 %>
<%=myResult%>
