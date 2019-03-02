abstract class CloudNotificationRepository {

	/// Returns the instance of the used Cloud Service
	Future<void> getNotificationService();

	/// Adds a device to the online database
	Future<void> registerDevice();

	/// Removes a device from the online database
	Future<void> removeDevice();
}