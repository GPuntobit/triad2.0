import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import { copyFile, mkdir, mkdtemp, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

test("sweep does not disclose contents of tracked symlinks", async (t) => {
  const scratch = await mkdtemp(join(tmpdir(), "jev-audit-symlink-"));
  t.after(() => rm(scratch, { recursive: true, force: true }));

  const repo = join(scratch, "repo");
  const auditDir = join(repo, "ai");
  const nestedDir = join(repo, "nested");
  const outsideDir = join(scratch, "outside");
  const script = fileURLToPath(new URL("./jev_audit.mjs", import.meta.url));
  const privateFile = join(scratch, "private.txt");
  await mkdir(auditDir, { recursive: true });
  await mkdir(nestedDir);
  await mkdir(outsideDir);
  await copyFile(script, join(auditDir, "jev_audit.mjs"));
  await writeFile(privateFile, "private-symlink-target-content");
  await writeFile(join(nestedDir, "review.md"), "private-parent-symlink-content");
  await writeFile(join(outsideDir, "review.md"), "private-parent-symlink-content");
  await writeFile(join(repo, "safe.md"), "safe tracked content");

  try {
    await symlink(privateFile, join(repo, "review.md"), "file");
  } catch (error) {
    if (["EPERM", "EACCES", "UNKNOWN"].includes(error.code)) {
      t.skip(`Creating symlinks is not permitted: ${error.code}`);
      return;
    }
    throw error;
  }

  execFileSync("git", ["init", "-q"], { cwd: repo });
  execFileSync("git", ["add", "ai/jev_audit.mjs", "review.md", "nested/review.md", "safe.md"], { cwd: repo });

  try {
    await rm(nestedDir, { recursive: true });
    await symlink(outsideDir, nestedDir, process.platform === "win32" ? "junction" : "dir");
  } catch (error) {
    if (["EPERM", "EACCES", "UNKNOWN"].includes(error.code)) {
      t.skip(`Creating symlinked directories is not permitted: ${error.code}`);
      return;
    }
    throw error;
  }

  const result = spawnSync(process.execPath, ["ai/jev_audit.mjs", "sweep", "--dry-run"], {
    cwd: repo,
    encoding: "utf8",
  });

  assert.equal(result.status, 0, result.stderr);
  assert.ok(result.stdout.includes("safe tracked content"));
  assert.ok(!result.stdout.includes("private-symlink-target-content"));
  assert.ok(!result.stdout.includes("private-parent-symlink-content"));
  assert.ok(!result.stdout.includes('"path": "review.md"'));
  assert.ok(!result.stdout.includes('"path": "nested/review.md"'));
});
