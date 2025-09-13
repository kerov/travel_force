import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

import getAvailableFlights from '@salesforce/apex/FlightSelectorController.getAvailableFlights';
import getCurrentTicket from '@salesforce/apex/FlightSelectorController.getCurrentTicket';

import TRIP_PREFERRED_DATE from '@salesforce/schema/Trip__c.Preferred_Trip_Start__c';
import TRIP_FLIGHT from '@salesforce/schema/Trip__c.Flight__c';
import TRIP_CONTACT from '@salesforce/schema/Trip__c.Contact__c';

import LABEL_TITLE from '@salesforce/label/c.FlightSelector_Title';
import LABEL_LOADING from '@salesforce/label/c.FlightSelector_Loading';
import LABEL_SELECT_TRIP_MESSAGE from '@salesforce/label/c.FlightSelector_SelectTripMessage';
import LABEL_SET_DATE_MESSAGE from '@salesforce/label/c.FlightSelector_SetDateMessage';
import LABEL_PREFERRED_TRIP_START from '@salesforce/label/c.FlightSelector_PreferredTripStart';
import LABEL_CURRENTLY_SELECTED from '@salesforce/label/c.FlightSelector_CurrentlySelected';
import LABEL_CLEAR_SELECTION from '@salesforce/label/c.FlightSelector_ClearSelection';
import LABEL_YOUR_TICKET from '@salesforce/label/c.FlightSelector_YourTicket';
import LABEL_VIEW_TICKET from '@salesforce/label/c.FlightSelector_ViewTicket';
import LABEL_SELECT_FLIGHT from '@salesforce/label/c.FlightSelector_SelectFlight';
import LABEL_NO_FLIGHTS_TITLE from '@salesforce/label/c.FlightSelector_NoFlightsTitle';
import LABEL_NO_FLIGHTS_MESSAGE from '@salesforce/label/c.FlightSelector_NoFlightsMessage';

const TRIP_FIELDS = [TRIP_PREFERRED_DATE, TRIP_FLIGHT, TRIP_CONTACT];

export default class FlightSelector extends NavigationMixin(LightningElement) {
    @api recordId;
    @track availableFlights = [];
    @track isLoading = false;
    @track currentFlight;
    @track currentTicket;
    
    wiredTripResult;
    wiredFlightsResult;

    @wire(getRecord, { recordId: '$recordId', fields: TRIP_FIELDS })
    wiredTrip(result) {
        this.wiredTripResult = result;
        if (result.data) {
            this.handleTripDataChange();
        } else if (result.error) {
            console.error('Error loading trip:', result.error);
        }
    }

    @wire(getAvailableFlights, { preferredDate: '$preferredDate' })
    wiredFlights(result) {
        this.wiredFlightsResult = result;
        this.isLoading = false;
        
        if (result.data) {
            this.availableFlights = result.data.map(flight => ({
                ...flight,
                availableTicketsLabel: `${flight.availableTickets || 0} available`,
                startFormatted: this.formatDateTime(flight.StartDateTime),
                Start__c: flight.StartDateTime 
            }));
            this.loadCurrentFlight();
            this.loadCurrentTicket();
        } else if (result.error) {
            console.error('Error loading flights:', result.error);
            this.showToast('Error', 'Error loading flights: ' + result.error.body?.message, 'error');
        }
    }

    get preferredDate() {
        return getFieldValue(this.wiredTripResult.data, TRIP_PREFERRED_DATE);
    }

    get currentFlightId() {
        return getFieldValue(this.wiredTripResult.data, TRIP_FLIGHT);
    }

    get contactId() {
        return getFieldValue(this.wiredTripResult.data, TRIP_CONTACT);
    }

    get preferredDateFormatted() {
        if (!this.preferredDate) return '';
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'long', 
            day: 'numeric'
        }).format(new Date(this.preferredDate));
    }

    get showFlights() {
        return this.recordId && this.preferredDate && !this.isLoading;
    }

    get flightsGridClass() {
        return this.availableFlights && this.availableFlights.length > 3 
            ? 'flights-grid scrollable' 
            : 'flights-grid';
    }

    get hasAvailableFlights() {
        return this.availableFlights && this.availableFlights.length > 0;
    }

    get labels() {
        return {
            title: LABEL_TITLE,
            loading: LABEL_LOADING,
            selectTripMessage: LABEL_SELECT_TRIP_MESSAGE,
            setDateMessage: LABEL_SET_DATE_MESSAGE.replace('{0}', LABEL_PREFERRED_TRIP_START),
            currentlySelected: LABEL_CURRENTLY_SELECTED,
            clearSelection: LABEL_CLEAR_SELECTION,
            yourTicket: LABEL_YOUR_TICKET,
            viewTicket: LABEL_VIEW_TICKET,
            selectFlight: LABEL_SELECT_FLIGHT,
            noFlightsTitle: LABEL_NO_FLIGHTS_TITLE,
            noFlightsMessage: LABEL_NO_FLIGHTS_MESSAGE.replace('{0}', this.preferredDateFormatted)
        };
    }

    handleTripDataChange() {
        if (this.preferredDate && !this.isLoading) {
            this.isLoading = true;
        }
        this.loadCurrentFlight();
        this.loadCurrentTicket();
    }

    loadCurrentFlight() {
        if (this.currentFlightId && this.availableFlights) {
            const flight = this.availableFlights.find(f => f.Id === this.currentFlightId);
            if (flight) {
                this.currentFlight = {
                    ...flight,
                    startFormatted: this.formatDateTime(flight.StartDateTime)
                };
            } else if (this.currentFlightId) {
                this.currentFlight = {
                    Id: this.currentFlightId,
                    Name: 'Selected Flight',
                    startFormatted: 'Loading...'
                };
            }
        } else {
            this.currentFlight = null;
        }
    }

    loadCurrentTicket() {
        if (this.currentFlightId && this.contactId) {
            getCurrentTicket({ 
                flightId: this.currentFlightId, 
                contactId: this.contactId 
            })
            .then(ticket => {
                this.currentTicket = ticket;
            })
            .catch(error => {
                console.error('Error loading current ticket:', error);
                this.currentTicket = null;
            });
        } else {
            this.currentTicket = null;
        }
    }

    selectFlight(event) {
        const flightId = event.target.dataset.flightId;
        
        this.isLoading = true;
        
        if (this.currentFlightId && this.currentFlightId !== flightId) {
            const clearFields = {};
            clearFields[TRIP_FLIGHT.fieldApiName] = null;
            clearFields.Id = this.recordId;
            updateRecord({ fields: clearFields })
            .then(() => {
                return new Promise(resolve => setTimeout(resolve, 500));
            })
            .then(() => {
                const assignFields = {};
                assignFields[TRIP_FLIGHT.fieldApiName] = flightId;
                assignFields.Id = this.recordId;

                return updateRecord({ fields: assignFields });
            })
            .then(() => {
                this.showToast('Success', 'Flight assigned successfully!', 'success');
                
                return Promise.all([
                    refreshApex(this.wiredTripResult),
                    refreshApex(this.wiredFlightsResult)
                ]);
            })
            .catch(error => {
                console.error('Error selecting flight:', error);
                this.showToast('Error', 'Error assigning flight: ' + error.body?.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
        } else {
            const assignFields = {};
            assignFields[TRIP_FLIGHT.fieldApiName] = flightId;
            assignFields.Id = this.recordId;

            updateRecord({ fields: assignFields })
            .then(() => {
                this.showToast('Success', 'Flight assigned successfully!', 'success');
                
                return Promise.all([
                    refreshApex(this.wiredTripResult),
                    refreshApex(this.wiredFlightsResult)
                ]);
            })
            .catch(error => {
                console.error('Error selecting flight:', error);
                this.showToast('Error', 'Error assigning flight: ' + error.body?.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
        }
    }

    clearFlight() {
        this.isLoading = true;
        
        const fields = {};
        fields[TRIP_FLIGHT.fieldApiName] = null;
        fields.Id = this.recordId;

        updateRecord({ fields })
        .then(() => {
            this.showToast('Success', 'Flight cleared successfully!', 'success');
            return Promise.all([
                refreshApex(this.wiredTripResult),
                refreshApex(this.wiredFlightsResult)
            ]);
        })
        .catch(error => {
            console.error('Error clearing flight:', error);
            this.showToast('Error', 'Error clearing flight: ' + error.body?.message, 'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    formatDateTime(dateTimeString) {
        if (!dateTimeString) return '';
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(new Date(dateTimeString));
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    navigateToTicket() {
        if (this.currentTicket && this.currentTicket.Id) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.currentTicket.Id,
                    objectApiName: 'Ticket__c',
                    actionName: 'view'
                }
            });
        }
    }
}