# Salesforce Integration Reloaded

This Salesforce DX project connects Salesforce to third-party APIs. The integrations are written in Apex and Lightning Web Components (LWC). A few small Node.js apps work with the org from outside.

## Integrations

| Service | Where | What it does |
| --- | --- | --- |
| QuickBooks | `force-app` (`QB_*`, `PS_QBTokenUtil`, `QuickBooksWebhookListener`) | Syncs customers and items with OAuth 2.0. Receives QuickBooks webhooks. |
| Xero | `force-app` (`PS_XeroHandler`) | Calls the Xero API. |
| Stripe | `force-app` (`StripeWebhookListner`, `StripeSignatureVerifier`) | Receives invoice webhooks after checking their HMAC signature. |
| Razorpay / PayPal | `web`, `razorpay/` | Handles payment and order callbacks for the course site. |
| Freshdesk | `force-app` (`FreshdeskService`, `freshdeskTicket` LWC) | Shows and manages tickets. |
| Zendesk | `assignments/zendesk`, `force-app` (`PS_Zendesk*`) | Creates tickets and handles agents. |
| Zoom | `assignments/zoom` | Creates meetings with OAuth. |
| Google Drive / Calendar | `assignments/google-api`, `force-app` (`GC_Events`, `GoogleDriveIntegration`) | Browses and uploads Drive files. Manages Calendar events. |
| Dropbox | `project/dropbox` | File manager LWC plus the `DropBoxFile__c` object. |
| AWS S3 | `project/aws` | Bucket and object operations, with S3 XML error parsing. |
| SharePoint | `assignments/sharepoint` | Gets an access token. |
| LinkedIn | `force-app` (`LinkedInService`, `LinkedInRegistrationHandler`) | Signs users in with the LinkedIn Auth Provider. Posts to LinkedIn. |
| PostGrid | `force-app` (`PostGridAddressVerification*`) | Verifies addresses, one at a time or in batches. |
| OpenCage | `force-app` (`OpenCageGeocoderService`) | Reverse geocoding. |
| Salesforce ↔ Salesforce | `force-app` (`PS_SalesforceTokenUtils`, `PS_AccountManager`, `PS_ContactManager`) | OAuth (JWT and PKCE) plus custom Apex REST endpoints. |
| Custom Apex REST | `assignments/apex-rest` (`CourseManager`, `UserManager`) | Example REST resources. |

## Project structure

```
force-app/               Default package: most integrations, Named/External Credentials,
                         Auth Providers, custom metadata types, platform events
assignments/<topic>/     One package directory per integration exercise
project/dropbox|aws/     Larger integration projects
web/                     LWC course and booking site with payment callbacks
platformevent/           Node (Express + jsforce): publishes and subscribes to platform events
streaming-api/           Node Streaming API client (Parcel)
razorpay/                Node Razorpay helper
scripts/apex, scripts/soql   Anonymous Apex and SOQL scripts
data/                    Sample request payloads (e.g. Google Calendar events)
```

`sfdx-project.json` lists every package directory. `force-app` is the default.

## How it works

- **Callouts** use Named Credentials (`callout:<Name>/...`). Most are paired with External Credentials.
- **OAuth tokens**, for integrations that manage their own tokens (QuickBooks, Google, Zoom, Salesforce), are stored in custom metadata types such as `qb_Metadata__mdt`, `Google_Config__mdt`, `zoom_Metadata__mdt` and `sfdc_Config__mdt`. After a refresh, `CreateUpdateMetadataUtils` writes them back through the Apex Metadata API.
- **Webhooks** arrive at `@RestResource` classes, which check the request signature before processing it.
- **Platform events** (`SAP_Account__e`, `OrderStatus__e`, `MetadataDeploymentResult__e`) connect the org with the external Node apps.
- **Triggers** contain no logic. They call handler classes, which make the callouts asynchronously.

## Getting started

Prerequisites: the [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) (`sf`), Node.js, and a Salesforce org.

```bash
npm install                                   # dev tooling + Husky hooks
sf org login web --set-default --alias dev    # authorize an org
sf project deploy start --source-dir force-app
```

To create a scratch org instead:

```bash
sf org create scratch --definition-file config/project-scratch-def.json --set-default --alias scratch
```

After deploying, finish the auth setup in the org, which the source code cannot hold:
1. Add each service's client ID and secret to the Auth Providers and External Credentials.
2. Authenticate the Named Credentials, or the External Credential principals.
3. Fill in the custom metadata records that the token utilities read.

Deploy another package directory or a single component:

```bash
sf project deploy start --source-dir project/dropbox
sf project deploy start --metadata ApexClass:LinkedInService
```

## Development

| Task | Command |
| --- | --- |
| LWC unit tests | `npm test` |
| LWC tests (watch / coverage) | `npm run test:unit:watch` / `npm run test:unit:coverage` |
| Lint LWC/Aura JS | `npm run lint` |
| Format / check formatting | `npm run prettier` / `npm run prettier:verify` |
| Apex tests | `sf apex run test --class-names PostGridAddressVerificationTest --result-format human --synchronous` |
| Anonymous Apex | `sf apex run --file scripts/apex/verify_address.apex` |

A Husky pre-commit hook runs `lint-staged`. It formats staged files with Prettier and lints LWC/Aura JavaScript with ESLint.

Each Node app (`platformevent/`, `streaming-api/`, `razorpay/`) has its own `package.json`. Run `npm install` inside the app's directory before using it.

## Resources

- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Named Credentials](https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm)
