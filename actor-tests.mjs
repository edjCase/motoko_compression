#!/usr/bin/env zx

import fs, { createReadStream, existsSync, statSync, writeFileSync } from "fs";
import events from "events";
import { readFile, stat } from "fs/promises";
import readline from "readline";
import { spawn } from "child_process";
import path from "path";
import { unescape } from "querystring";
// import 'zx/globals'

$.verbose = false;

try {
    await $`dfx start --background`;
} catch {}

await $`dfx deploy test --yes`;
let res = await $`dfx canister call test runTests`;
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

exit();