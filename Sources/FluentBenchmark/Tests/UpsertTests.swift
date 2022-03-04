extension FluentBenchmarker {
    public func testUpsert() throws {
        try self.testConflictUpdate()
        try self.testConflictIgnore()
    }

    private func testConflictUpdate() throws {
        try self.runTest(#function, [
            FooMigration()
        ]) {
            let first = Foo(bar: "a")
            try first.create(on: self.database).wait()

            let second = Foo(bar: "a")

            try second.create(
                onConflict: \.$bar,
                .update {
                    $0.set(\.$bar, to: "b")
                },
                on: self.database
            )
            .wait()

            XCTAssertEqual(first.id, second.id)
            XCTAssertEqual(second.bar, "b")
        }
    }

    private func testConflictIgnore() throws {
        try self.runTest(#function, [
            FooMigration()
        ]) {
            let first = Foo(bar: "a")
            try first.create(on: self.database).wait()

            let second = Foo(bar: "a")

            do {
                try second.create(
                    onConflict: \.$bar, .ignore,
                    on: self.database
                )
                .wait()
                XCTFail("Insert should fail with error \(FluentError.noResults)")
            } catch {
                XCTAssertEqual("\(error)", FluentError.noResults.description)
            }

            let fooCount = try Foo
                .query(on: self.database)
                .count()
                .wait()

            XCTAssertEqual(fooCount, 1)
        }
    }
}

private final class Foo: Model {
    static let schema = "foos"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "bar")
    var bar: String

    init() { }

    init(id: IDValue? = nil, bar: String) {
        self.id = id
        self.bar = bar
    }
}

private struct FooMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("foos")
            .id()
            .field("bar", .string, .required)
            .unique(on: "bar")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("foos").delete()
    }
}
