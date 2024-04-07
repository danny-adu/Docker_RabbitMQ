#!/bin/bash

# The node that will join the cluster
JOINING_NODE=$1
# The node to join
CLUSTER_NODE=$2

if [ -z "$JOINING_NODE" ] || [ -z "$CLUSTER_NODE" ]; then
    echo "Usage: $0 <joining-node-container-id> <cluster-node-name>"
    exit 1
fi

# Stop the RabbitMQ application
docker exec -it $JOINING_NODE rabbitmqctl stop_app

# Reset the node
docker exec -it $JOINING_NODE rabbitmqctl reset

# Join the cluster
docker exec -it $JOINING_NODE rabbitmqctl join_cluster $CLUSTER_NODE

# Start the RabbitMQ application
docker exec -it $JOINING_NODE rabbitmqctl start_app