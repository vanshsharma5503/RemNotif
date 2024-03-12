
import SwiftUI
import UserNotifications
struct Reminder: Identifiable {
    var id = UUID()
    var name: String
    var image: UIImage? // Change to UIImage?
    var location: String
    var action: String
    var repeatOptions: [Date]
    var time: Date
    var lastWatering: Date
    var isCompleted: Bool = false
}
struct ContentViewRem_Previews: PreviewProvider {
    static var previews: some View {
        RemindersView()
    }
}


struct ReminderDetailsView: View {
    var reminder: Reminder

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Section
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.gray.opacity(0.2))
                    reminder.image.map {
                        Image(uiImage: $0)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                    }
                }
                .padding(.horizontal)

                // Reminder Details
                ZStack{
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Location:")
                            .font(.headline)
                        Text("\(reminder.location)")
                            .foregroundColor(.secondary)

                        Text("Action:")
                            .font(.headline)
                        Text("\(reminder.action)")
                            .foregroundColor(.secondary)

                        Text("Repeat Options:")
                            .font(.headline)
                        ForEach(reminder.repeatOptions, id: \.self) { date in
                            Text("\(date)")
                                .foregroundColor(.secondary)
                        }

                        Text("Time:")
                            .font(.headline)
                        Text("\(reminder.time)")
                            .foregroundColor(.secondary)

                        Text("Last Watering:")
                            .font(.headline)
                        Text("\(reminder.lastWatering)")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .padding()
            .navigationBarTitle(reminder.name)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.9686, green: 0.8824, blue: 0.8431), Color(red: 240/255.0, green: 255/255.0, blue: 241/255.0)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
}

struct ReminderRowView: View {
    @ObservedObject var reminderStore: ReminderStore
    var reminder: Reminder

    var body: some View {
        HStack {
            Image(uiImage: reminder.image ?? UIImage(systemName: "photo")!) // Placeholder image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)

            Button(action: {
                reminderStore.toggleCompletion(for: reminder)
                if reminder.isCompleted {
                    if let index = reminderStore.reminders.firstIndex(where: { $0.id == reminder.id }) {
                        reminderStore.deleteReminder(at: IndexSet([index]))
                    }
                }
            }) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(BorderlessButtonStyle())

            Text(reminder.name)

            Spacer()

            NavigationLink(destination: ReminderDetailsView(reminder: reminder)) {
                EmptyView()
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct AddReminderView: View {
    @ObservedObject var reminderStore: ReminderStore
    @State private var name = ""
    @State private var location = ""
    @State private var action = "Watering"
    @State private var repeatOptions: [Date] = [Date()]
    @State private var time = Date()
    @State private var lastWatering = Date()
    @State private var showImagePicker = false
    @State private var image: UIImage?
    @State private var isReminderAdded = false
    @Environment(\.presentationMode) var presentationMode

    let names = ["Rose", "SnakePlant"]
    let actions = ["Watering", "Misting", "Fertilizing", "Pruning"]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Reminder Details")) {
                    Picker("Name", selection: $name) {
                        ForEach(names, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("Location", text: $location)

                    Picker("Action", selection: $action) {
                        ForEach(actions, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section(header: Text("Schedule")) {
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    DatePicker("Last Watering", selection: $lastWatering, displayedComponents: .date)

                    ForEach(repeatOptions.indices, id: \.self) { index in
                        DatePicker("Repeat Option", selection: $repeatOptions[index], displayedComponents: .date)
                    }

                    Button(action: {
                        repeatOptions.append(Date())
                    }) {
                        Text("Add Another Date")
                    }
                }

                Section(header: Text("Photo")) {
                    Button(action: {
                        self.showImagePicker = true
                    }) {
                        Text("Add Photo")
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePickerRem(image: self.$image)
                    }
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                }

                Section {
                    HStack {


                        Button(action: {
                            let newReminder = Reminder(name: self.name, image: self.image, location: self.location, action: self.action, repeatOptions: self.repeatOptions, time: self.time, lastWatering: self.lastWatering)
                            self.reminderStore.addReminder(reminder: newReminder)
                            self.isReminderAdded = true
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Add Reminder")
                        }
                        .disabled(isReminderAdded)                     }
                }
            }
            .navigationBarTitle("Add Reminder")
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.9686, green: 0.8824, blue: 0.8431), Color(red: 240/255.0, green: 255/255.0, blue: 241/255.0)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                )
            )
        }
    }
}


struct ImagePickerRem: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerRem

        init(parent: ImagePickerRem) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
struct ReminderSummaryView: View {
    @ObservedObject var reminderStore: ReminderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Due Today: \(dueTodayCount())")
                Spacer()
                Text("Remaining: \(remainingCount())")
                Spacer()
                Text("Completed: \(completedCount())")
            }
            .foregroundColor(.secondary)
        }
    }

    func dueTodayCount() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return reminderStore.reminders.filter { Calendar.current.isDate($0.time, inSameDayAs: today) }.count
    }

    func remainingCount() -> Int {
        return reminderStore.reminders.filter { !$0.isCompleted }.count
    }

    func completedCount() -> Int {
        return reminderStore.reminders.filter { $0.isCompleted }.count
    }
}
struct RemindersView: View {
    @ObservedObject var reminderStore = ReminderStore()
    @State private var isAddReminderSheetPresented = false

    var body: some View {
        NavigationView {
            List {
                Section(header: ReminderSummaryView(reminderStore: reminderStore)) {
                    ForEach(reminderStore.reminders) { reminder in
                        ReminderRowView(reminderStore: reminderStore, reminder: reminder)
                    }
                    .onDelete { indexSet in
                        reminderStore.deleteReminder(at: indexSet)
                    }
                }
            }
            .background( LinearGradient(gradient: Gradient(colors: [Color(red: 0.9686, green: 0.8824, blue: 0.8431), Color(red: 240/255.0, green: 255/255.0, blue: 241/255.0)]),
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing
                                     ))
            .scrollContentBackground(.hidden)
            .navigationBarTitle("Reminders")
            .navigationBarItems(trailing: Button(action: {
                isAddReminderSheetPresented = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $isAddReminderSheetPresented) {
                AddReminderView(reminderStore: reminderStore)
            }
        }
    }
}

struct RemindersView_Preview: PreviewProvider {
    static var previews: some View {
        RemindersView()
    }
}

class ReminderStore: ObservableObject {
    @Published var reminders: [Reminder] = []

    func addReminder(reminder: Reminder) {
        reminders.append(reminder)
    }

    func deleteReminder(at indexSet: IndexSet) {
        reminders.remove(atOffsets: indexSet)
    }

    func toggleCompletion(for reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isCompleted.toggle()
        }
    }

    func editReminder(for reminder: Reminder, newName: String, newLocation: String, newAction: String, newRepeatOptions: [Date], newTime: Date, newLastWatering: Date) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].name = newName
            reminders[index].location = newLocation
            reminders[index].action = newAction
            reminders[index].repeatOptions = newRepeatOptions
            reminders[index].time = newTime
            reminders[index].lastWatering = newLastWatering
        }
    }
}

