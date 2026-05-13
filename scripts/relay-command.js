#!/usr/bin/env node
import {spawnSync} from "node:child_process";
import {dirname, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const webCwd = resolve(root, "apps/web");
const rescriptRelayCompiler = resolve(root, "node_modules/.bin/rescript-relay-compiler");
const args = process.argv.slice(2);

const toolAliases = new Map([
  ["find-references", "find-schema-references"],
  ["fragment-usage", "fragment-spread-usage"],
  ["schema-dce", "unused-schema-members"],
  ["executable-definitions", "definition-audit"],
]);

const printToolsHelp = () => {
  console.log(`Relay project analysis helpers.

Usage: yarn relay tools <COMMAND>

Commands:
  find-references         Find references for a schema path. E.g. User.name
  print-operation         Print the full text for a named GraphQL operation
  fragment-dependents     Find dependent operations and fragments for a fragment
  deprecated-usage        Find deprecated fields, arguments, and directives
  unused-fragments        Find fragments not referenced from any operation
  fragment-usage          List fragments by spread usage count
  rename-fragment         Rename a fragment and update spread sites
  schema-dce              Find schema fields unused by Relay documents
  executable-definitions  Find operations/fragments by selection size/depth
  help                    Print this message or subcommand help

Options:
  -h, --help  Print help`);
};

const run = (command, commandArgs, options = {}) => {
  const result = spawnSync(command, commandArgs, {
    cwd: options.cwd ?? root,
    env: process.env,
    stdio: "inherit",
  });

  if (result.error) {
    console.error(result.error.message);
    process.exit(1);
  }

  process.exit(result.status ?? 1);
};

if (args[0] === "tools") {
  const [, rawCommand, ...toolArgs] = args;

  if (rawCommand === undefined || rawCommand === "--help" || rawCommand === "-h") {
    printToolsHelp();
    process.exit(0);
  }

  if (rawCommand === "help") {
    const [helpCommand] = toolArgs;
    if (helpCommand === undefined) {
      printToolsHelp();
      process.exit(0);
    }

    const mappedHelpCommand = toolAliases.get(helpCommand) ?? helpCommand;
    run(rescriptRelayCompiler, ["tools", mappedHelpCommand, "--help"], {cwd: webCwd});
  }

  const mappedCommand = toolAliases.get(rawCommand) ?? rawCommand;
  run(rescriptRelayCompiler, ["tools", mappedCommand, ...toolArgs], {cwd: webCwd});
}

run("sh", [resolve(root, "scripts/relay-no-watchman.sh"), "relay.config.json", ...args], {
  cwd: webCwd,
});
