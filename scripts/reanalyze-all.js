#!/usr/bin/env node

import {spawnSync} from "node:child_process";
import path from "node:path";
import process from "node:process";

const ROOT = process.cwd();
const BIN_PATH = path.join(ROOT, "node_modules", ".bin");
const PATH = [BIN_PATH, process.env.PATH ?? ""].filter(Boolean).join(path.delimiter);
const EXCLUDE_PATHS = [
  "node_modules",
  "lib",
  "apps/web/lib/bs",
  "api/graphql/lib/bs",
  "packages/schema/lib/bs",
  "packages/generative-ui/lib/bs",
].map(excludePath => path.join(ROOT, excludePath));
const GENERATED_PATHS = [
  "apps/web/src/__generated__",
  "apps/web/src/routes/__generated__",
  "packages/schema/src/__generated__",
  "packages/schema/db/queries/__generated__",
  "db/queries/__generated__",
].map(generatedPath => path.join(ROOT, generatedPath));

function isGeneratedReport(report) {
  const file = typeof report?.file === "string" ? report.file : "";
  return GENERATED_PATHS.some(generatedPath => file.startsWith(generatedPath + path.sep));
}

function reanalyzeArgs(args) {
  return [
    "reanalyze",
    ...cmtArgs(args),
    "-exclude-paths",
    EXCLUDE_PATHS.join(","),
    "-suppress",
    GENERATED_PATHS.join(","),
  ];
}

function cmtArgs(args) {
  let result = [];

  for (const arg of args) {
    switch (arg) {
      case "-config":
        // Root scripts use explicit CMT modes; keep -config as a DCE alias for manual runs.
      case "-dce":
        result.push("-dce-cmt", ROOT);
        break;
      case "-exception":
        result.push("-exception-cmt", ROOT);
        break;
      case "-termination":
        result.push("-termination-cmt", ROOT);
        break;
      case "-all":
        result.push("-all-cmt", ROOT);
        break;
      default:
        result.push(arg);
        break;
    }
  }

  return result;
}

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: options.cwd ?? process.cwd(),
    encoding: "utf8",
    env: {...process.env, PATH},
    stdio: options.capture ? ["ignore", "pipe", "pipe"] : "inherit",
  });

  if (result.error) {
    throw result.error;
  }

  return {
    status: result.status ?? 1,
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? "",
  };
}

function runChecked(command, args, options = {}) {
  const result = run(command, args, options);

  if (result.status !== 0) {
    if (options.capture) {
      if (result.stdout.trim()) process.stdout.write(result.stdout);
      if (result.stderr.trim()) process.stderr.write(result.stderr);
    }
    process.exit(result.status);
  }

  return result;
}

function parseJsonReports(packageName, stdout) {
  const text = stdout.trim();

  if (text === "") {
    return [];
  }

  const parsed = JSON.parse(text);

  if (!Array.isArray(parsed)) {
    throw new Error(`${packageName}: expected Reanalyze JSON output to be an array.`);
  }

  return parsed;
}

function lineFromReport(report) {
  const rangeLine = Array.isArray(report?.range) ? report.range[0] : undefined;
  const locationLine = report?.location?.line ?? report?.location?.start?.line;
  const line = report?.line ?? locationLine ?? rangeLine;

  return typeof line === "number" && Number.isFinite(line) ? line : undefined;
}

function reportType(report) {
  return (
    report?.name ??
    report?.kind ??
    report?.type ??
    report?.warning ??
    "Reanalyze Issue"
  );
}

function reportMessage(report) {
  return (
    report?.message ??
    report?.text ??
    report?.description ??
    report?.reason ??
    JSON.stringify(report)
  );
}

function reportLocation(report) {
  const file = typeof report?.file === "string" ? report.file : "unknown location";
  const relativeFile = file.startsWith(ROOT + path.sep) ? file.slice(ROOT.length + 1) : file;
  const line = lineFromReport(report);

  return line === undefined ? relativeFile : `${relativeFile}:${line}`;
}

function reportGroup(report) {
  const file = typeof report?.file === "string" ? report.file : "";
  const relativeFile = file.startsWith(ROOT + path.sep) ? file.slice(ROOT.length + 1) : file;

  if (relativeFile.startsWith("apps/web/")) return "@vibespace/web";
  if (relativeFile.startsWith("api/graphql/")) return "@vibespace/graphql";
  if (relativeFile.startsWith("packages/schema/")) return "@vibespace/schema";
  if (relativeFile.startsWith("packages/generative-ui/")) return "@vibespace/generative-ui";
  if (relativeFile.startsWith("db/queries/")) return "@vibespace/schema";

  return "other";
}

function printReports(reports) {
  const groups = reports.reduce((map, report) => {
    const group = reportGroup(report);
    const existing = map.get(group) ?? [];
    existing.push(report);
    map.set(group, existing);
    return map;
  }, new Map());

  if (reports.length === 0) {
    console.log("No Reanalyze issues.");
    return;
  }

  console.log(`Reanalyze reported ${reports.length} issues.`);

  for (const [group, groupReports] of groups) {
    console.log(`\n== ${group} ==`);

    for (const report of groupReports) {
      console.log(`- ${reportLocation(report)} - ${reportType(report)}: ${reportMessage(report)}`);
    }
  }
}

function main() {
  const args = process.argv.slice(2);
  const json = args.includes("-json") || args.includes("--json");
  const rawOutput = args.includes("-mermaid") || args.includes("-timing");
  const structuredOutput = json || !rawOutput;
  const reanalyzeCliArgs = structuredOutput && !json ? [...args, "-json"] : args;
  runChecked("yarn", ["rescript"], {cwd: ROOT, capture: structuredOutput});
  const result = runChecked("rescript-tools", reanalyzeArgs(reanalyzeCliArgs), {
    cwd: ROOT,
    capture: structuredOutput,
  });

  if (structuredOutput) {
    const reports = parseJsonReports("vibespace", result.stdout).filter(
      report => !isGeneratedReport(report),
    );

    if (json) {
      console.log(JSON.stringify(reports, null, 2));
    } else {
      printReports(reports);
    }
  }
}

try {
  main();
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}
