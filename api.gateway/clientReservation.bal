import ballerina/http;

public isolated client class ReservationClient {
    final http:Client resCli;

    # Gets invoked to initialize the `connector`.
    #
    # + config - The configurations to be used when initializing the `connector` 
    # + serviceUrl - URL of the target service 
    # + return - An error if connector initialization failed 
    public isolated function init(ConnectionConfig config = {}, string serviceUrl = "http://localhost:2040/order") returns error? {
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
        self.resCli = check new (serviceUrl, httpClientConfig);
        return;
    }

    #
    # + return - Ok 
    resource isolated function get .() returns ReservationDTO[]|error {
        return check self.resCli->/;
    }

    #
    # + return - Ok 
    resource isolated function get [int reservation_id]() returns ReservationDTO|error {
        return check self.resCli->/id/[reservation_id];
    }

    #
    # + return - Created 
    resource isolated function post create(CreateReservationDTO payload) returns int|error {
        return check self.resCli->/create.post(payload);
    }

    #
    #
    # + return - Ok 
    resource isolated function get init() returns boolean|error {
        return check self.resCli->/init;
    }
}
