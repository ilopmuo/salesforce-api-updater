/**
 * @description Service class for Contact management
 * @author Contact Team
 */
public class ContactService {
    
    private static final String DEFAULT_LEAD_SOURCE = 'Web';
    
    /**
     * @description Creates bulk contacts from lead conversion
     * @param leads List of leads to convert to contacts
     * @return List<Contact> Created contact records
     */
    public static List<Contact> createContactsFromLeads(List<Lead> leads) {
        List<Contact> contactsToInsert = new List<Contact>();
        
        for(Lead currentLead : leads) {
            Contact newContact = new Contact();
            newContact.FirstName = currentLead.FirstName;
            newContact.LastName = currentLead.LastName;
            newContact.Email = currentLead.Email;
            newContact.Phone = currentLead.Phone;
            newContact.LeadSource = currentLead.LeadSource != null ? currentLead.LeadSource : DEFAULT_LEAD_SOURCE;
            
            contactsToInsert.add(newContact);
        }
        
        if(!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
            System.debug('Successfully created ' + contactsToInsert.size() + ' contacts');
        }
        
        return contactsToInsert;
    }
    
    /**
     * @description Updates contact preferences
     * @param contactIds Set of contact IDs to update
     * @param hasOptedOutOfEmail Email opt-out preference
     */
    public static void updateEmailPreferences(Set<Id> contactIds, Boolean hasOptedOutOfEmail) {
        List<Contact> contactsToUpdate = [
            SELECT Id, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Id IN :contactIds
        ];
        
        for(Contact cont : contactsToUpdate) {
            cont.HasOptedOutOfEmail = hasOptedOutOfEmail;
        }
        
        update contactsToUpdate;
        
        String message = hasOptedOutOfEmail ? 'opted out of' : 'opted into';
        System.debug(contactsToUpdate.size() + ' contacts ' + message + ' email communications');
    }
    
    /**
     * @description Finds duplicate contacts by email
     * @return Map<String, List<Contact>> Map of email to list of duplicate contacts
     */
    public static Map<String, List<Contact>> findDuplicatesByEmail() {
        Map<String, List<Contact>> duplicatesMap = new Map<String, List<Contact>>();
        
        for(Contact cont : [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Email != null]) {
            if(!duplicatesMap.containsKey(cont.Email)) {
                duplicatesMap.put(cont.Email, new List<Contact>());
            }
            duplicatesMap.get(cont.Email).add(cont);
        }
        
        // Remove entries with only one contact (not duplicates)
        Map<String, List<Contact>> actualDuplicates = new Map<String, List<Contact>>();
        for(String email : duplicatesMap.keySet()) {
            if(duplicatesMap.get(email).size() > 1) {
                actualDuplicates.put(email, duplicatesMap.get(email));
            }
        }
        
        return actualDuplicates;
    }
} 