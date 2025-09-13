// TODO: Move logic to a queueable job for better error handling and retries
public with sharing class ApiCalloutServiceImpl {
    
    private static final String CONFIG_NAME = TravelForceConstants.API_CONFIG_NAME;
    
    private static Api_Configuration__mdt getApiConfiguration() {
        Api_Configuration__mdt config = Api_Configuration__mdt.getInstance(CONFIG_NAME);
        if (config == null) {
            throw new TravelForceExceptions.ServiceException(TravelForceConstants.ERROR_API_CONFIG_NOT_FOUND + CONFIG_NAME);
        }
        return config;
    }

    public void notifyTicketBookingsAsync(List<Ticket__c> ticketBookings) {
        if (ticketBookings == null || ticketBookings.isEmpty()) {
            return;
        }
        
        List<Id> ticketIds = new List<Id>();
        for (Ticket__c ticket : ticketBookings) {
            ticketIds.add(ticket.Id);
        }
        
        if (!ticketIds.isEmpty()) {
            processTicketBookingsAsync(ticketIds);
        }
    }

    @future(callout=true)
    private static void processTicketBookingsAsync(List<Id> ticketIds) {
        try {
            TicketsSelector ticketsSelector = (TicketsSelector) Application.Selector.newInstance(Ticket__c.SObjectType);
            Set<Id> flightIds = new Set<Id>();
            
            List<Ticket__c> ticketsFromIds = (List<Ticket__c>) Database.query(ticketsSelector.newQueryFactory().setCondition('Id IN :ticketIds').toSOQL());
            for (Ticket__c ticket : ticketsFromIds) {
                if (ticket.Flight__c != null) {
                    flightIds.add(ticket.Flight__c);
                }
            }
            
            List<Ticket__c> tickets = ticketsSelector.selectByFlightIdWithContact(flightIds);
            
            for (Ticket__c ticket : tickets) {
                if (ticketIds.contains(ticket.Id) && ticket.Contact__c != null) {
                    try {
                        makeApiCallout(ticket);
                    } catch (Exception e) {
                        // TODO: Add logging
                    }
                }
            }

        } catch (Exception e) {
            // TODO: Add logging
        }
    }
    
    private static void makeApiCallout(Ticket__c ticket) {
        if (ticket.Contact__r == null || ticket.Flight__r == null) {
            throw new TravelForceExceptions.ServiceException(TravelForceConstants.ERROR_MISSING_RELATED_DATA + ticket.Id);
        }
        
        Api_Configuration__mdt config = getApiConfiguration();
        
        if (!config.Is_Active__c) {
            return;
        }
        
        Map<String, Object> payload = new Map<String, Object>{
            'ticketNumber' => ticket.Name,
            'flightNumber' => ticket.Flight__r.Name,
            'departureDate' => ticket.Flight__r.Start__c?.format(TravelForceConstants.DATE_FORMAT_YYYY_MM_DD),
            'passengerName' => ticket.Contact__r.Name,
            'passengerEmail' => ticket.Contact__r.Email
        };
        
        String requestBody = JSON.serialize(payload);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(config.URL__c);
        request.setMethod(TravelForceConstants.HTTP_METHOD_POST);
        request.setHeader(TravelForceConstants.CONTENT_TYPE, TravelForceConstants.CONTENT_TYPE_JSON);
        request.setBody(requestBody);
        request.setTimeout(Integer.valueOf(config.Timeout__c));
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() < 200 || response.getStatusCode() >= 300) {
            logApiError(ticket, config.URL__c, requestBody, response.getStatusCode(), response.getBody());
            throw new TravelForceExceptions.CalloutException(
                TravelForceConstants.ERROR_API_CALL_FAILED
                + response.getStatusCode() 
                + ', Body: ' 
                + response.getBody()
            );
        }
    }

    private static void logApiError(Ticket__c ticket, String endpoint, String requestBody, Integer statusCode, String responseBody) {
        try {
            API_Error_Log__c errorLog = new API_Error_Log__c();
            errorLog.Ticket__c = ticket.Id;
            errorLog.Status_Code__c = statusCode;
            errorLog.Error_Message__c = 'Endpoint: ' + endpoint + '\n' +
                                      'Request: ' + requestBody + '\n' + 
                                      'Response: ' + responseBody;
            errorLog.Retry_Count__c = 0;
            
            insert errorLog;
        } catch (Exception e) {
            // TODO: Add logging
        }
    }
    
}