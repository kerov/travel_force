@IsTest
private class TravelForceConstantsTest {
    
    @IsTest
    static void testTripStatusConstants() {
        Test.startTest();
        String flightSearch = TravelForceConstants.TRIP_STATUS_FLIGHT_SEARCH;
        String flightBooked = TravelForceConstants.TRIP_STATUS_FLIGHT_BOOKED;
        Test.stopTest();
        
        Assert.areEqual('Flight search', flightSearch, 'Flight search status should be correct');
        Assert.areEqual('Flight booked', flightBooked, 'Flight booked status should be correct');
    }
    
    @IsTest
    static void testErrorMessageConstants() {
        Test.startTest();
        String tripError = TravelForceConstants.ERROR_TRIP_ID_FLIGHT_ID_NULL;
        String ticketError = TravelForceConstants.ERROR_TICKET_ID_CONTACT_ID_NULL;
        String retrievingError = TravelForceConstants.ERROR_RETRIEVING_FLIGHTS;
        Test.stopTest();
        
        Assert.isTrue(tripError.contains('Trip ID'), 'Trip error should mention Trip ID');
        Assert.isTrue(ticketError.contains('Ticket ID'), 'Ticket error should mention Ticket ID');
        Assert.isTrue(retrievingError.contains('retrieving'), 'Retrieving error should mention retrieving');
    }
    
    @IsTest
    static void testApiConfigurationConstants() {
        Test.startTest();
        String configName = TravelForceConstants.API_CONFIG_NAME;
        String httpMethod = TravelForceConstants.HTTP_METHOD_POST;
        String contentType = TravelForceConstants.CONTENT_TYPE_JSON;
        Test.stopTest();
        
        Assert.areEqual('TF_Booking', configName, 'API config name should be correct');
        Assert.areEqual('POST', httpMethod, 'HTTP method should be POST');
        Assert.areEqual('application/json', contentType, 'Content type should be JSON');
    }
    
    @IsTest
    static void testDateFormatConstants() {
        Test.startTest();
        String dateFormat = TravelForceConstants.DATE_FORMAT_YYYY_MM_DD;
        Test.stopTest();
        
        Assert.areEqual('yyyy-MM-dd', dateFormat, 'Date format should be yyyy-MM-dd');
    }
    
    @IsTest
    static void testDisplayConstants() {
        Test.startTest();
        String separator = TravelForceConstants.DISPLAY_NAME_SEPARATOR;
        Test.stopTest();
        
        Assert.areEqual(' - ', separator, 'Display name separator should be correct');
    }
    
    @IsTest
    static void testHttpConstants() {
        Test.startTest();
        String contentTypeHeader = TravelForceConstants.CONTENT_TYPE;
        String postMethod = TravelForceConstants.HTTP_METHOD_POST;
        String jsonContentType = TravelForceConstants.CONTENT_TYPE_JSON;
        Test.stopTest();
        
        Assert.areEqual('Content-Type', contentTypeHeader, 'Content-Type header should be correct');
        Assert.areEqual('POST', postMethod, 'POST method should be correct');
        Assert.areEqual('application/json', jsonContentType, 'JSON content type should be correct');
    }
    
    @IsTest
    static void testErrorConstantsNotNull() {
        Test.startTest();
        Assert.isNotNull(TravelForceConstants.ERROR_TRIP_ID_FLIGHT_ID_NULL, 'Error constant should not be null');
        Assert.isNotNull(TravelForceConstants.ERROR_TRIP_ID_NULL, 'Error constant should not be null');
        Assert.isNotNull(TravelForceConstants.ERROR_TICKET_ID_CONTACT_ID_NULL, 'Error constant should not be null');
        Assert.isNotNull(TravelForceConstants.ERROR_TRIP_NOT_FOUND, 'Error constant should not be null');
        Assert.isNotNull(TravelForceConstants.ERROR_TICKET_NOT_FOUND, 'Error constant should not be null');
        Assert.isNotNull(TravelForceConstants.ERROR_NO_AVAILABLE_TICKETS_FLIGHT, 'Error constant should not be null');
        Assert.isNotNull(TravelForceConstants.ERROR_RETRIEVING_FLIGHTS, 'Error constant should not be null');
        Assert.isNotNull(TravelForceConstants.ERROR_API_CONFIG_NOT_FOUND, 'Error constant should not be null');
        Assert.isNotNull(TravelForceConstants.ERROR_API_CALL_FAILED, 'Error constant should not be null');
        Test.stopTest();
    }
    
    @IsTest
    static void testConstantsAreNotEmpty() {
        Test.startTest();
        Assert.isTrue(TravelForceConstants.TRIP_STATUS_FLIGHT_SEARCH.length() > 0, 'Constant should not be empty');
        Assert.isTrue(TravelForceConstants.TRIP_STATUS_FLIGHT_BOOKED.length() > 0, 'Constant should not be empty');
        Assert.isTrue(TravelForceConstants.API_CONFIG_NAME.length() > 0, 'Constant should not be empty');
        Assert.isTrue(TravelForceConstants.HTTP_METHOD_POST.length() > 0, 'Constant should not be empty');
        Assert.isTrue(TravelForceConstants.DATE_FORMAT_YYYY_MM_DD.length() > 0, 'Constant should not be empty');
        Test.stopTest();
    }
    
    @IsTest
    static void testBusinessLogicConstants() {
        Test.startTest();
        String startAfterEnd = TravelForceConstants.ERROR_START_DATE_AFTER_END;
        String noTicketsSelected = TravelForceConstants.ERROR_NO_AVAILABLE_TICKETS_SELECTED;
        String failedBookTickets = TravelForceConstants.ERROR_FAILED_BOOK_TICKETS;
        Test.stopTest();
        
        Assert.isTrue(startAfterEnd.contains('Start date'), 'Error should mention start date');
        Assert.isTrue(noTicketsSelected.contains('available'), 'Error should mention available tickets');
        Assert.isTrue(failedBookTickets.contains('book'), 'Error should mention booking');
    }
}