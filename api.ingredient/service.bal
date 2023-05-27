import ballerina/http;

service /ingredient on new http:Listener(2030) {
    resource isolated function get .() returns Ingredient[]|error {
        return check getAllIngredients();
    }

    resource isolated function get [int ingredient_id]() returns Ingredient?|error {
        return check getIngredient(ingredient_id);
    }

    resource isolated function post .(Ingredient ingredient) returns int|error {
        return check createIngredient(ingredient);
    }

    resource isolated function get init() returns boolean|error? {
        _ = createTable();
        _ = check bootstrap();

        return true;
    }
}
