// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
var twilio = require("twilio")("AC6ca747980db1123b20a10728c7ad86ec", "66f9051ed1a7de979de273144270c3a0");
// var twilio = require("twilio")("AC5ef092330a8de90da0aeb8543d8f2d44", "77a12e7d5855fb0c1cc02b61d4ed59b5");

//var twilio = require('twilio');
//twilio.initialize("AC5ef092330a8de90da0aeb8543d8f2d44","77a12e7d5855fb0c1cc02b61d4ed59b5");

Parse.Cloud.define("sendVerificationCode", function(request, response) {
                   if (request.params.phoneNumber == "+10000000000") {
                   response.success("Demo Login");
                   return;
                   }
                   
                   var verificationCode = Math.floor(Math.random()*999999);
                   var user = Parse.User.current();
                   user.set("phoneVerificationCode", verificationCode);
                   user.save();
                   
                   twilio.sendSms({
                                  From: "+12242203703",
                                  To: request.params.phoneNumber,
                                  Body: "Code: " + verificationCode
                                  }, function(err, responseData) {
                                  if (err) {
                                  response.error(err);
                                  } else {
                                  response.success("Success");
                                  }
                                  });
                   });

Parse.Cloud.define("verifyPhoneNumber", function(request, response) {
                   var user = Parse.User.current();
                   var verificationCode = user.get("phoneVerificationCode");
                   if (verificationCode == request.params.phoneVerificationCode) {
                   user.set("phoneNumber", request.params.phoneNumber);
                   user.set("isVerified", 1);
                   user.save();
                   response.success("Success");
                   } else {
                   response.error("Invalid verification code.");
                   }
                   });