import ballerinax/postgresql.driver as _;
import ballerinax/postgresql;
import ballerina/sql;
import ballerina/io;
import ballerina/time;

configurable string host = "reservation-db";
configurable string username = "postgres";
configurable string password = "postgres";
configurable string database = "reservation";
final postgresql:Client dbClient = check new (host, username, password, database);

//DEBUG CONFIG
//configurable int port = 2029;
//final postgresql:Client dbClient = check new ("localhost", username, password, database, port);

public function main() {
    _ = createTable();
};

isolated function createTable() returns boolean {

    //query instantiation error
    stream<Reservation, sql:Error?> dbExistsResult = dbClient->query(`SELECT * FROM reservation;`);

    if !(dbExistsResult.next() is sql:Error) {
        record {|Reservation value;|}|error? checkNameExists = dbExistsResult.next();
        if checkNameExists is record {|Reservation value;|} {

            io:println("api-Reservation | INF | Database exists");
            return true;
        }
    }

    //Creation of table
    sql:ParameterizedQuery createDbQuery = `CREATE TABLE Reservation (
                                            reservation_id SERIAL PRIMARY KEY,
                                            reservation_time INT NOT NULL,
                                            delivery_time INT NOT NULL
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
        io:println("api-Reservation | ERR | Unable to create table Reservation");
        return false;
    }

    return true;
}

isolated function getAllReservations() returns Reservation[]|error {

    stream<Reservation, sql:Error?> ReservationStream = dbClient->query(`SELECT * FROM Reservation`);
    Reservation[] Reservations = [];

    check from Reservation sando in ReservationStream
        do {
            Reservation compSando = check composeReservation(sando);
            Reservations.push(compSando);
        };

    return Reservations;
}

isolated function getReservation(int ReservationId) returns Reservation|error {

    sql:ParameterizedQuery selectSandoQuery = `SELECT * FROM Reservation WHERE Reservation_id = ${ReservationId}`;

    stream<Reservation, sql:Error?> ReservationStream = dbClient->query(selectSandoQuery);

    record {|Reservation value;|}|error? result = ReservationStream.next();

    if result is record {|Reservation value;|} {
        Reservation sando = check composeReservation(result.value);
        return sando;
    } else {
        return error("Reservation not found");
    }
}

isolated function createReservation(CreateReservationDTO dto) returns int|error {
    //CREATE Reservation
    sql:ParameterizedQuery createReservationQuery = `INSERT INTO Reservation (reservation_time, delivery_time) 
                                                VALUES (${time:utcToString(time:utcNow())}, ${time:utcToString(time:utcAddSeconds(time:utcNow(),1800))})`;

    sql:ExecutionResult result = check dbClient->execute(createReservationQuery);
    int reservationId = <int>result.lastInsertId;

    //CREATE ReservationItem
    from CreateReservationItem item in dto.items
    do {
        if existsSandwich(item.sandwich_id) {
            sql:ParameterizedQuery createSandIngQuery = `INSERT INTO ReservationItems (reservation_id, sandwich_id, quantity, selling_price) 
                                                VALUES (${reservationId}, ${item.sandwich_id}, ${item.quantity}, ${item.item_price})`;

            sql:ExecutionResult _ = check dbClient->execute(createSandIngQuery);
        }else{
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

    return reserve;
}
