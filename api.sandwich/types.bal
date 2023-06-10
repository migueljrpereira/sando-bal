import ballerina/http;

//API OUTPUT OBJECTS
type SandwichDTO record{
    string Name;
    float Price;
    IngredientDTO[] IngredientsList = [];
    Description[] Descriptions = [];
};

type CreateSandwichDTO record {
    string designation;
    float selling_price;
    int[] ingredients = [];
    Description[] descriptions = [];
};

type IngredientDTO record {|
    string name;
|};

//DOMAIN OBJECTS
type Sandwich record {
    int sandwich_id;
    string designation;
    float selling_price;
    int[] ingredients = [];
    Description[] descriptions = [];
};

type Ingredient record {|
    int ingredient_id;
    string name;
|};

type Description record {|
    string content;
    string language;
|};

//ERRORS

type SandoBadRequest record {|
    *http:BadRequest;
|};
