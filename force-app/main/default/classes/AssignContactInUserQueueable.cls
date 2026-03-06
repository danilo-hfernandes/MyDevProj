public class AssignContactInUserQueueable implements Queueable{
    List<User> userList;
    public AssignContactInUserQueueable(List<User> userRecords) {
        system.debug('User Records=== '+userRecords);
        this.userList = userRecords;
    }
    public void execute(QueueableContext context) {        
        update this.userList;
        system.debug('Updated users=== '+this.userList);
        system.debug('Updated users Count=== '+this.userList.size());
    }
}