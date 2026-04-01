const forge = require('node-forge');
const fs = require('fs');
const path = require('path');

const certPath = path.join(__dirname, 'certificate.pfx');
const keyPath = path.join(__dirname, 'private-key.pem');
const certPemPath = path.join(__dirname, 'certificate.pem');

console.log('Generating SHA256 self-signed certificate...');

const pki = forge.pki;

const keys = pki.rsa.generateKeyPair(2048);
const cert = pki.createCertificate();

cert.publicKey = keys.publicKey;
cert.serialNumber = '01';
cert.validity.notBefore = new Date();
cert.validity.notAfter = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000);

const attrs = [
  { name: 'commonName', value: 'CodeFetch' },
  { name: 'organizationName', value: 'CodeFetch' },
  { name: 'organizationalUnitName', value: 'Development' }
];

cert.setSubject(attrs);
cert.setIssuer(attrs);

cert.setExtensions([
  { name: 'basicConstraints', cA: true },
  { name: 'keyUsage', keyCertSign: true, digitalSignature: true, nonRepudiation: true, keyEncipherment: true, dataEncipherment: true },
  {
    name: 'extKeyUsage',
    serverAuth: true,
    clientAuth: true,
    codeSigning: true
  },
  {
    name: 'subjectAltName',
    altNames: [
      { type: 2, value: 'localhost' },
      { type: 2, value: '127.0.0.1' }
    ]
  }
]);

cert.sign(keys.privateKey, forge.md.sha256.create());

const privateKeyPem = pki.privateKeyToPem(keys.privateKey);
const certPem = pki.certificateToPem(cert);

fs.writeFileSync(keyPath, privateKeyPem);
console.log('Private key saved to:', keyPath);

fs.writeFileSync(certPemPath, certPem);
console.log('Certificate saved to:', certPemPath);

try {
  const newForge = require('node-forge');
  
  const pkcs12Asn1 = newForge.pkcs12.toPkcs12Asn1(
    keys.privateKey,
    [cert],
    '',
    {
      algorithm: '3des',
      generateLocalKeyId: true
    }
  );
  
  const pkcs12Der = newForge.asn1.toDer(pkcs12Asn1).getBytes();
  const pkcs12Buffer = Buffer.from(pkcs12Der, 'binary');
  
  fs.writeFileSync(certPath, pkcs12Buffer);
  console.log('PFX certificate saved to:', certPath);
  
  console.log('Certificate generation completed successfully!');
  console.log('Certificate details:');
  console.log('  - Algorithm: SHA256 with RSA');
  console.log('  - Valid from:', cert.validity.notBefore);
  console.log('  - Valid to:', cert.validity.notAfter);
  console.log('');
  console.log('To use this certificate for code signing, add the following to package.json:');
  console.log('"win": {');
  console.log('  "certificateFile": "certificate.pfx",');
  console.log('  "certificatePassword": ""');
  console.log('}');
} catch (pkcs12Error) {
  console.log('Note: PFX generation failed, but PEM files are still available');
  console.log('Error:', pkcs12Error.message);
  console.log('');
  console.log('You can use OpenSSL to convert PEM to PFX:');
  console.log('openssl pkcs12 -export -out certificate.pfx -inkey private-key.pem -in certificate.pem -passout pass:');
}
