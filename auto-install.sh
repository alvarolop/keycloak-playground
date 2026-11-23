#!/bin/bash
set -e

echo "🚀 Starting Keycloak deployment..."

#####################################
# Deploy Keycloak
#####################################

echo -e "\n📋 Deploy Keycloak..."

helm template keycloak-chart \
--set global.clusterDomain=$(oc get dns.config/cluster -o jsonpath='{.spec.baseDomain}') \
| oc apply -f -

echo "⏳ Waiting for the Keycloak route created by the operator..."
until oc get route -n keycloak -l 'app=keycloak' -o name 2>/dev/null | grep -q route; do sleep 5; done

KEYCLOAK_URL=$(oc get route -n keycloak -l 'app=keycloak' -o go-template='https://{{(index .items 0).spec.host}}')

echo "🔗 Keycloak URL: $KEYCLOAK_URL"

echo "✅ Keycloak deployed successfully!"
