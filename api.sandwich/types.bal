import ballerina/http;

type CreateSandwichDTO record {|
    string designation;
    float selling_price;
    int[] ingredients = [];
    Description[] descriptions = [];
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
