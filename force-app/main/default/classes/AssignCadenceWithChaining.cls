public class AssignCadenceWithChaining implements Queueable, Database.AllowsCallouts {
/* This Queueable class serves as a driver/controller to orchestrate batched assignments of Contacts
 * to multiple Sales Cadences. It processes one cadence at a time and chains the next cadence assignment
 * as a separate Queueable job to avoid exceeding platform limits.
 *
 * Why This Was Created:
 * - To work around the `Too many queueable jobs` and `Too many future calls` governor limits.
 * - To manage cadence assignment logic dynamically when multiple cadence groups must be processed.
 *
 * Key Features:
 * - Accepts a map of Cadence Name → Set of Contact Ids.
 * - Iterates one cadence per queueable job (by using `currentIndex`).
 * - Chains the next job only after the current one finishes.
 * - Delegates actual assignment to `GenericAssignToSalesCadenceChained`.

 * Platform Limit Strategy:
 * - Only one `System.enqueueJob()` is called per execution.
 * - Prevents hitting `System.LimitException: Too many queueable jobs added to the queue`.

 * Example Usage:
 * System.enqueueJob(new AssignCadenceWithChaining(myCadenceMap, 0));
 */

    private Map<String, Set<Id>> cadenceMap;
    private List<String> cadenceKeys;
    private Integer currentIndex;

    public AssignCadenceWithChaining(Map<String, Set<Id>> cadenceMap, Integer currentIndex) {
        this.cadenceMap = cadenceMap;
        this.cadenceKeys = new List<String>(cadenceMap.keySet());
        this.currentIndex = currentIndex;
    }

    public void execute(QueueableContext context) {
        if (currentIndex >= cadenceKeys.size()) return;

        String cadenceName = cadenceKeys[currentIndex];
        Set<Id> contactIds = cadenceMap.get(cadenceName);

        if (!contactIds.isEmpty()) {
            // Instead of queuing a separate job, do it directly here
            GenericAssignToSalesCadenceChained handler = new GenericAssignToSalesCadenceChained(contactIds, cadenceName, 0);
            handler.execute(null); // Direct call instead of enqueueing
        }

        // Now chain next cadence job
        if (currentIndex + 1 < cadenceKeys.size()) {
            System.enqueueJob(new AssignCadenceWithChaining(cadenceMap, currentIndex + 1));
        }
    }
}