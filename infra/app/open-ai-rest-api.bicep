param apiManagementServiceName string
param apiManagementLoggerName string
param path string = 'open-ai'
param azureOpenAIApiVersion string = '2023-07-01-preview'
param azureOpenAIBaseUrl string = ''
param azureAIModelName string= 'gpt-35'

@secure()
param azureOpenAIKey string

var groundingprompt = loadTextContent('./grounding-prompt.md')
var payloadgpt = loadTextContent('./payload-gpt.json')

var namedValues = [
  {
    key: 'groundingprompt'
    value: groundingprompt
  }
  {
    key: 'payloadgpt'
    value: payloadgpt
  }
  {
    key: 'apiurl'
    value: '${azureOpenAIBaseUrl}/openai/deployments/${azureAIModelName}/chat/completions'
  }
  {
    key: 'apikey'
    value: azureOpenAIKey
  }
  {
    key: 'apiversion'
    value: azureOpenAIApiVersion
  }
]

module restApiDefinition '../core/gateway/rest-api.bicep' = if (!empty(apiManagementServiceName)) {
  name: 'open-ai-api-definition'
  params: {
    name: 'open-ai'
    apimServiceName: apiManagementServiceName
    apimLoggerName: apiManagementLoggerName
    path: path
    definition: loadTextContent('./chat-open-ai-openapi.json')
    namedValues: namedValues
  }
}

output gatewayUri string = restApiDefinition.outputs.serviceUrl
