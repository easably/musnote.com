# Deployment — Cloudflare Pages

The notes container and the stem container run on server7 (`127.0.0.1:8095` and `127.0.0.1:8096`). server8 only forwards those two ports. Caddy on server1 still sends `api.musnote.com` to `192.168.1.164`. GitHub Actions deploys `api/` with `DEPLOY_HOST` and `DEPLOY_PORT`, which point at server7.

Static site in `web/` is deployed to [Cloudflare Pages](https://pages.cloudflare.com/).

## One-time Cloudflare setup

1. Create a Cloudflare account and open **Workers & Pages**.
2. Create a Pages project (name, e.g. `musnote`) — or let the first deploy create it via Wrangler.
3. Create an API token:
   - **My Profile → API Tokens → Create Token**
   - Template **Edit Cloudflare Workers**, or custom permissions:
     - Account → Cloudflare Pages → Edit
     - Account → Account Settings → Read (if required by Wrangler)
4. Copy your **Account ID** from the Cloudflare dashboard sidebar.

## GitHub configuration

### Secret (token — the only secret)

| Name | Value |
|------|--------|
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token |

Repository → **Settings → Secrets and variables → Actions → Secrets**.

### Variables (non-secret)

| Name | Value |
|------|--------|
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare Account ID |
| `CLOUDFLARE_PAGES_PROJECT` | Pages project name (optional, default `musnote`) |

Repository → **Settings → Secrets and variables → Actions → Variables**.

## Deploy

Workflow: `.github/workflows/deploy-cloudflare-pages.yml`

Runs on:
- push to `main` / `master`
- pull requests (preview deployments)
- manual **workflow_dispatch**

Command used:

```bash
wrangler pages deploy web --project-name=<CLOUDFLARE_PAGES_PROJECT>
```

## Local preview

Serve the static folder locally (any static server):

```bash
npx --yes serve web
# or
python3 -m http.server -d web 8080
```

No Docker image or container is required.
