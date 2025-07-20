{{/*
Define a reusable template for creating a database secret.
*/}}
{{- define "mychart.database.secret" -}}
{{- $secretName := printf "%s-%s-db-secret" .release.Name .serviceName -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $secretName }}
type: Opaque
data:
  # Passwords must be base64 encoded in Kubernetes secrets
  POSTGRES_PASSWORD: {{ .dbConfig.password | b64enc | quote }}
{{- end -}}


{{/*
Define a reusable template for creating a PostgreSQL database.
This template can be called from anywhere in the chart.

Parameters:
  - .release: The global release object.
  - .serviceName: The name of the parent service (e.g., "service-b").
  - .dbConfig: The database configuration object from values.yaml (e.g., .Values.serviceB.database).
*/}}
{{- define "mychart.postgresql.database" -}}
{{- $dbServiceName := printf "%s-%s-db" .release.Name .serviceName -}}
{{- $secretName := printf "%s-%s-db-secret" .release.Name .serviceName -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ $dbServiceName }}
spec:
  type: ClusterIP
  ports:
  - port: 5432
  selector:
    app: {{ $dbServiceName }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ $dbServiceName }}
spec:
  serviceName: {{ $dbServiceName }}
  replicas: 1
  selector:
    matchLabels:
      app: {{ $dbServiceName }}
  template:
    metadata:
      labels:
        app: {{ $dbServiceName }}
    spec:
      containers:
      - name: postgres
        image: "{{ .dbConfig.image.repository }}:{{ .dbConfig.image.tag }}"
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_USER
          value: {{ .dbConfig.user | quote }}
        - name: POSTGRES_DB
          value: {{ .dbConfig.name | quote }}
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ $secretName }}
              key: POSTGRES_PASSWORD
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
  {{- if .dbConfig.persistence.enabled }}
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      {{- if .dbConfig.persistence.storageClass }}
      storageClassName: {{ .dbConfig.persistence.storageClass | quote }}
      {{- end }}
      resources:
        requests:
          storage: {{ .dbConfig.persistence.size | quote }}
  {{- end }}
{{- end -}}
