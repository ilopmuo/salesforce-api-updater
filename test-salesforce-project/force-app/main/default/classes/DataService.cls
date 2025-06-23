/**
 * @description Data service for various database operations
 * @author Test Team
 */
public class DataService {
    
    /**
     * @description Performs bulk data cleanup operations
     * @param objectType The SObject type to cleanup
     * @param daysOld Number of days old records to delete
     * @return Integer Number of records deleted
     */
    public static Integer cleanupOldRecords(String objectType, Integer daysOld) {
        String query = 'SELECT Id FROM ' + objectType + ' WHERE CreatedDate < LAST_N_DAYS:' + daysOld;
        List<SObject> recordsToDelete = Database.query(query);
        
        if(!recordsToDelete.isEmpty()) {
            Database.delete(recordsToDelete, false);
            System.debug('Deleted ' + recordsToDelete.size() + ' old ' + objectType + ' records');
        }
        
        return recordsToDelete.size();
    }
    
    /**
     * @description Exports data to CSV format
     * @param records List of records to export
     * @return String CSV formatted string
     */
    public static String exportToCSV(List<SObject> records) {
        if(records.isEmpty()) {
            return '';
        }
        
        String csvContent = '';
        
        // Add headers (field names)
        if(!records.isEmpty()) {
            Map<String, Object> firstRecord = records[0].getPopulatedFieldsAsMap();
            csvContent += String.join(new List<String>(firstRecord.keySet()), ',') + '\n';
            
            // Add data rows
            for(SObject record : records) {
                List<String> values = new List<String>();
                for(String fieldName : firstRecord.keySet()) {
                    Object fieldValue = record.get(fieldName);
                    values.add(fieldValue != null ? String.valueOf(fieldValue) : '');
                }
                csvContent += String.join(values, ',') + '\n';
            }
        }
        
        return csvContent;
    }
} 