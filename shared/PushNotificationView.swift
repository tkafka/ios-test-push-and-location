//
//  PushNotificationView.swift
//  testLocation
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import SwiftUI
import UserNotifications

struct PushNotificationView: View {
	@State var authorizationState: UNAuthorizationStatus?
	
	public init() {
		self._authorizationState = .init(initialValue: nil)
	}
	
	private func refreshAuthorizationState() async {
		let center = UNUserNotificationCenter.current()

		let authorizationState = await center.notificationSettings().authorizationStatus
		
		await MainActor.run {
			self.authorizationState = authorizationState
		}
	}
	
	public var body: some View {
		VStack {
			Text("Push notifications")
				.font(.title)
			
			if let authorizationState {
				Text("Authorization state: \(authorizationState.debug())")
			}
			
			Button(action: {
				Task {
					await self.refreshAuthorizationState()
				}
			}, label: {
				Text("Check push auth")
			})
			
			Button(action: {
				Task {
					let center = UNUserNotificationCenter.current()
					let success = try await center.requestAuthorization(options: [.alert])
					
					if success {
						await self.refreshAuthorizationState()
					}
				}
			}, label: {
				Text("Request push permission")
			})
		}
		.onAppear(perform: {
			Task {
				await self.refreshAuthorizationState()
			}
		})
	}
}