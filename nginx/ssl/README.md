# SSL Certificates Directory

Place your SSL certificates here for the Nginx reverse proxy.

## Required Files

- `cert.pem` - SSL certificate
- `key.pem` - Private key

## Generating Self-Signed Certificates (Development Only)

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```

## Production Certificates

For production, use certificates from:
- Let's Encrypt (free)
- Your certificate authority
- Cloud provider certificate manager

## Security Note

**Never commit SSL private keys to version control!**

These files are excluded in `.gitignore`.
