import ballerina/http;

service / on new http:Listener(2020) {
    isolated resource function get .() returns Sandwich[]|error {
        return check getAllSandwiches();
    }

    //GET by IDS
    isolated resource function get id/[int sandwich_id]() returns Sandwich|error {
        return check getSandwich(sandwich_id);
    }

    isolated resource function get id/[int sandwich_id]/price() returns float|SandoBadRequest|error {
        var sando = getSandwich(sandwich_id);
        if sando is Sandwich {
            return sando.selling_price;
        }

        SandoBadRequest result = {body: "Error on getting price"};
        return result;
    }

    isolated resource function get id/[string sandwich_id]/ingredients() returns int[]|SandoBadRequest|error {
        var sando = getSandwich(sandwich_id);
        if sando is Sandwich {
            return sando.ingredients;
        }

        SandoBadRequest result = {body: "Error on getting ingredient list"};
        return result;
    }

    //GET by NAMES
    isolated resource function get name/[string sandwich_id]() returns Sandwich|error {
        return check getSandwich(sandwich_id);
    }

    isolated resource function get name/[string sandwich_id]/price() returns float|SandoBadRequest|error {
        var sando = getSandwich(sandwich_id);
        if sando is Sandwich {
            return sando.selling_price;
        }

        SandoBadRequest result = {body: "Error on getting price"};
        return result;
    }

    isolated resource function get name/[string sandwich_id]/ingredients() returns int[]|SandoBadRequest|error {
        var sando = getSandwich(sandwich_id);
        if sando is Sandwich {
            return sando.ingredients;
        }

        SandoBadRequest result = {body: "Error on getting ingredient list"};
        return result;
    }

    isolated resource function post create(CreateSandwichDTO sandwich) returns int|error {
        return check createSandwich(sandwich);
    }

    isolated resource function put [int sandwich_id]() returns string|error {
        boolean result = check reactivateSandwich(sandwich_id);
        return result ? string `Reactivated sandwich ${sandwich_id}` : "Failure on reactivation!";
    }

    isolated resource function delete [int sandwich_id]() returns string|error {
        boolean result = check deactivateSandwich(sandwich_id);
        return result ? string `Deactivated sandwich ${sandwich_id}` : "Failure on deactivation!";
    }

    isolated resource function get init() returns boolean|error {
        _ = createTable();
        _ = check bootstrap();

        return true;
    }
}
