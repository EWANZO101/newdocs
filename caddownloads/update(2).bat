@echo off
cd Documents
cd snaily-cadv4
node scripts/copy-env.mjs --client --api
git pull origin main
git stash && git pull origin main
pnpm install
pnpm run build
exit