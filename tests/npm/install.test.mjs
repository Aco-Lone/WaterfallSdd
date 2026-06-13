import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';

import { installPayload, resolveWorkspaceRoot, runPostinstall } from '../../tools/install.mjs';

test('installPayload copies a missing payload file into the workspace', async () => {
  const sandboxRoot = await mkdtemp(path.join(os.tmpdir(), 'waterfallsdd-install-'));
  const sourceRoot = path.join(sandboxRoot, 'package');
  const targetRoot = path.join(sandboxRoot, 'workspace');
  const relativePath = path.join('.github', 'hooks', 'openspec-bootstrap.json');

  await mkdir(path.dirname(path.join(sourceRoot, relativePath)), { recursive: true });
  await mkdir(targetRoot, { recursive: true });
  await writeFile(path.join(sourceRoot, relativePath), '{"hooks":{}}', 'utf8');

  const result = await installPayload({
    sourceRoot,
    targetRoot,
    payloadPaths: [relativePath]
  });

  assert.deepEqual(result.added, [relativePath]);
  assert.deepEqual(result.skipped, []);
  assert.equal(
    await readFile(path.join(targetRoot, relativePath), 'utf8'),
    '{"hooks":{}}'
  );
});

test('installPayload copies files from a payload directory recursively', async () => {
  const sandboxRoot = await mkdtemp(path.join(os.tmpdir(), 'waterfallsdd-install-'));
  const sourceRoot = path.join(sandboxRoot, 'package');
  const targetRoot = path.join(sandboxRoot, 'workspace');
  const directoryPath = path.join('.github', 'skills');
  const nestedFile = path.join(directoryPath, 'sample-skill', 'SKILL.md');

  await mkdir(path.dirname(path.join(sourceRoot, nestedFile)), { recursive: true });
  await mkdir(targetRoot, { recursive: true });
  await writeFile(path.join(sourceRoot, nestedFile), '# Sample skill', 'utf8');

  const result = await installPayload({
    sourceRoot,
    targetRoot,
    payloadPaths: [directoryPath]
  });

  assert.deepEqual(result.added, [nestedFile]);
  assert.deepEqual(result.skipped, []);
  assert.equal(
    await readFile(path.join(targetRoot, nestedFile), 'utf8'),
    '# Sample skill'
  );
});

test('installPayload keeps an existing workspace file and reports it as skipped', async () => {
  const sandboxRoot = await mkdtemp(path.join(os.tmpdir(), 'waterfallsdd-install-'));
  const sourceRoot = path.join(sandboxRoot, 'package');
  const targetRoot = path.join(sandboxRoot, 'workspace');
  const relativePath = path.join('.github', 'hooks', 'openspec-bootstrap.json');

  await mkdir(path.dirname(path.join(sourceRoot, relativePath)), { recursive: true });
  await mkdir(path.dirname(path.join(targetRoot, relativePath)), { recursive: true });
  await writeFile(path.join(sourceRoot, relativePath), '{"hooks":{"package":true}}', 'utf8');
  await writeFile(path.join(targetRoot, relativePath), '{"hooks":{"workspace":true}}', 'utf8');

  const result = await installPayload({
    sourceRoot,
    targetRoot,
    payloadPaths: [relativePath]
  });

  assert.deepEqual(result.added, []);
  assert.deepEqual(result.skipped, [relativePath]);
  assert.equal(
    await readFile(path.join(targetRoot, relativePath), 'utf8'),
    '{"hooks":{"workspace":true}}'
  );
});

test('runPostinstall installs payload entries listed in the manifest', async () => {
  const sandboxRoot = await mkdtemp(path.join(os.tmpdir(), 'waterfallsdd-install-'));
  const packageRoot = path.join(sandboxRoot, 'package');
  const workspaceRoot = path.join(sandboxRoot, 'workspace');
  const manifestPath = path.join(packageRoot, 'payload.manifest.json');
  const payloadDirectory = path.join('templates');
  const payloadFile = path.join('README.md');
  const nestedTemplate = path.join(payloadDirectory, 'subsystem-spec.md');

  await mkdir(path.dirname(path.join(packageRoot, nestedTemplate)), { recursive: true });
  await mkdir(workspaceRoot, { recursive: true });
  await writeFile(path.join(packageRoot, nestedTemplate), '# Template', 'utf8');
  await writeFile(path.join(packageRoot, payloadFile), '# Package Readme', 'utf8');
  await writeFile(
    manifestPath,
    JSON.stringify({ payloadPaths: [payloadDirectory, payloadFile] }),
    'utf8'
  );

  const result = await runPostinstall({ packageRoot, workspaceRoot, manifestPath });

  assert.deepEqual(result.added, [nestedTemplate, payloadFile]);
  assert.deepEqual(result.skipped, []);
  assert.equal(await readFile(path.join(workspaceRoot, nestedTemplate), 'utf8'), '# Template');
  assert.equal(await readFile(path.join(workspaceRoot, payloadFile), 'utf8'), '# Package Readme');
});

test('resolveWorkspaceRoot prefers INIT_CWD over the current working directory', () => {
  const workspaceRoot = resolveWorkspaceRoot({
    INIT_CWD: path.join('F:', 'workspace', 'consumer-project'),
    PWD: path.join('F:', 'workspace', 'package')
  });

  assert.equal(workspaceRoot, path.join('F:', 'workspace', 'consumer-project'));
});