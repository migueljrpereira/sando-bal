import ballerina/http;
import ballerina/io;

isolated http:Client clientEndpoint = check new ("http://sando-ms:2020", {httpVersion: "2.0"});

isolated function getSandwich(int id) returns Sandwich? {
    Sandwich|http:ClientError? response;

    lock {
        response = clientEndpoint->get("/id/" + id.toString(), (), Sandwich);
    }

    if response is Sandwich {
        //io:println("api-sandwich | INF | Got Sandwich " + response.toJsonString());
        return response;
    } else {
        io:println("api-sandwich | ERR | Sandwich id=" + id.toString() + " does not exist. Check sandwich definition.");
        return ();
    }
};

isolated function existsSandwich(int ingredient_id) returns boolean {
    return getSandwich(ingredient_id) is Sandwich;
}
