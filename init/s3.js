var AWS, promise, s3;

promise = require("fairmont").promise;

AWS = require("aws-sdk");

s3 = new AWS.S3;

module.exports = function(bucketName) {
  var get, put;
  get = function(key) {
    return promise(function(resolve, reject) {
      return s3.getObject({
        Bucket: bucketName,
        Key: key
      }, function(error, data) {
        if (error == null) {
          return resolve(data.Body);
        } else {
          return reject(error);
        }
      });
    });
  };
  put = function(key, value) {
    return promise(function(resolve, reject) {
      return s3.putObject({
        Bucket: bucketName,
        Key: key,
        Body: value
      }, function(error, data) {
        if (error == null) {
          return resolve(null);
        } else {
          return reject(error);
        }
      });
    });
  };
  return {
    get: get,
    put: put
  };
};
