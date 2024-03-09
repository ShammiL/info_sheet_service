import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerinax/googleapis.sheets as sheets;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

public type StarRecord record {|
    string ID;
    string name;
    int starredRepoCount;
|};

public type BookRecord record {|
    string ID;
    string name;
    string bookOrder;
|};

sheets:ConnectionConfig spreadsheetConfig = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: refreshToken
    }
};

sheets:Client spreadsheetClient = check new (spreadsheetConfig);
string spreadSheetId = "1cE704Mxq0BR1NaEITlFB3SbvItlVsCeUHDyNWBPKL6Y";

service /students on new http:Listener(9092) {
    resource function post star(@http:Payload StarRecord starRecord) returns http:Ok|http:InternalServerError {
        sheets:ValueRange|error errResponse = spreadsheetClient->appendValue(spreadSheetId,
            [starRecord.ID, starRecord.name, starRecord.starredRepoCount], {sheetName: "starRepo"});
        if errResponse is error {
            return <http:InternalServerError> {
                body: "Error occurred while writing student details with starred repo count"
            };
        }
        return <http:Ok> {
            body: "Student details with starred repo count added successfully"
        };
    }

    resource function post books(@http:Payload BookRecord bookRecord) returns http:Ok|http:InternalServerError {
        sheets:ValueRange|error? errResponse = spreadsheetClient->appendValue(spreadSheetId,
        [bookRecord.ID, bookRecord.name, bookRecord.bookOrder], {sheetName: "bookstore"});
            if errResponse is error {
                return <http:InternalServerError> {
                body: "Error occurred while writing student details with book orders"
            };
        }
        return <http:Ok> {
            body: "Student details with book orders added successfully"
        };
    }
}

public function addSpreadSheet() {
    sheets:Spreadsheet|error response = spreadsheetClient->createSpreadsheet("WorkshopChallengeData");
    if (response is sheets:Spreadsheet) {
        io:println(string `sheet URL: ${response.spreadsheetUrl}`);
        io:println(string `sheet id: ${response.spreadsheetId}`);
    } else {
        log:printError("Error: " + response.toString());
    }
}

public function addWorkSheet(string spreadSheetId, string name) {
    sheets:Sheet|error sheet = spreadsheetClient->addSheet(spreadSheetId, name);
    if (sheet is sheets:Sheet) {
        log:printInfo("Sheet Details: " + sheet.toString());
    } else {
        log:printError("Error: " + sheet.toString());
    }
}
