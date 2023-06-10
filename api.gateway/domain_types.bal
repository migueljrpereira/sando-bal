import ballerina/time;
import ballerina/http;

//API OUTPUT OBJECTS
public type SandwichDTO record{
    string Name;
    float Price;
    IngredientDTO[] IngredientsList = [];
    Description[] Descriptions = [];
};

public type IngredientDTO record {|
    string name;
|};

public type CreateSandwichDTO record {
    string designation;
    float selling_price;
    int[] ingredients = [];
    Description[] descriptions = [];
};


//DOMAIN OBJECTS
public type Sandwich record {
    int sandwich_id;
    string designation;
    float selling_price;
    int[] ingredients = [];
    Description[] descriptions = [];
};

# Description
#
# + ingredient_id - Field Description  
# + name - Field Description
public type Ingredient record {|
    int ingredient_id;
    string name;
|};

type IngredientArr Ingredient[];

public type Description record {|
    string content;
    string language;
|};


type Reservation record {|
    int reservation_id;
    time:Utc reservation_time;
    time:Utc delivery_date_unix;
    ReservationItem[] items;
|};

type ReservationItem record {|
    int reservationitem_id;
    int reservation_id;
    int sandwich_id;
    int quantity;
    float item_price;
|};

type ReservationDTO record {|
    time:Utc CreatedAt;
    time:Utc ETA;
    ReservationItem[] Details;
|};

type ReservationItemDTO record {|
    SandwichDTO Sandwich;
    int Quantity;
    float Price;
|};

//ERRORS

type SandoBadRequest record {|
    *http:BadRequest;
|};

