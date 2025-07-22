# The Velvet Ace Frontend Startup & Development Guide

> This guide supports all developers—from beginners to advanced engineers—covering environment setup, local debugging, and professional development standards.

## Table of Contents

1. [Environment Requirements](#environment-requirements)
2. [Project Cloning](#project-cloning)
3. [Dependency Installation](#dependency-installation)
4. [Environment Variable Configuration](#environment-variable-configuration)
5. [Local HTTPS Certificate Generation](#local-https-certificate-generation)
6. [Starting the Development Server](#starting-the-development-server)
7. [Production Build](#production-build)
8. [Development Standards & ESLint Recommendations](#development-standards--eslint-recommendations)
9. [Common Issues & Solutions](#common-issues--solutions)
10. [FAQ & Troubleshooting](#faq--troubleshooting)
11. [Contact Information](#contact-information)

## 1. Environment Requirements

- **Node.js**: Recommended >= 20.18.0 (must be above 20.11.1, or some dependencies will fail to install)
- **npm** or **pnpm**: Either is acceptable, always use the latest version
- **openssl**: Required for local HTTPS certificate generation
- **Git**: For project cloning

> ⚠️ It's recommended to use [nvm](https://github.com/coreybutler/nvm-windows) to manage Node.js versions and avoid conflicts.

## 2. Project Cloning

```bash
git clone https://github.com/your-org/The-Velvet-Ace.git
cd The-Velvet-Ace/poker-texas-hold-em/client
```

## 3. Dependency Installation

### Using npm

```bash
npm install
```

> If you encounter 404 errors or dependency conflicts, try switching the npm registry to the official source:
>
> ```bash
> npm config set registry https://registry.npmjs.org/
> ```

## 4. Environment Variable Configuration

- If a `.env.example` exists in the project root, copy it to `.env` and fill out necessary fields:

```bash
cp .env.example .env
```

- If there is no `.env.example`, you can skip this step.

## 5. Local HTTPS Certificate Generation

This project uses HTTPS by default. Generate a self-signed certificate in the `client` directory:

```bash
openssl req -x509 -newkey rsa:2048 -nodes -keyout localhost-key.pem -out localhost-cert.pem -days 365
```

- Name the files `localhost-key.pem` and `localhost-cert.pem` and place them in the `client` directory.
- Press Enter to skip all prompts during generation if unnecessary.

> ⚠️ Never upload certificate files to version control. Add to `.gitignore`:
>
> ```
> localhost-key.pem
> localhost-cert.pem
> ```

## 6. Starting the Development Server

```bash
npm run dev
# or
pnpm run dev
```

- Default URL: https://localhost:5173
- If your browser warns of an “unsafe certificate,” simply “continue anyway”—this is expected for self-signed local certificates.

## 7. Production Build

```bash
npm run build
# or
pnpm run build
```

- Compiled assets are output to the `dist/` directory.

## 8. Development Standards & ESLint Recommendations

This project is built with Vite + React + TypeScript and comes with basic ESLint rules.  
For production-grade applications, further enhancements are recommended:

### 8.1 Enable Type-Aware Linting

- Update `parserOptions` in your ESLint config:

```js
export default tseslint.config({
  languageOptions: {
    // other options...
    parserOptions: {
      project: ["./tsconfig.node.json", "./tsconfig.app.json"],
      tsconfigRootDir: import.meta.dirname,
    },
  },
});
```

- Replace `tseslint.configs.recommended` with `tseslint.configs.recommendedTypeChecked` or `tseslint.configs.strictTypeChecked`
- Optionally, add `...tseslint.configs.stylisticTypeChecked`

### 8.2 Install and Configure eslint-plugin-react

```bash
npm install eslint-plugin-react --save-dev
```

Add to your `eslint.config.js`:

```js
import react from "eslint-plugin-react";

export default tseslint.config({
  // Specify React version
  settings: { react: { version: "18.3" } },
  plugins: {
    react,
  },
  rules: {
    // Enable recommended rules
    ...react.configs.recommended.rules,
    ...react.configs["jsx-runtime"].rules,
    // other rules...
  },
});
```

> For more ESLint configuration suggestions, refer to the [eslint-plugin-react documentation](https://github.com/jsx-eslint/eslint-plugin-react)[1][2][3].

## 9. Common Issues & Solutions

### 9.1 Dependency Installation Fails / 404

- **Error**: `404 Not Found - ... @cartridge/utils@0.7.13`
- **Solution**: Switch npm registry to the official source, or check version existence in your `package.json`.

### 9.2 Certificate-Related Errors

- **Error**: `ENOENT: no such file or directory, open './localhost-key.pem'`
- **Solution**: Make sure the certificates are generated in `client`, and the filenames match your `vite.config.ts` settings.

### 9.3 Port Conflict

- **Error**: `EADDRINUSE: address already in use`
- **Solution**: Change the port in `vite.config.ts` or free up the port being used.

### 9.4 API Request Failure

- **Error**: `ERR_CONNECTION_REFUSED`, `Failed to fetch`
- **Cause**: Backend is not running, or port mismatch.
- **Solution**: Start the backend as well, or consult the backend documentation for details.

### 9.5 Browser “Unsafe Certificate” Warning

- **Explanation**: This is normal for local self-signed certificates; simply proceed to the site.

### 9.6 Wallet/Blockchain Related

- **Error**: `MetaMask extension not found`
- **Solution**: Install the [MetaMask](https://metamask.io/) browser extension.

## 10. FAQ & Troubleshooting

- **Q: Dependency installation is slow or fails?**  
  A: Switch npm registry or use a VPN.

- **Q: "openssl" command not found?**  
  A: On Windows, use Git Bash or Chocolatey to install openssl; on macOS/Linux, use your package manager.

- **Q: Frontend loads but API requests fail?**  
  A: Your frontend is running properly; the backend service is required for full functionality—see the backend docs.

- **Q: How to clear cache or reinstall dependencies?**  
  A:

  ```bash
  rm -rf node_modules package-lock.json
  npm install
  ```

- **Q: More questions?**  
  A: Review this FAQ first, or contact the maintainer below.

## 11. Contact Information

- Maintainer: [@Birdmannn](https://github.com/Birdmannn)
- For questions, contact via Telegram or open an issue in the project repository.

> **Recommendation:** Always restart the development server after changing dependencies or configuration to ensure changes take effect.
