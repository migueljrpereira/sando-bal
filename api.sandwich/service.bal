import ballerina/http;

service /sandwich on new http:Listener(2020) {
    isolated resource function get .() returns SandwichDTO[]|error {
        var list = check getAllSandwiches();
        SandwichDTO[] result = [];
        foreach Sandwich sando in list {
            result.push(buildDto(sando));
        }
        return result;
    }

    isolated resource function get [int sandwich_id]() returns SandwichDTO?|error {
        var sando = check getSandwich(sandwich_id);
        if sando is Sandwich {
            return buildDto(sando);
        }
        return ();
    }

    isolated resource function post .(Sandwich sandwich) returns int|error {
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

# Description
#
# + sando - Parameter Description
# + return - Return Value Description
isolated function buildDto(Sandwich sando) returns SandwichDTO {
    SandwichDTO result = {
                            Name: sando.designation,
                            Descriptions: sando.descriptions,
                            IngredientsList: [],
                            Price: sando.selling_price
                        };

    foreach int id in sando.ingredients {
        Ingredient? ing = getIngredient(id);
        if ing is Ingredient
        {
            result.IngredientsList.push({name: ing.name});
        }
    }

    return result;
}
