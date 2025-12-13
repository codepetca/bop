import Foundation
import Darwin

private let featuresFilePath = ".ai/features.json"

private struct FeaturesFile: Codable {
    var meta: Meta
    var features: [Feature]
}

private struct Meta: Codable {
    var project: String
    var lastUpdated: String
    var phase: String
    var doNotDeleteFeatures: String
    var deletionPolicy: String
    var totalFeatures: Int
    var passing: Int
    var failing: Int

    private enum CodingKeys: String, CodingKey {
        case project
        case lastUpdated
        case phase
        case doNotDeleteFeatures = "DO_NOT_DELETE_FEATURES"
        case deletionPolicy
        case totalFeatures
        case passing
        case failing
    }
}

private struct Feature: Codable {
    var id: String
    var phase: String
    var category: String
    var description: String
    var passes: Bool
    var verification: String
    var files: [String]
    var tests: [String]?
    var architectureRef: String
    var addedDate: String
    var completedDate: String?
    var blockedBy: [String]?
}

private enum Command {
    case summary
    case next
    case phase(String)
    case detail(String)
    case pass(String)
    case fail(String)
    case validate
    case repairMeta
}

private struct OutputStyle {
    var useColor: Bool

    func header(_ title: String) -> String {
        if useColor {
            return "\u{001B}[0;34m\(title)\u{001B}[0m"
        }
        return title
    }

    func success(_ text: String) -> String {
        if useColor {
            return "\u{001B}[0;32m\(text)\u{001B}[0m"
        }
        return text
    }

    func failure(_ text: String) -> String {
        if useColor {
            return "\u{001B}[0;31m\(text)\u{001B}[0m"
        }
        return text
    }

    func warning(_ text: String) -> String {
        if useColor {
            return "\u{001B}[1;33m\(text)\u{001B}[0m"
        }
        return text
    }
}

private struct UsageError: LocalizedError {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}

private let usageText = """
Usage:
  bash scripts/features.sh summary
  bash scripts/features.sh next
  bash scripts/features.sh phase <phase-name>
  bash scripts/features.sh detail <feature-id>
  bash scripts/features.sh pass <feature-id>
  bash scripts/features.sh fail <feature-id>
  bash scripts/features.sh validate
  bash scripts/features.sh repair-meta
"""

private func parseCommand(arguments: [String]) throws -> Command {
    guard let subcommand = arguments.first else {
        return .summary
    }

    switch subcommand {
    case "summary":
        return .summary
    case "next":
        return .next
    case "phase":
        let phaseName = arguments.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phaseName.isEmpty else {
            throw UsageError("Usage: bash scripts/features.sh phase <phase-name>")
        }
        return .phase(phaseName)
    case "detail":
        guard let id = arguments.dropFirst().first, !id.isEmpty else {
            throw UsageError("Usage: bash scripts/features.sh detail <feature-id>")
        }
        return .detail(id)
    case "pass":
        guard let id = arguments.dropFirst().first, !id.isEmpty else {
            throw UsageError("Usage: bash scripts/features.sh pass <feature-id>")
        }
        return .pass(id)
    case "fail":
        guard let id = arguments.dropFirst().first, !id.isEmpty else {
            throw UsageError("Usage: bash scripts/features.sh fail <feature-id>")
        }
        return .fail(id)
    case "validate":
        return .validate
    case "repair-meta":
        return .repairMeta
    case "-h", "--help", "help":
        throw UsageError(usageText)
    default:
        throw UsageError("Unknown command: \(subcommand)\n\n\(usageText)")
    }
}

private func loadFeaturesFile() throws -> FeaturesFile {
    let url = URL(fileURLWithPath: featuresFilePath)
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try decoder.decode(FeaturesFile.self, from: data)
}

private func saveFeaturesFile(_ file: FeaturesFile) throws {
    let url = URL(fileURLWithPath: featuresFilePath)
    let json = serializeFeaturesFile(file)
    try json.write(to: url, atomically: true, encoding: .utf8)
}

private func updateFeatureStatus(_ file: inout FeaturesFile, featureID: String, passes: Bool) throws {
    guard let index = file.features.firstIndex(where: { $0.id == featureID }) else {
        throw UsageError("Feature \(featureID) not found in \(featuresFilePath)")
    }

    let date = todayString()

    file.features[index].passes = passes
    file.features[index].completedDate = passes ? date : nil

    syncMeta(&file, lastUpdated: date)
}

private func syncMeta(_ file: inout FeaturesFile, lastUpdated: String) {
    file.meta.lastUpdated = lastUpdated
    file.meta.totalFeatures = file.features.count
    file.meta.passing = file.features.filter { $0.passes }.count
    file.meta.failing = file.features.filter { !$0.passes }.count
}

private func validateFeaturesFile(_ file: FeaturesFile) throws {
    let ids = file.features.map { $0.id }
    let uniqueIDs = Set(ids)
    if uniqueIDs.count != ids.count {
        throw UsageError("Duplicate feature IDs found in \(featuresFilePath)")
    }

    let computedTotal = file.features.count
    let computedPassing = file.features.filter { $0.passes }.count
    let computedFailing = computedTotal - computedPassing

    if file.meta.totalFeatures != computedTotal {
        throw UsageError("meta.totalFeatures=\(file.meta.totalFeatures) but computed=\(computedTotal)")
    }
    if file.meta.passing != computedPassing {
        throw UsageError("meta.passing=\(file.meta.passing) but computed=\(computedPassing)")
    }
    if file.meta.failing != computedFailing {
        throw UsageError("meta.failing=\(file.meta.failing) but computed=\(computedFailing)")
    }
}

private func printSummary(_ file: FeaturesFile, style: OutputStyle) {
    let computedTotal = file.features.count
    let computedPassing = file.features.filter { $0.passes }.count
    let computedFailing = computedTotal - computedPassing

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(style.header("WristBop Feature Status"))
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("")
    print("\(style.header("Current Phase:")) \(file.meta.phase)")
    print("\(style.header("Total Features:")) \(computedTotal)")
    print("\(style.success("✅ Passing:")) \(computedPassing)")
    print("\(style.failure("❌ Failing:")) \(computedFailing)")

    if file.meta.totalFeatures != computedTotal || file.meta.passing != computedPassing || file.meta.failing != computedFailing {
        print("")
        print(style.warning("⚠️  meta counts drift detected (run: swift scripts/features.swift repair-meta)"))
    }

    print("")
    print(style.header("By Phase:"))
    for entry in phaseSummaries(features: file.features) {
        print("  \(entry.phase): \(entry.passing)/\(entry.total) passing")
    }

    print("")
    print(style.header("Next Tasks (first 5 failing, not blocked):"))
    let next = nextUnblockedFailingFeatures(in: file).prefix(5)
    if next.isEmpty {
        print("  \(style.success("✅ All unblocked features are passing"))")
    } else {
        for feature in next {
            print("  \(style.failure("❌")) [\(feature.id)] \(feature.description)")
        }
    }
}

private func printNext(_ file: FeaturesFile, style: OutputStyle) {
    print(style.header("Next recommended features to work on:"))
    print("")

    let next = nextUnblockedFailingFeatures(in: file).prefix(5)
    if next.isEmpty {
        print(style.success("✅ No unblocked failing features found"))
        return
    }

    for feature in next {
        print("[\(feature.id)] \(feature.description)")
        print("  Verify: \(feature.verification)")
        print("  Files: \(feature.files.joined(separator: ", "))")
        print("")
    }
}

private func printPhase(_ file: FeaturesFile, phaseName: String, style: OutputStyle) {
    let matches = file.features.filter { $0.phase == phaseName }
    if matches.isEmpty {
        print(style.warning("No features found for phase: \(phaseName)"))
        return
    }

    print(style.header("Features in \(phaseName):"))
    for feature in matches {
        let marker = feature.passes ? style.success("✅") : style.failure("❌")
        print("\(marker) [\(feature.id)] \(feature.description)")
    }
}

private func printDetail(_ file: FeaturesFile, featureID: String) throws {
    guard let feature = file.features.first(where: { $0.id == featureID }) else {
        throw UsageError("Feature \(featureID) not found in \(featuresFilePath)")
    }

    print(serializeFeature(feature))
}

private func nextUnblockedFailingFeatures(in file: FeaturesFile) -> [Feature] {
    file.features.filter { feature in
        guard feature.passes == false else { return false }
        let blockers = feature.blockedBy ?? []
        return blockers.isEmpty
    }
}

private func phaseSummaries(features: [Feature]) -> [(phase: String, total: Int, passing: Int)] {
    let groups = Dictionary(grouping: features, by: { $0.phase })
    return groups
        .map { phase, group in
            (phase: phase, total: group.count, passing: group.filter { $0.passes }.count)
        }
        .sorted { lhs, rhs in
            phaseSortKey(lhs.phase) < phaseSortKey(rhs.phase)
        }
}

private func phaseSortKey(_ phase: String) -> (Int, String) {
    let digits = phase.compactMap { $0.isNumber ? $0 : nil }
    if let number = Int(String(digits)) {
        return (number, phase)
    }
    return (Int.max, phase)
}

private func todayString() -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
}

// MARK: - JSON Serialization (compact, repo-friendly)

private func serializeFeaturesFile(_ file: FeaturesFile) -> String {
    var lines: [String] = []

    lines.append("{")
    lines.append("  \"meta\": {")
    lines.append(contentsOf: serializeMeta(file.meta, indentLevel: 2))
    lines.append("  },")
    lines.append("  \"features\": [")

    for (index, feature) in file.features.enumerated() {
        lines.append("    {")
        lines.append(contentsOf: serializeFeatureLines(feature, indentLevel: 3))
        let trailing = index == file.features.count - 1 ? "" : ","
        lines.append("    }\(trailing)")
    }

    lines.append("  ]")
    lines.append("}")
    lines.append("")

    return lines.joined(separator: "\n")
}

private func serializeMeta(_ meta: Meta, indentLevel: Int) -> [String] {
    let pairs: [(String, String)] = [
        ("project", encodeString(meta.project)),
        ("lastUpdated", encodeString(meta.lastUpdated)),
        ("phase", encodeString(meta.phase)),
        ("DO_NOT_DELETE_FEATURES", encodeString(meta.doNotDeleteFeatures)),
        ("deletionPolicy", encodeString(meta.deletionPolicy)),
        ("totalFeatures", String(meta.totalFeatures)),
        ("passing", String(meta.passing)),
        ("failing", String(meta.failing)),
    ]

    return serializeObjectLines(pairs: pairs, indentLevel: indentLevel)
}

private func serializeFeature(_ feature: Feature) -> String {
    var lines: [String] = []
    lines.append("{")
    lines.append(contentsOf: serializeFeatureLines(feature, indentLevel: 1))
    lines.append("}")
    return lines.joined(separator: "\n")
}

private func serializeFeatureLines(_ feature: Feature, indentLevel: Int) -> [String] {
    var pairs: [(String, String)] = []

    pairs.append(("id", encodeString(feature.id)))
    pairs.append(("phase", encodeString(feature.phase)))
    pairs.append(("category", encodeString(feature.category)))
    pairs.append(("description", encodeString(feature.description)))
    pairs.append(("passes", feature.passes ? "true" : "false"))
    pairs.append(("verification", encodeString(feature.verification)))
    pairs.append(("files", encodeStringArrayInline(feature.files)))

    if let tests = feature.tests {
        pairs.append(("tests", encodeStringArrayInline(tests)))
    }

    pairs.append(("architectureRef", encodeString(feature.architectureRef)))
    pairs.append(("addedDate", encodeString(feature.addedDate)))

    if let completedDate = feature.completedDate {
        pairs.append(("completedDate", encodeString(completedDate)))
    }

    if let blockedBy = feature.blockedBy {
        pairs.append(("blockedBy", encodeStringArrayInline(blockedBy)))
    }

    return serializeObjectLines(pairs: pairs, indentLevel: indentLevel)
}

private func serializeObjectLines(pairs: [(String, String)], indentLevel: Int) -> [String] {
    let indent = String(repeating: "  ", count: indentLevel)
    return pairs.enumerated().map { index, pair in
        let trailing = index == pairs.count - 1 ? "" : ","
        return "\(indent)\"\(pair.0)\": \(pair.1)\(trailing)"
    }
}

private func encodeStringArrayInline(_ strings: [String]) -> String {
    let encoded = strings.map(encodeString).joined(separator: ", ")
    return "[\(encoded)]"
}

private func encodeString(_ string: String) -> String {
    "\"\(escapeJSONString(string))\""
}

private func escapeJSONString(_ string: String) -> String {
    var result = ""
    result.reserveCapacity(string.count)

    for scalar in string.unicodeScalars {
        switch scalar.value {
        case 0x22: // "
            result.append("\\\"")
        case 0x5C: // \
            result.append("\\\\")
        case 0x08: // backspace
            result.append("\\b")
        case 0x0C: // form feed
            result.append("\\f")
        case 0x0A: // \n
            result.append("\\n")
        case 0x0D: // \r
            result.append("\\r")
        case 0x09: // \t
            result.append("\\t")
        case 0x00...0x1F:
            result.append(String(format: "\\u%04X", scalar.value))
        default:
            result.unicodeScalars.append(scalar)
        }
    }

    return result
}

private let style = OutputStyle(useColor: isatty(STDOUT_FILENO) != 0)

do {
    let command = try parseCommand(arguments: Array(CommandLine.arguments.dropFirst()))
    switch command {
    case .summary:
        let file = try loadFeaturesFile()
        printSummary(file, style: style)
    case .next:
        let file = try loadFeaturesFile()
        printNext(file, style: style)
    case let .phase(phaseName):
        let file = try loadFeaturesFile()
        printPhase(file, phaseName: phaseName, style: style)
    case let .detail(featureID):
        let file = try loadFeaturesFile()
        try printDetail(file, featureID: featureID)
    case let .pass(featureID):
        var file = try loadFeaturesFile()
        try updateFeatureStatus(&file, featureID: featureID, passes: true)
        try saveFeaturesFile(file)
        print(style.success("✅ Feature \(featureID) marked as passing"))
    case let .fail(featureID):
        var file = try loadFeaturesFile()
        try updateFeatureStatus(&file, featureID: featureID, passes: false)
        try saveFeaturesFile(file)
        print(style.failure("❌ Feature \(featureID) marked as failing"))
    case .validate:
        let file = try loadFeaturesFile()
        try validateFeaturesFile(file)
        print(style.success("✅ features.json validation passed"))
    case .repairMeta:
        var file = try loadFeaturesFile()
        syncMeta(&file, lastUpdated: todayString())
        try saveFeaturesFile(file)
        print(style.success("✅ features.json meta repaired"))
    }
} catch {
    fputs("\(style.failure("Error:")) \(error)\n", stderr)
    exit(1)
}
