{{/*
Create a standard name for resources based on the chart name
*/}}
{{- define "name" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end -}}

{{/*
Create a name for resources that includes the release name
and the chart name to avoid naming collisions
*/}}
{{- define "fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
