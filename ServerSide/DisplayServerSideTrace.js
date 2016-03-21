// File: DisplayServerSideTrace.js

// Start function when DOM has completely loaded 
$(document).ready(function () {
    // Open the ServerSideTraceHeader.xml file
    $.get('ServerSideTraceHeader.xml', {}, function (xml) {

        // Define Vars
        myHTMLOutput = '';
        x = 0;

        // Run the function for each ServerTrace in xml file
        $('ServerTrace', xml).each(function (i) {

            jobID = $(this).find('JobID').text();
            if (jobID != "") {
                jobStart = $(this).find('StartTime').text();
                var dStart = new Date(jobStart);

                // Build Option Row for Drop down
                myHTMLOutput += '<option value=' + jobID + '>&nbsp;&nbsp;' + dateString(dStart, 'noMilli') + '&nbsp;&nbsp;</option>';
                x += 1;
            };
        });

        // Update the Job List drop down with the HTML string
        $("#JobList").append(myHTMLOutput);

        // Select last job and call onchange event to load job details
        document.getElementById("JobList").selectedIndex = x - 1;
        document.getElementById("JobList").onchange();
    });
});

function PullJobDetails() {
    // Get the selected Job ID from the drop down 
    headerJobID = document.getElementById("JobList").value;

    // Set Data Loading Message to visible
    document.getElementById('MessageDiv').style.visibility = 'visible';

    // Open the ServerSideTraceDetail.xml file
    $.get('ServerSideTraceDetail.xml', {}, function (xml) {

        // Define Vars
        myHTMLOutput = '';

        // Run the function for each TraceRecord in xml file
        $('TraceRecord', xml).each(function (i) {

            jobID = $(this).find('JobID').text();
            hopID = $(this).find('HopID').text();
            if (jobID == headerJobID && hopID == 1) {
                traceID = $(this).find('TraceID').text();
                traceStart = $(this).find('TimeStamp').text();
                var dStart = new Date(traceStart);

                // Build Option Row for Drop down
                myHTMLOutput += '<option value=' + pad(traceID) + '>&nbsp;&nbsp;' + traceID + ' | ' + dateString(dStart, 'mm:ss') + '&nbsp;&nbsp;</option>';
            };
        });

        // Update the Job List drop down with the HTML string
        $("#HeaderList").append(myHTMLOutput);

        // Select last job and call onchange event to load job details
        document.getElementById("HeaderList").selectedIndex = 1;
        document.getElementById("HeaderList").onchange();
    });

    // Set Data Loading Message to hidden
    document.getElementById('MessageDiv').style.visibility = 'hidden';
};

function PullTrace() {
    // Get the selected Job and Trace IDs 
    headerJobID = document.getElementById("JobList").value;
    headerTraceID = document.getElementById("HeaderList").value;

    // Set Data Loading Message to visible
    document.getElementById('MessageDiv').style.visibility = 'visible';

    // Open the ServerSideTraceDetail.xml file
    $.get('ServerSideTraceDetail.xml', {}, function (xml) {

        // Define HTML string Var
        myHTMLOutput = '<table id="DetailTable">';
        myHTMLOutput += '<tr>';
        myHTMLOutput += '<th id="HopID">Hop #</th>';
        myHTMLOutput += '<th id="Address">IP Address</th>';
        myHTMLOutput += '<th id="Latency">Latency</th>';
        myHTMLOutput += '</tr>';


        // Run the function for each Trace in xml file
        $('TraceRecord', xml).each(function (i) {

            traceJobID = $(this).find('JobID').text();
            traceTraceID = $(this).find('TraceID').text();

            // Pull Job Header info into variables
            if (traceJobID == headerJobID && traceTraceID == headerTraceID) {
                traceHopID = $(this).find('HopID').text();
                traceTimeStamp = $(this).find('TimeStamp').text();
                traceAddress = $(this).find('Address').text();
                traceTripTime = $(this).find('TripTime').text();

                myHTMLOutput += '<tr>';
                myHTMLOutput += '<td>' + traceHopID + '</td>';
                myHTMLOutput += '<td>' + traceAddress + '</td>';

                switch (traceTripTime) {
                    case '*':
                        myHTMLOutput += '<td>*</td>';
                        break;
                    case '0':
                        myHTMLOutput += '<td>< 1 ms</td>';
                        break;
                    default:
                        myHTMLOutput += '<td>' + traceTripTime + ' ms</td>';
                };
                myHTMLOutput += '</tr>';
            };
        });

        myHTMLOutput += '</table>';
        $("#DetailDiv").html(myHTMLOutput);
        document.getElementById('TraceDiv').style.visibility = 'visible';
    });

    // Set Data Loading Message to hidden
    document.getElementById('MessageDiv').style.visibility = 'hidden';
};

function pad(num) {
    return ('000' + num).substr(-4);
};

function dateString(dDate, sOption) {
    var yyyy = dDate.getFullYear().toString();
    var mm = (dDate.getMonth() + 1).toString();
    var dd = dDate.getDate().toString();
    var hh = dDate.getHours().toString();
    var MM = dDate.getMinutes().toString();
    var ss = dDate.getSeconds().toString();

    switch (sOption) {
        case 'noMilli':
            var sDisplay = yyyy + '-' + (mm[1] ? mm : "0" + mm[0]) + '-' + (dd[1] ? dd : "0" + dd[0]) + ' | ' + (hh[1] ? hh : "0" + hh[0]) + ':' + (MM[1] ? MM : "0" + MM[0]) + ':' + (ss[1] ? ss : "0" + ss[0]);
            break;
        case 'withMilli':
            var fff = ('000' + dDate.getMilliseconds().toString()).substr(-3);
            var sDisplay = yyyy + '-' + (mm[1] ? mm : "0" + mm[0]) + '-' + (dd[1] ? dd : "0" + dd[0]) + ' | ' + (hh[1] ? hh : "0" + hh[0]) + ':' + (MM[1] ? MM : "0" + MM[0]) + ':' + (ss[1] ? ss : "0" + ss[0]) + '.' + fff;
            break;
        case 'mm:ss':
            var sDisplay = (MM[1] ? MM : "0" + MM[0]) + ':' + (ss[1] ? ss : "0" + ss[0]);
            break;
        default:
            var sDisplay = '';
    };
    return sDisplay;
};

