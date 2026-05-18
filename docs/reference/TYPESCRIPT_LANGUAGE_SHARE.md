# TypeScript Language Share Note

## Summary

GitHub reports a notable TypeScript share for this repository because the project includes a TypeScript-based documentation migration utility under `scripts/documentation-migration/`.

This TypeScript code is intentional project tooling. It is not the main Salesforce application runtime.

## Investigation Results

- TypeScript files found outside `.git` and `node_modules`: 51
- TypeScript bytes found locally: 700,871
- Location: `scripts/documentation-migration/`
- Source area: `scripts/documentation-migration/src`
- Test area: `scripts/documentation-migration/test`

The documentation migrator has its own:

- `package.json`
- `package-lock.json`
- `tsconfig.json`
- `jest.config.js`
- TypeScript source files
- TypeScript unit, integration, and performance tests

## Why It Exists

The Salesforce Documentation Migrator converts markdown documentation into Salesforce Knowledge Base articles. It supports:

- markdown scanning and parsing
- content processing
- category mapping
- link mapping
- Salesforce API integration
- migration reporting
- resumable migration workflows

TypeScript is useful here because the migrator is a standalone Node.js command-line tool with structured data models, configuration validation, and tests.

## What This Means For Reviewers

The main Salesforce app remains built around:

- Apex
- Lightning Web Components
- Salesforce metadata
- JavaScript, HTML, and CSS for LWC UI

The TypeScript percentage in GitHub language stats reflects supporting migration tooling, not a separate TypeScript web application or leaked generated artifact.

## Decision

Keep the TypeScript files in the repository and document their purpose rather than hiding them from GitHub Linguist. They are source-controlled project tooling and are relevant to the documentation/Knowledge Base workflow.
