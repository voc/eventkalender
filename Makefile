DOCKER_REPO := docker.pkg.github.com/voc/eventkalender/eventkalender


.PHONY: build test ruby.lint latest

build:
	docker build -t $(DOCKER_REPO):$(build_version) .
	docker push $(DOCKER_REPO):$(build_version)

latest:
	docker tag $(DOCKER_REPO):$(build_version) $(DOCKER_REPO):latest
	docker push $(DOCKER_REPO):latest

.PHONY: test
test: ruby.lint
	rake

.PHONY: ruby.lint
ruby.lint:
	rubocop -l
