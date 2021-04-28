apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  annotations: {}
  labels:
    cloud.googleapis.com/location: ${gcp_region}
  name: ${stack_name}-cloudrun-frontend
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/maxScale: '1000'
    spec:
      containerConcurrency: 80
      containers:
      - image: ${gcp_region}-docker.pkg.dev/${gcp_project}/${env}/frontend:${image_tag}
        ports:
        - containerPort: 8080
        env:
        - name: REACT_APP_BACKEND_API
          value: ${backend_url}/v1/graphql/
        - name: REACT_APP_APPLICATION_VERSION
          value: ${release_tag}
        - name: REACT_APP_ABOUT_CONTENT_URL
          value: https://raw.githubusercontent.com/CBIIT/bento-frontend/master/src/content/dev/aboutPagesContent.yaml
        resources:
          limits:
            cpu: 1000m
            memory: 1024M
      timeoutSeconds: 300
  traffic:
  - latestRevision: true
    percent: 100
