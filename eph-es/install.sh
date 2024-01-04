#! /bin/bash

#wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.4.2-linux-x86_64.tar.gz
#wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.4.2-linux-x86_64.tar.gz.sha512
shasum -a 512 -c elasticsearch-oss-7.4.2-linux-x86_64.tar.gz.sha512 
tar -xzf elasticsearch-oss-7.4.2-linux-x86_64.tar.gz --skip-old-files

elasticsearch-7.4.2/bin/elasticsearch &

#wait for elasticserach to start before trying to load templates
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8080/)" != "200" ]]; do sleep 1; done

#curl -X PUT localhost:8080/_template/company_template_1 -H "Content-Type: application/json" --data-binary @company_template_1.json

#curl -X PUT localhost:8080/_template/company_eventsoutcomes_template_1 -H "Content-Type: application/json" --data-binary @company_eventsoutcomes_template_1.json
