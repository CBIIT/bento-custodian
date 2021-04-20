#!/bin/bash
set -e
eval "$('@sh "export NEO4J_PASSWORD=\(.neo4j_password)"')"
bearer=`echo "Basic $(echo -n "neo4j:$NEO4J_PASSWORD" | base64)"`
printf '{"bearer": "%s"}\n' "$bearer" 