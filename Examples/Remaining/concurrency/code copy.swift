enum VendingMachineError: Error {
    case invalidSelection
    case insufficientFunds(coinsNeeded: Int)
    case outOfStock
}

class VendingMachine {
    var inventory = [
        "Candy Bar": Item(price: 12, count: 7),
        "Chips": Item(price: 10, count: 4),
        "Pretzels": Item(price: 7, count: 11)
    ]
    var coinsDeposited = 0


    func vend(itemNamed name: String) throws {
        guard let item = inventory[name] else {
            throw VendingMachineError.invalidSelection
        }


        guard item.count > 0 else {
            throw VendingMachineError.outOfStock
        }


        guard item.price <= coinsDeposited else {
            throw VendingMachineError.insufficientFunds(coinsNeeded: item.price - coinsDeposited)
        }


        coinsDeposited -= item.price


        var newItem = item
        newItem.count -= 1
        inventory[name] = newItem


        print("Dispensing \(name)")
    }
}

var vendingMachine = VendingMachine()
vendingMachine.coinsDeposited = 8
do {
    try buyFavoriteSnack(person: "Alice", vendingMachine: vendingMachine)
    print("Success! Yum.")
} catch VendingMachineError.invalidSelection {
    print("Invalid Selection.")
} catch VendingMachineError.outOfStock {
    print("Out of Stock.")
} catch VendingMachineError.insufficientFunds(let coinsNeeded) {
    print("Insufficient funds. Please insert an additional \(coinsNeeded) coins.")
} catch {
    print("Unexpected error: \(error).")
}

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

let x = try? someThrowingFunction()


let y: Int?
do {
    y = try someThrowingFunction()
} catch {
    y = nil
}


let photo = try! loadImage(atPath: "./Resources/John Appleseed.jpg")

enum StatisticsError: Error {
    case noRatings
    case invalidRating(Int)
}

func nonThrowingFunction() throws(Never) {
  // ...
}

func summarize(_ ratings: [Int]) throws(StatisticsError) {
    guard !ratings.isEmpty else { throw .noRatings }


    var counts = [1: 0, 2: 0, 3: 0]
    for rating in ratings {
        guard rating > 0 && rating <= 3 else { throw .invalidRating(rating) }
        counts[rating]! += 1
    }


    print("*", counts[1]!, "-- **", counts[2]!, "-- ***", counts[3]!)
}

let ratings = []
do throws(StatisticsError) {
    try summarize(ratings)
} catch {
    switch error {
    case .noRatings:
        print("No ratings available")
    case .invalidRating(let rating):
        print("Invalid rating: \(rating)")
    }
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
