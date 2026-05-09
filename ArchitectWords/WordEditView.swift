import SwiftUI
import SwiftData

/// 単語の新規追加 / 編集を行うフォーム。
/// `word == nil` のときは新規追加モード。
struct WordEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let word: Word?

    @State private var term: String = ""
    @State private var reading: String = ""
    @State private var meaning: String = ""
    @State private var detail: String = ""
    @State private var category: WordCategory = .planning
    @State private var importance: Int = 2
    @State private var isFavorite: Bool = false
    @State private var isWeak: Bool = false
    @State private var isMemorized: Bool = false

    @State private var showDeleteConfirm: Bool = false

    private var isNew: Bool { word == nil }
    private var canSave: Bool {
        !term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !meaning.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("単語") {
                TextField("単語(必須)", text: $term)
                    .textInputAutocapitalization(.never)
                TextField("読み(かな)", text: $reading)
                    .textInputAutocapitalization(.never)
            }

            Section("意味") {
                TextField("短い意味(必須)", text: $meaning, axis: .vertical)
                    .lineLimit(2...4)
                TextField("詳細解説", text: $detail, axis: .vertical)
                    .lineLimit(3...10)
            }

            Section("分類") {
                Picker("カテゴリ", selection: $category) {
                    ForEach(WordCategory.allCases) { c in
                        Label(c.rawValue, systemImage: c.systemImage).tag(c)
                    }
                }
                Picker("重要度", selection: $importance) {
                    Text("☆ 普通").tag(1)
                    Text("☆☆ 大事").tag(2)
                    Text("☆☆☆ 最重要").tag(3)
                }
            }

            if !isNew {
                Section("ステータス") {
                    Toggle(isOn: $isFavorite) {
                        Label("お気に入り", systemImage: "star.fill").foregroundStyle(.primary)
                    }
                    Toggle(isOn: $isWeak) {
                        Label("苦手", systemImage: "exclamationmark.triangle.fill").foregroundStyle(.primary)
                    }
                    Toggle(isOn: $isMemorized) {
                        Label("暗記済み", systemImage: "checkmark.circle.fill").foregroundStyle(.primary)
                    }
                }
            }

            if let w = word, w.isUserAdded {
                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("この単語を削除", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle(isNew ? "単語を追加" : "単語を編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isNew ? "追加" : "保存") { save() }
                    .disabled(!canSave)
            }
            if isNew {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") { resetForm() }
                }
            }
        }
        .onAppear { loadFromWord() }
        .alert("削除しますか?", isPresented: $showDeleteConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) { deleteWord() }
        } message: {
            Text("この単語をデータから削除します。元に戻せません。")
        }
    }

    private func loadFromWord() {
        guard let w = word else { return }
        term = w.term
        reading = w.reading
        meaning = w.meaning
        detail = w.detail
        category = w.categoryEnum
        importance = w.importance
        isFavorite = w.isFavorite
        isWeak = w.isWeak
        isMemorized = w.isMemorized
    }

    private func save() {
        let trimmedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMeaning = meaning.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTerm.isEmpty, !trimmedMeaning.isEmpty else { return }

        if let w = word {
            w.term = trimmedTerm
            w.reading = reading
            w.meaning = trimmedMeaning
            w.detail = detail
            w.category = category.rawValue
            w.importance = importance
            w.isFavorite = isFavorite
            w.isWeak = isWeak
            w.isMemorized = isMemorized
        } else {
            let new = Word(
                term: trimmedTerm,
                reading: reading,
                meaning: trimmedMeaning,
                detail: detail,
                category: category,
                importance: importance,
                isUserAdded: true
            )
            modelContext.insert(new)
        }

        try? modelContext.save()

        if isNew {
            resetForm()
        } else {
            dismiss()
        }
    }

    private func deleteWord() {
        guard let w = word else { return }
        modelContext.delete(w)
        try? modelContext.save()
        dismiss()
    }

    private func resetForm() {
        term = ""
        reading = ""
        meaning = ""
        detail = ""
        category = .planning
        importance = 2
        isFavorite = false
        isWeak = false
        isMemorized = false
    }
}
