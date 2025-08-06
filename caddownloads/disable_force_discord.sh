#!/bin/bash

echo "Disabling FORCE_DISCORD_AUTH in SnailyCAD..."

# Run the PostgreSQL command as the 'postgres' user
sudo -i -u postgres psql snaily-cad-v4 <<EOF
-- Disable FORCE_DISCORD_AUTH
UPDATE public."CadFeature" SET "isEnabled" = false WHERE feature = 'FORCE_DISCORD_AUTH';

-- Confirm the change
SELECT feature, "isEnabled" FROM public."CadFeature" WHERE feature = 'FORCE_DISCORD_AUTH';
EOF

echo "✅ FORCE_DISCORD_AUTH has been disabled."
