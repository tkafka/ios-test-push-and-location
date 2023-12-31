//
//  AppDelegate.swift
//  testLocation
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
	/// If your app wasn’t running and the user launches it by tapping the push notification, iOS passes the notification to your app in the `launchOptions` of `application(_:didFinishLaunchingWithOptions:)`.
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [
			UIApplication.LaunchOptionsKey: Any
		]?
	) -> Bool {
		/// register
		Task {
			let center = UNUserNotificationCenter.current()
			let authorizationStatus = await center.notificationSettings().authorizationStatus
			
			if authorizationStatus.canPush() {
				await MainActor.run {
					application.registerForRemoteNotifications()
					print("Registered for remote notifications")
				}
			} else {
				print("Not authorized (\(authorizationStatus.debug())), not registering for remote notifications.")
			}
		}
		
		let notificationOption = launchOptions?[.remoteNotification]
		if let notification = notificationOption as? [String: AnyObject] {
			print("Application.didFinishLaunchingWithOptions: \(notification.asJson())")
			let _ = DataStore.shared.saveDataFromUserInfo(userInfo: notification)
		}
		
		return true
	}
	
	// MARK: Register the push notifications
	
	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		DataStore.shared.setDevicePushToken(deviceToken)
		NotificationDelegate.addToken(deviceToken: deviceToken)
	}

	func application(
		_ application: UIApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error
	) {
		print("Push notifications: Error registering for push notifications: \(error.localizedDescription)")
	}
	
	// MARK: Push notifications
	
	/// If your app was running either in the foreground or the background, the system notifies your app by calling `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`. When the user opens the app by tapping the push notification, iOS may call this method again, so you can update the UI and display relevant information.
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
		print("Received remote notification: \(userInfo.asJson())")
		if DataStore.shared.saveDataFromUserInfo(userInfo: userInfo) {
			return .newData
		} else {
			return .noData
		}
	}
}
