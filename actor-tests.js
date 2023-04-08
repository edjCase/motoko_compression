const {execSync, spawn } = require("child_process");

execSync(`dfx deploy test --yes`);
let res = execSync(`dfx canister call test runTests`);
res = res.toString().trim();
res = res.slice(1, res.length - 1);
res = res.trim();

let index = res.indexOf(",");
let success = res.slice(0, index).trim() === "true";

let output = res.slice(index + 1).trim();
if (output.startsWith("\"")) {
    output = output.slice(1);
}

if (output.endsWith("\",")) {
    output = output.slice(0, -2);
}

output = output.replace(/\\n/g, "\n");
output = output.replace(/\\"/g, "\"");

output = output.replace(/\\u{1b}/g, "\u{1b}");

console.log(output);

if (!success){
    process.exitCode = 1;
}
