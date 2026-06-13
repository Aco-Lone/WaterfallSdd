import { copyFile, mkdir, readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';

async function pathExists(filePath) {
  try {
    await stat(filePath);
    return true;
  } catch (error) {
    if (error && error.code === 'ENOENT') {
      return false;
    }

    throw error;
  }
}

export async function installPayload({ sourceRoot, targetRoot, payloadPaths }) {
  const added = [];
  const skipped = [];

  for (const relativePath of await expandPayloadPaths(sourceRoot, payloadPaths)) {
    const sourcePath = path.join(sourceRoot, relativePath);
    const targetPath = path.join(targetRoot, relativePath);

    if (await pathExists(targetPath)) {
      skipped.push(relativePath);
      continue;
    }

    await mkdir(path.dirname(targetPath), { recursive: true });
    await copyFile(sourcePath, targetPath);
    added.push(relativePath);
  }

  return { added, skipped };
}

export async function runPostinstall({ packageRoot, workspaceRoot, manifestPath }) {
  const payloadPaths = await readPayloadManifest(manifestPath);

  return installPayload({
    sourceRoot: packageRoot,
    targetRoot: workspaceRoot,
    payloadPaths
  });
}

export function resolveWorkspaceRoot(environment = process.env) {
  return environment.INIT_CWD || process.cwd();
}

async function expandPayloadPaths(sourceRoot, payloadPaths) {
  const expandedPaths = [];

  for (const relativePath of payloadPaths) {
    const sourcePath = path.join(sourceRoot, relativePath);
    const sourceStats = await stat(sourcePath);

    if (sourceStats.isDirectory()) {
      expandedPaths.push(...await walkDirectory(sourceRoot, relativePath));
      continue;
    }

    expandedPaths.push(relativePath);
  }

  return expandedPaths;
}

async function readPayloadManifest(manifestPath) {
  const manifest = JSON.parse(await readFile(manifestPath, 'utf8'));
  return manifest.payloadPaths;
}

async function walkDirectory(sourceRoot, directoryPath) {
  const absoluteDirectoryPath = path.join(sourceRoot, directoryPath);
  const directoryEntries = await readdir(absoluteDirectoryPath, { withFileTypes: true });
  const collectedPaths = [];

  for (const directoryEntry of directoryEntries) {
    const relativeEntryPath = path.join(directoryPath, directoryEntry.name);

    if (directoryEntry.isDirectory()) {
      collectedPaths.push(...await walkDirectory(sourceRoot, relativeEntryPath));
      continue;
    }

    collectedPaths.push(relativeEntryPath);
  }

  return collectedPaths;
}