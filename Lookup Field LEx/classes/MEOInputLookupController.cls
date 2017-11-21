public with sharing class MEOInputLookupController {

    public String selectedFldValue {get; set;}

    public MEOInputLookupController() {}

    public class LookupHelper {
        public String id;
        public String label;

    }

    public static MEOInputLookupController.LookupHelper[] wrapRecords(sObject[] sobjts, String fldName) {
        List<MEOInputLookupController.LookupHelper> res = new List<MEOInputLookupController.LookupHelper>();
        if (sobjts != null && String.isNotBlank(fldName)) {
            for (SObject so: sobjts) {
                MEOInputLookupController.LookupHelper h = new MEOInputLookupController.LookupHelper();
                h.id = so.Id;
                h.label = (String) so.get(fldName);
                res.add(h);
            }
        }
        return res;
    }

    /**
     * Returns an array with LookupHelper objects that correspond recently viewed records for requested type of SObject
     * @param params - the string[] with next params: 0='object name', 1='search field'
     * @return LookupHelper[]
     */
    @RemoteAction
    public static MEOInputLookupController.LookupHelper[] getRecentItems(String[] params) {
        List<MEOInputLookupController.LookupHelper> res = new List<MEOInputLookupController.LookupHelper>();
        if (params != null && params.size() == 2) {
            String objName = params[0];
            String searchFld = params[1];
            if (String.isNotBlank(objName) && String.isNotBlank(searchFld)) {
                String qryString = 'SELECT Id, ' + String.escapeSingleQuotes(searchFld) + ' FROM RecentlyViewed WHERE Type =: objName ORDER BY LastViewedDate DESC LIMIT 200';
                try {
                    res = wrapRecords(Database.query(qryString), searchFld);
                } catch (Exception e) {
                }
            }
        }
        return res;
    }

    /**
     * Returns an array with LookupHelper objects that contains the searchable string in requested field of specified type of SObject
     * @param params - the string[] with next params: 0='object name', 1='search field' , 2='search string'
     * @return LookupHelper[]
     */
    @RemoteAction
    public static MEOInputLookupController.LookupHelper[] getRecentFilledItems(String[] params) {
        List<MEOInputLookupController.LookupHelper> res = new List<MEOInputLookupController.LookupHelper>();
        if (params != null && params.size() == 3) {
            String objName = params[0] != null ? String.escapeSingleQuotes(params[0]) : '';
            String searchFld = params[1] != null ? String.escapeSingleQuotes(params[1]) : '';
            String searchString = params[2] != null ? String.escapeSingleQuotes(params[2]) : '';
            if (String.isNotBlank(objName) && String.isNotBlank(searchFld)) {
                String whereCondString = '';
                if (String.isNotBlank(searchString)) {
                    whereCondString = ' WHERE ' + searchFld + ' LIKE  \'%' +  searchString + '%\' ';
                }
                String qryString = 'SELECT Id, ' + searchFld + ' FROM ' + objName + whereCondString + ' LIMIT 200';
                try {
                    res = wrapRecords(Database.query(qryString), searchFld);
                } catch (Exception e) {
                }
            }
        }
        return res;
    }
}