#!/bin/bash

# Define the namespace and DaemonSet name
NAMESPACE="realtime"  # Change this to your namespace
DAEMONSET_NAME="k8s-realtime"  # Change this to your DaemonSet name

# Get all pod names in the DaemonSet
POD_NAMES=$(kubectl get pods -n $NAMESPACE -l "name=$DAEMONSET_NAME" -o jsonpath='{.items[*].metadata.name}')

# Initialize the starting port
LOCAL_PORT=8080
INDEX=1

# Iterate over each pod and create port forwardings
for POD in $POD_NAMES; do
  echo "Port forwarding for pod $POD on port $LOCAL_PORT"
  # Start port forwarding in the background
  kubectl port-forward -n $NAMESPACE $POD $LOCAL_PORT:80 &
  PORT_FORWARD_PID=$!
  
  # Give some time for port-forward to establish
  sleep 3
  
  # Download the plot.png file from the open port
  URL="http://localhost:$LOCAL_PORT/plot.png"
  OUTPUT_FILE="plot_$INDEX.png"
  echo "Downloading $URL to $OUTPUT_FILE"
  curl -s -o $OUTPUT_FILE $URL
  
  # Increment the port and index for the next pod
  LOCAL_PORT=$((LOCAL_PORT + 1))
  INDEX=$((INDEX + 1))
  
  # Kill the port-forward process
  kill $PORT_FORWARD_PID &> /dev/null
done

echo "Port forwarding and download complete."
