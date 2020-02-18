DOCKER := $(shell which docker 2>/dev/null)

rm-dangling-images:
	$(shell $(DOCKER) rmi $($(DOCKER) images -q -f dangling=true`))

docker-help:
	@echo "\n\
  (docker.mk)\n\
  rm-dangling-images:  Remove all dangling images\n\
	";

.PHONY: docker-help
