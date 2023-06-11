configurable string ingredientApiUrl = ?;
configurable string sandwichApiUrl = ?;
configurable string reservationApiUrl = ?;

# The Orchestrator class of the API Gateway, wich also implements the aggregator pattern for DTO consolidation
public isolated class Orchestrator {

    private final IngredientClient ingredientEndpoint;
    private final SandwichClient sandwichEndpoint;

    // http:Client ordersEndpoint;
    // http:Client customerEndpoint;

    public isolated function init() returns error? {

        self.ingredientEndpoint = check new ({}, ingredientApiUrl);
        self.sandwichEndpoint = check new ({}, sandwichApiUrl);
        //self.reservationEndpoint = check new ({}, reservationApiUrl);

        // customerEndpoint = check new ("http://customer_ms:2050", {httpVersion: "2.0"});
    }

    public isolated function createSandwich(SandwichDTO sandwich) returns int|error {

        CreateSandwichDTO command = {
            selling_price: sandwich.Price,
            designation: sandwich.Name,
            descriptions: sandwich.Descriptions
        };

        command.ingredients =
        from Ingredient ing in (
            from IngredientDTO dto in sandwich.IngredientsList
        select check self.getIngredient(dto.name)
            )
        select ing.ingredient_id;

        var result = check self.sandwichEndpoint->/create.post(command);
        return result;

    }

    public isolated function ReadAllIngredients() returns IngredientDTO[]|error {
        var list = check self.ingredientEndpoint->/;

        IngredientDTO[] result = from Ingredient ing in list
            select {name: ing.name};

        return result;
    }

    isolated function getIngredient(int|string token) returns Ingredient|error {
        if token is int {
            return check self.ingredientEndpoint->/id/[token];
        } else {
            return check self.ingredientEndpoint->/name/[token];
        }
    }

    # Description
    #
    # + sando - Parameter Description
    # + return - Return Value Description
    isolated function buildSandwichDto(Sandwich sando) returns SandwichDTO|error {
        SandwichDTO result = {
            Name: sando.designation,
            Descriptions: sando.descriptions,
            IngredientsList: [],
            Price: sando.selling_price
        };

        foreach int id in sando.ingredients {
            Ingredient ing = check self.getIngredient(id);
            result.IngredientsList.push({name: ing.name});
        }

        return result;
    }

}

