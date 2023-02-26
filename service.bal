import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service /sandwich on new http:Listener(9090) {

    # A resource for testing upstream connection
    # + return - simple response
    resource function get test() returns string|error {
        return "Hello, Sando-bal here!";
    }

    resource function get list() returns Sandwich[]|error{
        return sandoCache.toArray();
    } 
}

public final table<Sandwich> key(designation) sandoCache = table [
    {designation: "mista", descriptions: [[en, "CheeseHam Sandwich"], [pt,"Sande mista"]], ingredients: [ingredientsCache.get("queijo"), ingredientsCache.get("fiambre")], sellPrice: 2.5}];


public final table<Ingredient> key(designation) ingredientsCache = table [
    { designation: "queijo"},
    { designation: "fiambre"},
    { designation: "tomate"}
];

public type Sandwich record {|
    readonly string designation;
    decimal sellPrice;
    Ingredient[] ingredients;
    [Language, string][] descriptions;
|};

public type Ingredient record {|
    readonly string designation;
|};

public enum Language {
    en = "en-EN",
    pt = "pt-PT",
    es = "es-ES",
    fr = "fr-FR",
    jp = "jp-JP"
}
