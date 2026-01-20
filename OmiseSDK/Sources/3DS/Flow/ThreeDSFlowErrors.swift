import Foundation

public enum ThreeDSFlowError: Error, Equatable {
    case configUnavailable
    case sdkStartFailed(String)
    case authenticationFailed(String)
    case challengeDataMissing
    case challengeFailed(String)
}

public enum ThreeDSRepositoryError: Error, Equatable {
    case invalidResponse
    case missingChallengeData
}

public enum ThreeDSFlowControllerError: Error, Equatable {
    case cancelled
    case failed(String)
}
