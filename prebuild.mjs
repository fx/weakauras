import path from "path";
import { glob } from "glob";
import { writeFile } from 'fs/promises';

const examples = (await glob("public/examples/**/*.rb")).map((file) => file.replace(/^public/, ''));
const lua = (await glob("public/lua/**/*.lua")).map((file) => file.replace(/^public/, ''));

await writeFile('public/index.json', JSON.stringify({ examples, lua }, null, 2));