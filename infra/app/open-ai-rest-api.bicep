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
var auzreOpenAiSwagger = loadTextContent('./2023-09-01-preview.json')
var openAIPolicy = loadTextContent('./aoai-operation-policy.xml')

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
    key: 'azureOpenAIBaseUrl'
    value: azureOpenAIBaseUrl
  }
  {
    key: 'azureAIModelName'
    value: azureAIModelName
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

module completetionWrapperAPI '../core/gateway/rest-api.bicep' = if (!empty(apiManagementServiceName)) {
  name: 'open-ai-api-definition'
  params: {
    name: 'open-ai'
    apimServiceName: apiManagementServiceName
    apimLoggerName: apiManagementLoggerName
    path: path
    definition: loadTextContent('./chat-open-ai-openapi.json')
    namedValues: namedValues
    policy: openAIPolicy
  }
}

module completetionProxyAPI '../core/gateway/rest-api.bicep' = if (!empty(apiManagementServiceName)) {
  name: 'open-ai-api-proxy'
  params: {
    name: 'open-ai-proxy'
    apimServiceName: apiManagementServiceName
    apimLoggerName: apiManagementLoggerName
    path: 'openai'
    policy: loadTextContent('./aoai-api-policy.xml')
    definition: auzreOpenAiSwagger
  }
}

output gatewayUri string = completetionWrapperAPI.outputs.serviceUrl
