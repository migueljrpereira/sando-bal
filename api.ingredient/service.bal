import ballerina/http;
import migueljrpereira/sandobal.domain;

service /ingredient on new http:Listener(3030) {
    resource function get list() returns domain:Ingredient[]|error {
        return domain:ingredientsCache.toArray();
    }

    resource function get .(string ingName) returns domain:Ingredient|http:NotFound|error {
        if (domain:ingredientsCache.hasKey(ingName)) {
            return domain:ingredientsCache.get(ingName);
        }
        return http:NOT_FOUND;
    }
}