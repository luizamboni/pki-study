Certificado raiz e autoassinado(root & selfsigned) em nodejs
===

# Conteúdo
 - [Usando openssl](#usando-openssl)
 - [Usando cfssl](#usando-cfssl)
 - [Aplicação Exemplo](#aplicação-exemplo)
 - Formatos
 
# Usando openssl

1) Criar uma chave privada para o seu domínio

```bash
$ openssl genrsa -out pki/exerciciosresolvidos.net.key 2048
```

2) Extrair a chave pública da chave privada

```bash
$ openssl rsa -in pki/exerciciosresolvidos.net.key -pubout -out pki/exerciciosresolvidos.public.net.key
```

3) Constuir um crs (Certificate sign request), ou seja um pedido para assinatura de certificado,
para isso é fornecida a chave privada (de onde será extraída a chave pública) e diversas informações 
sobre o host etc
```bash
$ openssl req -new -key pki/exerciciosresolvidos.net.key -out pki/exerciciosresolvidos.net.csr
```

4) Verificar csr
```bash
$ openssl req -text -in pki/exerciciosresolvidos.net.csr -noout -verify
```

5) autoassinar (sem CA)
```bash
$ openssl x509 -req -days 365 -in pki/exerciciosresolvidos.net.csr -signkey pki/exerciciosresolvidos.net.key -out pki/exerciciosresolvidos.net.crt
```

ver o arquivo [openssl.sh](openssl.sh)


# Usando cfssl 
(cloudfront ssl)





# Aplicação exemplo
Adicionar a aplicação nodejs (escolhida aqui simplicidade para ser o mais didático possível)

```javascript
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('exerciciosresolvidos.net.key'),
  cert: fs.readFileSync('exerciciosresolvidos.net.crt'),
};

https.createServer(options, (req, res) => {
  res.writeHead(200);
  res.end('hello world\n');
}).listen(8000);
```

ver o arquivo [https-server.js](https-server.js)



# Arquivos e extensões

## formato <b>PEM</b>
  - São arquivos ACII codificados Base64
  - Eles possuem extensões como .pem, .crt, .cer, .key
  - Servidores Apache e similares usam certificados de formato PEM

## formato <b>DER</b>
  - São arquivos em formato binário
  - Eles possuem extensões .cer & .der
  - DER normalmente é usado na plataforma Java

# Referências

https://www.digicert.com/ssl-support/openssl-quick-reference-guide.htm

https://ajudadoprogramador.com.br/artigo/certificado-auto-assinado-no-linux

https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR