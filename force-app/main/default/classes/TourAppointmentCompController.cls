/**
* @File Name : TourAppointmentCompController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : March 9, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 9, 2025 |   | Initial Version
**/

public class TourAppointmentCompController {
 	@AuraEnabled(cacheable=true)
    public static Tour_appointment__c getTourAppointment(Id opportunityId) {
        return [
            SELECT Id, Name, Appointment_Date__c, Appointment_Time__c, Tour__c, Tour__r.Name,Location__c,Wave__c,Lead_Type__c,Closing_Agents__c,Opp_Status__c
            FROM Tour_appointment__c
            WHERE Opportunity__c =: opportunityId AND /*Opp_Status__c = 'Booked'*/ Opp_Status__c != 'Cancelled' AND Opp_Status__c != 'Canceled' AND Opp_Status__c != 'Rescheduled' ORDER BY CreatedDate DESC LIMIT 1
        ];
    }

  
   @AuraEnabled
    public static string createRebookTourAppointment(String oppRecordId, String tourRecordId , Id teeUpAgentId, Id closingAgentId) { 
        System.debug('Fetching tours for oppRecordId: ' + oppRecordId);
        System.debug('Fetching tours for tourRecordId: ' + tourRecordId); 
        
        try {
            // Fetch existing tour appointments for the given Opportunity ID and cancel them
            List<Tour_appointment__c> tourAppointmentList = [SELECT Id, Opportunity__c, Opportunity_First_Last_Name_1__c, Opp_Status__c ,Lead_Type__c,Lead_ID__c,TA_Rebooked_From_Comp__c
                                                            FROM Tour_appointment__c 
                                                            WHERE Opportunity__c = :oppRecordId];
            System.debug('🟡 Fetched ' + tourAppointmentList.size() + ' existing tour appointments.');
            String leadType;
            String leadId;
            String leadFirstName;
            String leadLastName;
            String OppId;            
            String OppName;



            if (!tourAppointmentList.isEmpty()) {
                 
                for (Tour_appointment__c tour : tourAppointmentList) {
                    System.debug('🔹 Existing Tour Appointment ID: ' + tour.Id + ' | Current Status: ' + tour.Opp_Status__c);
                    //tour.Opp_Status__c = 'Rescheduled'; // Mark as "Cancelled"
                    if (tour.Opp_Status__c == 'Cancelled' || tour.Opp_Status__c == 'Canceled') {
                            continue;
                        }

                        // ✅ Only non-cancelled appointments get rescheduled
                        tour.Opp_Status__c = 'Rescheduled';
                    

                    // ✅ Capture Lead_Type__c & Lead_ID__c from existing tour
                    leadType = tour.Lead_Type__c;
                    leadId = tour.Lead_ID__c;
                    OppId = tour.Opportunity__c;
                    OppName = tour.Opportunity_First_Last_Name_1__c;


                    System.debug('Fetching tours for leadType: ' + leadType);
                    System.debug('Fetching tours for leadId: ' + leadId);
                    System.debug('Fetching tours for OppName: ' + OppName);
                    System.debug('Fetching tours for OppId: ' + OppId);            

                }
                update tourAppointmentList;
                System.debug('Existing tour appointments cancelled successfully.');
            } else {
                System.debug('No existing tour appointments found for the given Opportunity ID.');
            }

            // ✅ Fetch tour details from Tour__c
            Tour__c tourRecord = [SELECT Id, Name, Date__c, Tour_Time__c ,Wave__c,Location__c
                                FROM Tour__c 
                                WHERE Id = :tourRecordId LIMIT 1];
            System.debug('🟡 Retrieved Tour Record: ' + tourRecord.Name + ' | Date: ' + tourRecord.Date__c + ' | Time: ' + tourRecord.Tour_Time__c);

            if (tourRecord == null) {
                throw new AuraHandledException('Tour record not found.');
            }

            // ✅ Fetch Lead Name if leadId exists
            if (leadId != null) {
                Lead leadRecord = [SELECT FirstName, LastName FROM Lead WHERE Id = :leadId LIMIT 1];
                leadFirstName = leadRecord.FirstName;
                leadLastName = leadRecord.LastName;
                System.debug('🟢 Retrieved Lead Name: ' + leadFirstName + ' ' + leadLastName);
                
            }

            if (OppId != null) {
                Opportunity OppRecord = [SELECT Name FROM Opportunity WHERE Id = :OppId LIMIT 1];
                OppName = OppRecord.Name;
                System.debug('🟢 Retrieved Opp Name: ' + ' ' + OppName);
                
            }

            // ✅ Create a new tour appointment with date and time from Tour__c
            Tour_appointment__c newTour = new Tour_appointment__c();
            newTour.Name = (OppName != null ) ? OppName : 'Appointment ' ;
            newTour.Opportunity__c = oppRecordId;
            newTour.Tour__c = tourRecordId;
            newTour.Opp_Status__c = 'Booked';  // Assuming 'Open' is the correct status
            newTour.Appointment_Date__c = tourRecord.Date__c;
            newTour.Appointment_Time__c = tourRecord.Tour_Time__c;
            newTour.Wave__c = tourRecord.Wave__c;
            newTour.Location__c = tourRecord.Location__c;
            newTour.Lead_Type__c= leadType;
            newTour.Lead_ID__c=leadId;
            newTour.TA_Rebooked_From_Comp__c=True;
            
            newTour.Tee_Up_Agent__c = teeUpAgentId;
            newTour.Closing_Agents__c = closingAgentId;
        
            insert newTour;
        
            return 'Tour rebooked successfully!';
        
        } catch (Exception e) {
            System.debug('Error rebooking tour appointment: ' + e.getMessage());
            throw new AuraHandledException('Error rebooking tour appointment: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Tour__c> getToursByDateTime(Date selectedDate, String selectedTime) {
        try {
            System.debug('🔹 Fetching tours for Date: ' + selectedDate);
            System.debug('🔹 Fetching tours for Time: ' + selectedTime);

            if (selectedDate == null) {
                throw new AuraHandledException('⚠️ Error: Date is required.');
            }

            // ✅ Base Query (Date + Available Tours Filter)
            String baseQuery = 'SELECT Id, Name, Date__c, Tour_Time__c, Location__c, Day__c,Wave__c, ' +
                            'Available_Tours__c, Booked_Tours__c, Tour_Allotment__c ' +
                            'FROM Tour__c WHERE Date__c = :selectedDate AND Available_Tours__c > 0 AND Valid_Date__c = True';

            List<Tour__c> tourList;

            // ✅ If Time is selected, filter only for that time
            if (String.isNotBlank(selectedTime)) {
               // Time tourTime = convertStringToTime(selectedTime);
                Time tourTime = convertStringToTime(selectedTime);
                System.debug('✅ Converted Time: ' + tourTime);
                baseQuery += ' AND Tour_Time__c = :tourTime';
            }

            // ✅ Order by Time
            baseQuery += ' ORDER BY Tour_Time__c ASC';

            tourList = Database.query(baseQuery);
            System.debug('✅ Tours Found: ' + tourList.size());

            return tourList;

        } catch (Exception e) {
            System.debug('❌ Error fetching tours: ' + e.getMessage());
            throw new AuraHandledException('Error fetching tours: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getActiveUsers() {
        // Query standard User fields (Id, Name, IsActive)
        List<User> users = [SELECT Id, Name FROM User Where IsActive = TRUE 
        AND Profile.Name NOT IN ('Chatter Free User', 'System Administrator', 'Sales Insights Integration User', 'Monster API Only Integration', 'Analytics Cloud Integration User', 'Salesforce API Only System Integrations CLONE', 'HSI Reception') ORDER BY Name];
        
        // Convert to list of maps for LWC combobox
        List<Map<String, String>> options = new List<Map<String, String>>();
        for(User u : users){
            options.add(new Map<String, String>{
                'label' => u.Name,
                'value' => u.Id
            });
        }
        
        return options;
    }

    public static Time convertStringToTime(String timeString) {
        if (String.isBlank(timeString)) {
            throw new AuraHandledException('Time cannot be blank.');
        }

        // Parse "4:00 PM" -> 16:00:00.000Z
        String[] timeParts = timeString.split(':');
        Integer hours = Integer.valueOf(timeParts[0]);
        Integer minutes = Integer.valueOf(timeParts[1].substring(0, 2));
        String amPm = timeParts[1].substring(3, 5); // "AM" or "PM"

        // Convert to 24-hour format
        if (amPm.equalsIgnoreCase('PM') && hours != 12) {
            hours += 12;
        } else if (amPm.equalsIgnoreCase('AM') && hours == 12) {
            hours = 0;
        }

        return Time.newInstance(hours, minutes, 0, 0);
    }




}