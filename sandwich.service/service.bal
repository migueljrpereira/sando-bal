import ballerina/http;
import migueljrpereira/sandobal.domain as domain;


# A service representing a network-accessible API
# bound to port `9090`.
service /sandwich on new http:Listener(2020) {

    # Description
    # + return - Return Value Description
    resource function get list() returns domain:Sandwich[]|error {
        return domain:sandoCache.toArray();
    }

    resource function get .(string sandoName) returns domain:Sandwich|http:NotFound|error {
        if (domain:sandoCache.hasKey(sandoName)) {
            return domain:sandoCache.get(sandoName);
        }
        return http:NOT_FOUND;
    }

    resource function post .(@http:Payload domain:Sandwich newSando) returns http:Created|http:BadRequest|error {

        if (domain:sandoCache.hasKey(newSando.designation)) {
            return http:BAD_REQUEST;
        }

        domain:sandoCache.add(newSando);

        return http:CREATED;
    }
}