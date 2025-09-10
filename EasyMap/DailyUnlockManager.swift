//
//  DailyUnlockManager.swift
//  EasyMap
//
//  Created by Studente on 10/09/25.
//
import Foundation

@MainActor
final class DailyUnlockManager: ObservableObject {
    static let shared = DailyUnlockManager()
    @Published private(set) var isUnlockedToday: Bool = false

    private let key = "bookingUnlockedDate"
    private let cal = Calendar.current

    private init() {
        refresh()
    }

    func refresh() {
        if let saved = UserDefaults.standard.object(forKey: key) as? Date {
            isUnlockedToday = cal.isDate(saved, inSameDayAs: Date())
        } else {
            isUnlockedToday = false
        }
    }

    func unlockForToday() {
        UserDefaults.standard.set(Date(), forKey: key)
        isUnlockedToday = true
    }
}
