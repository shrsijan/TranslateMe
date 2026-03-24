//
//  ContentView.swift
//  TranslateMe
//
//  Created by Sijan Shrestha on 3/24/26.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var viewModel = TranslationViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                header

                sourceTextSection

                languageSection

                actionSection

                translatedSection

                historySection

                Spacer(minLength: 0)
            }
            .padding(16)
            .navigationTitle("TranslateMe")
            .task {
                await viewModel.loadHistory()
            }
            .alert("Unable to Translate", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Quick translation")
                .font(.headline)
            Text("Enter text, choose languages, and save every result to your history.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var sourceTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Text to translate")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("Type a word, phrase, or sentence", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...5)
        }
    }

    private var languageSection: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("From")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("From", selection: $viewModel.sourceLanguage) {
                    ForEach(LanguageOption.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.menu)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("To")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("To", selection: $viewModel.targetLanguage) {
                    ForEach(LanguageOption.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    private var actionSection: some View {
        HStack {
            Button {
                Task {
                    await viewModel.translate()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Translate")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Button("Clear") {
                viewModel.clearCurrentTranslation()
            }
            .buttonStyle(.bordered)
        }
    }

    private var translatedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Translation")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.translatedText.isEmpty ? "Your translation appears here." : viewModel.translatedText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("History")
                    .font(.headline)

                Spacer()

                Button("Erase History", role: .destructive) {
                    Task {
                        await viewModel.clearHistory()
                    }
                }
                .disabled(viewModel.history.isEmpty)
            }

            if viewModel.history.isEmpty {
                Text("No saved translations yet.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.history) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.sourceText)
                                    .font(.subheadline)
                                Text(item.translatedText)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                Text("\(item.sourceLanguage.uppercased()) → \(item.targetLanguage.uppercased())")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                    .padding(.top, 2)
                }
                .frame(maxHeight: 220)
            }
        }
    }
}

#Preview {
    ContentView()
}
