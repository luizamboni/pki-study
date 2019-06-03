const https = require('https');
const fs = require('fs');


const options = {
  key:  fs.readFileSync('./certs/certificates/peer-key.pem'),
  cert: fs.readFileSync('./certs/certificates/peer.pem'),

  ca:  fs.readFileSync('./certs/bundle.pem'),
  /*
  * make request Client certificate
  */
  requestCert: true,
  /*
  * not automatic reject unauthorized request
  * becouse we need use this information in endpoint
  */
  rejectUnauthorized: false,
};

const server = https.createServer(options, (req, res) => {

  const cert = req.connection.getPeerCertificate()
  console.log("authorized:", req.client.authorized)
  console.log("certificate:", cert)

  if(req.client.authorized) {
    // console.log(req.rawHeaders)
    res.writeHead(200);
    res.end('hello world\n');
  } else {
    // console.log(req.rawHeaders)
    res.writeHead(401);
    res.end('by world\n');
  }

}).listen(8000, () => {
  console.log("listening https in port 8000")
});

server.on("tlsClientError", err => {
  console.error(err.message)
})


