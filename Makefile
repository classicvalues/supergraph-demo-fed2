.PHONY: default
default: demo

.PHONY: ci
ci: supergraph docker-build-force docker-up-local smoke docker-down

.PHONY: ci-router
ci-router: supergraph docker-build-force docker-up-local-router smoke docker-down

.PHONY: demo
demo: publish take-five docker-up smoke docker-down

.PHONY: demo-local
demo-local: supergraph docker-up-local smoke docker-down

.PHONY: demo-local-router
demo-local-router: supergraph docker-up-local-router smoke docker-down-router

.PHONY: demo-rebuild
demo-rebuild: supergraph docker-build-force docker-up-local smoke docker-down

.PHONY: docker-up
docker-up: docker-up-local

.PHONY: docker-up-local
docker-up-local:
	docker-compose -f docker-compose.yml up -d
	@sleep 2
	@docker logs apollo-gateway

.PHONY: docker-up-local-router
docker-up-local-router:
	docker-compose -f docker-compose.router.yml up -d
	@sleep 2
	@docker logs apollo-router

.PHONY: docker-build
docker-build:
	docker-compose build

.PHONY: docker-build-force
docker-build-force:
	docker-compose build --no-cache --pull --parallel --progress plain

.PHONY: docker-build-router
docker-build-router:
	@docker build -t supergraph-demo-fed2_apollo-router router/. --no-cache

.PHONY: query
query:
	@.scripts/query.sh

.PHONY: smoke
smoke:
	@.scripts/smoke.sh

.PHONY: docker-down
docker-down:
	docker-compose down --remove-orphans

.PHONY: docker-down-router
docker-down-router:
	docker-compose -f docker-compose.router.yml down --remove-orphans

.PHONY: supergraph
supergraph: config compose

.PHONY: config
config:
	.scripts/config.sh > ./supergraph.yaml

.PHONY: compose
compose:
	.scripts/compose.sh

.PHONY: publish
publish:
	.scripts/publish.sh

.PHONY: unpublish
unpublish:
	.scripts/unpublish.sh

.PHONY: graph-api-env
graph-api-env:
	@.scripts/graph-api-env.sh

.PHONY: check-products
check-products:
	.scripts/check-products.sh

.PHONY: check-all
check-all:
	.scripts/check-all.sh

.PHONY: docker-up-zipkin
docker-up-zipkin:
	docker-compose -f docker-compose.otel-zipkin.yml up -d
	@sleep 2
	docker-compose -f docker-compose.otel-zipkin.yml logs

.PHONY: docker-down-zipkin
docker-down-zipkin:
	docker-compose -f docker-compose.otel-zipkin.yml down

.PHONY: docker-up-otel-collector
docker-up-otel-collector:
	docker-compose -f docker-compose.otel-collector.yml up -d
	@sleep 2
	docker-compose -f docker-compose.otel-collector.yml logs

.PHONY: docker-down-otel-collector
docker-down-otel-collector:
	docker-compose -f docker-compose.otel-collector.yml down

.PHONY: docker-up-router-otel
docker-up-router-otel:
	docker-compose -f docker-compose.router-otel.yml up -d
	@sleep 2
	docker-compose -f docker-compose.router-otel.yml logs

.PHONY: docker-down-router-otel
docker-down-router-otel:
	docker-compose -f docker-compose.router-otel.yml down

.PHONY: dep-act
dep-act:
	curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s v0.2.23

ubuntu-latest=ubuntu-latest=catthehacker/ubuntu:act-latest

.PHONY: act
act: act-ci-local

.PHONY: act-ci-local
act-ci-local:
	act -P $(ubuntu-latest) -W .github/workflows/main.yml --detect-event

.PHONY: act-ci-local-router
act-ci-local-router:
	act -P $(ubuntu-latest) -W .github/workflows/main-router.yml --detect-event

.PHONY: act-ci-managed
act-ci-managed:
	act -P $(ubuntu-latest) -W .github/workflows/managed.yml --secret-file graph-api.env --detect-event -j ci-docker-managed

.PHONY: act-rebase
act-rebase:
	act -P $(ubuntu-latest) -W .github/workflows/rebase.yml -s GITHUB_TOKEN --secret-file docker.secrets --detect-event

.PHONY: act-release
act-release:
	act -P $(ubuntu-latest) -W .github/workflows/release.yml --secret-file docker.secrets

.PHONY: act-subgraph-check
act-subgraph-check:
	act -P $(ubuntu-latest) -W .github/workflows/subgraph-check.yml --secret-file graph-api.env --detect-event

.PHONY: act-subgraph-deploy-publish
act-subgraph-deploy-publish:
	act -P $(ubuntu-latest) -W .github/workflows/subgraph-deploy-publish.yml --secret-file graph-api.env --detect-event

.PHONY: docker-prune
docker-prune:
	.scripts/docker-prune.sh

.PHONY: take-five
take-five:
	@echo waiting for robots to finish work ...
	@sleep 5
