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
    public static let decorationListKey = "decorationListKey"

    private static let titleKey = "titleKey"
    private static let detailsKey = "detailsKey"
    private static let urlKey = "urlKey"
    private static let sourceKey = "sourceKey"
    private static let versionKey = "versionKey"

    private static let currentVersion = 1

    public let version: Int
    
    public let title: String
    
    public let source: String
    
    public let details: String?

    public let url: URL?
    
    public let point: Point?
    
    public static func decodeJSON(data:Data, dateFormatter: DateFormatter = DateFormatter()) throws -> [Decoration] {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return []
        }
        guard let decorationArray = dict[decorationListKey] as? [[String: Any]] else {
            return []
        }
        
        var retVal = [Decoration]()
        
        for decorationListDict in decorationArray {
            guard let pointDict = decorationListDict[Point.pointKey] as? [String: Any] else { continue }
            guard let point = Point(fromDict: pointDict, dateFormatter: dateFormatter) else { continue }
            guard let decorationDictArray = decorationListDict[Decoration.decorationKey] as? [[String: Any]] else { continue }
            let decorations = decorationDictArray.flatMap {Decoration(fromDict:$0, point: point)}
            retVal.append(contentsOf: decorations)
        }

        return retVal
    }
    
    public static func encodeJSON(decorations:[Decoration], dateFormatter: DateFormatter = DateFormatter()) throws -> Data {
        
        var dictToEncode = [Point:[Decoration]]()
        var orphanedDecorations = [Decoration]()
        var lastPoint: Point? = nil
        for decoration in decorations {
            let keyPoint: Point
            if let decorationPoint = decoration.point {
                keyPoint = decorationPoint
                lastPoint = decorationPoint
            } else if let decorationPoint = lastPoint {
                keyPoint = decorationPoint
            } else {
                orphanedDecorations.append(decoration)
                continue
            }
            var decorationsForThisPoint: [Decoration] = dictToEncode[keyPoint] ?? [Decoration]()
            decorationsForThisPoint.append(decoration)
            dictToEncode[keyPoint]=decorationsForThisPoint
        }
        if (orphanedDecorations.count > 0 && lastPoint != nil) {
            var decorationsForThisPoint: [Decoration] = dictToEncode[lastPoint!] ?? [Decoration]()
            decorationsForThisPoint.append(contentsOf: orphanedDecorations)
            dictToEncode[lastPoint!]=decorationsForThisPoint
        }
        
        var arrayOfDicts = [[String: Any]]()
        for point in dictToEncode.keys {
            if let decorationsForThisPoint = dictToEncode[point] {
                let pointDict = point.toDictionary(dateFormatter)
                let decorationsDictArray : [[String: Any]] = decorationsForThisPoint.flatMap {$0.toDictionary()}
                arrayOfDicts.append([
                    Point.pointKey: pointDict,
                    Decoration.decorationKey: decorationsDictArray
                    ])
            }
        }
        let retVal = [Decoration.decorationListKey: arrayOfDicts]
        let resultToSend = try JSONSerialization.data(withJSONObject: retVal)
        return resultToSend
    }
    
    public init(title: String, source: String, details: String? = nil, url: URL? = nil, point:Point? = nil) {
        self.title = title
        self.source = source
        self.details = details
        self.url = url
        self.point = point
        self.version = Decoration.currentVersion
    }
    
    
    public init?(fromDict dict: [String: Any], point:Point? = nil) {
        self.point = point
        guard
            let title = dict[Decoration.titleKey] as? String,
            let source = dict[Decoration.sourceKey] as? String,
            let version = dict[Decoration.versionKey] as? Int,
            version == Decoration.currentVersion
            else {
                print ("Invalid Dict: \(dict)")
                return nil
        }
        self.title = title
        self.source = source
        self.version = version
        self.details = dict[Decoration.detailsKey] as? String
        if let urlString = dict[Decoration.urlKey] as? String {
            self.url = URL(string: urlString)
        } else {
            self.url = nil
        }
    }
    
    public func toDictionary() -> [String: Any] {
        var retVal = [
            Decoration.versionKey: version,
            Decoration.titleKey: title,
            Decoration.sourceKey: source
        ] as [String : Any]
        if let details = self.details {
            retVal[Decoration.detailsKey]=details
        }
        if let urlString = url?.absoluteString {
            retVal[Decoration.urlKey]=urlString
        }
        return retVal
    }
    
    public static func points(_ decorations:[Decoration]) -> [Point] {
        return decorations.flatMap {$0.point} as [Point]
    }
    
}
