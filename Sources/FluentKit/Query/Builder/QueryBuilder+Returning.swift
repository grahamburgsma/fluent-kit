extension QueryBuilder {

    /// Allows returning the full model from an insert/update/delete query
    public func returning(action: DatabaseQuery.Action) -> Self {
        query.returning = true
        query.action = action
        return self
    }
}
