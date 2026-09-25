# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Salesforce DX project (API v67.0) that collects Apex/LWC integrations with third-party APIs: QuickBooks, Xero, Stripe, Razorpay, PayPal, Freshdesk, Zendesk, Zoom, Google Drive/Calendar, Dropbox, AWS S3, LinkedIn, PostGrid, OpenCage, and others. It also holds a few standalone Node.js apps that talk to Salesforce from outside the org.

## Commands

Salesforce (uses the `sf` CLI):
- Deploy one component: `sf project deploy start --metadata ApexClass:LinkedInService`, or `LightningComponentBundle:<name>`. See [scripts/deploy/auto.sh](scripts/deploy/auto.sh).
- Deploy one package directory: `sf project deploy start --source-dir project/dropbox`
- Run an Apex test class: `sf apex run test --class-names PostGridAddressVerificationTest --result-format human --synchronous`
- Run a single Apex test method: `sf apex run test --tests PostGridAddressVerificationTest.methodName --synchronous`
- Run an anonymous Apex script: `sf apex run --file scripts/apex/verify_address.apex`

Node (repo root):
- LWC Jest tests: `npm test`. Run one test with `npx sfdx-lwc-jest -- path/to/__tests__/file.test.js`.
- Lint LWC/Aura JS: `npm run lint`
- Format: `npm run prettier`. Check formatting without changes: `npm run prettier:verify`. Prettier uses the Apex and XML plugins and `trailingComma: none`.
- A Husky pre-commit hook runs `lint-staged`, which runs Prettier on staged files and ESLint on LWC/Aura JS.

## Layout

`sfdx-project.json` declares several package directories. `force-app` is the default, so new metadata goes there unless you choose another directory:
- `force-app/`: most integrations, plus shared metadata such as Named Credentials, External Credentials, Auth Providers, custom metadata types and platform events.
- `assignments/<topic>/`: one package directory per integration exercise (apex-rest, zoom, sharepoint, country-metadata, google-api, zendesk, linkedin).
- `project/dropbox`, `project/aws`: larger integration projects. `project/dropbox/classes/` sits outside `main/default`, but it is still inside the package path.
- `web/`: an LWC-based public site (courses, bookings, Razorpay/PayPal payment callbacks) with its Apex controllers.

Node apps with their own `package.json` and `node_modules`. They are not Salesforce metadata:
- `platformevent/`: Express and jsforce OAuth, used to publish and subscribe to platform events.
- `streaming-api/`: Streaming API client, built with Parcel (`npm start`).
- `razorpay/`: Razorpay helper.
- `project/academy/`: Express app. It is gitignored.

Other directories: `data/` holds sample JSON payloads (Google Calendar and others). `scripts/apex` and `scripts/soql` hold ad-hoc scripts. `docs/` is gitignored.

## Integration patterns

- **Callouts** use Named Credentials: `callout:<Name>/path`. Newer ones pair a Named Credential with an External Credential. Requests are usually built inline or with `PS_CalloutUtils.prepareRequest`.
- **OAuth token storage**: some integrations (QuickBooks, Google, Zoom, Salesforce-to-Salesforce) manage their own tokens. These store the access and refresh tokens in custom metadata records (`qb_Metadata__mdt`, `Google_Config__mdt`, `zoom_Metadata__mdt`, `sfdc_Config__mdt`, and others). Records are read with `getInstance('<DeveloperName>')`. On refresh, they are written back asynchronously through the Apex Metadata API in `CreateUpdateMetadataUtils` (`Metadata.DeployContainer` + `DeployCallback`). The write does not happen in the same transaction, so a token read right after a refresh may still be stale.
- **Inbound webhooks** are `@RestResource` classes. Examples: `StripeWebhookListner` plus `StripeSignatureVerifier`, and `QuickBooksWebhookListener`. Signatures are verified with HMAC.
- **Triggers** hold no logic. They delegate to a handler class, for example `CaseTrigger` → `CaseTriggerHandler`, which makes async callouts. Platform events (`SAP_Account__e`, `OrderStatus__e`, `MetadataDeploymentResult__e`) connect the org with the external Node apps.
- **Tests** mock callouts with `HttpCalloutMock` implementations, for example `Assignment_CaseTriggerMock` and `Assignment_CaseTriggerErrorMock`.
- **Class name prefixes** show which integration a class belongs to: `PS_` for shared/"project" utilities, `QB_` for QuickBooks, `GC_` for Google Calendar, `PE_` for platform events, `Assignment_`/`assignment_` for assignment exercises.
