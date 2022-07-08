#!/bin/bash

#set -x

es_url=http://localhost:8080

main () {

    follow=false

    while getopts "fu:" option; do
        case ${option} in
            f )
                follow=true
                ;;
            u )
                es_url=${OPTARG}
                ;;
            * )
                help
                exit 1
                ;;
        esac
    done

    if [ "$follow" = true ] ; then
        live_audit
    else
        single_audit
    fi

}

help () {
    cat << EOF
-f      follow
-u url      set url
EOF
}

#single line version
#cf run-task --command "curl -X GET -s http://localhost:8080/_search -H 'Content-Type: application/json' -d '{ \"size\":10000, \"query\": { \"bool\": { \"must\": [ { \"match_phrase\": { \"eventVisibility\": { \"query\": \"customer\" } } }, { \"exists\": { \"field\": \"invokedByCustomerId\" } } ], \"filter\": [ { \"match_all\": {} } ], \"should\": [], \"must_not\": [] } } }' | jq -c '.hits.hits[]._source'" eph-es

single_audit () {

    echo "Running Audit Dump"

    query='{
        "size":10,
        "query": {
            "bool": {
                "must": [
                    {
                        "match_phrase": {
                            "eventVisibility": {
                                "query": "customer"
                            }
                        }
                    },
                    {
                        "exists": {
                            "field": "invokedByCustomerId"
                        }
                    }
                ],
                "filter": [
                    {
                        "match_all": {}
                    }
                ],
                "should": [],
                "must_not": []
            }
        }
    }'

    response=$(curl -X GET -s "$es_url/dev-skevents-*/_search?scroll=1m" -H 'Content-Type: application/json' -d "$query")
    scroll_id=$(echo "$response" | jq -r ._scroll_id)
    hits_count=$(echo "$response" | jq -r '.hits.hits | length')

    while [ "$hits_count" != "0" ]; do

        echo "$response" | jq -c '.hits.hits[]._source'

        response=$(curl -s "$es_url/dev-skevents-*/_search/scroll" -H "Content-Type: application/json" -d "{ \"scroll\": \"1m\", \"scroll_id\": \"$scroll_id\" }")
        scroll_id=$(echo "$response" | jq -r ._scroll_id)
        hits_count=$(echo "$response" | jq -r '.hits.hits | length')
    done

    echo "Completed Audit Dump"

}

live_audit () {

    echo "Running Live Audit"

    live_query='{
        "size":10,
        "query": {
            "bool": {
                "must": [
                    {
                        "match_phrase": {
                            "eventVisibility": {
                                "query": "customer"
                            }
                        }
                    },
                    {
                        "exists": {
                            "field": "invokedByCustomerId"
                        }
                    }
                ],
                "filter": [
                    {
                        "match_all": {}
                    }
                ],
                "should": [],
                "must_not": []
            }
        },
        "search_after": [0],
        "sort" : [ "tsEms"]
    }'

    while true; do
        response=$(curl -X GET -s "$es_url/dev-skevents-*/_search" -H 'Content-Type: application/json' -d "$live_query")
        hits_count=$(echo "$response" | jq -r '.hits.hits | length')
        if (( hits_count > 0 )); then
            echo "$response" | jq -c '.hits.hits[]._source'
            last_item=$(echo "$response" | jq -r '.hits.hits | last | .sort | first')
            live_query=$(echo "$live_query" | jq --argjson sa "$last_item" '.search_after[0] = $sa')
        else
            sleep 1m
        fi
    done

}

main "$@"