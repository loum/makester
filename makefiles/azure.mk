AZ := $(shell which az 2>/dev/null || echo "3env/bin/az")

azure-login:
	$(AZ) login

azure-cr-login:
	$(AZ) acr login --name $(MAKESTER__CONTAINER_REGISTRY)

MAKESTER__AZURE_RESOURCE_GROUP =
MAKESTER__AZURE_TEMPLATE_FILE =
MAKESTER__AZURE_PARAMETERS = "{}"

MAKESTER__AZ_SUBGROUP = deployment group
MAKESTER__AZ_CMD = validate

azure-rm:
	$(AZ) $(MAKESTER__AZ_SUBGROUP) $(MAKESTER__AZ_CMD)\
 --resource-group ${MAKESTER__AZURE_RESOURCE_GROUP}\
 --template-file ${MAKESTER__AZURE_TEMPLATE_FILE}\
 --parameters ${MAKESTER__AZURE_PARAMETERS}

MAKESTER__AZURE_RESOURCE_NAME =
MAKESTER__AZURE_RESOURCE_TYPE =

azure-rm-del:
	$(AZ) $(MAKESTER__AZ_SUBGROUP) $(MAKESTER__AZ_CMD)\
 --verbose\
 --resource-group ${MAKESTER__AZURE_RESOURCE_GROUP}\
 --name ${MAKESTER__AZURE_RESOURCE_NAME}

azure-help:
	@echo "(makefiles/azure.mk)\n\
  azure-login         Log into Azure via CLI\n\
  azure-cr-login      Log into Azure Container Registry via CLI\n\
  azure-rm            Deploy an Azure resource using Resource Manager\n\
  azure-rm-del        Delete an Azure resource\n"

.PHONY: azure-help
