import SwiftUI

// MARK: - Exercise Picker View

struct ExercisePickerView: View {
    @Binding var selectedExercise: ExerciseType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(ExerciseType.allCases) { exercise in
                    Button {
                        selectedExercise = exercise
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: exercise.iconName)
                                .font(.title3)
                                .foregroundColor(.forgeAmber)
                                .frame(width: 32, alignment: .center)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.displayName)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text(exercise.description)
                                    .font(.caption)
                                    .foregroundColor(.forgeMediumGray)
                                    .lineLimit(2)
                            }

                            Spacer()

                            if exercise == selectedExercise {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.forgeAmber)
                            }
                        }
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(Color.forgeCardBackground)
                    .accessibilityLabel("\(exercise.displayName). \(exercise.description)")
                    .accessibilityAddTraits(exercise == selectedExercise ? .isSelected : [])
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.forgeBlack)
            .navigationTitle("Select Exercise")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.forgeAmber)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ExercisePickerView(selectedExercise: .constant(.squat))
}
