docker_build_test:
	docker build -t randmeister/algon-helm-test:local -f docker/Dockerfile_helm_test docker

docker_build:
	docker build -t randmeister/algon:local docker

helm_upgrade_local:
	helm upgrade \
		--install \
		--namespace algon \
		--set image.tag=local \
		--set image.pullPolicy=Never \
		algon charts/algon
