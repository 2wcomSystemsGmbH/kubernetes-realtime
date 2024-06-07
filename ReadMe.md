# kubernetes-realtime

This repository contains everything you need to deploy a Kubernetes DaemonSet that tests the scheduling behavior of processes in a container using the Cyclitest tool. It includes a Dockerfile to build the container image, a DaemonSet YAML configuration, and utility scripts to facilitate the testing and retrieval of results.

Inspired by the creators of the [docker-realtime](https://github.com/2b-t/docker-realtime) project, this setup aims to provide a comprehensive solution for visualizing scheduling behavior in kubernetes.

## Repository Structure

```
.
├── Dockerfile
├── daemonSet.yaml
├── scripts/
│   └── mklatencyplot.bash
├── download.sh
└── README.md
```

### Dockerfile

The Dockerfile is used to create a Docker image containing the Cyclitest tool. This image includes all necessary dependencies and scripts required to run Cyclitest and generate a plot of the results.

### daemonSet.yaml

The `daemonSet.yaml` file contains the Kubernetes configuration for deploying the DaemonSet. This DaemonSet consists of:

- An init container that runs the Cyclitest tool.
- A second container that runs a simple HTTP server to serve the generated plot.

#### Environment Variables

The init container in the DaemonSet has the following environment variables to configure the Cyclitest tool and plot:

- `HIST_LOOPS`: Specifies the number of loops for Cyclitest. (default: 1000000)
- `HIST_MAX_LATENCY`: Specifies the maximum latency in microseconds for the test. (default: 400)

### scripts/

The `scripts/` directory contains shell scripts that serve as wrappers around the Cyclitest tool. These scripts help generate a plot of the scheduling behavior, which can be accessed via HTTP once the test is complete.

### download.sh

The `download.sh` script is used to download the generated plot from each pod in the DaemonSet. The script fetches the plot served over HTTP by the second container in each pod.

## Usage

### Building the Docker Image

To build the Docker image, run the following command in the root of the repository:

#### x86/amd64 based machines

```shell
docker build -t your-repo:tag .
docker push your-repo:tag
```

#### Arm based machines (Apple M-Series)

```shell
docker buildx build --tag your-repo:tag -o type=image --push --platform=linux/amd64 .
```

### Updating the DaemonSet

Before we can deploy the DaemonSet, update the image of the init container with your image and tag:

```yaml
    ...
    spec:
      terminationGracePeriodSeconds: 0
      initContainers:
        - name: cyclictest
          image: <your-repo:tag> # Replace this with your own image:tag
    ...
```

### Deploying the DaemonSet

To deploy the DaemonSet in your Kubernetes cluster, apply the DaemonSet configuration:

```bash
kubectl apply -f daemonSet.yaml
```

### Downloading the Plot

After the DaemonSet is deployed and the tests have run, you can download the generated plot from each pod using the `download.sh` script. Make sure to adjust the namespace in the script to match your use case. By default, the script assumes the `default` namespace.

```bash
./download.sh
```
