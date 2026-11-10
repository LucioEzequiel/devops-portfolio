#!/bin/bash
# Genera respuestas 404 bajo /api/ para medir la regla IngressPicoErrores4xx5xx.
# Nota: en el hardware del laboratorio la tasa máxima medida fue ~3,7 req/s,
# por debajo del umbral de 10 req/s, así que la alerta no llega a dispararse aquí.
set -euo pipefail

TRAEFIK_IP=172.22.0.2
HOST="devops-portfolio.dev"
CONCURRENCIA=${1:-20}
DURACION=${2:-150}

echo "Objetivo: http://$TRAEFIK_IP/api/admin-N (Host: $HOST)"
echo "Concurrencia: $CONCURRENCIA, duración: ${DURACION}s"

timeout "$DURACION" sh -c "seq 1 1000000 | xargs -P $CONCURRENCIA -I{} curl -s -o /dev/null -H 'Host: $HOST' http://$TRAEFIK_IP/api/admin-{}" || true

echo "=== Carga terminada. Consultá las alertas con: ==="
echo "kubectl exec -n devops-portfolio deploy/prometheus -- wget -qO- 'http://localhost:9090/api/v1/alerts'"
