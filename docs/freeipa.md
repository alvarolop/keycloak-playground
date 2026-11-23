# Deploy FreeIPA

This section explains how to install FreeIPA, an Identity Management (IdM) solution that combines Linux, 389 Directory Server, MIT Kerberos, NTP, DNS and Dogtag. For more information, you can check the [FreeIPA documentation](https://www.freeipa.org/page/About), which is the upstream product for Red Hat Identity Management.

> [!NOTE]  
> The FreeIPA Helm chart is maintained by Red Hat Cop. For more information, you can check the [Red Hat Cop Helm charts repository](https://redhat-cop.github.io/helm-charts/). In this repo, we use a copy of the chart to avoid depending on the upstream repository. Last copy was made on 2025-10-04 using commit `eed4b2f`: [repo files](https://github.com/redhat-cop/helm-charts/tree/eed4b2f706e9690430dbfc5926073d53aa8c2206/charts/ipa).


```bash
helm template ipa ../ipa-chart \
--set app_domain=$(oc get dns.config/cluster -o jsonpath='{.spec.baseDomain}') \
--set fullnameOverride=ipa \
--set namespaceOverride=keycloak \
--set image=quay.io/freeipa/freeipa-server:fedora-42-4.12.5 \
--set machineconfig.ignition_version=3.5.0 | oc apply -f -
```

```bash
echo -n "Waiting for pods ready..."
while [[ $(oc get pods -l app=freeipa -n ipa -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo -n "." && sleep 1; done; echo -n -e "  [OK]\n"

# Expose it using NodePort and use 389 for LDAP on the node port 
oc patch service freeipa -n ipa -p '{
  "spec": {
    "type": "NodePort",
    "ports": [
      {
        "name": "ldap",
        "protocol": "TCP",
        "port": 389,
        "targetPort": 389,
        "nodePort": 30389
      }
    ]
  }
}'

echo -e "\tConfiguring groups and users..."

./05-init-freeipa.sh

echo -e "\tFreeIPA is ready to use!"
```
