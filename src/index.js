// var http = require('http');

// //create a server object:
// http.createServer(function (req, res) {
//   res.write('A Monk in Cloud'); //write a response to the client
//   res.end(); //end the response
// }).listen(80); //the server object listens on port 80


var http = require('http');

const PORT = process.env.PORT || 3000;

http.createServer(function (req, res) {
  res.write('A Monk in Cloud');
  res.end();
}).listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
