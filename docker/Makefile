version ?= v0.0.2-dev

all: build push

build:
	docker build --tag mattfemia/scrna-pipeline:${version} .
	
push:
	docker push mattfemia/scrna-pipeline:${version}
