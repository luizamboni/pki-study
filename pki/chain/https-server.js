const https = require('https');
const fs = require('fs');


const options = {
  key:  fs.readFileSync('../certs/certificates/peer-key.pem'),
  cert: fs.readFileSync('../certs/certificates/peer.pem'),
  ca:  fs.readFileSync('../certs/bundle.pem')
};

https.createServer(options, (req, res) => {

  console.log(req.rawHeaders)
  res.writeHead(200);
  res.end('hello world\n');

}).listen(8000, () => {
  console.log("listening https in port 8000")
});

