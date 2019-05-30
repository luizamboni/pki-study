Certificado raiz e autoassinado(root & selfsigned) em nodejs
===

# Conteúdo
 - [Usando openssl](#usando-openssl)
 - [Usando cfssl](#usando-cfssl)
 - [Aplicação Exemplo](#aplicação-exemplo)
 - Formatos
 
# Usando openssl

### 1) Criar uma chave privada para o seu domínio

```bash
$ openssl genrsa -out exerciciosresolvidos.net.key 2048
```

### 2) Extrair a chave pública da chave privada

```bash
$ openssl rsa -in exerciciosresolvidos.net.key -pubout -out exerciciosresolvidos.public.net.key
```

### 3) Constuir um crs (Certificate sign request), ou seja um pedido para assinatura de certificado,
para isso é fornecida a chave privada (de onde será extraída a chave pública) e diversas informações 
sobre o host etc
```bash
$ openssl req -new -key exerciciosresolvidos.net.key -out exerciciosresolvidos.net.csr
```

### 4) Verificar csr
```bash
$ openssl req -text -in exerciciosresolvidos.net.csr -noout -verify
```

### 5) autoassinar (sem CA)
```bash
$ openssl x509 -req -days 365 -in exerciciosresolvidos.net.csr -signkey exerciciosresolvidos.net.key -out exerciciosresolvidos.net.crt
```

ver o arquivo [openssl.sh](openssl.sh)


# Usando cfssl 
cfssl (cloudfront ssl) é um wrapper para o openssl desenvolvidos pelo cloudFront que simplifica muitas tarefas cotidianas no gerenciamente de certificados, ele também possui uma api http+json.
O cfssl trabalha com inputs em formato json (sua api http recebe exatamente este mesmo input) 
diferente do openssl que trabalha com um formato proprio ou requer interação.

### 1) é necessário ter um arquivo de configuração,
nele já são informados todos os campos necessários ao certificado (names)
bem como a maneira como a chave privada será gerada (key)
e também a duração do mesmo

Então aí estão os <b>3 componentes</b> da chave:
  - informações
  - chave privada
  - expiração

```bash
$ cat > config.json <<EOF
{
   "hosts": [
      "localhost",
      "www.example.com"
   ],
   "CN": "localhost",
   "key": {
      "algo": "rsa",
      "size": 2048
   },
   "names": [
      {
         "C": "BR",
         "L": "Rio de Janeiro",
         "O": "zamba",
         "OU": "exerciciosresolvidos site 1"
      }
   ],
   "ca": {
      "expiry": "262800h"
   }
}
EOF
```

### 2) Com este comando são gerados 3 arquivos.

```bash
cfssl selfsign localhost config.json | cfssljson -bare exerciciosresolvidos
```



Este comando pode ser dividido em 2 partes,
A primeira dá saída em um json com 3 campos (key, cert e csr) e a segundo transforma esta saída em 3 arquivos,

<b>exerciciosresolvidos-ca.pem</b> para o campo <b>key</b>(chave privada)

<b>exerciciosresolviros.csr</b>   para o campo <b>csr</b>

<b>exerciciosresolvidos.pem</b> para o campo <b>cert</b>


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

## sinopse


### formato <b>PEM</b>
  - São arquivos ACII codificados Base64
  - Eles possuem extensões como .pem, .crt, .cer, .key
  - Servidores Apache e similares usam certificados de formato PEM

### formato <b>DER</b>
  - São arquivos em formato binário
  - Eles possuem extensões .cer & .der
  - DER normalmente é usado na plataforma Java

# Referências

https://www.digicert.com/ssl-support/openssl-quick-reference-guide.htm

https://ajudadoprogramador.com.br/artigo/certificado-auto-assinado-no-linux

https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR

https://www.sitepoint.com/how-to-use-ssltls-with-node-js/

https://gist.github.com/Soarez/9688998