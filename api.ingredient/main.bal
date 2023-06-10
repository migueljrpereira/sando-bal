import ballerinax/postgresql.driver as _;
import ballerinax/postgresql;
import ballerina/sql;
import ballerina/io;

configurable string username = "postgres";
configurable string password = "postgres";
configurable string database = "ingredient";

configurable string host = "ingredient_db";
final postgresql:Client dbClient = check new (host, username, password, database);

type Ingredient record {
    int ingredient_id;
    string name;
};

public function main() {
    _ = createTable();
}

isolated function createTable() returns boolean {

    //query instantiation error
    stream<Ingredient, sql:Error?> dbExistsResult = dbClient->query(`SELECT * FROM ingredient;`);

    if !(dbExistsResult.next() is sql:Error) {
        record {|Ingredient value;|}|error? checkNameExists = dbExistsResult.next();

        if checkNameExists is record {|Ingredient value;|} {
            io:println("api-sandwich | INF | Database exists");
            return true;
        }
    }
    
    //Creation of table
    sql:ParameterizedQuery createDbQuery = `CREATE TABLE Ingredient (
                                            ingredient_id SERIAL PRIMARY KEY,
                                            name VARCHAR(255)
                                            );`;

    sql:ExecutionResult|sql:Error result = dbClient->execute(createDbQuery);

    if result is sql:Error {
        io:println("api-ingredient | ERROR | Unable to create table Ingredient");
        return false;
    }

    return true;
}

isolated function getAllIngredients() returns Ingredient[]|error {

    stream<Ingredient, sql:Error?> ingredientStream = dbClient->query(`SELECT * FROM Ingredient`);
    Ingredient[] ingredients = [];

    check from Ingredient ingrd in ingredientStream
        do {
            ingredients.push(ingrd);
        };

    _ = check ingredientStream.close();
    return ingredients;
}

isolated function getIngredient(int ingredientId) returns Ingredient|error {

    sql:ParameterizedQuery selectIngredientQuery = `SELECT * FROM Ingredient WHERE ingredient_id = ${ingredientId}`;

    stream<Ingredient, sql:Error?> ingredientStream = dbClient->query(selectIngredientQuery);

    record {|Ingredient value;|}|error? result = ingredientStream.next();

    _ = check ingredientStream.close();
    if result is record {|Ingredient value;|} {
        return result.value;
    } else {
        return error("Ingredient not found");
    }
}

isolated function getIngredientByName(string name) returns Ingredient|error {

    sql:ParameterizedQuery selectIngredientQuery = `SELECT * FROM Ingredient WHERE name = ${name}`;

    stream<Ingredient, sql:Error?> ingredientStream = dbClient->query(selectIngredientQuery);

    record {|Ingredient value;|}|error? result = ingredientStream.next();

    _ = check ingredientStream.close();
    if result is record {|Ingredient value;|} {
        return result.value;
    } else {
        return error("Ingredient not found");
    }
}

isolated function createIngredient(string name) returns int|error {
    if getIngredientByName(name) is error {

        //CREATE Ingredient
        sql:ParameterizedQuery createIngredientQuery = `INSERT INTO Ingredient (name) 
                                                VALUES (${name})`;

        sql:ExecutionResult result = check dbClient->execute(createIngredientQuery);

        return <int>result.affectedRowCount;

    } else {
        return error("Ingredient already exisits");
    }
}

isolated function bootstrap() returns error? {
    Ingredient[] list = [
        {ingredient_id: 1, name: "Fiambre"},
        {ingredient_id: 2, name: "Queijo"},
        {ingredient_id: 3, name: "Tomate"},
        {ingredient_id: 4, name: "Ovo"},
        {ingredient_id: 5, name: "Bacon"},
        {ingredient_id: 6, name: "Alface"},
        {ingredient_id: 7, name: "Cebola"},
        {ingredient_id: 8, name: "Hamburger"}
    ];

    foreach Ingredient item in list {
        int|error res = createIngredient(item.name);
        io:println(res);
    }
}
