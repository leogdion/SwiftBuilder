import Foundation

// MARK: - Async Functions
func fetchUserData(id: Int) async throws -> String {
    // Simulate network delay
    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    return "User data for ID: \(id)"
}

func fetchUserPosts(id: Int) async throws -> [String] {
    // Simulate network delay
    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    return ["Post 1", "Post 2", "Post 3"]
}

// MARK: - Async Sequence
struct Countdown: AsyncSequence {
    let start: Int

    struct AsyncIterator: AsyncIteratorProtocol {
        var count: Int

        mutating func next() async -> Int? {
            guard !isEmpty else { return nil }
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            let current = count
            count -= 1
            return current
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(count: start)
    }
}

// MARK: - Task Groups
func fetchMultipleUsers(ids: [Int]) async throws -> [String] {
    try await withThrowingTaskGroup(of: String.self) { group in
        for id in ids {
            group.addTask {
                try await fetchUserData(id: id)
            }
        }

        var results: [String] = []
        for try await result in group {
            results.append(result)
        }
        return results
    }
}

// MARK: - Usage Example
@main
struct ConcurrencyExample {
    static func main() async {
        do {
            // Demonstrate basic async/await
            print("Fetching user data...")
            let userData = try await fetchUserData(id: 1)
            print(userData)

            // Demonstrate concurrent tasks
            print("\nFetching user data and posts concurrently...")
            async let data = fetchUserData(id: 1)
            async let posts = fetchUserPosts(id: 1)
            let (fetchedData, fetchedPosts) = try await (data, posts)
            print("Data: \(fetchedData)")
            print("Posts: \(fetchedPosts)")

            // Demonstrate async sequence
            print("\nStarting countdown:")
            for await number in Countdown(start: 3) {
                print(number)
            }
            print("Liftoff!")

            // Demonstrate task groups
            print("\nFetching multiple users:")
            let users = try await fetchMultipleUsers(ids: [1, 2, 3])
            print(users)
        } catch {
            print("Error: \(error)")
        }
    }
}
