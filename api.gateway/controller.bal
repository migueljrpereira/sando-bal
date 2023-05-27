import ballerina/http;

listener http:Listener controllerListener = new(9090);

service /sandwich on controllerListener {

    resource function get all() returns domain:Sandwich[]|error {

        return domain:sandoCache.toArray();
         
    }
}

service /ingredient on controllerListener {

    resource function get all() returns domain:Sandwich[]|error {

        return domain:sandoCache.toArray();
         
    }
}

