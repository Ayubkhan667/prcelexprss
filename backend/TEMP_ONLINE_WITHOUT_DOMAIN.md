# Temporary Online Access Without a Domain

This guide is for quick internet testing when you do **not** have a domain yet.

Best use case:

- you want to test the app from another phone/network
- you want an HTTPS API URL quickly
- you are not ready for full production hosting yet

This is **not** the final production setup.

## Recommended Option: Cloudflare Quick Tunnel

Cloudflare Quick Tunnel gives you a temporary public HTTPS URL like:

```text
https://random-name.trycloudflare.com
```

You can point the Flutter app to:

```text
https://random-name.trycloudflare.com/api
```

## 1. Start Laravel Backend Locally

```bash
cd backend
php artisan serve --host=127.0.0.1 --port=8000
```

Keep this terminal open.

## 2. Install `cloudflared`

### macOS

```bash
brew install cloudflared
```

### Ubuntu

```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
sudo dpkg -i cloudflared.deb
```

## 3. Start Quick Tunnel

In a new terminal:

```bash
cloudflared tunnel --url http://127.0.0.1:8000
```

Cloudflare will print a URL similar to:

```text
https://happy-river-sky.trycloudflare.com
```

## 4. Use It in the App

Set API URL to:

```text
https://happy-river-sky.trycloudflare.com/api
```

In Flutter run command:

```bash
flutter run --dart-define=API_BASE_URL=https://happy-river-sky.trycloudflare.com/api
```

Or enter the same URL inside app settings.

## 5. Test Public Health Endpoint

```bash
curl https://happy-river-sky.trycloudflare.com/api/health
```

If working, you should get a JSON response with `status: ok`.

## Important Limits

- Quick Tunnel is for testing, not permanent production
- URL changes when you restart the tunnel
- no uptime guarantee
- not suitable for final business deployment

## Alternative Option: ngrok

If you prefer ngrok:

### 1. Install ngrok

Follow ngrok account and install steps from:

- https://ngrok.com/pricing

### 2. Expose Laravel

```bash
ngrok http 8000
```

It will give a public HTTPS URL. Use:

```text
https://YOUR-NGROK-URL/api
```

## Final Recommendation

- for testing today: use Cloudflare Quick Tunnel
- for real launch: buy a domain and follow [DEPLOY_VPS.md](./DEPLOY_VPS.md)
