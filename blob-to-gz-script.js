const fs = require('fs');

// get input hex data from command-line argument
const input = (process.argv?.[2] || fs.readFileSync("output.data", "utf8")).replace(/(\\|\s|")+/g, '');

// convert hex string to buffer
const buffer = Buffer.from(input, 'hex');
console.log(buffer);

// write buffer to new gzip file
fs.writeFileSync('output.gz', buffer);

console.log('Done!');