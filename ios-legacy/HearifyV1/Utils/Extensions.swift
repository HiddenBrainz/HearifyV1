//
//  Extensions.swift
//  HearifyV1
//
//  Utility extensions for UserDefaults and other helpers
//

import Foundation

// MARK: - UserDefaults Extension for Codable
extension UserDefaults {
    func setCodableObject<T: Codable>(_ data: T?, forKey defaultName: String) {
        do {
            let encoded = try JSONEncoder().encode(data)
            set(encoded, forKey: defaultName)
        } catch {
            print("Error encoding object for key \(defaultName): \(error.localizedDescription)")
        }
    }

    func codableObject<T : Codable>(dataType: T.Type, key: String) -> T? {
        guard let userDefaultData = data(forKey: key) else {
            print("No data found for key: \(key)")
            return nil
        }

        do {
            return try JSONDecoder().decode(T.self, from: userDefaultData)
        } catch {
            print("Error decoding object for key \(key): \(error.localizedDescription)")
            removeObject(forKey: key)
            return nil
        }
    }
}
