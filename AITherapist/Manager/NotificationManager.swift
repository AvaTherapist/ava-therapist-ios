//
//  NotificationManager.swift
//  AITherapist
//
//  Created by cyrus refahi on 7/20/24.
//

import Foundation
import SwiftUI

protocol NotificationProtocol {
    func requestNotifAuthorization(onSuccess: @escaping () -> (), onFailiure: @escaping () -> ())
    func scheduelNotification(_ time: NotificationTime)
}

class NotificationManager: NotificationProtocol {
    static let instance: NotificationManager = NotificationManager()
    
    func requestNotifAuthorization(onSuccess: @escaping () -> (), onFailiure: @escaping () -> ()) {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("ERROR: \(error)")
                onFailiure()
            }else{
                print("SUCCESS")
                onSuccess()
            }
        }
    }
    
    func scheduelNotification(_ time: NotificationTime) {
        let content = UNMutableNotificationContent()
        content.title = "You Deserve Some Me-Time"
        content.body = "Take a break and talk with Ava. Your well-being is worth it"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        
        switch time {
        case .Morning:
            dateComponents.hour = 8
            dateComponents.minute = 0
        case .Afternoon:
            dateComponents.hour = 12
            dateComponents.minute = 0
        case .Evening:
            dateComponents.hour = 17
            dateComponents.minute = 0
        case .Night:
            dateComponents.hour = 20
            dateComponents.minute = 0
        }
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}


enum NotificationTime: String {
    case Morning = "Morning"
    case Afternoon = "Afternoon"
    case Evening = "Evening"
    case Night = "Night"
}
