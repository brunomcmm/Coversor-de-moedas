//
//  ContentView.swift
//  Conversor de Moedas
//
//  Este módulo gerencia a interface do usuário, exibindo a taxa de câmbio
//  atual e um gráfico de histórico.
//  Criado por Bruno Maciel.
//
//  Commit: Alterado para usar índices numéricos em vez de datas no eixo X. Adicionado histórico inicial de 3 valores fixos.

import SwiftUI
import Charts

struct ContentView: View {
    @State private var currentRate: Double = 727.40 // Valor inicial
    @State private var previousRate: Double? = nil // Valor anterior para comparação
    @State private var storedRates: [Double] = [] // Lista de taxas armazenadas
    @State private var storedIndices: [Int] = [] // Índices correspondentes às taxas

    private let conversor = ConversorDeMoedas() // Instância do módulo de conversão

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Título do aplicativo
                Text("1 BRL = COP")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                // Exibição do valor atual
                currentRateView()

                // Gráfico da variação
                if !storedRates.isEmpty && !storedIndices.isEmpty {
                    ExchangeRateChartView(
                        rates: storedRates,
                        indices: storedIndices // Agora passamos os índices
                    )
                    .frame(height: 200)
                    .padding()
                } else {
                    Text("Carregando gráfico...")
                        .foregroundColor(.gray)
                }

                // Botão para atualizar a taxa
                updateButton()

                Spacer()
            }
            .padding()
            .onAppear {
                NotificationManager.shared.requestPermission()
                initializeDefaultHistory()
                loadStoredRates()

                // Agendar atualizações às 10h e 12h, de segunda a sexta
                NotificationManager.shared.scheduleDailyUpdates(at: [10, 12]) {
                    currentRate
                }
            }
        }
    }

    // Exibição do valor atual e comparação
    @ViewBuilder
    private func currentRateView() -> some View {
        HStack {
            Text("1 BRL =")
                .font(.headline)
            Text(String(format: "%.2f", currentRate) + " COP")
                .font(.title3)
                .bold()
                .foregroundColor(compareRates(current: currentRate, previous: previousRate))
        }
        .padding(.horizontal)
    }

    // Botão para atualizar a taxa
    @ViewBuilder
    private func updateButton() -> some View {
        Button(action: {
            fetchDailyExchangeRate()
        }) {
            Text("Atualizar")
                .font(.title) // Aumenta a fonte para um tamanho maior
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    // Função para comparar taxas
    private func compareRates(current: Double, previous: Double?) -> Color {
        guard let previous = previous else { return .primary }
        return current > previous ? .green : .red
    }

    // Buscar e salvar a taxa diária
    private func fetchDailyExchangeRate() {
        conversor.fetchExchangeRate(from: "BRL", to: "COP") { rate in
            DispatchQueue.main.async {
                if let rate = rate {
                    previousRate = currentRate
                    currentRate = rate

                    // Adiciona a nova taxa e índice à lista
                    storedRates.append(rate)
                    let nextIndex = (storedIndices.last ?? 0) + 1
                    storedIndices.append(nextIndex)

                    // Mantém no máximo 160 entradas
                    if storedRates.count > 160 {
                        storedRates.removeFirst()
                        storedIndices.removeFirst()
                    }

                    saveStoredRates()

                    // Notifica o usuário
                    NotificationManager.shared.sendNotification(for: rate)
                }
            }
        }
    }

    // Inicializa o histórico padrão
    private func initializeDefaultHistory() {
        if storedRates.isEmpty && storedIndices.isEmpty {
            storedRates = [700, 715, 730]
            storedIndices = [1, 2, 3]
        }
    }

    // Salvar as taxas armazenadas
    private func saveStoredRates() {
        UserDefaults.standard.set(storedRates, forKey: "storedRates")
        UserDefaults.standard.set(storedIndices, forKey: "storedIndices")
    }

    // Carregar as taxas armazenadas
    private func loadStoredRates() {
        if let rates = UserDefaults.standard.array(forKey: "storedRates") as? [Double],
           let indices = UserDefaults.standard.array(forKey: "storedIndices") as? [Int] {
            storedRates = rates
            storedIndices = indices
        }

        // Define o valor atual e o anterior
        currentRate = storedRates.last ?? 727.40
        previousRate = storedRates.dropLast().last
    }
}

#Preview {
    ContentView()
}
