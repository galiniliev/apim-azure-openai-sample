param apiManagementServiceName string = ''
param apiManagementLoggerName string = ''
param path string = 'open-ai'

module restApiDefinition '../core/gateway/rest-api.bicep' = if (!empty(apiManagementServiceName)) {
  name: 'open-ai-api-definition'
  params: {
    name: 'open-ai'
    apimServiceName: apiManagementServiceName
    apimLoggerName: apiManagementLoggerName
    path: path
    // policy: loadTextContent('../../src/ApiManagement/StarWarsRestApi/policy.xml')
    definition: loadTextContent('./chat-open-ai-openapi.json')
  }
}

output gatewayUri string = restApiDefinition.outputs.serviceUrl
