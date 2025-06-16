import SwiftUI

// MARK: - Models
struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

// MARK: - View Models
class TodoListViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    @Published var newItemTitle: String = ""
    
    func addItem() {
        guard !newItemTitle.isEmpty else { return }
        items.append(TodoItem(title: newItemTitle, isCompleted: false))
        newItemTitle = ""
    }
    
    func toggleItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }
    
    func deleteItem(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
    }
}

// MARK: - Views
struct TodoListView: View {
    @StateObject private var viewModel = TodoListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Add new item
                HStack {
                    TextField("New todo item", text: $viewModel.newItemTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: viewModel.addItem) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // List of items
                List {
                    ForEach(viewModel.items) { item in
                        TodoItemRow(item: item) {
                            viewModel.toggleItem(item)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            viewModel.deleteItem(viewModel.items[index])
                        }
                    }
                }
            }
            .navigationTitle("Todo List")
        }
    }
}

struct TodoItemRow: View {
    let item: TodoItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            
            Text(item.title)
                .strikethrough(item.isCompleted)
                .foregroundColor(item.isCompleted ? .gray : .primary)
        }
    }
}

// MARK: - Preview
struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}

// MARK: - App Entry Point
@main
struct TodoApp: App {
    var body: some Scene {
        WindowGroup {
            TodoListView()
        }
    }
} 