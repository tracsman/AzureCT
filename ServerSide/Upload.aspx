<%@ Page Language="VB" %>
<%@ Import Namespace="System.XML" %>
<%
    Dim myResult As String = "Bad"
    Dim strFileID As String
    Dim strXMLNode As String
    Dim strFileCurrent As String
    Dim strFileHeader As String = "DiagJobHeader.xml"
    Dim strFileDetail As String = "DiagJobDetail.xml"

    Dim xmlOutput As XmlDocument
    Dim xmlInput As XmlDocument
    Dim xmlTemp As XmlDocumentFragment

    Try
        strFileID = Request.Headers.GetValues("FileID").First

        If strFileID = "Header" Or strFileID = "Detail" Then
            If strFileID = "Header" Then
                strFileCurrent = HttpContext.Current.Server.MapPath(".\" & strFileHeader)
                strXMLNode = ".//Jobs/Job"
            Else
                strFileCurrent =HttpContext.Current.Server.MapPath(".\" & strFileDetail)
                strXMLNode = ".//JobRecords/JobRecord"
            End If
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
        Else
            myResult = "Bad"
        End If
    Catch ex As Exception
        myResult = "Bad"
    End Try
 %>
<%=myResult%>