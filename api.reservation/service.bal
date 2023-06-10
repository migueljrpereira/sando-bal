import ballerina/http;

service /reservations on new http:Listener(2040) {
    isolated resource function get .() returns Reservation[]|error {
        return check getAllReservations();
    }

    isolated resource function get [int reservation_id]() returns Reservation|error {
        var reservationObj = getReservation(reservation_id);
        if reservationObj is Reservation {
            return reservationObj;
        }
        return error("No reservation found!");
    }

    isolated resource function post .(CreateReservationDTO obj) returns int|error {
        return check createReservation(obj);
    }

    isolated resource function get init() returns boolean|error {
        _ = createTable();

        return true;
    }
}
