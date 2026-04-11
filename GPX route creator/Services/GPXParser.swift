//
//  GPXParser.swift
//  GPX route creator
//

import Foundation

enum GPXParserError: LocalizedError {
    case unreadableData
    case invalidUTF8
    case emptyTrack

    var errorDescription: String? {
        switch self {
        case .unreadableData:
            return "The GPX file could not be read."
        case .invalidUTF8:
            return "The GPX file contains invalid text data."
        case .emptyTrack:
            return "The GPX file did not contain any track points."
        }
    }
}

final class GPXParser: NSObject {
    func parse(contentsOf url: URL) throws -> GPXTrack {
        let data = try Data(contentsOf: url)
        return try parse(data: data)
    }

    func parse(data: Data) throws -> GPXTrack {
        let delegate = GPXParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate

        guard parser.parse() else {
            if let error = parser.parserError {
                throw error
            }

            throw GPXParserError.unreadableData
        }

        let track = delegate.buildTrack()

        guard track.pointCount > 0 else {
            throw GPXParserError.emptyTrack
        }

        return track
    }
}

private final class GPXParserDelegate: NSObject, XMLParserDelegate {
    private enum ElementName: String {
        case track = "trk"
        case trackName = "name"
        case segment = "trkseg"
        case point = "trkpt"
        case elevation = "ele"
        case time
    }

    private var trackName: String?
    private var segments: [GPXTrackSegment] = []
    private var currentSegmentPoints: [GPXTrackPoint] = []
    private var currentPointLatitude: Double?
    private var currentPointLongitude: Double?
    private var currentPointElevation: Double?
    private var currentPointTime: Date?
    private var currentText = ""
    private var isInsideTrack = false
    private var isInsidePoint = false
    private var isInsideSegment = false

    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    func buildTrack() -> GPXTrack {
        GPXTrack(name: normalizedTrackName, segments: finalizedSegments())
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentText = ""

        guard let element = ElementName(rawValue: elementName) else {
            return
        }

        switch element {
        case .track:
            isInsideTrack = true
        case .segment:
            isInsideSegment = true
            currentSegmentPoints = []
        case .point:
            isInsidePoint = true
            currentPointLatitude = Double(attributeDict["lat"] ?? "")
            currentPointLongitude = Double(attributeDict["lon"] ?? "")
            currentPointElevation = nil
            currentPointTime = nil
        case .trackName, .elevation, .time:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let trimmedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let element = ElementName(rawValue: elementName) else {
            currentText = ""
            return
        }

        switch element {
        case .track:
            isInsideTrack = false
        case .trackName:
            if isInsideTrack && !isInsidePoint && trackName == nil && !trimmedText.isEmpty {
                trackName = trimmedText
            }
        case .segment:
            if !currentSegmentPoints.isEmpty {
                segments.append(GPXTrackSegment(points: currentSegmentPoints))
            }

            currentSegmentPoints = []
            isInsideSegment = false
        case .point:
            if
                isInsideSegment,
                let latitude = currentPointLatitude,
                let longitude = currentPointLongitude
            {
                currentSegmentPoints.append(
                    GPXTrackPoint(
                        latitude: latitude,
                        longitude: longitude,
                        elevationMeters: currentPointElevation,
                        timestamp: currentPointTime
                    )
                )
            }

            isInsidePoint = false
        case .elevation:
            if isInsidePoint {
                currentPointElevation = Double(trimmedText)
            }
        case .time:
            if isInsidePoint {
                currentPointTime = parsedDate(from: trimmedText)
            }
        }

        currentText = ""
    }

    private var normalizedTrackName: String? {
        guard let trackName, !trackName.isEmpty else {
            return nil
        }

        return trackName
    }

    private func finalizedSegments() -> [GPXTrackSegment] {
        if currentSegmentPoints.isEmpty {
            return segments
        }

        return segments + [GPXTrackSegment(points: currentSegmentPoints)]
    }

    private func parsedDate(from text: String) -> Date? {
        if let date = dateFormatter.date(from: text) {
            return date
        }

        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]
        return fallbackFormatter.date(from: text)
    }
}
