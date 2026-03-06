/**
* @File Name : FutureDelayedExecutionJob.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 13, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 13, 2024 |   | Initial Version
**/

public class FutureDelayedExecutionJob implements Schedulable {
	private String authUserId;
	public FutureDelayedExecutionJob(String authUserId) {
        this.authUserId = authUserId;
    }
    public void execute(SchedulableContext sc) {
        AuthorizedUserAPIController.getAuthorizedUser(authUserId);
    }
}