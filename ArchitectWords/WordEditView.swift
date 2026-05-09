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
    @State private var showAddedToast: Bool = false

    /// キーボード制御用。`@FocusState` で全 TextField をひと括りに管理する。
    enum Field: Hashable { case term, reading, meaning, detail }
    @FocusState private var focused: Field?

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
                    .submitLabel(.next)
                    .focused($focused, equals: .term)
                    .onSubmit { focused = .reading }
                TextField("読み(かな)", text: $reading)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .focused($focused, equals: .reading)
                    .onSubmit { focused = .meaning }
            }

            Section("意味") {
                TextField("短い意味(必須)", text: $meaning, axis: .vertical)
                    .lineLimit(2...4)
                    .focused($focused, equals: .meaning)
                TextField("詳細解説", text: $detail, axis: .vertical)
                    .lineLimit(3...10)
                    .focused($focused, equals: .detail)
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
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isNew ? "追加" : "保存") { save() }
                    .disabled(!canSave)
            }
            // キーボード上部の「完了」ボタン。これが無いとタブバーが隠れて画面遷移できない。
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完了") { focused = nil }
            }
        }
        .onAppear { loadFromWord() }
        .alert("削除しますか?", isPresented: $showDeleteConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) { deleteWord() }
        } message: {
            Text("この単語をデータから削除します。元に戻せません。")
        }
        .overlay(alignment: .top) {
            if showAddedToast {
                Label("追加しました", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: Capsule())
                    .foregroundStyle(.green)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
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

        // キーボードを閉じてタブバーを露出させる。これが無いと他タブに行けない。
        focused = nil

        if isNew {
            resetForm()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showAddedToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeOut(duration: 0.25)) { showAddedToast = false }
            }
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
