import ballerinax/postgresql.driver as _;
import ballerinax/postgresql;
import ballerina/sql;
import ballerina/io;

configurable string host = "sando-db";
configurable string username = "postgres";
configurable string password = "postgres";
configurable string database = "sandwich";
final postgresql:Client dbClient = check new (host, username, password, database);

//DEBUG CONFIG
//configurable int port = 2029;
//final postgresql:Client dbClient = check new ("localhost", username, password, database, port);

public function main() {
    _ = createTable();
};

isolated function createTable() returns boolean {

    //query instantiation error
    stream<Sandwich, sql:Error?> dbExistsResult = dbClient->query(`SELECT * FROM sandwich;`);

    if !(dbExistsResult.next() is sql:Error) {
        record {|Sandwich value;|}|error? checkNameExists = dbExistsResult.next();
        if checkNameExists is record {|Sandwich value;|} {

            io:println("api-sandwich | INF | Database exists");
            return true;
        }
    }

    //Creation of table
    sql:ParameterizedQuery createDbQuery = `CREATE TABLE Sandwich (
                                            sandwich_id SERIAL PRIMARY KEY,
                                            designation VARCHAR(255),
                                            selling_price FLOAT,
                                            is_active BOOLEAN DEFAULT TRUE
                                            );

                                            CREATE TABLE SandwichIngredients (
                                            id SERIAL PRIMARY KEY,
                                            ingredient_id INT NOT NULL,
                                            sandwich_id INT NOT NULL,
                                            FOREIGN KEY (sandwich_id) REFERENCES Sandwich(sandwich_id)
                                            );

                                            CREATE TABLE SandwichDescriptions (
                                            id SERIAL PRIMARY KEY,
                                            sandwich_id INT NOT NULL,
                                            content VARCHAR(255),
                                            language VARCHAR(255),
                                            FOREIGN KEY (sandwich_id) REFERENCES Sandwich(sandwich_id)
                                            );
                                            `;

    sql:ExecutionResult|sql:Error result = dbClient->execute(createDbQuery);

    if result is sql:Error {
        io:println("api-sandwich | ERR | Unable to create table Sandwich");
        return false;
    }

    return true;
}

isolated function getAllSandwiches() returns Sandwich[]|error {

    stream<Sandwich, sql:Error?> sandwichStream = dbClient->query(`SELECT * FROM sandwich WHERE is_active = TRUE`);
    Sandwich[] sandwiches = [];

    check from Sandwich sando in sandwichStream
        do {
            Sandwich compSando = check composeSandwich(sando);
            sandwiches.push(compSando);
        };

    return sandwiches;
}

isolated function getSandwich(int|string token) returns Sandwich|error {

    sql:ParameterizedQuery selectSandoQueryInitial = `SELECT * FROM sandwich`;
    sql:ParameterizedQuery selectSandoQueryWhere;
    if token is int {
        selectSandoQueryWhere = `WHERE sandwich_id = ${token} AND is_active = TRUE`;
    } else {
        selectSandoQueryWhere = `WHERE designation = ${token} AND is_active = TRUE`;
    }

    stream<Sandwich, sql:Error?> sandwichStream = dbClient->query(sql:queryConcat(selectSandoQueryInitial, selectSandoQueryWhere));

    record {|Sandwich value;|}|error? result = sandwichStream.next();

    if result is record {|Sandwich value;|} {
        Sandwich sando = check composeSandwich(result.value);
        return sando;
    } else {
        return error("Sandwich not found");
    }
}

isolated function createSandwich(CreateSandwichDTO command) returns int|error {

    if getSandwich(command.designation) is Sandwich {
        return error("Sandwich already exists");
    }

    //CREATE SANDWICH
    sql:ParameterizedQuery createSandwichQuery = `INSERT INTO sandwich ( designation, selling_price) 
                                                VALUES ( ${command.designation}, ${command.selling_price})`;

    var result = check dbClient->execute(createSandwichQuery);
    
    var createdId = result.lastInsertId;

    //CREATE INGREDIENT
    from int ingredient_id in command.ingredients
    do {
        if existsIngredient(ingredient_id) {
            sql:ParameterizedQuery createSandIngQuery = `INSERT INTO SandwichIngredients (sandwich_id, ingredient_id) 
                                                VALUES (${createdId}, ${ingredient_id})`;

            sql:ExecutionResult _ = check dbClient->execute(createSandIngQuery);
        } else {
            sql:ParameterizedQuery deleteSandIngQuery = `DELETE FROM sandwich WHERE sandwich_id = ${createdId};`;
            sql:ExecutionResult _ = check dbClient->execute(deleteSandIngQuery);
        }
    };

    //CREATE DESCRIPTIONS
    from Description desc in command.descriptions
    do {
        sql:ParameterizedQuery createSandDescQuery = `INSERT INTO SandwichDescriptions (sandwich_id, content, language) 
                                                VALUES (${createdId}, ${desc.content}, ${desc.language})`;

        sql:ExecutionResult _ = check dbClient->execute(createSandDescQuery);
    };

    return <int>result.affectedRowCount;
}

isolated function deactivateSandwich(int sandwichId) returns boolean|error {

    sql:ParameterizedQuery query = `UPDATE Sandwich
                                    SET is_active = FALSE
                                    WHERE sandwich_id = ${sandwichId}`;

    sql:ExecutionResult result = check dbClient->execute(query);

    return result.affectedRowCount > 0;
}

isolated function reactivateSandwich(int sandwichId) returns boolean|error {

    sql:ParameterizedQuery query = `UPDATE Sandwich
                                    SET is_active = TRUE
                                    WHERE sandwich_id = ${sandwichId}`;

    sql:ExecutionResult result = check dbClient->execute(query);

    return result.affectedRowCount > 0;
}

//COMPOSE OF MAIN AGG ROOT
isolated function composeSandwich(Sandwich sando) returns Sandwich|error {
    sql:ParameterizedQuery getIngQuery = `SELECT ingredient_id FROM SandwichIngredients WHERE sandwich_id = ${sando.sandwich_id}`;
    sql:ParameterizedQuery getDescQuery = `SELECT content, language FROM SandwichDescriptions WHERE sandwich_id = ${sando.sandwich_id}`;

    stream<Ingredient, sql:Error?> ingredientIdStream = dbClient->query(getIngQuery);
    check from Ingredient value in ingredientIdStream
        do {
            sando.ingredients.push(value.ingredient_id);
        };

    stream<Description, sql:Error?> descriptionsStream = dbClient->query(getDescQuery);
    check from Description desc in descriptionsStream
        do {
            sando.descriptions.push(desc);
        };

    return sando;
}

isolated function bootstrap() returns error? {
    Sandwich[] list = [
        {selling_price: 5.99, designation: "Tosta Mista", sandwich_id: 1, ingredients: [1, 2], descriptions: [{content: "Sande tostada com fiambre e queijo", language: "pt-PT"}, {content: "Grilled sandwich with ham and cheese", language: "en-US"}]},
        {selling_price: 5.99, designation: "Americana", sandwich_id: 2, ingredients: [1, 2, 3, 4, 5], descriptions: [{content: "sande fresca com ovo e fiambre", language: "pt-PT"}, {content: "Fresh sandwich with ham and egg", language: "en-US"}]},
        {selling_price: 5.99, designation: "Mig Back", sandwich_id: 3, ingredients: [7, 5, 8, 6, 3, 2], descriptions: [{content: "Reinterpretação do famoso hamburger", language: "pt-PT"}, {content: "Remake of the famous burger", language: "en-US"}]}
    ];

    foreach Sandwich item in list {
        _ = check createSandwich(item);
    }
}
