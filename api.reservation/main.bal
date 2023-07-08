import ballerinax/postgresql.driver as _;
import ballerinax/postgresql;
import ballerina/sql;
import ballerina/log;
import ballerina/time;

configurable string host = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable int port = 5432;

final postgresql:Client dbClient;

isolated function init() returns error? {
    string dbName = "reservation";

    //Create initial client to check database existence
    postgresql:Client|sql:Error dbCreateClient = new (host, username, password, "postgres", port);
    if dbCreateClient is sql:Error {
        log:printError(dbCreateClient.message(), dbCreateClient);
        return;
    }

    //Check database existence
    sql:ParameterizedQuery checkDb = `SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower(reservation);`;
    sql:ExecutionResult|sql:Error checkDbExists = dbCreateClient->execute(checkDb);
    if checkDbExists is sql:Error {
        //Create database
        sql:ExecutionResult|sql:Error createDb = dbCreateClient->execute(`CREATE DATABASE reservation`);
        if createDb is sql:Error {
            log:printError(createDb.message(), createDb);
        }

    }

    _ = check dbCreateClient.close();

    dbClient = check new (host, username, password, database, port);
    //Creation of table
    sql:ParameterizedQuery createDbQuery = `CREATE TABLE Reservation (
                                            reservation_id SERIAL PRIMARY KEY,
                                            reservation_time VARCHAR(255) NOT NULL,
                                            delivery_time VARCHAR(255) NOT NULL
                                            );

                                            CREATE TABLE ReservationItems (
                                            reservationitem_id SERIAL PRIMARY KEY,
                                            reservation_id INT NOT NULL,
                                            sandwich_id INT NOT NULL,
                                            quantity INT NOT NULL,
                                            selling_price FLOAT NOT NULL,
                                            FOREIGN KEY (Reservation_id) REFERENCES Reservation(Reservation_id)
                                            );
                                            `;

    sql:ExecutionResult|sql:Error result = dbClient->execute(createDbQuery);

    if result is sql:Error {
        log:printError("Unable to create table Reservation: " + result.message(), result, result.stackTrace())
;
    } else {
        log:printInfo("Database created!");

    }
}

isolated function getAllReservations() returns Reservation[]|error {

    stream<Reservation, sql:Error?> ReservationStream = dbClient->query(`SELECT * FROM Reservation`);
    Reservation[] Reservations = [];

    check from Reservation sando in ReservationStream
        do {
            Reservation compSando = check composeReservation(sando);
            Reservations.push(compSando);
        };

    _ = check ReservationStream.close();
    return Reservations;
}

isolated function getReservation(int ReservationId) returns Reservation|error {

    sql:ParameterizedQuery selectSandoQuery = `SELECT * FROM Reservation WHERE Reservation_id = ${ReservationId}`;

    stream<Reservation, sql:Error?> ReservationStream = dbClient->query(selectSandoQuery);

    record {|Reservation value;|}|error? result = ReservationStream.next();
    _ = check ReservationStream.close();

    if result is record {|Reservation value;|} {
        Reservation sando = check composeReservation(result.value);
        return sando;
    } else {
        return error("Reservation not found");
    }
}

isolated function createReservation(CreateReservationDTO dto) returns int|error {

    string timeStart = time:utcToString(time:utcNow());
    string timeEnd = time:utcToString(time:utcAddSeconds(time:utcNow(), 1800));
    //CREATE Reservation
    sql:ParameterizedQuery createReservationQuery = `INSERT INTO Reservation (reservation_time, delivery_time) 
                                                VALUES (${timeStart}, ${timeEnd})`;

    sql:ExecutionResult result = check dbClient->execute(createReservationQuery);
    int reservationId = <int>result.lastInsertId;

    //CREATE ReservationItem
    from CreateReservationItem item in dto.items
    do {
        if existsSandwich(item.sandwich_id) {
            sql:ParameterizedQuery createSandIngQuery = `INSERT INTO ReservationItems (reservation_id, sandwich_id, quantity, selling_price) 
                                                VALUES (${reservationId}, ${item.sandwich_id}, ${item.quantity}, ${item.item_price})`;

            sql:ExecutionResult _ = check dbClient->execute(createSandIngQuery);
        } else {
            sql:ParameterizedQuery deleteSandIngQuery = `DELETE FROM Reservation WHERE reservation_id = ${reservationId};`;
            sql:ExecutionResult _ = check dbClient->execute(deleteSandIngQuery);
        }
    };

    return reservationId;
}

//COMPOSE OF MAIN AGG ROOT
isolated function composeReservation(Reservation reserve) returns Reservation|error {
    sql:ParameterizedQuery getItemsQuery = `SELECT * FROM ReservationItems WHERE Reservation_id = ${reserve.reservation_id}`;

    stream<ReservationItem, sql:Error?> itemsIdStream = dbClient->query(getItemsQuery);
    check from ReservationItem value in itemsIdStream
        do {
            reserve.items.push(value);
        };

    _ = check itemsIdStream.close();
    return reserve;
}
