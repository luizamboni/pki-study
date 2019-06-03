const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('./certs/exerciciosresolvidos.key'),
  cert: fs.readFileSync('./certs/exerciciosresolvidos.crt'),
};

https.createServer(options, (req, res) => {

  res.writeHead(200);
  res.end('hello world\n');

}).listen(8000, () => {
  console.log("listening https in port 8000")
});