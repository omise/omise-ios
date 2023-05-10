import Foundation

public class TestCaseValueGenerator {
    public typealias GeneratorFunction<T> = (TestCaseValueGenerator) -> (T)

    public enum Filter {
        case invalid
        case valid
    }

    private var iteration: Int = 0
    private var totalIterations: Int = 0
    private var filter: Filter

    private var processingSubsetIndex: Int = 0
    private var subsetsCount: [Int] = []

    private init(filter: Filter) {
        self.filter = filter
    }

    public static func validCases<T>(_ function: GeneratorFunction<T>) -> [T] {
        filterCases(filter: .valid, function)
    }
    public static func invalidCases<T>(_ function: GeneratorFunction<T>) -> [T] {
        filterCases(filter: .invalid, function)
    }

    public static func allCases<T>(_ function: GeneratorFunction<T>) -> [T] {
        filterCases(filter: .valid, function) + filterCases(filter: .invalid, function)
    }

    public func cases<T: Hashable>(_ from: TestCaseValue<T>...) -> T {
        var array = [TestCaseValue<T>]()
        for item in from {
            array.append(item)
        }
        return cases(array)
    }

    /// Return value of T based on the current generator's filter.
    /// Warning: Currently can be used in debug mode only as it force unwrap result and coud cause app crash
    public func cases<T: Hashable>(_ from: [TestCaseValue<T>]) -> T {
        let filteredValues = TestCaseValueSet(from).filtered(filter)
        let currentCaseClosureIndex = self.subsetIndex(for: iteration)
        var returnValue: T?

        if iteration == 0 {
            subsetsCount.append(filteredValues.count)

            switch filter {
            case .invalid:
                totalIterations += filteredValues.count
                if currentCaseClosureIndex == processingSubsetIndex {
                    returnValue = filteredValues.first
                } else {
                    returnValue = TestCaseValueSet(from).valid
                }
            case .valid:
                if filteredValues.count > totalIterations {
                    totalIterations = filteredValues.count
                }
                returnValue = filteredValues.first
            }
        } else {
            switch filter {
            case .invalid:
                if currentCaseClosureIndex == processingSubsetIndex {
                    returnValue = filteredValues[iteration % filteredValues.count]
                } else {
                    let validValues = TestCaseValueSet(from).validAll
                    returnValue = validValues[iteration % validValues.count]
                }
            case .valid:
                returnValue = filteredValues[iteration % filteredValues.count]
            }
        }

        processingSubsetIndex += 1

        // swiftlint:disable:next force_unwrapping
        return returnValue!
    }
}

private extension TestCaseValueGenerator {
    func subsetIndex(for iteraction: Int) -> Int {
        var count = 0
        var caseIndex = 0
        for caseCount in subsetsCount {
            count += caseCount

            if iteraction < count {
                return caseIndex
            }

            caseIndex += 1
        }

        return 0
    }

    static func filterCases<T>(filter: Filter, _ function: GeneratorFunction<T>) -> [T] {
        let generator = TestCaseValueGenerator(filter: filter)
        var values: [T] = []
        repeat {
            generator.processingSubsetIndex = 0
            let value = function(generator)
            values.append(value)
            generator.iteration += 1
        } while (generator.iteration < generator.totalIterations)
        return values
    }
}

private extension TestCaseValueSet {
    func filtered(_ filter: TestCaseValueGenerator.Filter) -> [T] {
        switch filter {
        case .invalid:
            return self.invalidAll
        case .valid:
            return self.validAll
        }
    }
}
