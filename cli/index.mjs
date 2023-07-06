#!/usr/bin/env node

import { execSync } from "child_process";
import { existsSync } from "fs";

const [, , schemaFile, resultFile] = process.argv;

if (!schemaFile) {
  console.error("The schema file param is missing.");
  process.exit(1);
}

if (!schemaFile.endsWith(".js") && !schemaFile.endsWith(".mjs")) {
  console.error("The schema file should be a *.js or *.mjs file.");
  process.exit(1);
}

if (!existsSync(schemaFile)) {
  console.error("The schema file doesn't exist.");
  process.exit(1);
}

if (!resultFile) {
  console.error("The result file param is missing.");
  process.exit(1);
}

if (resultFile.endsWith(".res")) {
  generateSchemaRes();
  process.exit(0);
} else if (resultFile.endsWith(".sql")) {
  generateSchemaSQL();
  process.exit(0);
} else {
  console.error("The result file should be a *.res or *.sql file.");
  process.exit(1);
}

function generateSchemaRes() {
  const command = `node ${schemaFile} generate:res > ${resultFile}`;

  console.log(command)
  execSync(command);
}

function generateSchemaSQL() {
  const command = `node ${schemaFile} generate:sql > ${resultFile}`;

  console.log(command)
  execSync(command);
}
