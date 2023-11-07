This is sample deployment of Azure API Management that uses a policy to provide API Key, limit tokens and ground the AI assitant. This way the client application and end user only have to provide the user prompt.


To deploy the samples, use `azd up` 

Examples

```
set AZURE_OPENAI_KEY=YOUR_KEY
azd up -e aoai-france-2
```

Once the API Management is deployed, an HTTP requests can be sent as demonstrated in the [Sample requests.http](Sample-Requests.http)