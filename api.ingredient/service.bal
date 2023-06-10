import ballerina/http;

service /ingredient on new http:Listener(2030) {
    resource isolated function get .() returns Ingredient[]|error {
        return check getAllIngredients();
    }

    resource isolated function get id/[int ingredient_id]() returns Ingredient|error {
        return check getIngredient(ingredient_id);
    }

    resource isolated function get name/[string ingredient_name]() returns Ingredient|error {
        return check getIngredientByName(ingredient_name);
    }

    resource isolated function post id/list(int[] ingredient_ids) returns Ingredient[]|error {
        Ingredient[] list = [];
        foreach int id in ingredient_ids {
            list.push(check getIngredient(id));
        }
        return list;
    }

    resource isolated function post name/list(string[] ingredient_names) returns Ingredient[]|error {
        Ingredient[] list = [];
        foreach string name in ingredient_names {
            list.push(check getIngredientByName(name));
        }
        return list;
    }

    resource isolated function post .(string name) returns int|error {
        return check createIngredient(name);
    }

    resource isolated function get init() returns boolean|error? {
        _ = createTable();
        _ = check bootstrap();

        return true;
    }
}
