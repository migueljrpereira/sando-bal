import ballerina/http;

public isolated client class SandwichClient {
    final http:Client sandCli;

    # Gets invoked to initialize the `connector`.
    #
    # + config - The configurations to be used when initializing the `connector` 
    # + serviceUrl - URL of the target service 
    # + return - An error if connector initialization failed 
    public isolated function init(ConnectionConfig config = {}, string serviceUrl = "http://localhost:2020/sandwich") returns error? {
        http:ClientConfiguration httpClientConfig = {httpVersion: config.httpVersion, timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
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
        self.sandCli = check new (serviceUrl, httpClientConfig);
        return;
    }

    #
    # + return - Ok 
    resource isolated function get .() returns SandwichDTO[]|error {
        return check self.sandCli->/;
    }

    #
    # + return - Ok 
    resource isolated function get id/[int sandwich_id]() returns SandwichDTO|error {
        return check self.sandCli->/id/[sandwich_id];
    }

    #
    # + return - Ok 
    resource isolated function get id/[int sandwich_id]/price() returns decimal|error {
        return check self.sandCli->/id/[sandwich_id]/price;
    }

    #
    # + return - Ok 
    resource isolated function get id/[string sandwich_id]/ingredients() returns int[]|error {
        return check self.sandCli->/id/[sandwich_id]/ingredients;
    }

    #
    # + return - Ok 
    resource isolated function get name/[string sandwich_id]() returns SandwichDTO|error {
        return check self.sandCli->/name/[sandwich_id];
    }

    #
    # + return - Ok 
    resource isolated function get name/[string sandwich_id]/price() returns decimal|error {
        return check self.sandCli->/name/[sandwich_id]/price;
    }

    #
    # + return - Ok 
    resource isolated function get name/[string sandwich_id]/ingredients() returns int[]|error {
        return check self.sandCli->/name/[sandwich_id]/ingredients;
    }

    #
    # + return - Created 
    resource isolated function post create(CreateSandwichDTO payload) returns int|error {
        return check self.sandCli->/create.post(payload);
    }

    #
    # + return - Ok 
    resource isolated function put [int sandwich_id]() returns string|error {
        return check self.sandCli->/[sandwich_id].put({message: ""});
    }

    #
    # + return - Ok 
    resource isolated function delete [int sandwich_id]() returns string|error {
        return check self.sandCli->/[sandwich_id].delete();
    }

    #
    #
    # + return - Ok 
    resource isolated function get init() returns boolean|error {
        return check self.sandCli->/init;
    }
}
