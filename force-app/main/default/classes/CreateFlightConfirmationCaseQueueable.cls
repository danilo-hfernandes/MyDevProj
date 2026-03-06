public class CreateFlightConfirmationCaseQueueable implements Queueable{
    public List<Case> caseList = new List<Case>();
	public CreateFlightConfirmationCaseQueueable(List<Case> caseList) {
        this.caseList = caseList;
    }
    public void execute(QueueableContext context) {
        insert this.caseList;
    }
}