# Ephemeral Elasticsearch

Ephemeral Elasticsearch for debugging purposes
### Deploy instance
```
deploy.sh
```
### Revert to normal configuration
🟊 **Ensure Debugging is disabled before restoring** 🟊
```
restore.sh
```
### Run Manual Audit
```
cf run-task --command "~/audit.sh" eph-es
```