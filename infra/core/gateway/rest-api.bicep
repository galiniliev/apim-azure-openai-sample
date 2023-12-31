@description('The display name of the API')
param name string

@description('The name of the API Management service')
param apimServiceName string

@description('The name of the API Management logger to use (or blank to disable)')
param apimLoggerName string

@description('The path that will be exposed by the API Management service')
param path string = 'openai'

@description('The URL of the backend service to proxy the request to')
param serviceUrl string = 'https://httpbin.org'

@description('The policy to configure.  If blank, a default policy will be used.')
param policy string = ''

@description('The OpenAPI description of the API')
param definition string = ''

@description('The named values that need to be defined prior to the policy being uploaded')
param namedValues array = []

@description('The number of bytes of the request/response body to record for diagnostic purposes')
param logBytes int = 8192

var logSettings = {
  headers: [ 'Content-type', 'User-agent' ]
  body: { bytes: logBytes }
}

resource apimService 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimServiceName
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2022-08-01' existing = if (!empty(apimLoggerName)) {
  name: apimLoggerName
  parent: apimService
}

var realPolicy = empty(policy) ? loadTextContent('./default-policy.xml') : policy

resource restApi 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  name: name
  parent: apimService
  properties: {
    displayName: name
    path: path
    protocols: [ 'https' ]
    subscriptionRequired: false
    type: 'http'
    format: 'openapi'
    serviceUrl: serviceUrl
    value: definition
  }
}

resource apimNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = [for nv in namedValues: {
  name: nv.key
  parent: apimService
  properties: {
    displayName: nv.key
    secret: contains(nv, 'secret') ? nv.secret : false
    value: nv.value
  }
}]

resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2022-08-01' = {
  name: 'policy'
  parent: restApi
  properties: {
    format: 'rawxml'
    value: realPolicy
  }
  dependsOn: [
    apimNamedValue
  ]
}

// resource apiOperation 'Microsoft.ApiManagement/service/apis/operations@2022-08-01' = {
//   name: '${apimServiceName}/${name}/chat'
//     properties: {
//       displayName: 'chat'
//       method: 'POST'
//       urlTemplate: '/chat'
//       templateParameters: []
//       description: 'Sample API Operation that demonstrates proxying to Azure OpenAI service and does built-in grounding.'
//       responses: []
//       policies: openAIPolicy
//     }
//   dependsOn: [
//     apimNamedValue
//   ]
// }

// resource operationPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-08-01' = {
//   name: 'policy'
//   parent: apiOperation
//   properties: {
//     format: 'rawxml'
//     value: openAIPolicy
//   }
//   dependsOn: [
//     apimNamedValue
//   ]
// }

resource diagnosticsPolicy 'Microsoft.ApiManagement/service/apis/diagnostics@2022-08-01' = if (!empty(apimLoggerName)) {
  name: 'applicationinsights'
  parent: restApi
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'W3C'
    logClientIp: true
    loggerId: apimLogger.id
    metrics: true
    verbosity: 'verbose'
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: logSettings
      response: logSettings
    }
    backend: {
      request: logSettings
      response: logSettings
    }
  }
}

output serviceUrl string = '${apimService.properties.gatewayUrl}/${path}'
