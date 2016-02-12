var express = require('express');
var https = require('https');
var logger = require('./config/logging/logger');
var util = require('util');
var fs = require('fs');
var gcm = require('node-gcm');
var crypto = require('crypto');
var pointInPolygon = require('point-in-polygon');
var bodyParser = require('body-parser');
var cookieParser = require('cookie-parser'); 
var optimist = require('optimist')
    .usage('Usage: $0 -h -d [deviceId] -l -r')
    .describe('h', 'Display the usage message')
    .describe('d', 'Device ID to use when new client regesters')
    .describe('l', 'List device IDs which can be used to register a new device')
    .describe('r', 'Remove all currently registered device IDs');
var argv = optimist.argv;
var currentChildCount = 0;
var xmlAppDoc;
var pkg;
var simulatedDeviceIdentifier = "000ab8ffe9ec";
var webApp = "/cmx-cloud-server";

if (fs.existsSync('./node_modules/cisco-cmx-mobile-app-server-simulator/package.json')) {
    pkg = require('./node_modules/cisco-cmx-mobile-app-server-simulator/package.json');
} else {
    pkg = require('../package.json');
}

var options = {
        key: fs.readFileSync('server-key.pem'),
        cert: fs.readFileSync('server-cert.pem')
};
var mobileAppServer = express();

mobileAppServer.use(bodyParser.urlencoded({ extended: false }));
mobileAppServer.use(bodyParser.json());
mobileAppServer.use(cookieParser());

if (argv.h) {
    optimist.showHelp();
    process.exit(0);
}

if (argv.l) {
    console.log("Listing all the avaialable devices");
    console.log(" ------------------------------------------------------------------");
    console.log("|   Device ID  |                      Description                  |");
    console.log(" ------------------------------------------------------------------");
    var directoryName = "./config/devices/";
    var directoryFiles = fs.readdirSync(directoryName);
    for (var i in directoryFiles) {
        if (directoryFiles[i].match(".json$")) {
            var deviceInfo = require(directoryName + directoryFiles[i]);
            console.log("| " + deviceInfo.deviceId + " | " + deviceInfo.description);
        }
    }
    console.log(" ------------------------------------------------------------------");
    process.exit(0);
}

if (argv.d) {
    simulatedDeviceIdentifier = argv.d;
    var fileName = "./config/location/" + simulatedDeviceIdentifier + ".json";
    if (!fs.existsSync(fileName)) {
        console.log("Device ID does not exist for: " + simulatedDeviceIdentifier);
        process.exit(0);
    }
}

if (argv.r) {
    console.log("Starting to remove all registered devices");
    var directoryName = "./config/registered/";
    var directoryFiles = fs.readdirSync(directoryName);
    for (var i in directoryFiles) {
        if (directoryFiles[i].match(".json$")) {
            fs.unlinkSync(directoryName + directoryFiles[i]);
        }
    }
    console.log("Completed removing all registered devices");
    process.exit(0);
}

mobileAppServer.get(webApp+'/api/cmxmobile/v1/venues/info/', function(req, res) {
    logger.info("Get all venues info request from: " + req.ip);
    var directoryName = "./config/venues/";
    var directoryFiles = fs.readdirSync(directoryName);
    var allVenueInfo = [];
    var venueInfoCount = 0;
    for (var i in directoryFiles) {
        if (directoryFiles[i].match(".json$")) {
            var singleVenueInfo = require(directoryName + directoryFiles[i]);
            allVenueInfo[venueInfoCount] = singleVenueInfo;
            ++venueInfoCount;
            logger.info("Venue info found for : " + singleVenueInfo.name);
        }
    }
    if (venueInfoCount === 0) {
        logger.error("Get venue info does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get venue info does not exist", "errors": [{"domain": "Venues", "reason": "ResourceNotFound", "message": "Get venue info does not exist"}]}');
    }
    return res.json(allVenueInfo);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/venues/info/:venueId', function(req, res) {
    logger.info("Get venues info request from: " + req.ip + " params: " + util.inspect(req.params));
    var venueId = req.params.venueId;
    if (venueId === undefined) {
        logger.error("Get venue info request missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get venue info request missing all required parameters", "errors": [{"domain": "Venues", "reason": "MissingParameters", "message": "Get venue info request missing all required parameters"}]}');
    } 
    var fileName = "./config/venues/" + venueId + ".json";
    if (!fs.existsSync(fileName)) {
        logger.error("Get venue info does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get venue info does not exist", "errors": [{"domain": "Venues", "reason": "ResourceNotFound", "message": "Get venue info does not exist"}]}');
    }
    var venueInfo = require(fileName);
    var directoryName = "./config/maps/" + venueId + "/";
    if (!fs.existsSync(directoryName)) {
        logger.error("Get venue info venue ID search does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get venue info venue ID search does not exist", "errors": [{"domain": "Venues", "reason": "ResourceNotFound", "message": "Get venue info search does not exist"}]}');
    }
    var directoryFiles = fs.readdirSync(directoryName);
    var mapInfo = [];
    var mapInfoCount = 0;
    for (var i in directoryFiles) {
        if (directoryFiles[i].match(".json$")) {
            var mapFloorInfo = require(directoryName + directoryFiles[i]);
            mapInfo[mapInfoCount] = mapFloorInfo;
            ++mapInfoCount;
            logger.info("Map info found for : " + mapFloorInfo.mapHierarchyString);
        }
    }
    if (mapInfoCount === 0) {
        logger.error("Get venue map info does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get venue map info does not exist", "errors": [{"domain": "Venues", "reason": "ResourceNotFound", "message": "Get venue map info does not exist"}]}');
    }
    venueInfo.floors = mapInfo;
    return res.json(venueInfo);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/venues/image/:venueId', function(req, res) {
    logger.info("Get venues image request from: " + req.ip + " params: " + util.inspect(req.params));
    var venueId = req.params.venueId;
    if (venueId === undefined) {
        logger.error("Get venues image is missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get venues image is missing all required parameters", "errors": [{"domain": "Venues", "reason": "MissingParameters", "message": "Get venues image is missing all required parameters"}]}');
    }
    var baseFileName = "./config/venues/" + venueId;
    var fileName = baseFileName + ".gif";
    if (!fs.existsSync(fileName)) {
        fileName = baseFileName + ".png";
        if (!fs.existsSync(fileName)) {
            fileName = baseFileName + ".svg";
            if (!fs.existsSync(fileName)) {
                logger.error("Get venues image does not exist");
                return res.send(404, '"error": {"code": 404,"message": "Get venues image does not exist", "errors": [{"domain": "Venues", "reason": "ResourceNotFound", "message": "Get venues image does not exist"}]}');
            }
        }
    }
    return res.sendfile(fileName);
});

mobileAppServer.post(webApp+'/api/cmxmobile/v1/clients/notification/:deviceId', function(req, res) {
    logger.info("Send push notification request from: " + req.ip + " params " + util.inspect(req.params));
    var deviceId = req.params.deviceId.replace(/:/g, "");
    if (deviceId === undefined) {
        logger.error("Send push notification request missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Send push notification request missing all required parameters", "errors": [{"domain": "Noficiation", "reason": "MissingParameters", "message": "Send push notification request missing all required parameters"}]}');
    } 
    var fileName = "./config/registered/"+deviceId+".json";
    if (!fs.existsSync(fileName)) {
        logger.error("Send push notification for device ID does not exist: " + deviceId);
        return res.send(404, '"error": {"code": 404,"message": "Send push notification for device ID does not exist", "errors": [{"domain": "Notification", "reason": "ResourceNotFound", "message": "Send push notification for device ID does not exist"}]}');
    }
    var pushNotificationSender = new gcm.Sender('AIzaSyCdx_vj1-ooJoN8l0RJYOhjvOCWQdCA3Z0');
    var messageBody = req.body;
    logger.info("Push notification message: " + util.inspect(messageBody));
    var data = fs.readFileSync(fileName);
    var notification = JSON.parse(data);
    var messageNotification = new gcm.Message();
    var registrationIds = [];
    if (messageBody.message === undefined) {
        logger.error("Send push notification request missing message parameter");
        return res.send(500, '"error": {"code": 500,"message": "Send push notification request missing message parameter", "errors": [{"domain": "Noficiation", "reason": "MissingParameters", "message": "Send push notification request missing message parameter"}]}');
    }
    messageNotification.addDataWithKeyValue('message', messageBody.message);
    var preferredNetwork = "";
    if (messageBody.ssid === undefined || messageBody.ssid.length <= 0) {
        var locationFileName = "./config/location/" + deviceId + ".json";
        if (!fs.existsSync(locationFileName)) {
            logger.error("Get location device ID does not exist");
            return res.send(401, '"error": {"code": 401,"message": "Get location device ID does not exist", "errors": [{"domain": "Notification", "reason": "AuthenticationFailure", "message": "Get location device ID does not exist"}]}');
        }
        var locations = require(locationFileName);
        var venueId = locations[0].venueId;
        var venueFileName = "./config/venues/" + venueId + ".json";
        if (!fs.existsSync(venueFileName)) {
            logger.error("Get venue info does not exist");
            return res.send(404, '"error": {"code": 404,"message": "Get venue info does not exist", "errors": [{"domain": "Notification", "reason": "ResourceNotFound", "message": "Get venue info does not exist"}]}');
        }
        var venueInfo = require(venueFileName);
        preferredNetwork = util.inspect(venueInfo.preferredNetwork);
    } else {
        var ssidPassword = "";
        if (messageBody.ssidPassword !== undefined) {
            ssidPassword = messageBody.ssidPassword;
        }
        preferredNetwork = "[ { ssid: '" + messageBody.ssid + "', password: '" + ssidPassword + "' } ]";    
    }
    messageNotification.addDataWithKeyValue('preferredNetwork', preferredNetwork);
    registrationIds.push(notification.pushRegistrationId);
    logger.info("Push notification message to be sent: " + messageBody.message + " with preferredNetwork: " + preferredNetwork + " to registration ID: " + notification.pushRegistrationId);
    pushNotificationSender.send(messageNotification, registrationIds, 4, function (err, result) {
        logger.info(result);
    });
    isDeviceRegistered = true;
    res.send(200);
});

mobileAppServer.post(webApp+'/api/cmxmobile/v1/clients/register', function(req, res) {
    logger.info("Client register request from: " + req.ip);
    var registerBody = req.body;
    logger.info("Client register body: " + util.inspect(registerBody));
    if (registerBody === undefined) {
        logger.error("Register body missing parameters");
        return res.send(500, '"error": {"code": 500,"message": "Register body missing parameters", "errors": [{"domain": "Register", "reason": "MissingParameters", "message": "Register body missing parameters"}]}');
    }
    if (registerBody.clientType !== undefined) {
        logger.info("Client Type: " + registerBody.clientType);
    } else {
        logger.error("No Client Type");
        return res.send(500, '"error": {"code": 500,"message": "Register body missing client type parameter", "errors": [{"domain": "Register", "reason": "MissingParameters", "message": "Register body missing client type parameter"}]}');
    }
    if (registerBody.clientType.indexOf('android') < 0 && registerBody.clientType.indexOf('ios') < 0) {
        logger.error("Client Type is not set to android, ios or ios6");
        return res.send(500, '"error": {"code": 500,"message": "Client Type is not set to android or ios", "errors": [{"domain": "Register", "reason": "ClientType", "message": "Client Type is not set to android or ios"}]}');
    }
    var pushRegistrationId = "";
    if (registerBody.pushNotificationRegistrationId !== undefined) {
        pushRegistrationId = registerBody.pushNotificationRegistrationId;
    }
    logger.info("Client push notification registration ID: " + pushRegistrationId);
    if (registerBody.apMACAddress !== undefined) {
        logger.info("Client AP MAC Address: " + registerBody.apMACAddress);
    } else {
        if (registerBody.clientType.indexOf('ios6') < 0 && registerBody.clientType.indexOf('ios') >= 0) {
            logger.error("No Client AP MAC Address");		
            return res.send(500, '"error": {"code": 500,"message": "Register body missing client AP MAC Address parameter", "errors": [{"domain": "Register", "reason": "MissingParameters", "message": "Register body missing client AP MAC Address parameter"}]}');
        } else {
            logger.info("No Client AP MAC Address required or set");	
        }
    }
    if (registerBody.clientIPAddress !== undefined) {
        logger.info("Client IP Address: " + registerBody.clientIPAddress);
    } else {
        if (registerBody.clientType.indexOf('ios6') < 0 && registerBody.clientType.indexOf('ios') >= 0) {
            logger.error("No Client IP Address");
            return res.send(500, '"error": {"code": 500,"message": "Register body missing client IP Address parameter", "errors": [{"domain": "Register", "reason": "MissingParameters", "message": "Register body missing client IP Address parameter"}]}');
        } else {
            logger.info("No Client IP Address required or set");
        }
    }
    if (registerBody.clientMACAddress !== undefined) {
        logger.info("Client MAC Address: " + registerBody.clientMACAddress);
    } else {
        if (registerBody.clientType.indexOf('ios6') >= 0 && registerBody.clientType.indexOf('ios') >= 0) {
            logger.error("No Client MAC Address for android or ios6 device type");
            return res.send(500, '"error": {"code": 500,"message": "Client MAC Address is not set to android or ios6", "errors": [{"domain": "Register", "reason": "MissingParameters", "message": "Client MAC Address is not set to android or ios6"}]}');
        } else {
            logger.info("No Client MAC Address required or set");
        }
    }
    var cryptoBuf = crypto.randomBytes(48);
    var uniqueDeviceId = cryptoBuf.toString('hex');
    var fileName = "./config/registered/" + uniqueDeviceId + ".json";
    var outputFile = fs.openSync(fileName, 'w');
    var registrationTime = new Date();
    fs.writeSync(outputFile, '{\n\"deviceId\": \"'+uniqueDeviceId+'\",\n\"simulatedDeviceId\": \"'+simulatedDeviceIdentifier+'\",\n\"deviceType\": \"Android\",\n\"pushRegistrationId\": \"'+pushRegistrationId+'\",\n\"ipAddress\": \"'+registerBody.clientIPAddress+'\",\n\"macAddress\": \"'+registerBody.clientMACAddress+'\",\n\"registrationTime\": \"'+registrationTime+'\"\n}');
    fs.closeSync(outputFile);
    res.cookie('cmxMobileApplicationCookie', 'randomCookiePassword');
    res.location(webApp+'/api/cmxmobile/v1/clients/location/' + uniqueDeviceId);
    return res.send(201);
});

mobileAppServer.post(webApp+'/api/cmxmobile/v1/clients/feedback/location/:deviceId', function(req, res) {
    logger.info("Client location feedback from: " + req.ip + " params " + util.inspect(req.params));
    var feedbackBody = req.body;
    logger.info("Client location feedback body: " + util.inspect(feedbackBody));
    if (req.cookies === undefined || req.cookies.cmxMobileApplicationCookie === undefined) {
        logger.error("The cookie cmxMobileApplicationCookie for authentication is not defined");
        return res.send(401, '"error": {"code": 401,"message": "The cookie cmxMobileApplicationCookie for authentication is not defined", "errors": [{"domain": "Location feedback", "reason": "AuthenticationFailure", "message": "The cookie cmxMobileApplicationCookie for authentication is not defined"}]}');
    } else if (req.cookies.cmxMobileApplicationCookie.indexOf('randomCookiePassword') < 0) {
        logger.error("The cookie cmxMobileApplicationCookie does not match the expected cookie");
        return res.send(401, '"error": {"code": 401,"message": "The cookie cmxMobileApplicationCookie does not match the expected cookie", "errors": [{"domain": "Location feedback", "reason": "AuthenticationFailure", "message": "The cookie cmxMobileApplicationCookie does not match the expected cookie"}]}');
    }
    if (feedbackBody === undefined) {
        logger.error("Feedback body missing parameters");
        return res.send(500, '"error": {"code": 500,"message": "Location feedback body missing parameters", "errors": [{"domain": "Location feedback", "reason": "MissingParameters", "message": "Location feedback body missing parameters"}]}');
    }
    if (feedbackBody.x !== undefined) {
        logger.info("Client X Location: " + feedbackBody.x);
    } else {
        logger.info("No Client X Location");		
    }
    if (feedbackBody.y !== undefined) {
        logger.info("Client Y Location: " + feedbackBody.y);
    } else {
        logger.info("No Client Y Location");
    }
    return res.send(200);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/clients/location/:deviceId', function(req, res) {
    logger.info("Get location request from: " + req.ip + " params " + util.inspect(req.params));
    if (req.cookies === undefined || req.cookies.cmxMobileApplicationCookie === undefined) {
        logger.error("The cookie cmxMobileApplicationCookie for authentication is not defined");
        return res.send(401, '"error": {"code": 401,"message": "The cookie cmxMobileApplicationCookie for authentication is not defined", "errors": [{"domain": "Location", "reason": "AuthenticationFailure", "message": "The cookie cmxMobileApplicationCookie for authentication is not defined"}]}');
    } else if (req.cookies.cmxMobileApplicationCookie.indexOf('randomCookiePassword') < 0) {
        logger.error("The cookie cmxMobileApplicationCookie does not match the expected cookie");
        return res.send(401, '"error": {"code": 401,"message": "The cookie cmxMobileApplicationCookie does not match the expected cookie", "errors": [{"domain": "Location", "reason": "AuthenticationFailure", "message": "The cookie cmxMobileApplicationCookie does not match the expected cookie"}]}');
    }
    var deviceId = req.params.deviceId.replace(/:/g, "");
    if (deviceId === undefined) {
        logger.error("Get location request missing all required parameters");
        return res.send(401, '"error": {"code": 401,"message": "Get location request missing all required parameters", "errors": [{"domain": "Location", "reason": "AuthenticationFailure", "message": "Get location request missing all required parameters"}]}');
    }
    var demoFileName = "./config/registered/location_" + deviceId + ".json";
    if (fs.existsSync(demoFileName)) {
        var data = fs.readFileSync(demoFileName);
        logger.info("Location data: " + data);
        var location = JSON.parse(data);
        res.json(location);
    } else {
        var registeredFileName = "./config/registered/" + deviceId + ".json";
        if (!fs.existsSync(registeredFileName)) {
            logger.error("Get location device ID is not registered");
            return res.send(401, '"error": {"code": 401,"message": "Get location device ID is not registered", "errors": [{"domain": "Location", "reason": "AuthenticationFailure", "message": "Get location device ID is not registered"}]}');
        }
        var registeredFileData = fs.readFileSync(registeredFileName);
        var registeredData = JSON.parse(registeredFileData);
        logger.info("Get location request from: " + req.ip + " device ID for simulation is " + registeredData.simulatedDeviceId);
        var fileName = "./config/location/" + registeredData.simulatedDeviceId + ".json";
        if (!fs.existsSync(fileName)) {
            logger.error("Get location device ID does not exist: " + registeredData.simulatedDeviceId);
            return res.send(401, '"error": {"code": 401,"message": "Get location device ID does not exist", "errors": [{"domain": "Location", "reason": "AuthenticationFailure", "message": "Get location device ID does not exist"}]}');
        }
        var locations = require(fileName);
        res.json(locations[currentChildCount]);
        ++currentChildCount;
        if (currentChildCount >= locations.length) {
            currentChildCount = 0;
        }
    }
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/clients/isRegistered/:deviceId', function(req, res) {
    logger.info("Get isRegistered request from: " + req.ip + " params " + util.inspect(req.params));
    var deviceId = req.params.deviceId.replace(/:/g, "");
    if (deviceId === undefined) {
        logger.error("Get isRegistered request missing all required parameters");
        return res.send(401, '"error": {"code": 401,"message": "Get isRegistered request missing all required parameters", "errors": [{"domain": "isRegistered", "reason": "AuthenticationFailure", "message": "Get isRegistered request missing all required parameters"}]}');
    } 
    if (!isDeviceRegistered) {
        logger.info("Get isRegistered device ID does not exist");
        return res.send(200, '{"isRegistered":"false"}');
    }
    return res.send(200, '{"isRegistered":"true"}');
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/banners/info/:venueId/:floorId/:zoneId', function(req, res) {
    logger.info("Get all banner information request from: " + req.ip + " params: " + util.inspect(req.params));
    var venueId = req.params.venueId;
    var floorId = req.params.floorId;
    var zoneId = req.params.zoneId;
    if (venueId === undefined || floorId === undefined || zoneId === undefined) {
        logger.error("Get banner information is missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get banner information is missing all required parameters", "errors": [{"domain": "Banners", "reason": "MissingParameters", "message": "Get banner information is missing all required parameters"}]}');
    }
    var fileName = "./config/banners/" + venueId + "/" + zoneId + ".json";
    if (!fs.existsSync(fileName)) {
        logger.error("Get all banner information does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get all banner information does not exist", "errors": [{"domain": "Banners", "reason": "ResourceNotFound", "message": "Get all banner information does not exist"}]}');
    }
    var bannersResult = require(fileName);
    for (var n = 0; n < bannersResult.length; ++n) {
        bannersResult[n].url = "https://" + req.host + req.path.substr(0, req.path.indexOf("info")) + "image/" + venueId + "/" + floorId + "/" + zoneId + "/" + bannersResult[n].id;
    }
    return res.json(bannersResult);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/banners/image/:venueId/:floorId/:zoneId/:imageId', function(req, res) {
    logger.info("Get banner image request from: " + req.ip + " params: " + util.inspect(req.params));
    var venueId = req.params.venueId;
    var floorId = req.params.floorId;
    var zoneId = req.params.zoneId;
    var imageId = req.params.imageId;
    if (venueId === undefined || floorId === undefined || zoneId === undefined || imageId === undefined) {
        logger.error("Get banner image is missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get banner image is missing all required parameters", "errors": [{"domain": "Banners", "reason": "MissingParameters", "message": "Get banner image is missing all required parameters"}]}');
    }
    var baseFileName = "./config/banners/" + venueId + "/" + zoneId + "-" + imageId;
    var fileName = baseFileName + ".gif";
    if (!fs.existsSync(fileName)) {
        fileName = baseFileName + ".png";
        if (!fs.existsSync(fileName)) {
            fileName = baseFileName + ".svg";
            if (!fs.existsSync(fileName)) {
                logger.error("Get banner image does not exist");
                return res.send(404, '"error": {"code": 404,"message": "Get banner image does not exist", "errors": [{"domain": "Banners", "reason": "ResourceNotFound", "message": "Get banner image does not exist"}]}');
            }
        }
    }
    return res.sendfile(fileName);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/pois/info/:venueId/:floorId', function(req, res) {
    logger.info("Get all points of interest request from: " + req.ip + " params: " + util.inspect(req.params));
    var venueId = req.params.venueId;
    var floorId = req.params.floorId;
    if (venueId === undefined || floorId === undefined) {
        logger.error("Get points of interest is missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get points of interest is missing all required parameters", "errors": [{"domain": "POIs", "reason": "MissingParameters", "message": "Get points of interest is missing all required parameters"}]}');
    }
    var fileName = "./config/pois/" + venueId + "/" + floorId + ".json";
    if (!fs.existsSync(fileName)) {
        logger.error("Get all points of interest for floor ID does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get all points of interest for floor ID does not exist", "errors": [{"domain": "POIs", "reason": "ResourceNotFound", "message": "Get all points of interest for floor ID does not exist"}]}');
    }
    var poisResult = require(fileName);
    return res.json(poisResult);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/pois/info/:venueId', function(req, res) {
    logger.info("Get points of interest request from: " + req.ip + " params: " + util.inspect(req.params));
    logger.info("Get points of interest request from: " + req.ip + " queries: " + util.inspect(req.query));
    var venueId = req.params.venueId;
    if (venueId === undefined) {
        logger.error("Get points of interest search is missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get points of interest search is missing all required parameters", "errors": [{"domain": "POIs", "reason": "MissingParameters", "message": "Get points of interest search is missing all required parameters"}]}');
    }
    var directoryName = "./config/pois/" + venueId + "/";
    if (!fs.existsSync(directoryName)) {
        logger.error("Get points of interest venue ID search does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get points of interest venue ID search does not exist", "errors": [{"domain": "POIs", "reason": "ResourceNotFound", "message": "Get points of interest search does not exist"}]}');
    }
    var directoryFiles = fs.readdirSync(directoryName);
    var searchResults = [];
    var searchFoundCount = 0;
    var search = req.query['search'];
    if (search !== undefined) {
        search = req.query['search'].toLowerCase();
    }
    for (var i in directoryFiles) {
        if (directoryFiles[i].match(".json$")) {
            var poisFloor = require(directoryName + directoryFiles[i]);
            for (var n = 0; n < poisFloor.length; ++n) {
                if (search === undefined) {
                    searchResults[searchFoundCount] = poisFloor[n];
                    ++searchFoundCount;
                } else {
                    if (poisFloor[n].name.toLowerCase().indexOf(search) > -1) {
                        searchResults[searchFoundCount] = poisFloor[n];
                        ++searchFoundCount;
                        logger.info("Match found for search: " + search + " is: " + poisFloor[n].name);
                    }
                }
            }
        }
    }
    if (searchFoundCount === 0) {
        logger.error("Get points of interest search does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get points of interest search does not exist", "errors": [{"domain": "POIs", "reason": "ResourceNotFound", "message": "Get points of interest search does not exist"}]}');
    }
    return res.json(searchResults);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/pois/image/:venueId/:poiId', function(req, res) {
    logger.info("Get points of interest image request from: " + req.ip + " params: " + util.inspect(req.params));
    var venueId = req.params.venueId;
    var poiId = req.params.poiId;
    if (venueId === undefined || poiId === undefined) {
        logger.error("Get points of interest image missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get points of interest image missing all required parameters", "errors": [{"domain": "POIs", "reason": "MissingParameters", "message": "Get points of interest image missing all required parameters"}]}');
    }
    var directoryName = "./config/pois/" + venueId + "/";
    if (!fs.existsSync(directoryName)) {
        logger.error("Get points of interest image does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get points of interest image venue does not exist", "errors": [{"domain": "POIs", "reason": "ResourceNotFound", "message": "Get points of interest image venue does not exist"}]}');
    }
    var directoryFiles = fs.readdirSync(directoryName);
    var searchResults = "";
    var searchFound = false;
    for (var i in directoryFiles) {
        if (directoryFiles[i].match(".json$")) {
            var poisFloor = require(directoryName + directoryFiles[i]);
            for (var n = 0; n < poisFloor.length; ++n) {
                if (poisFloor[n].id.indexOf(poiId) > -1) {
                    searchResults = poisFloor[n].imageId;
                    searchFound = true;
                    logger.info("Match found for search: " + poiId + " is: " + poisFloor[n].name);
                    break;
                }
            }
            if (searchFound) {
                break;
            }
        }
    }
    if (!searchFound) {
        logger.error("Get points of interest image does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get points of interest image does not exist", "errors": [{"domain": "POIs", "reason": "ResourceNotFound", "message": "Get points of interest image does not exist"}]}');
    }
    var baseFileName = "./config/pois/" + venueId + "/" + searchResults;
    var fileName = baseFileName + ".gif";
    if (!fs.existsSync(fileName)) {
        fileName = baseFileName + ".png";
        if (!fs.existsSync(fileName)) {
            fileName = baseFileName + ".svg";
            if (!fs.existsSync(fileName)) {
                logger.error("Get points of interest image does not exist");
                return res.send(404, '"error": {"code": 404,"message": "Get points of interest image does not exist", "errors": [{"domain": "POIs", "reason": "ResourceNotFound", "message": "Get points of interest image does not exist"}]}');
            }
        }
    }
    return res.sendfile(fileName);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/pois/imageid/:venueId/:imageId', function(req, res) {
    logger.info("Get points of interest image by ID request from: " + req.ip + " params: " + util.inspect(req.params));
    var venueId = req.params.venueId;
    var imageId = req.params.imageId;
    if (venueId === undefined || imageId === undefined) {
        logger.error("Get points of interest image by ID missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get points of interest image by ID missing all required parameters", "errors": [{"domain": "POIs", "reason": "MissingParameters", "message": "Get points of interest image by ID missing all required parameters"}]}');
    }
    var baseFileName = "./config/pois/" + venueId + "/" + imageId;
    var fileName = baseFileName + ".gif";
    if (!fs.existsSync(fileName)) {
        fileName = baseFileName + ".png";
        if (!fs.existsSync(fileName)) {
            fileName = baseFileName + ".svg";
            if (!fs.existsSync(fileName)) {
                logger.error("Get points of interest image does not exist");
                return res.send(404, '"error": {"code": 404,"message": "Get points of interest image by ID does not exist", "errors": [{"domain": "POIs", "reason": "ResourceNotFound", "message": "Get points of interest image by ID does not exist"}]}');
            }
        }
    }
    return res.sendfile(fileName);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/routes/clients/:deviceId', function(req, res) {
    logger.info("Get route for client request from: " + req.ip + " params: " + util.inspect(req.params));
    logger.info("Get route for client request from: " + req.ip + " queries: " + util.inspect(req.query));
    if (req.cookies === undefined || req.cookies.cmxMobileApplicationCookie === undefined) {
        logger.error("The cookie cmxMobileApplicationCookie for authentication is not defined");
        return res.send(401, '"error": {"code": 401,"message": "The cookie cmxMobileApplicationCookie for authentication is not defined", "errors": [{"domain": "Routes", "reason": "AuthenticationFailure", "message": "The cookie cmxMobileApplicationCookie for authentication is not defined"}]}');
    } else if (req.cookies.cmxMobileApplicationCookie.indexOf('randomCookiePassword') < 0) {
        logger.error("The cookie cmxMobileApplicationCookie does not match the expected cookie");
        return res.send(401, '"error": {"code": 401,"message": "The cookie cmxMobileApplicationCookie does not match the expected cookie", "errors": [{"domain": "Routes", "reason": "AuthenticationFailure", "message": "The cookie cmxMobileApplicationCookie does not match the expected cookie"}]}');
    }
    var deviceId = req.params.deviceId.replace(/:/g, "");
    if (deviceId === undefined) {
        logger.error("Get route for client request missing all required parameters");
        return res.send(401, '"error": {"code": 401,"message": "Get route for client destination request missing all required queries", "errors": [{"domain": "Routes", "reason": "AuthenticationFailure", "message": "Get route for client destination request missing all required queries"}]}');
    }
    var registeredFileName = "./config/registered/" + deviceId + ".json";
    if (!fs.existsSync(registeredFileName)) {
        logger.error("Get location device ID is not registered");
        return res.send(404, '"error": {"code": 401,"message": "Get location device ID is not registered", "errors": [{"domain": "Location", "reason": "AuthenticationFailure", "message": "Get location device ID is not registered"}]}');
    }
    var registeredFileData = fs.readFileSync(registeredFileName);
    var registeredData = JSON.parse(registeredFileData);
    var destpoi = req.query['destpoi'];
    if (destpoi === undefined) {
        var destx = req.query['destx'];
        var desty = req.query['desty'];
        if (destx === undefined || desty === undefined) {
            logger.error("Get route for client destination request missing all required queries");
            return res.send(401, '"error": {"code": 401,"message": "Get route for client destination request missing all required queries", "errors": [{"domain": "Routes", "reason": "AuthenticationFailure", "message": "Get route for client destination request missing all required queries"}]}');
        }
        var destFileName = "./config/routes/" + registeredData.simulatedDeviceId + "/" + destx + "_" + desty + ".json";
        if (!fs.existsSync(destFileName)) {
            logger.error("Get route for destination does not exist: " + registeredData.simulatedDeviceId);
            return res.send(401, '"error": {"code": 401,"message": "Get route for destination does not exist", "errors": [{"domain": "Routes", "reason": "AuthenticationFailure", "message": "Get route for destination does not exist"}]}');
        }
        var destNavigationPath = require(destFileName);
        var destNavigationLocationFileName = "./config/location/" + registeredData.simulatedDeviceId + ".json";
        if (!fs.existsSync(destNavigationLocationFileName)) {
            logger.error("Get location device ID does not exist: " + registeredData.simulatedDeviceId);
            return res.send(404, '"error": {"code": 404,"message": "Get location device ID does not exist", "errors": [{"domain": "Location", "reason": "ResourceNotFound", "message": "Get location device ID does not exist"}]}');
        }
        var destNavigationLocations = require(destNavigationLocationFileName);
        var destNavigationCurrentLocation = destNavigationLocations[currentChildCount];
        var destNavigationNearestDistance = 10000;
        var destNavigationNearestPosition = 0;
        var currentDest = {};
        currentDest.x = destNavigationCurrentLocation.mapCoordinate.x;
        currentDest.y = destNavigationCurrentLocation.mapCoordinate.y;
        for (var n = 0; n < destNavigationPath.length; ++n) {
            logger.debug("Destination X: " + destNavigationPath[n].x + " Y: " + destNavigationPath[n].y);
            logger.debug("Current X: " + destNavigationCurrentLocation.mapCoordinate.x + " Y: " + destNavigationCurrentLocation.mapCoordinate.y);
            var distance = Math.abs(destNavigationPath[n].x - destNavigationCurrentLocation.mapCoordinate.x) + Math.abs(destNavigationPath[n].y - destNavigationCurrentLocation.mapCoordinate.y);
            if (distance < destNavigationNearestDistance) {
                logger.debug("Found splice position for destination X: " + destNavigationPath[n].x + " Y: " + destNavigationPath[n].y);
                destNavigationNearestDistance = distance;
                destNavigationNearestPosition = n + 1;
            }
        }
        destNavigationPath.splice(0, destNavigationNearestPosition, currentDest);
        return res.json(destNavigationPath);
    }
    var destPoiFileName = "./config/routes/" + registeredData.simulatedDeviceId + "/" + destpoi + ".json";
    if (!fs.existsSync(destPoiFileName)) {
        logger.error("Get route for destination POI does not exist: " + registeredData.simulatedDeviceId);
        return res.send(404, '"error": {"code": 404,"message": "Get route for destination POI does not exist", "errors": [{"domain": "Routes", "reason": "ResourceNotFound", "message": "Get route for destination POI does not exist"}]}');
    }
    var destPoiNavigationPath = require(destPoiFileName);
    var destPoiNavigationLocationFileName = "./config/location/" + registeredData.simulatedDeviceId + ".json";
    if (!fs.existsSync(destPoiNavigationLocationFileName)) {
        logger.error("Get location device ID does not exist: " + registeredData.simulatedDeviceId);
        return res.send(404, '"error": {"code": 404,"message": "Get location device ID does not exist", "errors": [{"domain": "Location", "reason": "ResourceNotFound", "message": "Get location device ID does not exist"}]}');
    }
    var destPoiNavigationLocations = require(destPoiNavigationLocationFileName);
    var destPoiNavigationCurrentLocation = destPoiNavigationLocations[currentChildCount];
    var destPoiNavigationNearestDistance = 10000;
    var destPoiNavigationNearestPosition = 0;
    var currentDestPoi = {};
    currentDestPoi.x = destPoiNavigationCurrentLocation.mapCoordinate.x;
    currentDestPoi.y = destPoiNavigationCurrentLocation.mapCoordinate.y;
    for (var o = 0; o < destPoiNavigationPath.length; ++o) {
        logger.debug("Destination X: " + destPoiNavigationPath[o].x + " Y: " + destPoiNavigationPath[o].y);
        logger.debug("Current X: " + destPoiNavigationCurrentLocation.mapCoordinate.x + " Y: " + destPoiNavigationCurrentLocation.mapCoordinate.y);
        var distancePoi = Math.abs(destPoiNavigationPath[o].x - destPoiNavigationCurrentLocation.mapCoordinate.x) + Math.abs(destPoiNavigationPath[o].y - destPoiNavigationCurrentLocation.mapCoordinate.y);
        if (distancePoi < destPoiNavigationNearestDistance) {
            logger.debug("Found splice position for destination X: " + destPoiNavigationPath[o].x + " Y: " + destPoiNavigationPath[o].y);
            destPoiNavigationNearestDistance = distancePoi;
            destPoiNavigationNearestPosition = o + 1;
        }
    }
    destPoiNavigationPath.splice(0, destPoiNavigationNearestPosition, currentDestPoi);
    return res.json(destPoiNavigationPath);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/maps/info/:venueId', function(req, res) {
    logger.info("Get map info request from: " + req.ip + " params: " + util.inspect(req.params));
    var venueId = req.params.venueId;
    if (venueId === undefined) {
        logger.error("Get map info missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get map info missing all required parameters", "errors": [{"domain": "Maps", "reason": "MissingParameters", "message": "Get map info missing all required parameters"}]}');
    }
    var directoryName = "./config/maps/" + venueId + "/";
    if (!fs.existsSync(directoryName)) {
        logger.error("Get map info venue ID search does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get map info venue ID search does not exist", "errors": [{"domain": "POIs", "reason": "ResourceNotFound", "message": "Get map info search does not exist"}]}');
    }
    var directoryFiles = fs.readdirSync(directoryName);
    var mapInfo = [];
    var mapInfoCount = 0;
    for (var i in directoryFiles) {
        if (directoryFiles[i].match(".json$")) {
            var mapFloorInfo = require(directoryName + directoryFiles[i]);
            mapInfo[mapInfoCount] = mapFloorInfo;
            ++mapInfoCount;
            logger.info("Map info found for : " + mapFloorInfo.mapHierarchyString);
        }
    }
    if (mapInfoCount === 0) {
        logger.error("Get map info does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get map info does not exist", "errors": [{"domain": "POIs", "reason": "ResourceNotFound", "message": "Get map info does not exist"}]}');
    }
    return res.json(mapInfo);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/maps/info/:venueId/:floorId', function(req, res) {
    logger.info("Get map info request from: " + req.ip + " params: " + util.inspect(req.params));
    var venueId = req.params.venueId;
    var floorId = req.params.floorId;
    if (venueId === undefined || floorId === undefined) {
        logger.error("Get map info missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get map info missing all required parameters", "errors": [{"domain": "Maps", "reason": "MissingParameters", "message": "Get map info missing all required parameters"}]}');
    }
    var fileName = "./config/maps/" + venueId + "/" + floorId + ".json";
    if (!fs.existsSync(fileName)) {
        logger.error("Get map info does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get map info does not exist", "errors": [{"domain": "Maps", "reason": "ResourceNotFound", "message": "Get map info does not exist"}]}');
    }
    var mapinfo = require(fileName);
    return res.json(mapinfo);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/maps/image/:venueId/:floorId', function(req, res) {
    logger.info("Get map image request from: " + req.ip + " params: " + util.inspect(req.params));
    var venueId = req.params.venueId;
    var floorId = req.params.floorId;
    if (venueId === undefined || floorId === undefined) {
        logger.error("Get map image missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Get map image missing all required parameters", "errors": [{"domain": "Maps", "reason": "MissingParameters", "message": "Get map image missing all required parameters"}]}');
    } 
    var fileName = "./config/maps/" + venueId + "/" + floorId + ".gif";
    if (!fs.existsSync(fileName)) {
        logger.error("Get map image does not exist");
        return res.send(404, '"error": {"code": 404,"message": "Get map image does not exist", "errors": [{"domain": "Maps", "reason": "ResourceNotFound", "message": "Get map image does not exist"}]}');
    }
    return res.sendfile(fileName);
});

mobileAppServer.post(webApp+'/api/cmxmobile/v1/location/update/:deviceId', function(req, res) {
    logger.info("Post location update request from: " + req.ip + " params: " + util.inspect(req.params));
    logger.debug("Post location imageupdate request from: " + req.ip + " body: " + util.inspect(req.body));
    var locationFileName = "./config/registered/location_" + req.params.deviceId + ".json";
    var locationInfo = req.body;
    var venueId = locationInfo.venueId;
    var floorId = locationInfo.floorId;
    if (venueId === undefined || floorId === undefined) {
        logger.error("Location update missing all required parameters");
        return res.send(500, '"error": {"code": 500,"message": "Location update missing all required parameters", "errors": [{"domain": "Location", "reason": "MissingParameters", "message": "Location update missing all required parameters"}]}');
    }
    var fileName = "./config/zones/" + venueId + "/" + floorId + ".json";
    if (!fs.existsSync(fileName)) {
        logger.error("Location update zones do not exist");
        return res.send(404, '"error": {"code": 404,"message": "Location update zones do not exist", "errors": [{"domain": "Location", "reason": "ResourceNotFound", "message": "Location update zones do not exist"}]}');
    }
    var zonesInfo = require(fileName);
    var searchFound = false;
    logger.info("Location [x: " + locationInfo.mapCoordinate.x + ", y: " + locationInfo.mapCoordinate.x + " ]");
    for (var n = 0; n < zonesInfo.length; ++n) {
        logger.info("Checking zone " + util.inspect(zonesInfo[n].zonePoints));
        if (pointInPolygon([locationInfo.mapCoordinate.x, locationInfo.mapCoordinate.y], zonesInfo[n].zonePoints)) {
            locationInfo.zoneId = zonesInfo[n].zoneId;
            locationInfo.zoneName = zonesInfo[n].zoneName;
            searchFound = true;
            logger.info("Match found for zone: " + locationInfo.zoneName);
            break;
        }
    }
    if (!searchFound) {
        locationInfo.zoneId = "0000";
        locationInfo.zoneName = "";
    }
    
    var jsonData = util.inspect(locationInfo);
    jsonData = jsonData.replace(/'/g, '"');
    jsonData = jsonData.replace(/:/g, '":');
    jsonData = jsonData.replace(/,[^a-z]*/g, ',"');
    jsonData = jsonData.replace(/{[^a-z]*/g, '{"');
    var outputFile = fs.openSync(locationFileName, 'w');
    fs.writeSync(outputFile, jsonData);
    fs.closeSync(outputFile);
});

mobileAppServer.get('/demo/start', function(req, res) {
    logger.info("Get start demo page from: " + req.ip);
    var directoryName = "./config/registered/";
    var directoryFiles = fs.readdirSync(directoryName);
    var body = fs.readFileSync("./config/html/demoStart.html", "utf8");
    var tableRows = "";
    for (var i in directoryFiles) {
        if (directoryFiles[i].match(".json$") && !directoryFiles[i].match("^location")) {
            var data = fs.readFileSync(directoryName + directoryFiles[i]);
            var deviceRegistrationInfo = JSON.parse(data);
            tableRows += '<tr>';
            tableRows += '<td><a href="'+webApp+'/api/cmxmobile/v1/demo/maps/'+deviceRegistrationInfo.deviceId+'">'+deviceRegistrationInfo.ipAddress+'</a></td>';
            tableRows += '<td><a href="'+webApp+'/api/cmxmobile/v1/demo/maps/'+deviceRegistrationInfo.deviceId+'">'+deviceRegistrationInfo.macAddress+'</a></td>';
            tableRows += '<td><a href="'+webApp+'/api/cmxmobile/v1/demo/maps/'+deviceRegistrationInfo.deviceId+'">'+deviceRegistrationInfo.registrationTime+'</a></td>';
            tableRows += '</tr>';
        }
    }
    body = body.replace(/%CMX_INSERT_TABLE_ROWS%/g, tableRows);
    body = body.replace(/%CMX_WEB_APP%/g, webApp);
    res.setHeader('Content-Type', 'text/html');
    res.send(200, body);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/demo/maps/:deviceId', function(req, res) {
    logger.info("Get maps for demo page for: " + req.ip + " params: " + util.inspect(req.params));
    var directoryName = "./config/maps/";
    var directoryFiles = fs.readdirSync(directoryName);
    var body = fs.readFileSync("./config/html/allFloors.html", "utf8");
    var tableRows = "";
    for (var i in directoryFiles) {
        var jsonFiles = fs.readdirSync(directoryName + directoryFiles[i]);
        for (var j in jsonFiles) {
            if (jsonFiles[j].match(".json$")) {
                var singleVenueInfo = require(directoryName + directoryFiles[i] + "/" + jsonFiles[j]);
                tableRows += '<tr><td><a href="'+webApp+'/api/cmxmobile/v1/demo/floor/'+ req.params.deviceId + '/' + singleVenueInfo.venueid+'/'+ singleVenueInfo.floorId+'?name='+ singleVenueInfo.name+'&dimWidth='+ singleVenueInfo.demo.width+'&dimLength='+ singleVenueInfo.demo.length+'&dimOffsetRatio='+ singleVenueInfo.demo.offsetRatio+'">'+singleVenueInfo.mapHierarchyString+'</a></td><td><a href="'+webApp+'/api/cmxmobile/v1/demo/floor/'+ req.params.deviceId + '/' + singleVenueInfo.venueid+'/'+ singleVenueInfo.floorId+'?name='+ singleVenueInfo.name+'&dimWidth='+ singleVenueInfo.demo.width+'&dimLength='+ singleVenueInfo.demo.length+'&dimOffsetRatio='+ singleVenueInfo.demo.offsetRatio+'"><img src="'+webApp+'/api/cmxmobile/v1/maps/image/'+singleVenueInfo.venueid+'/'+ singleVenueInfo.floorId+'" height="100" width="100"></a></td></tr>';
            }
        }
    }
    body = body.replace(/%CMX_INSERT_TABLE_ROWS%/g, tableRows);
    body = body.replace(/%CMX_WEB_APP%/g, webApp);
    res.setHeader('Content-Type', 'text/html');
    res.send(200, body);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/demo/floor/:deviceId/:venueId/:floorId', function(req, res) {
    logger.info("Get floor page for: " + req.ip + " params: " + util.inspect(req.params));
    var body = fs.readFileSync("./config/html/floor.html", "utf8");
    var dimWidth = req.query['dimWidth'];
    var dimLength = req.query['dimLength'];
    var dimOffsetRatio = req.query['dimOffsetRatio'];
    var floorName = req.query['name'];
    body = body.replace(/%CMX_DEVICE_ID%/g, req.params.deviceId);
    body = body.replace(/%CMX_VENUE_ID%/g, req.params.venueId);
    body = body.replace(/%CMX_FLOOR_ID%/g, req.params.floorId);
    body = body.replace('%CMX_MAP_WIDTH%', dimWidth);
    body = body.replace('%CMX_MAP_LENGTH%', dimLength);
    body = body.replace(/%CMX_OFFSET_RATIO%/g, dimOffsetRatio);
    body = body.replace(/%CMX_DEFAULT_PUSH_NOTIFICATION_MESSAGE%/g, 'Welcome to ' + floorName);
    body = body.replace(/%CMX_WEB_APP%/g, webApp);
    res.setHeader('Content-Type', 'text/html');
    res.send(200, body);
});

mobileAppServer.get(webApp+'/api/cmxmobile/v1/demo/image/:image', function(req, res) {
    res.sendfile("./config/html/" + req.params.image);
});

https.createServer(options, mobileAppServer).listen(8082);
logger.info("CMX Mobile App Server new registered device ID will be: " + simulatedDeviceIdentifier);
logger.info("CMX Mobile App Server Version: " + pkg.version + " listening on HTTPS port 8082");