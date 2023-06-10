import ballerina/http;

isolated client class IngredientClient {
    final http:Client ingCli;

    # Gets invoked to initialize the `connector`.
    #
    # + config - The configurations to be used when initializing the `connector` 
    # + serviceUrl - URL of the target service 
    # + return - An error if connector initialization failed 
    public isolated function init(ConnectionConfig config = {}, string serviceUrl = "http://localhost:2030/ingredient") returns error? {
        http:ClientConfiguration httpClientConfig = {
            httpVersion: config.httpVersion,
            timeout: config.timeout,
            forwarded: config.forwarded,
            poolConfig: config.poolConfig,
            compression: config.compression,
            circuitBreaker: config.circuitBreaker,
            retryConfig: config.retryConfig,
            validation: config.validation
        };
        do {
            if config.http1Settings is ClientHttp1Settings {
                ClientHttp1Settings settings = check config.http1Settings.ensureType(ClientHttp1Settings);
                httpClientConfig.http1Settings = {...settings};
            }
            if config.http2Settings is http:ClientHttp2Settings {
                httpClientConfig.http2Settings = check config.http2Settings.ensureType(http:ClientHttp2Settings);
            }
            if config.cache is http:CacheConfig {
                httpClientConfig.cache = check config.cache.ensureType(http:CacheConfig);
            }
            if config.responseLimits is http:ResponseLimitConfigs {
                httpClientConfig.responseLimits = check config.responseLimits.ensureType(http:ResponseLimitConfigs);
            }
            if config.secureSocket is http:ClientSecureSocket {
                httpClientConfig.secureSocket = check config.secureSocket.ensureType(http:ClientSecureSocket);
            }
            if config.proxy is http:ProxyConfig {
                httpClientConfig.proxy = check config.proxy.ensureType(http:ProxyConfig);
            }
        }
        http:Client httpEp = check new (serviceUrl, httpClientConfig);
        self.ingCli = httpEp;
        return;
    }
    #
    # + return - Ok 
    resource isolated function get .() returns Ingredient[]|error {
        return check self.ingCli->/;
    }
    
    #
    # + return - Created 
    resource isolated function post .(string name) returns int|error {
        int response = check self.ingCli->/.post(name);
        return response;
    }
    
    #
    # + return - Ok 
    resource isolated function get id/[int ingredient_id]() returns Ingredient|error {
        return check self.ingCli->/id/[ingredient_id];
    }

    #
    # + return - Ok 
    resource isolated function get name/[string ingredient_name]() returns Ingredient|error {
        return check self.ingCli->/name/[ingredient_name];
    }

    #
    # + return - Ok 
    resource isolated function post id/list(int[] ingredient_ids) returns Ingredient[]|error {     
        Ingredient[] response = check self.ingCli->/id/list.post(ingredient_ids);
        return response;
    }

    #
    # + return - Ok 
    resource isolated function post name/list(string[] ingredient_names) returns Ingredient[]|error {
        Ingredient[] response = check self.ingCli->/name/list.post(ingredient_names);
        return response;
    }

    #
    # + return - Ok 
    resource isolated function get init() returns boolean|error {
        string resourcePath = string `/init`;
        boolean response = check self.ingCli->get(resourcePath);
        return response;
    }
}
