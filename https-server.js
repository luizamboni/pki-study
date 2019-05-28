const https = require('https');
const fs = require('fs');


const getCertificate = () => {
  if (fs.existsSync("./pki/exerciciosresolvidos.net.crt")) {
    return fs.readFileSync('./pki/exerciciosresolvidos.net.crt');
  } else {
    return fs.readFileSync('./pki/exerciciosresolvidos.pem');
  }
}

const getPrivateKey = () => {

  if (fs.existsSync('./pki/exerciciosresolvidos.net.key')) {
    return fs.readFileSync('./pki/exerciciosresolvidos.net.key');
  } else {
    return fs.readFileSync('./pki/exerciciosresolvidos-key.pem');
  }
}


const options = {
  key: getPrivateKey(),
  cert: getCertificate(),
};

https.createServer(options, (req, res) => {

  console.log(req.rawHeaders)
  res.writeHead(200);
  res.end('hello world\n');

}).listen(8000, () => {
  console.log("listening https in port 8000")
});