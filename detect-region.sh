#!/bin/bash
PROJECT="kbeseafmtepfjatzvjnr"
USER="postgres.$PROJECT"
# Using a fake password just to trigger authentication check - we want to see if the Tenant exists
# If we get "password authentication failed", the region is correct!
# If we get "Tenant or user not found", the region is wrong.
PASSWORD="wrongpassword"

REGIONS=(
  "aws-0-eu-central-1"
  "aws-0-eu-west-1"
  "aws-0-eu-west-2"
  "aws-0-eu-west-3"
  "aws-0-eu-north-1"
  "aws-0-us-east-1"
  "aws-0-us-west-1"
  "aws-0-us-west-2"
  "aws-0-ap-southeast-1"
  "aws-0-ap-southeast-2"
  "aws-0-ap-northeast-1"
  "aws-0-ap-northeast-2"
  "aws-0-ap-south-1"
  "aws-0-ca-central-1"
  "aws-0-sa-east-1"
)

echo "🔍 Searching for Supabase project region..."

for region in "${REGIONS[@]}"; do
  HOST="$region.pooler.supabase.com"
  echo -n "Testing $region ($HOST)... "
  
  # Try to connect with a short timeout
  OUT=$(PGPASSWORD="$PASSWORD" psql "postgresql://$USER@$HOST:6543/postgres" -c "SELECT 1" 2>&1)
  
  if echo "$OUT" | grep -q "password authentication failed"; then
    echo "✅ FOUND! Project is in $region"
    echo "Host: $HOST"
    exit 0
  elif echo "$OUT" | grep -q "Tenant or user not found"; then
     echo "❌ Not here (Tenant not found)"
  else
     echo "⚠️  Unknown response: $OUT"
  fi
done

echo "❌ Could not find project in common regions."
exit 1
