import ballerina/http;
import ballerina/log;

configurable string ingredientUri = ?;
isolated http:Client clientEndpoint = check new (ingredientUri);

isolated function getIngredient(int|string id) returns Ingredient? {
    Ingredient|http:ClientError? response;

    lock {
        if id is int {
            response = clientEndpoint->/id/[id];
        } else {
            response = clientEndpoint->/name/[id];
        }
    }

    if response is Ingredient {
        return response;
    } else {
        log:printError("failure to get ingredient " + id.toString(), response);
        return ();
    }
};

isolated function existsIngredient(int|string ingRef) returns boolean {
    return getIngredient(ingRef) is Ingredient;
}
