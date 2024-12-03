//
//  ContentView.swift
//  Conversor de Moedas
//
//  Este módulo gerencia a interface do usuário, exibindo a taxa de câmbio
//  atual e um gráfico de histórico. Atualizado para remover entrada de valor
//  e seleção de moeda.
//  Criado por Bruno Maciel em 28/11/2024.
//

import SwiftUI
import Charts

struct ContentView: View {
    @State private var currentRate: Double = 727.40 // Valor inicial
    @State private var previousRate: Double? = nil // Valor anterior para comparação
    @State private var storedRates: [Double] = [] // Lista de taxas armazenadas
    @State private var storedDates: [String] = [] // Datas correspondentes às taxas

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
                ExchangeRateChartView(
                    rates: storedRates,
                    dates: storedDates
                )
                .frame(height: 200)
                .padding()

                // Botão para atualizar a taxa
                updateButton()

                Spacer()
            }
            .padding()
            .onAppear {
                NotificationManager.shared.requestPermission()
                loadStoredRates()
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

                    // Adiciona a nova taxa e data à lista
                    storedRates.append(rate)
                    storedDates.append(generateDate())

                    // Mantém no máximo 30 entradas
                    if storedRates.count > 30 {
                        storedRates.removeFirst()
                    }
                    if storedDates.count > 30 {
                        storedDates.removeFirst()
                    }

                    saveStoredRates()

                    // Notifica o usuário
                    NotificationManager.shared.sendNotification(for: rate)
                }
            }
        }
    }

    // Salvar as taxas armazenadas
    private func saveStoredRates() {
        UserDefaults.standard.set(storedRates, forKey: "storedRates")
        UserDefaults.standard.set(storedDates, forKey: "storedDates")
    }

    // Carregar as taxas armazenadas
    private func loadStoredRates() {
        if let rates = UserDefaults.standard.array(forKey: "storedRates") as? [Double],
           let dates = UserDefaults.standard.array(forKey: "storedDates") as? [String] {
            storedRates = rates
            storedDates = dates
        }

        // Verifica se há ao menos um dado para exibição
        if storedRates.isEmpty || storedDates.isEmpty {
            storedRates = [currentRate]
            storedDates = [generateDate()]
        }

        // Define o valor atual e o anterior
        currentRate = storedRates.last ?? 727.40
        previousRate = storedRates.dropLast().last
    }

    // Gera a data atual para exibição no gráfico
    private func generateDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: Date())
    }
}

#Preview {
    ContentView()
}
