#!/bin/bash

# Speicher vor der Bereinigung anzeigen
echo "📦 Speicherverbrauch vor der Bereinigung:"
docker system df

echo
echo "🚀 Lösche ungenutzte Docker Images..."
docker image prune -a --force

echo
echo "📦 Speicherverbrauch nach der Bereinigung:"
docker system df
