{{- define "myapp.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "myapp.name" -}}
{{- default "myapp" .Chart.Name | lower -}}
{{- end -}}
