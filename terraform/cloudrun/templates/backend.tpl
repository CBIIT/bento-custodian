apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  annotations: {}
  labels:
    cloud.googleapis.com/location: ${gcp_region}
  name: ${stack_name}-cloudrun-backend
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/maxScale: '1000'
        run.googleapis.com/vpc-access-connector: ${connector_name}
    spec:
      containerConcurrency: 80
      containers:
      - name: backend
        image: ${gcp_region}-docker.pkg.dev/${gcp_project}/${env}/backend:${image_tag}
        ports:
        - containerPort: 8080
        env:
        - name: NEO4J_GRAPHQL_ENDPOINT
          value: http://${neo4j_ip}:7474/graphql/
        - name: NEO4J_AUTHORIZATION
          value: ${neo4j_bearer}"
        resources:
          limits:
            cpu: 1000m
            memory: 512M
      timeoutSeconds: 300
  traffic:
  - latestRevision: true
    percent: 100
