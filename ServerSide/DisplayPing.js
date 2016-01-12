// File: DisplayPing.js

// Start function when DOM has completely loaded 
$(document).ready(function(){
    // Open the DiagJobHeader.xml file
    $.get('DiagJobHeader.xml', {}, function (xml) {

        // Define Option Var
        myHTMLOutput = '';

        // Run the function for each Job in xml file
        $('Job', xml).each(function (i) {

            jobID = $(this).find('ID').text();
            if (jobID != "") {
                jobStart = $(this).find('StartTime').text();

                // Build Option Row for Drop down
                myHTMLOutput += '<option value=' + jobID + '>' + jobStart + '</option>';
            };
        });

        // Update the Job List drop down with the HTML string
        $("#JobList").append(myHTMLOutput);

        // Call onchange event to load the first job details
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
    currentPingCount = '';
    currentSuccessRate = '';
    currentPingMin = '';
    currentPingMax = '';
    currentPingAvg = '';
    currentDuration = '';
    currentJobDisplay = '';

    // Define graph var
    var data = [];

    // Open the DiagJobHeader.xml file
    $.get('DiagJobHeader.xml', {}, function (xml) {

        // Run the function for each Job in xml file
        $('Job', xml).each(function (i) {

            jobID = $(this).find('ID').text();

            // Pull Job Header info into variables
            if (jobID == headerJobID) {
                currentStartTime = $(this).find('StartTime').text();
                currentEndTime = $(this).find('EndTime').text();
                currentTarget = $(this).find('Target').text();
                currentTimeoutSeconds = $(this).find('TimeoutSeconds').text();
                currentPingCount = $(this).find('PingCount').text();
                currentSuccessRate = $(this).find('SuccessRate').text();
                currentPingMin = $(this).find('PingMin').text();
                currentPingMax = $(this).find('PingMax').text();
                currentPingAvg = $(this).find('PingAvg').text();

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

                currentDuration = runDays + ' ' + unitDays + ', ' + pad(runHours) + ':' + pad(runMinutes) + ':' + pad(runSeconds) + ' (hh:mm:ss)';

                myHTMLOutput = '';
                myHTMLOutput += '<table id="SummaryTable">';
                myHTMLOutput += '<tr><td class="SumHead" colspan=6 style="text-align:left;">Job Details:</td></tr>';
                myHTMLOutput += '<tr>';
                myHTMLOutput += '<td>Start Time:</td>';
                myHTMLOutput += '<td>' + currentStartTime + '</td>';
                myHTMLOutput += '<td>End Time:</td>';
                myHTMLOutput += '<td>' + currentEndTime + '</td>';
                myHTMLOutput += '<td>Job Duration:</td>';
                myHTMLOutput += '<td>' + currentDuration + '</td>';
                myHTMLOutput += '</tr>';
                myHTMLOutput += '<tr>';
                myHTMLOutput += '<td>Target IP:</td>';
                myHTMLOutput += '<td>' + currentTarget + '</td>';
                myHTMLOutput += '<td>Pings Sent:</td>';
                myHTMLOutput += '<td>' + currentPingCount + ' (' + currentSuccessRate + '%) Successful</td>';
                myHTMLOutput += '<td>Timeout Value:</td>';
                myHTMLOutput += '<td>' + currentTimeoutSeconds + ' Seconds</td>';
                myHTMLOutput += '</tr>';
                myHTMLOutput += '<tr><td class="SumHead" colspan="6" style="text-align:left;">Results Summary:</td></tr>';
                myHTMLOutput += '<tr>';
                myHTMLOutput += '<td>Min:</td>';
                myHTMLOutput += '<td>' + currentPingMin + ' ms</td>';
                myHTMLOutput += '<td>Max:</td>';
                myHTMLOutput += '<td>' + currentPingMax + ' ms</td>';
                myHTMLOutput += '<td>Avg:</td>';
                myHTMLOutput += '<td>' + currentPingAvg + ' ms</td>';
                myHTMLOutput += '</tr>';
                myHTMLOutput += '</table>';
                $("#SummaryDiv").html(myHTMLOutput);

            };
        });
    });

    // Open the DiagJobHeader.xml file
    $.get('DiagJobDetail.xml', {}, function (xml) {

        // Define HTML string Var
        myHTMLOutput = '';
        myHTMLOutput += '<table id="ResultsTable"';
        myHTMLOutput += '<thead>';
        myHTMLOutput += '<th id=time>Time Stamp</th>'
        myHTMLOutput += '<th id=return>Return</th>'
        myHTMLOutput += '<th id=display>Display</th>'
        myHTMLOutput += '<th id=valid>Valid</th>'
        myHTMLOutput += '<th id=duration>Duration</th>'
        myHTMLOutput += '</thead>';

        // Run the function for each Job in xml file
        $('JobRecord', xml).each(function (i) {

            jobID = $(this).find('JobID').text();
            if (jobID == headerJobID) {
                jobTimeStamp = $(this).find('TimeStamp').text();
                jobPingID = $(this).find('PingID').text();
                jobReturn = $(this).find('Return').text();
                jobDisplay = $(this).find('Display').text();
                currentJobDisplay=jobDisplay;
                jobValid = $(this).find('Valid').text();
                jobDuration = $(this).find('Duration').text();

                // Build Table Row for Results Table
                myHTMLOutput += '<tr>'
                myHTMLOutput += '<td>' + jobTimeStamp + '</td>';
                myHTMLOutput += '<td>' + jobReturn + '</td>';
                myHTMLOutput += '<td>' + jobDisplay + '</td>';
                myHTMLOutput += '<td>' + jobValid + '</td>';
                myHTMLOutput += '<td>' + Math.round(jobDuration) + ' ms</td>';
                myHTMLOutput += '</tr>'

                // Build graph array
                var myPingID = (+jobPingID);
                var datapoint = { x: myPingID, y: Math.round(jobDuration) };
                
                data.push(datapoint);
            };
        });
        myHTMLOutput += "</table>";

        // Update the DIV called ResultsDiv with the HTML string
        $("#ResultsDiv").html(myHTMLOutput);
       
        var myTick;
        if (currentPingCount < 15) { myTick = 1; } else { myTick = currentPingCount / 15; };
        var myYMax;
        if (currentPingMax > 1000) { myYMax = currentPingMax; } else { myYMax = 1000; };

        if (currentPingMax == 0) {
            ClearChart("ResultsGraph");
            ErrorChart("ResultsGraph", currentJobDisplay );
        }
        else {
            ClearChart("ResultsGraph");
            var myLineChart = new LineChart({
                canvasId: "ResultsGraph",
                minX: 0,
                minY: 0,
                maxX: currentPingCount,
                maxY: myYMax,
                unitsPerTickX: myTick,
                unitsPerTickY: myYMax / 8
            });

            myLineChart.drawLine(data, "blue", 1);
        };
    });
};

function pad(num) {
    return ('000' + num).substr(-2);
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
    var ChartLabel = 'Graph of Ping Response Time';
    this.context.fillText(ChartLabel, (this.width / 2), 20);

    var xLabel = 'Number of Pings';
    this.context.fillText(xLabel, (this.width / 2), 293);

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

function ErrorChart(CanID, Message) {
    var canvas = document.getElementById(CanID);
    var context = canvas.getContext('2d');
    context.font = "bold 250% sans-serif";
    context.fillStyle = "#FF0000";
    context.textAlign = "center";
    context.fillText(Message, 500, 150);
    context.fillStyle = "#000000";
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
    for (var n = 0; n < this.numXTicks; n++) {
        context.beginPath();
        context.moveTo((n + 1) * this.width / this.numXTicks + this.x, this.y + this.height);
        context.lineTo((n + 1) * this.width / this.numXTicks + this.x, this.y + this.height - this.tickSize);
        context.stroke();
    }

    // draw labels
    context.font = this.font;
    context.fillStyle = "black";
    context.textAlign = "center";
    context.textBaseline = "middle";

    for (var n = 0; n < this.numXTicks; n++) {
        var label = Math.round((n + 1) * this.maxX / this.numXTicks);
        context.save();
        context.translate((n + 1) * this.width / this.numXTicks + this.x, this.y + this.height + this.padding);
        context.fillText(label, 0, 0);
        context.restore();
    }
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
    context.moveTo(data[0].x * this.scaleX, data[0].y * this.scaleY);

    for (var n = 0; n < data.length; n++) {
        var point = data[n];

        // draw segment
        context.lineTo(point.x * this.scaleX, point.y * this.scaleY);
        context.stroke();
        context.closePath();
        context.beginPath();
        context.arc(point.x * this.scaleX, point.y * this.scaleY, this.pointRadius, 0, 2 * Math.PI, false);
        context.fill();
        context.closePath();

        // position for next segment
        context.beginPath();
        context.moveTo(point.x * this.scaleX, point.y * this.scaleY);
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