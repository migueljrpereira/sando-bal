import ballerina/http;
import migueljrpereira/sandobal.domain;

service /sandwich on new http:Listener(2020) {

    # Description
    # + return - Return Value Description
    resource function get list() returns domain:Sandwich[]|error {
        return domain:sandoCache.toArray();
    }

    resource function get .(string name) returns domain:Sandwich|http:NotFound|error {
        if (domain:sandoCache.hasKey(name)) {
            return domain:sandoCache.get(name);
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