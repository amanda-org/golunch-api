#!/bin/bash
set -e

echo "🚀 Instalando Metrics Server no cluster EKS..."

# Aplica o manifest oficial
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Aguarda o pod do Metrics Server ser criado
echo "⏳ Aguardando pods do Metrics Server..."
kubectl wait --for=condition=Available --timeout=120s deployment/metrics-server -n kube-system || true

# Ajusta flags obrigatórias para EKS
echo "⚙️ Ajustando flags para EKS..."
kubectl -n kube-system patch deployment metrics-server \
  --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/args","value":["--cert-dir=/tmp","--secure-port=4443","--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname","--kubelet-insecure-tls","--metric-resolution=15s"]}]'

# Aguarda o pod reiniciar
echo "⏳ Aguardando pod reiniciar com novas flags..."
kubectl rollout status deployment/metrics-server -n kube-system

echo "✅ Metrics Server instalado e configurado!"
kubectl get pods -n kube-system | grep metrics-server
kubectl top nodes
kubectl top pods
