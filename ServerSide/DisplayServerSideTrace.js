// File: DisplayAvailability.js

// Start function when DOM has completely loaded 
$(document).ready(function () {
    // Open the AvailabilityHeader.xml file
    $.get('ServerSideTraceHeader.xml', {}, function (xml) {

        // Define Option Var
        myHTMLOutput = '';
        x = 0;

        // Run the function for each Job in xml file
        $('Job', xml).each(function (i) {

            jobID = $(this).find('ID').text();
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
    currentStartTime = '';
    currentEndTime = '';
    currentTarget = '';
    currentTimeoutSeconds = '';
    currentCallCount = '';
    currentSuccessRate = '';
    currentJobMin = '';
    currentJobMax = '';
    currentJobMedian = '';
    currentJobDuration = '';
    currentJobDisplay = '';

    // Define graph var
    var data = [];

    // Set Data Loading Message to visible
    document.getElementById('MessageDiv').style.visibility = 'visible';

    // Open the AvailabilityHeader.xml file
    $.get('AvailabilityHeader.xml', {}, function (xml) {

        // Run the function for each Job in xml file
        $('Job', xml).each(function (i) {

            jobID = $(this).find('ID').text();

            // Pull Job Header info into variables
            if (jobID == headerJobID) {
                currentStartTime = $(this).find('StartTime').text();
                currentEndTime = $(this).find('EndTime').text();
                currentTarget = $(this).find('Target').text();
                currentTimeoutSeconds = $(this).find('TimeoutSeconds').text();
                currentCallCount = $(this).find('CallCount').text();
                currentSuccessRate = $(this).find('SuccessRate').text();
                currentJobMin = $(this).find('JobMin').text();
                currentJobMax = $(this).find('JobMax').text();
                currentJobMedian = $(this).find('JobMedian').text();

                var t1 = new Date(currentStartTime);
                var t2 = new Date(currentEndTime);
                var dif = (t2 - t1) / 1000;

                var runDays = Math.floor(dif / 86400);
                var rem = dif - (runDays * 86400);

                var runHours = Math.floor(rem / 3600);
                var rem = rem - (runHours * 3600);

                var runMinutes = Math.floor(rem / 60);
                var runSeconds = rem - (runMinutes * 60);

                if ((+runDays) == (+1)) { var unitDays = 'Day'; } else { var unitDays = 'Days'; };

                currentJobDuration = runDays + ' ' + unitDays + ', ' + pad(runHours) + ':' + pad(runMinutes) + ':' + pad(runSeconds) + ' (hh:mm:ss)';

                myHTMLOutput = '';
                myHTMLOutput += '<table id="SummaryTable">';
                myHTMLOutput += '<tr><td class="SumHead" colspan=6 style="text-align:left;">Job Details:</td></tr>';
                myHTMLOutput += '<tr>';
                myHTMLOutput += '<td>Start Time:</td>';
                myHTMLOutput += '<td>' + dateString(t1, 'noMilli') + '</td>';
                myHTMLOutput += '<td>End Time:</td>';
                myHTMLOutput += '<td>' + dateString(t2, 'noMilli') + '</td>';
                myHTMLOutput += '<td>Job Duration:</td>';
                myHTMLOutput += '<td>' + currentJobDuration + '</td>';
                myHTMLOutput += '</tr>';
                myHTMLOutput += '<tr>';
                myHTMLOutput += '<td>Target IP:</td>';
                myHTMLOutput += '<td>' + currentTarget + '</td>';
                myHTMLOutput += '<td>Calls Sent:</td>';
                myHTMLOutput += '<td>' + currentCallCount + ' (' + currentSuccessRate + '%) Successful</td>';
                myHTMLOutput += '<td>Timeout Value:</td>';
                myHTMLOutput += '<td>' + currentTimeoutSeconds + ' Seconds</td>';
                myHTMLOutput += '</tr>';
                myHTMLOutput += '<tr><td class="SumHead" colspan="6" style="text-align:left;">Results Summary:</td></tr>';
                myHTMLOutput += '<tr>';
                myHTMLOutput += '<td>Min:</td>';
                myHTMLOutput += '<td>' + currentJobMin + ' ms</td>';
                myHTMLOutput += '<td>Max:</td>';
                myHTMLOutput += '<td>' + currentJobMax + ' ms</td>';
                myHTMLOutput += '<td>Median:</td>';
                myHTMLOutput += '<td>' + currentJobMedian + ' ms</td>';
                myHTMLOutput += '</tr>';
                myHTMLOutput += '</table>';
                $("#SummaryDiv").html(myHTMLOutput);

            };
        });
    });

    // Open the AvailabilityDetail.xml file
    $.get('AvailabilityDetail.xml', {}, function (xml) {

        // Define HTML string Var
        myHTMLOutput = '';
        myHTMLOutput += '<table id="ResultsTable"';
        myHTMLOutput += '<thead>';
        myHTMLOutput += '<th id=time>Time Stamp</th>'
        myHTMLOutput += '<th id=display>Remarks</th>'
        myHTMLOutput += '<th id=duration>Duration</th>'
        myHTMLOutput += '<th id=trace>Trace</th>'
        myHTMLOutput += '</thead>';

        var t1 = new Date(currentStartTime);
        var t2 = new Date(currentEndTime);
        var chartWidth = document.getElementById("ResultsGraph").clientWidth - 100;
        var totalDurationMS = (t2 - t1);
        var timePerPixel = Math.round(totalDurationMS / chartWidth);
        var iRunning = 0;

        // Run the function for each Job in xml file
        $('JobRecord', xml).each(function (i) {

            jobID = $(this).find('JobID').text();
            if (jobID == headerJobID) {
                callTimeStamp = $(this).find('TimeStamp').text();
                callID = $(this).find('CallID').text();
                callReturn = $(this).find('Return').text();
                callDisplay = $(this).find('Display').text();
                callValid = $(this).find('Valid').text();
                callDuration = $(this).find('Duration').text();
                callTagged = $(this).find('Tag').text();

                // Calculate X position
                var thisTime = new Date(callTimeStamp);
                if (callID == 1 || callID == '') {
                    dif = 1;
                    pos = 1;
                    lastTime = thisTime;
                }
                else {
                    dif = thisTime - lastTime;
                    pos += dif / timePerPixel;
                    lastTime = thisTime;
                };

                // Build Table Row for Results Table
                myHTMLOutput += '<tr>';
                myHTMLOutput += '<td>' + dateString(thisTime, 'withMilli') + '</td>';
                myHTMLOutput += '<td>' + callDisplay + '</td>';
                myHTMLOutput += '<td>' + Math.round(callDuration) + ' ms</td>';
                if (callTagged == 'True') {
                    myHTMLOutput += "<td><a href=javascript:showTrace('" + jobID + "','" + callID + "')>View Trace</a></td>";
                }
                else {
                    myHTMLOutput += '<td>&nbsp;</td>';
                };
                myHTMLOutput += '</tr>';

                // Build graph array
                var myCallID = (+callID);
                var datapoint = { x: pos, y: Math.round(callDuration), z: callValid };
                data.push(datapoint);

            };
        });
        myHTMLOutput += "</table>";

        // Update the DIV called ResultsDiv with the HTML string
        $("#ResultsDiv").html(myHTMLOutput);

        var myTick;
        if (currentCallCount < 15) { myTick = 1; } else { myTick = currentCallCount / 15; };
        var myYMax;
        if (currentJobMax > 500) { myYMax = currentJobMax; } else { myYMax = 500; };

        // Instanitate the graph
        ClearChart("ResultsGraph");
        var myLineChart = new LineChart({
            canvasId: "ResultsGraph",
            minX: 0,
            minY: 0,
            maxX: currentCallCount,
            maxY: myYMax,
            unitsPerTickX: myTick,
            unitsPerTickY: myYMax / 8
        });

        // Draw the chart
        myLineChart.drawLine(data, "blue", 1);

    });

    // Set Data Loading Message to visible
    document.getElementById('MessageDiv').style.visibility = 'hidden';
};

function showTrace(JobID, CallID) {
    // Open the AvailabilityHeader.xml file
    $.get('AvailabilityTrace.xml', {}, function (xml) {

        // Define HTML string Var
        myHTMLOutput = '<span class="b">Select Trace Route</span>';
        myHTMLOutput += '<table id="TraceTable">';
        myHTMLOutput += '<tr>';
        myHTMLOutput += '<th id="HopID">Hop #</th>';
        myHTMLOutput += '<th id="Address">IP Address</th>';
        myHTMLOutput += '<th id="Latency">Latency</th>';
        myHTMLOutput += '</tr>';


        // Run the function for each Trace in xml file
        $('TraceRecord', xml).each(function (i) {

            traceJobID = $(this).find('JobID').text();
            traceCallID = $(this).find('CallID').text();

            // Pull Job Header info into variables
            if (traceJobID == JobID && traceCallID == CallID) {
                traceTimeStamp = $(this).find('TimeStamp').text();
                traceHopID = $(this).find('HopID').text();
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
        myHTMLOutput += '<br />';
        myHTMLOutput += '';
        myHTMLOutput += '<button style="position:absolute; right:45%;" onclick="closeTrace();">Close</button>';
        myHTMLOutput += '<br />';
        myHTMLOutput += '<br />';
        myHTMLOutput += '<span class="b">Notes:</span><br />';
        myHTMLOutput += '<span">The maximum trace route time will normally be less than the Duration value on the main web page. This is because the trace route is only calculating network latency, whereas the Duration column includes the processing time of the IIS server.</span>';
        myHTMLOutput += '<br /><br />';
        myHTMLOutput += '<span">This trace route was started <span class="b">*after*</span> the associated web call was completed. Network conditions may have changed in the short time span between the Web Call and the Trace Route. Also, each trace route row is a separate network trace, network conditions can vary between each trace event as well.</span>';
        myHTMLOutput += '<br />';
        myHTMLOutput += '<br />';
        $("#TraceDiv").html(myHTMLOutput);
        document.getElementById('TraceDiv').style.visibility = 'visible';
    });
};

function pad(num) {
    return ('000' + num).substr(-2);
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
        default:
            var sDisplay = '';
    };
    return sDisplay;
};

