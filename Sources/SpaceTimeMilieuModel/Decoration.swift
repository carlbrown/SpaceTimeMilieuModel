//
//  Decoration.swift
//  SpaceTimeMilieuModel
//
//  Created by Carl Brown on 3/6/17.
//
//

import Foundation

public struct Decoration {
    public static let decorationKey = "decorationKey"

    private static let titleKey = "titleKey"
    private static let descriptionKey = "descriptionKey"
    private static let urlKey = "urlKey"
    private static let versionKey = "versionKey"

    private static let currentVersion = 1

    public let version: Int
    
    public let title: String
    
    public let description: String?

    public let url: URL?
    
    public init(title: String, description: String? = nil, url: URL? = nil) {
        self.title = title
        self.description = description
        self.url = url
        self.version = Decoration.currentVersion
    }
    
    public init?(fromJSON: Data) {
        do {
            let obj = try JSONSerialization.jsonObject(with: fromJSON)
            guard
                let dict = obj as? [String: Any],
                let title = dict[Decoration.titleKey] as? String,
                let version = dict[Decoration.versionKey] as? Int,
                version == Decoration.currentVersion
                else {
                    print ("Invalid JSON: \(fromJSON)")
                    return nil
            }
            self.title = title
            self.version = version
            self.description = dict[Decoration.descriptionKey] as? String
            if let urlString = dict[Decoration.urlKey] as? String {
                self.url = URL(string: urlString)
            } else {
                self.url = nil
            }
        } catch {
            print("\(error)")
            return nil
        }
    }
    
    private func toDictionary() -> [String: Any] {
        var retVal = [
            Decoration.versionKey: version,
            Decoration.titleKey: title
        ] as [String : Any]
        if let description = self.description {
            retVal[Decoration.descriptionKey]=description
        }
        if let urlString = url?.absoluteString {
            retVal[Decoration.urlKey]=urlString
        }
        return retVal
    }
    
    public func toJSON() throws -> Data  {
        return try JSONSerialization.data(withJSONObject: self.toDictionary())
    }

}
