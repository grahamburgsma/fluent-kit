extension DatabaseQuery {
    public enum Returning {
        case all
        case fields([Field])
    }
}

extension DatabaseQuery.Returning: CustomStringConvertible {
    public var description: String {
        switch self {
        case .all:
            return "all"
        case let .fields(fields):
            return fields.description
        }
    }
}
