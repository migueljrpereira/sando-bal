import ballerina/http;
import ballerina/log;
import ballerina/io;

configurable string ingredientUri = ?;
isolated http:Client clientEndpoint = check new (ingredientUri);

isolated function getIngredient(int|string id) returns Ingredient? {
    log:printDebug("Calling /ingredient/" + id.toString());
    Ingredient|http:ClientError? response;

    lock {
        if id is int {
            response = clientEndpoint->/ingredient/id/[id];
        } else {
            response = clientEndpoint->/ingredient/name/[id];
        }
    }

    if response is Ingredient {
        return response;
    } else {
        io:println("api-sandwich | ERR | Ingredient id=" + id.toString() + " does not exist. Check sandwich definition.");
        log:printError("failure to get ingredient " + id.toString(), response);
        return ();
    }
};

isolated function existsIngredient(int|string ingRef) returns boolean {
    return getIngredient(ingRef) is Ingredient;
}
