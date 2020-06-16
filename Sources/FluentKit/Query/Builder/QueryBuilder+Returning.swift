extension QueryBuilder {

    public func create(returning: DatabaseQuery.Returning) -> EventLoopFuture<Model?> {
        query.returning = returning
        query.action = .create
        return first()
    }

    public func update(returning: DatabaseQuery.Returning) -> EventLoopFuture<Model?> {
        query.returning = returning
        query.action = .update
        return first()
    }

    public func delete(force: Bool = false, returning: DatabaseQuery.Returning) -> EventLoopFuture<Model?> {
        includeDeleted = true
        shouldForceDelete = force
        query.returning = returning
        query.action = .delete
        return first()
    }

    public func create(returning: DatabaseQuery.Returning) -> EventLoopFuture<[Model]> {
        query.returning = returning
        query.action = .create
        return all()
    }

    public func update(returning: DatabaseQuery.Returning) -> EventLoopFuture<[Model]> {
        query.returning = returning
        query.action = .update
        return all()
    }

    public func delete(force: Bool = false, returning: DatabaseQuery.Returning) -> EventLoopFuture<[Model]> {
        includeDeleted = true
        shouldForceDelete = force
        query.returning = returning
        query.action = .delete
        return all()
    }

    public func all(action: DatabaseQuery.Action) -> EventLoopFuture<[Model]> {
        query.action = action
        return all()
    }

    public func first(action: DatabaseQuery.Action) -> EventLoopFuture<Model?> {
        query.action = action
        return first()
    }
}
