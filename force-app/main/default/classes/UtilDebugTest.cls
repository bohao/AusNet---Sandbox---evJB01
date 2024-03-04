@isTest
private class UtilDebugTest
{
	@isTest static void test_UtilDebug()
	{
		UtilDebug de = new UtilDebug();
		de.bug('some debug comments');
		de.bugSend();

		de = new UtilDebug(true);
		de.bug('some debug comments');
		de.bugSend();
	}
}