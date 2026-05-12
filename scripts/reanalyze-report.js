#!/usr/bin/env node

import {spawnSync} from "node:child_process";
import process from "node:process";

const DEFAULT_MAX_WARNINGS = 0;

function parseMaxWarnings(argv, env) {
  const inlineArg = argv.find(arg => arg.startsWith("--max-warnings="));
  const splitArgIndex = argv.findIndex(arg => arg === "--max-warnings");
  const rawValue =
    inlineArg?.slice("--max-warnings=".length) ??
    (splitArgIndex >= 0 ? argv[splitArgIndex + 1] : undefined) ??
    env.REANALYZE_MAX_WARNINGS ??
    `${DEFAULT_MAX_WARNINGS}`;
  const value = Number.parseInt(rawValue, 10);

  if (!Number.isFinite(value) || value < 0 || `${value}` !== rawValue.trim()) {
    throw new Error(`Invalid Reanalyze warning budget: ${rawValue}`);
  }

  return value;
}

function run(command, args) {
  const result = spawnSync(command, args, {
    cwd: process.cwd(),
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
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

function runChecked(command, args) {
  const result = run(command, args);

  if (result.status !== 0) {
    if (result.stdout.trim()) process.stdout.write(result.stdout);
    if (result.stderr.trim()) process.stderr.write(result.stderr);
    process.exit(result.status);
  }

  return result;
}

function parseReports(stdout) {
  const text = stdout.trim();

  if (text === "") {
    return [];
  }

  const parsed = JSON.parse(text);

  if (!Array.isArray(parsed)) {
    throw new Error("Expected Reanalyze JSON output to be an array.");
  }

  return parsed;
}

function firstString(...values) {
  return values.find(value => typeof value === "string" && value.trim() !== "") ?? "";
}

function pathFromReport(report) {
  return firstString(
    report?.path,
    report?.file,
    report?.filename,
    report?.location?.path,
    report?.location?.file,
    report?.location?.filename,
    report?.range?.path,
    report?.range?.file,
    report?.range?.filename,
  );
}

function lineFromReport(report) {
  const value =
    report?.line ??
    report?.location?.line ??
    report?.location?.start?.line ??
    report?.range?.start?.line ??
    report?.start?.line;

  return typeof value === "number" && Number.isFinite(value) ? value : undefined;
}

function typeFromReport(report) {
  return firstString(
    report?.kind,
    report?.type,
    report?.warning,
    report?.code,
    report?.category,
    report?.name,
    "Reanalyze Issue",
  );
}

function messageFromReport(report) {
  return firstString(
    report?.message,
    report?.text,
    report?.description,
    report?.reason,
    report?.diagnostic,
    JSON.stringify(report),
  );
}

function formatLocation(report) {
  const path = pathFromReport(report);
  const line = lineFromReport(report);

  if (path && line !== undefined) {
    return `${path}:${line}`;
  }

  return path || "unknown location";
}

function groupByType(reports) {
  return reports.reduce((groups, report) => {
    const type = typeFromReport(report);
    const existing = groups.get(type) ?? [];
    existing.push(report);
    groups.set(type, existing);
    return groups;
  }, new Map());
}

function printReport(reports, maxWarnings) {
  if (reports.length === 0) {
    console.log(`Reanalyze reported 0 issues. Budget: ${maxWarnings}.`);
    return;
  }

  console.log(`Reanalyze reported ${reports.length} issues. Budget: ${maxWarnings}.`);

  for (const [type, group] of groupByType(reports)) {
    console.log(`\n${type}: ${group.length}`);

    for (const report of group) {
      console.log(`- ${formatLocation(report)} - ${messageFromReport(report)}`);
    }
  }
}

function main() {
  const maxWarnings = parseMaxWarnings(process.argv.slice(2), process.env);

  const result = runChecked("node", ["scripts/reanalyze-all.js", "-dce", "-json"]);
  const reports = parseReports(result.stdout);

  printReport(reports, maxWarnings);

  if (reports.length > maxWarnings) {
    console.error(
      `\nReanalyze issue count ${reports.length} exceeds budget ${maxWarnings}. ` +
        "Fix the issues or raise REANALYZE_MAX_WARNINGS for a temporary exploratory run.",
    );
    process.exit(1);
  }
}

try {
  main();
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}
