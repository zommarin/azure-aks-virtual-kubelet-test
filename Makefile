#
# Collection of commands to create and maintain the AKS cluster with virtual kubelet
#

include vars.mk

KUBECONFIG=$(HOME)/.kube/$(CLUSTER_NAME).yaml
export KUBECONFIG

# Create cluster according to: https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough
.PHONLY: create-aks-cluster
create-aks-cluster:
	az group create \
		--name $(RESOURCE_GROUP) \
		--location $(LOCATION)
	az aks create \
		--resource-group $(RESOURCE_GROUP) \
		--location $(LOCATION) \
		--name $(CLUSTER_NAME) \
		--node-count 1 \
		--enable-addons monitoring \
		--admin-username $(USER) \
		--kubernetes-version $(K8S_VERSION) \
		--network-plugin azure

get-credentials:
	az aks get-credentials \
		--resource-group $(RESOURCE_GROUP) \
		--name $(CLUSTER_NAME) \
		--file $(KUBECONFIG) \
		--admin

.PHONY: install-helm
install-helm:
	kubectl apply -f k8s-specs/tiller-rbac.yaml
	helm init --service-account tiller

# Install Virtual Kubelet according to: https://docs.microsoft.com/en-us/azure/aks/virtual-kubelet
.PHONY: install-virtual-kubelet
install-virtual-kubelet:
	kubectl apply -f k8s-specs/rbac-virtual-kubelet.yaml
	az aks install-connector \
		--resource-group $(RESOURCE_GROUP) \
		--name $(CLUSTER_NAME) \
		--connector-name virtual-kubelet \
		--os-type Linux

.PHONY: install-test-app
install-test-app:
	kubectl apply -f k8s-specs/virtual-kubelet-linux.yaml

.PHONY: install-ubuntu-util
install-ubuntu-util:
	kubectl apply -f k8s-specs/ubuntu-util-vk.yaml
	kubectl apply -f k8s-specs/ubuntu-util.yaml

remove-virtual-kubelet:
	az aks remove-connector \
		--resource-group $(RESOURCE_GROUP) \
		--name $(CLUSTER_NAME) \
		--connector-name virtual-kubelet

delete-aks-cluster:
	az group delete \
		--resource-group $(RESOURCE_GROUP) \
		--name $(CLUSTER_NAME)
