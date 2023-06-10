import ballerina/http;

listener http:Listener controllerListener = new (9090);
final Orchestrator orca = check new ();

service /sandwich on controllerListener {

    resource function post create(SandwichDTO sand) returns int|error {
        return check orca.createSandwich(sand);
    }
}

service /ingredient on controllerListener {

    resource function get all() returns IngredientDTO[]|error {
        return check orca.ReadAllIngredients();
    }
}

