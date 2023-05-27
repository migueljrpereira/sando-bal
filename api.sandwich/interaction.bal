import ballerina/http;
import ballerina/io;

isolated http:Client clientEndpoint = check new ("http://ingredient_ms:2030", {httpVersion: "2.0"});

isolated function getIngredient(int id) returns Ingredient? {
    //io:println("api-sandwich | DBG | Calling /ingredient/" + id.toString());
    Ingredient|http:ClientError? response;

    lock {
        response = clientEndpoint->get("/ingredient/" + id.toString(), (), Ingredient);
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

isolated function existsIngredient(int ingredient_id) returns boolean {
    return getIngredient(ingredient_id) is Ingredient;
}
