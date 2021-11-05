#!/bin/bash
# Install node_exporter to export host OS metrics
curl -fSsL https://cloudvisor-prometheus.s3.eu-central-1.amazonaws.com/node_exporter.sh | bash

# Install cadvisor container using docker-compose to export host docker and container metrics
curl -fSsL https://cloudvisor-prometheus.s3.eu-central-1.amazonaws.com/cadvisor.yml -o /opt/cadvisor.yml
docker-compose -f /opt/cadvisor.yml up -d
