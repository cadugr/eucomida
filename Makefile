# Makefile for managing the Kubernetes deployment of the eu-comida application.

# Default target to run when 'make' is called without arguments.
.PHONY: all
all: deploy

# Target to deploy the entire stack.
# It creates the cluster, builds and imports the local image, and applies the Kubernetes manifests.
.PHONY: deploy
deploy: create-cluster build-and-import-image apply-manifests
	@echo "----------------------------------------------------------------"
	@echo "Deployment finished!"
	@echo "----------------------------------------------------------------"
	@echo "You can check the status of the services with:"
	@echo "  kubectl get services -o wide"
	@echo "----------------------------------------------------------------"

# Target to build the Docker image and import it into the k3d cluster.
.PHONY: build-and-import-image
build-and-import-image:
	@echo "Building Docker image 'cadugr/eu-comida:latest..."
	@docker build -t cadugr/eu-comida:latest .
	@echo "Importing image into k3d cluster 'eu-comida-cluster..."
	@k3d image import cadugr/eu-comida:latest -c eu-comida-cluster

# Target to create the k3d cluster.
# It maps the application and RabbitMQ management ports to the host.
.PHONY: create-cluster
create-cluster:
	@if ! k3d cluster list | grep -q "eu-comida-cluster"; then \
		echo "Creating k3d cluster 'eu-comida-cluster..."; \
		k3d cluster create eu-comida-cluster --port "8080:8080@loadbalancer" --port "15672:15672@loadbalancer"; \
	else \
		echo "k3d cluster 'eu-comida-cluster' already exists."; \
	fi


# Target to apply all Kubernetes manifests from the 'k8s' directory.
# Infra (MySQL/RabbitMQ) goes to 'eucomida-infra' and the app to 'eucomida',
# mirroring how the ArgoCD Applications target them in the real cluster.
.PHONY: apply-manifests
apply-manifests:
	@echo "Creating namespaces..."; \
	kubectl create namespace eucomida --dry-run=client -o yaml | kubectl apply -f -; \
	kubectl create namespace eucomida-infra --dry-run=client -o yaml | kubectl apply -f -; \
	echo "Applying Kubernetes manifests..."; \
	kubectl apply -n eucomida-infra -f k8s/mysql.yaml -f k8s/rabbitmq.yaml; \
	kubectl apply -n eucomida -f k8s/app.yaml

# Target to delete the k3d cluster.
.PHONY: delete-cluster
delete-cluster:
	@echo "Deleting k3d cluster 'eu-comida-cluster..."; \
    k3d cluster delete eu-comida-cluster
