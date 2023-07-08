import ballerina/http;

listener http:Listener controllerListener = new (9090);
final Orchestrator orca = check new ();

service /sandwich on controllerListener {

    resource function post create(SandwichDTO sand) returns int|error {
        return check orca.createSandwich(sand);
    }

    resource function get [string Name]() returns SandwichDTO|error{
        return check orca.buildSandwichDto(check orca.getSandwich(Name));
    }
}

service /ingredient on controllerListener {

    resource function get all() returns IngredientDTO[]|error {
        return check orca.ReadAllIngredients();
    }
}

service /reservation on controllerListener {
    isolated resource function post create(ReservationRequestItemDTO[] payload) returns ReservationRequestResponse {
        ReservationRequestResponse|error result = orca.createReservation(payload);

        if result is error {
            return 
            {
                Response: -1,
                Message: "Failure creating reservation, check Sandwich names\n"
            };
        }

        return result;
    }
}

