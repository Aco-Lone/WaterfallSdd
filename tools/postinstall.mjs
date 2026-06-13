import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { resolveWorkspaceRoot, runPostinstall } from './install.mjs';

const packageRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const workspaceRoot = resolveWorkspaceRoot();
const manifestPath = path.join(packageRoot, 'payload.manifest.json');

if (process.platform !== 'win32') {
  console.warn('[waterfall-sdd-bootstrap] This package installs PowerShell-based hooks. Windows is the supported environment.');
}

const result = await runPostinstall({ packageRoot, workspaceRoot, manifestPath });

console.log(`[waterfall-sdd-bootstrap] Installed ${result.added.length} files, skipped ${result.skipped.length} existing files.`);

if (result.added.length > 0) {
  console.log(`[waterfall-sdd-bootstrap] Added: ${result.added.join(', ')}`);
}

if (result.skipped.length > 0) {
  console.log(`[waterfall-sdd-bootstrap] Skipped: ${result.skipped.join(', ')}`);
}