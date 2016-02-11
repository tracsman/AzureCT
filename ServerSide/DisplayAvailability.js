// File: DisplayAvailability.js

// Start function when DOM has completely loaded 
$(document).ready(function () {
    // Open the AvailabilityHeader.xml file
    $.get('AvailabilityHeader.xml', {}, function (xml) {

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
                myHTMLOutput += '<td>' + traceTripTime + '</td>';
                myHTMLOutput += '</tr>';


            };
        });

        myHTMLOutput += '</table>';
        myHTMLOutput += '<br />';
        myHTMLOutput += '';
        myHTMLOutput += '<button style="position:absolute; right:50px;" onclick="closeTrace();">Close</button>';
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

function closeTrace() {
    document.getElementById('TraceDiv').style.visibility = 'hidden';
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

function LineChart(con) {

    // user defined properties
    this.canvas = document.getElementById(con.canvasId);
    this.minX = con.minX;
    this.minY = con.minY;
    this.maxX = con.maxX;
    this.maxY = con.maxY;
    this.unitsPerTickX = con.unitsPerTickX;
    this.unitsPerTickY = con.unitsPerTickY;

    // constants
    this.padding = 10;
    this.tickSize = 5;
    this.axisColor = "#555";
    this.pointRadius = 3;
    this.font = "12pt Calibri";
    this.fontHeight = 12;
    this.xAxisAdjustment = 15;
    this.yAxisAdjustment = 11;

    // relationships
    this.context = this.canvas.getContext("2d");
    this.rangeX = this.maxX - this.minX;
    this.rangeY = this.maxY - this.minY;
    this.numXTicks = Math.round(this.rangeX / this.unitsPerTickX);
    this.numYTicks = Math.round(this.rangeY / this.unitsPerTickY);
    this.x = this.getLongestValueWidth() + this.padding * 2;
    this.y = this.padding * 2;
    this.width = (this.canvas.width - this.x - this.padding * 2) - this.yAxisAdjustment;
    this.height = this.canvas.height - this.y - this.padding - this.fontHeight - this.xAxisAdjustment;
    this.scaleX = this.width / this.rangeX;
    this.scaleY = this.height / this.rangeY;

    // draw title and axis labels
    this.context.textAlign = 'center';
    var ChartLabel = 'Graph of Call Response Time';
    this.context.fillText(ChartLabel, (this.width / 2) + 50, 20);

    var xLabel = 'Time (duration of this data set)';
    this.context.fillText(xLabel, (this.width / 2) + 50, 285);

    var yLabel = 'Response Time (ms)';
    this.context.save();
    this.context.rotate(-Math.PI / 2);
    this.context.fillText(yLabel, -150, 18);
    this.context.restore();

    // draw x y axis and tick marks
    this.drawXAxis();
    this.drawYAxis();
};

function ClearChart(CanID) {
    var canvas = document.getElementById(CanID);
    var context = canvas.getContext('2d');
    context.clearRect(0, 0, canvas.clientWidth, canvas.clientHeight);
};

LineChart.prototype.getLongestValueWidth = function () {
    this.context.font = this.font;
    var longestValueWidth = 0;
    for (var n = 0; n <= this.numYTicks; n++) {
        var value = this.maxY - (n * this.unitsPerTickY);
        longestValueWidth = Math.max(longestValueWidth, this.context.measureText(value).width);
    }
    return longestValueWidth;
};

LineChart.prototype.drawXAxis = function () {
    var context = this.context;
    context.save();
    context.beginPath();
    context.moveTo(this.x + this.yAxisAdjustment, this.y + this.height);
    context.lineTo(this.x + this.width + this.yAxisAdjustment, this.y + this.height);
    context.strokeStyle = this.axisColor;
    context.lineWidth = 2;
    context.stroke();

    // draw tick marks
    //for (var n = 0; n < this.numXTicks; n++) {
    //    context.beginPath();
    //    context.moveTo((n + 1) * this.width / this.numXTicks + this.x, this.y + this.height);
    //    context.lineTo((n + 1) * this.width / this.numXTicks + this.x, this.y + this.height - this.tickSize);
    //    context.stroke();
    //}

    // draw labels
    context.font = this.font;
    context.fillStyle = "black";
    context.textAlign = "center";
    context.textBaseline = "middle";

    //for (var n = 0; n < this.numXTicks; n++) {
    //    var label = Math.round((n + 1) * this.maxX / this.numXTicks);
    //    context.save();
    //    context.translate((n + 1) * this.width / this.numXTicks + this.x, this.y + this.height + this.padding);
    //    context.fillText(label, 0, 0);
    //    context.restore();
    //}
    context.restore();
};

LineChart.prototype.drawYAxis = function () {
    var context = this.context;
    context.save();
    context.save();
    context.beginPath();
    context.moveTo(this.x + this.yAxisAdjustment, this.y);
    context.lineTo(this.x + this.yAxisAdjustment, this.y + this.height);
    context.strokeStyle = this.axisColor;
    context.lineWidth = 2;
    context.stroke();
    context.restore();

    // draw tick marks
    for (var n = 0; n < this.numYTicks; n++) {
        context.beginPath();
        context.moveTo(this.x + this.yAxisAdjustment, n * this.height / this.numYTicks + this.y);
        context.lineTo(this.x + this.tickSize + this.yAxisAdjustment, n * this.height / this.numYTicks + this.y);
        context.stroke();
    }

    // draw values
    context.font = this.font;
    context.fillStyle = "black";
    context.textAlign = "right";
    context.textBaseline = "middle";

    for (var n = 0; n < this.numYTicks; n++) {
        var value = Math.round(this.maxY - n * this.maxY / this.numYTicks);
        context.save();
        context.translate(this.x - this.padding + this.yAxisAdjustment, n * this.height / this.numYTicks + this.y);
        context.fillText(value, 0, 0);
        context.restore();
    }
    context.restore();
};

LineChart.prototype.drawLine = function (data, color, width) {

    var context = this.context;
    context.save();
    this.transformContext();
    context.lineWidth = width;
    context.strokeStyle = color;
    context.fillStyle = color;
    context.beginPath();
    context.moveTo(data[0].x + 20, data[0].y * this.scaleY);

    for (var n = 0; n < data.length; n++) {
        var point = data[n];

        // draw segment
        context.lineTo(point.x + 20, point.y * this.scaleY);
        context.stroke();
        context.closePath();
        context.beginPath();
        if (data[n].z == "False") { context.fillStyle = "red"; };
        context.arc(point.x + 20, point.y * this.scaleY, this.pointRadius, 0, 2 * Math.PI, false);
        context.fill();
        context.closePath();
        if (data[n].z == "False") { context.fillStyle = color; };

        // position for next segment
        context.beginPath();
        context.moveTo(point.x + 20, point.y * this.scaleY);
    }
    context.restore();
};

LineChart.prototype.transformContext = function () {
    var context = this.context;

    // move context to center of canvas
    this.context.translate(this.x, this.y + this.height);

    // invert the y scale so that that increments
    // as you move upwards
    context.scale(1, -1);
};
