@IsTest
private class TravelForceExceptionsTest {
    
    @IsTest
    static void testBusinessExceptionCreation() {
        String errorMessage = 'Test business error';
        
        Test.startTest();
        TravelForceExceptions.BusinessException businessException = new TravelForceExceptions.BusinessException(errorMessage);
        Test.stopTest();
        
        Assert.areEqual(errorMessage, businessException.getMessage(), 'Business exception should have correct message');
    }
    
    @IsTest
    static void testServiceExceptionCreation() {
        String errorMessage = 'Test service error';
        
        Test.startTest();
        TravelForceExceptions.ServiceException serviceException = new TravelForceExceptions.ServiceException(errorMessage);
        Test.stopTest();
        
        Assert.areEqual(errorMessage, serviceException.getMessage(), 'Service exception should have correct message');
    }
    
    @IsTest
    static void testCalloutExceptionCreation() {
        String errorMessage = 'Test callout error';
        
        Test.startTest();
        TravelForceExceptions.CalloutException calloutException = new TravelForceExceptions.CalloutException(errorMessage);
        Test.stopTest();
        
        Assert.areEqual(errorMessage, calloutException.getMessage(), 'Callout exception should have correct message');
    }
    
    @IsTest
    static void testBusinessExceptionWithoutMessage() {
        Test.startTest();
        TravelForceExceptions.BusinessException businessException = new TravelForceExceptions.BusinessException();
        Test.stopTest();
        
        Assert.isNotNull(businessException, 'Business exception should be created without message');
    }
    
    @IsTest
    static void testServiceExceptionWithoutMessage() {
        Test.startTest();
        TravelForceExceptions.ServiceException serviceException = new TravelForceExceptions.ServiceException();
        Test.stopTest();
        
        Assert.isNotNull(serviceException, 'Service exception should be created without message');
    }
    
    @IsTest
    static void testCalloutExceptionWithoutMessage() {
        Test.startTest();
        TravelForceExceptions.CalloutException calloutException = new TravelForceExceptions.CalloutException();
        Test.stopTest();
        
        Assert.isNotNull(calloutException, 'Callout exception should be created without message');
    }
    
    @IsTest
    static void testExceptionThrowing() {
        String businessMessage = 'Business logic failed';
        String serviceMessage = 'Service unavailable';
        String calloutMessage = 'External API failed';
        
        Test.startTest();
        try {
            throw new TravelForceExceptions.BusinessException(businessMessage);
        } catch (TravelForceExceptions.BusinessException e) {
            Assert.areEqual(businessMessage, e.getMessage(), 'Thrown business exception should have correct message');
        }
        
        try {
            throw new TravelForceExceptions.ServiceException(serviceMessage);
        } catch (TravelForceExceptions.ServiceException e) {
            Assert.areEqual(serviceMessage, e.getMessage(), 'Thrown service exception should have correct message');
        }
        
        try {
            throw new TravelForceExceptions.CalloutException(calloutMessage);
        } catch (TravelForceExceptions.CalloutException e) {
            Assert.areEqual(calloutMessage, e.getMessage(), 'Thrown callout exception should have correct message');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testExceptionInheritance() {
        Test.startTest();
        TravelForceExceptions.BusinessException businessException = new TravelForceExceptions.BusinessException();
        TravelForceExceptions.ServiceException serviceException = new TravelForceExceptions.ServiceException();
        TravelForceExceptions.CalloutException calloutException = new TravelForceExceptions.CalloutException();
        Test.stopTest();
        
        Assert.isNotNull(businessException, 'BusinessException should be created');
        Assert.isNotNull(serviceException, 'ServiceException should be created');
        Assert.isNotNull(calloutException, 'CalloutException should be created');
    }
    
    @IsTest
    static void testExceptionTypeDifferences() {
        Test.startTest();
        TravelForceExceptions.BusinessException businessException = new TravelForceExceptions.BusinessException();
        TravelForceExceptions.ServiceException serviceException = new TravelForceExceptions.ServiceException();
        TravelForceExceptions.CalloutException calloutException = new TravelForceExceptions.CalloutException();
        Test.stopTest();
        
        String businessType = String.valueOf(businessException).substringBefore(':');
        String serviceType = String.valueOf(serviceException).substringBefore(':');
        String calloutType = String.valueOf(calloutException).substringBefore(':');
        
        Assert.areNotEqual(businessType, serviceType, 'BusinessException should be different type than ServiceException');
        Assert.areNotEqual(serviceType, calloutType, 'ServiceException should be different type than CalloutException');
        Assert.areNotEqual(calloutType, businessType, 'CalloutException should be different type than BusinessException');
    }
}