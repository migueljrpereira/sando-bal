import ballerina/log;

configurable string ingredientApiUrl = ?;
configurable string sandwichApiUrl = ?;
configurable string reservationApiUrl = ?;

# The Orchestrator class of the API Gateway, wich also implements the aggregator pattern for DTO consolidation
public isolated class Orchestrator {

    private final IngredientClient ingredientEndpoint;
    private final SandwichClient sandwichEndpoint;
    private final ReservationClient reservationEndpoint;

    // http:Client customerEndpoint;

    public isolated function init() returns error? {

        self.ingredientEndpoint = check new ({}, ingredientApiUrl);
        self.sandwichEndpoint = check new ({}, sandwichApiUrl);
        self.reservationEndpoint = check new ({}, reservationApiUrl);

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

    isolated function getSandwich(int|string token) returns Sandwich|error {
        if token is int {
            return check self.sandwichEndpoint->/id/[token];
        } else {
            return check self.sandwichEndpoint->/name/[token];
        }
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
            Ingredient|error ing = self.getIngredient(id);
            if ing is error {
                log:printError("There was an error: ", ing, ing.stackTrace(), id = id);
            } else {
                result.IngredientsList.push({name: ing.name});
            }
        }

        return result;
    }

    isolated function createReservation(ReservationRequestItemDTO[] payload) returns ReservationRequestResponse|error {
        CreateReservationDTO request = {items: []};

        foreach ReservationRequestItemDTO item in payload {
            Sandwich|error sando = self.getSandwich(item.Name);
            if sando is error {
                log:printError("There was an error: ", sando, sando.stackTrace(), name = item.Name);
            } else {
                request.items.push({
                    item_price: sando.selling_price,
                    quantity: item.quantity,
                    sandwich_id: sando.sandwich_id
                });
            }
        }

        log:printInfo("Saving reservation");
        int res = check self.reservationEndpoint->/create.post(request);

        float cost = 0.0;

        foreach float partial in (from CreateReservationItem item in request.items
        select item.quantity * item.item_price)
        {
            cost += partial;
        }

        ReservationRequestResponse response = {
            Response: res,
            Message: "Reservation created!",
            Cost: cost
        };

        return response;
    }

}

