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
      - image: ${gcp_region}-docker.pkg.dev/${gcp_project}/${env}/backend:${image_tag}
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: 1000m
            memory: 512M
      timeoutSeconds: 300
  traffic:
  - latestRevision: true
    percent: 100
