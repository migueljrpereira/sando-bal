import ballerina/http;
import ballerina/io;

isolated http:Client clientEndpoint = check new ("http://ingredient-ms:2030", {httpVersion: "2.0"});

isolated function getIngredient(int|string id) returns Ingredient? {
    //io:println("api-sandwich | DBG | Calling /ingredient/" + id.toString());
    Ingredient|http:ClientError? response;

    lock {
        if id is int {
            response = clientEndpoint->/ingredient/[id]/id;
        } else {
            response = clientEndpoint->/ingredient/[id]/name;
        }
    }

    if response is Ingredient {
        //io:println("api-sandwich | INF | Got Ingredient " + response.name);
        return response;
    } else {
        io:println("api-sandwich | ERR | Ingredient id=" + id.toString() + " does not exist. Check sandwich definition.");
        //io:println(response);
        return ();
    }
};

isolated function existsIngredient(int|string ingRef) returns boolean {
    return getIngredient(ingRef) is Ingredient;
}
