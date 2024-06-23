import path from "path";
import { glob } from "glob";
import { writeFile, readFile } from 'fs/promises';
import matter from "gray-matter";

const examples = (await glob("public/examples/**/*.rb")).map((file) => file.replace(/^public/, ''));
const lua = (await glob("public/lua/**/*.lua")).map((file) => file.replace(/^public/, ''));
const frontMatter = {};

// Parse frontmatter in examples
for (const path of examples) {
  const content = await readFile(`public${path}`, 'utf-8');
  const fm = content.match(/---\s*([\s\S]*?)\s*---/img);
  if (!fm || fm.length === 0) continue;
  const { data } = matter(fm.join().replace(/^[#\s]*/img, ''));
  frontMatter[path] = data;
}

await writeFile('public/index.json', JSON.stringify({ frontMatter, examples, lua }, null, 2));