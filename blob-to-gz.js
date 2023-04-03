const fs = require('fs');

// get input hex data from command-line argument
let param = process.argv?.[2];

if (param == "-rev"){
    let bytes = fs.readFileSync("output.gz");

    let hex = "";

    for (const byte of bytes){
        let hex_byte = byte.toString(16).padStart(2, '0');
        hex += `\\${hex_byte}`;
    }

    fs.writeFileSync("output.data", hex);

    return;
}

let input = "";

if (fs.existsSync(param)){
    input = fs.readFileSync(param, "utf8").replace(/(\\|\s|")+/g, '');
}else{
    input = (process.argv?.[2] || fs.readFileSync("output.data", "utf8")).replace(/(\\|\s|")+/g, '');
};

// convert hex string to buffer
const buffer = Buffer.from(input, 'hex');
console.log(buffer);

// write buffer to new gzip file
fs.writeFileSync('output.gz', buffer);

console.log('Done!');