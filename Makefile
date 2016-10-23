USER=iwalz
NAME=initial-deployment
VERSION=0.0.1
REGISTRY_URL=$(USER)/$(NAME)

pwd=$(shell pwd)

docker:
	docker build --no-cache=true -t $(REGISTRY_URL):latest .

run:
	docker run -d --name initial-deployment $(REGISTRY_URL):latest

stop:
	docker stop initial-deployment && docker rm initial-deployment

bash:
	docker run --entrypoint /bin/bash -it $(REGISTRY_URL) 

push:
	@echo $(VERSION)
	@echo $(REGISTRY_URL)
	@docker tag -f "$(REGISTRY_URL):latest" "$(REGISTRY_URL):$(VERSION)"
	@docker tag -f "$(REGISTRY_URL):latest" "$(REGISTRY_URL):latest"
	@docker push "$(REGISTRY_URL):$(VERSION)"
	@docker push "$(REGISTRY_URL):latest"