const fs = require('fs');

let input = (process.argv?.[2]).replace(/(\\|\s|")+/g, '');

// convert hex string to buffer
const buffer = Buffer.from(input, 'hex');
console.log([...buffer]);
