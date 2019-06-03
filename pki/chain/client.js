const https = require('https');
const fs = require("fs");

const ca = fs.readFileSync('./certs/bundle.pem');
const key = fs.readFileSync("./certs/certificates/peer-key.pem");
const cert = fs.readFileSync("./certs/certificates/peer.pem");
// console.log(ca);

const options = {
  port: 8000,
  hostname: "localhost",
  ca,
  key,
  cert,
}


const req = https.get(options, res => {

  res.on("data", data => {
    console.log(data.toString())
  })
})

req.end();
