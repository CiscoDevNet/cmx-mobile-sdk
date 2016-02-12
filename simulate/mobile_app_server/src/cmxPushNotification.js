var logger = require('./config/logging/logger');
var https = require('https');
var argv = require('optimist').usage('Usage: $0 -d deviceId -m message').demand(['m']).argv;
var deviceIdentifier = "770ab8ffe9ec";
var webApp = "";

callback = function(response) {
	var str = '';
	response.on('data', function(chunk) {
		str += chunk;
	});

	response.on('end', function() {
		console.log("Response: " + str);
	});
};

if (argv.d) {
	deviceIdentifier = argv.d;
}

var body = '{"message" : "' + argv.m + '"}';
var options = {
	host : 'localhost',
	path : webApp+'/api/cmxmobile/v1/clients/notification/' + deviceIdentifier,
	port : '8082',
	method : 'POST',
	rejectUnauthorized: false,
	headers : {
		"Content-Length" : body.length,
		"Content-Type" : "application/json"
	}

};
var req = https.request(options, callback);
req.write(body);
req.end();