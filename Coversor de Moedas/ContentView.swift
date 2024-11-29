//
//  ContentView.swift
//  Conversor de Moedas
//
//  Este módulo gerencia a interface do usuário, incluindo a atualização diária,
//  armazenamento de até 30 valores, e exibição de um gráfico de variação.
//  Criado por Bruno Maciel em 28/11/2024.
//

import SwiftUI
import Charts

struct ContentView: View {
    @State private var amount: String = "" // Valor digitado pelo usuário
    @State private var fromCurrency: String = "BRL" // Moeda de origem padrão
    @State private var toCurrency: String = "COP" // Moeda de destino padrão
    @State private var convertedAmount: String = "" // Resultado da conversão
    @State private var isLoading: Bool = false // Indica se a conversão está em andamento
    @State private var currentRate: Double = 727.40 // Valor atual inicial
    @State private var previousRate: Double? = nil // Valor anterior para comparação
    @State private var storedRates: [Double] = Array(repeating: 727.40, count: 30) // Lista de valores

    private let currencies = ["USD", "BRL", "EUR", "COP"] // Lista de moedas disponíveis
    private let conversor = ConversorDeMoedas() // Instância do módulo de conversão

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Título do aplicativo
                Text("Conversor de Moedas")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                // Campo de entrada para o valor
                TextField("Digite o valor", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                    )

                // Seletores de moeda
                currencyPickers()

                // Botão para converter
                conversionButton()

                // Exibição do resultado
                if !convertedAmount.isEmpty {
                    conversionResult()
                }

                // Linha horizontal
                Divider()
                    .padding(.vertical)

                // Exibição do valor atual
                currentRateView()

                // Gráfico da variação
                ExchangeRateChartView(rates: storedRates)
                    .frame(height: 200)
                    .padding()

                Spacer() // Espaço flexível para organizar os elementos
            }
            .padding()
            .onAppear {
                loadStoredRates()
                scheduleDailyUpdate()
            }
        }
    }

    // Picker para selecionar as moedas de origem e destino
    @ViewBuilder
    private func currencyPickers() -> some View {
        HStack {
            Picker("De", selection: $fromCurrency) {
                ForEach(currencies, id: \.self) { currency in
                    Text(currency)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Text("para")

            Picker("Para", selection: $toCurrency) {
                ForEach(currencies, id: \.self) { currency in
                    Text(currency)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }

    // Botão de conversão
    @ViewBuilder
    private func conversionButton() -> some View {
        Button(action: {
            convertCurrency()
        }) {
            Text(isLoading ? "Carregando..." : "Converter")
                .padding()
                .frame(maxWidth: .infinity)
                .background(isLoading ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(isLoading)
    }

    // Resultado da conversão
    @ViewBuilder
    private func conversionResult() -> some View {
        Text("\(convertedAmount) \(toCurrency)")
            .font(.title)
            .bold()
            .multilineTextAlignment(.center)
            .foregroundColor(Color.green)
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

    // Função para comparar taxas
    private func compareRates(current: Double, previous: Double?) -> Color {
        guard let previous = previous else { return .primary }
        return current > previous ? .green : .red
    }

    // Agendar atualização diária
    private func scheduleDailyUpdate() {
        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { _ in
            let currentHour = Calendar.current.component(.hour, from: Date())
            if currentHour == 10 {
                fetchDailyExchangeRate()
            }
        }
    }

    // Buscar e salvar a taxa diária
    private func fetchDailyExchangeRate() {
        conversor.fetchExchangeRate(from: "BRL", to: "COP") { rate in
            DispatchQueue.main.async {
                if let rate = rate {
                    previousRate = currentRate
                    currentRate = rate

                    // Adicionar à lista e armazenar
                    storedRates.append(rate)
                    if storedRates.count > 30 {
                        storedRates.removeFirst()
                    }
                    saveStoredRates()
                }
            }
        }
    }

    // Salvar as taxas armazenadas
    private func saveStoredRates() {
        UserDefaults.standard.set(storedRates, forKey: "storedRates")
    }

    // Carregar as taxas armazenadas
    private func loadStoredRates() {
        if let rates = UserDefaults.standard.array(forKey: "storedRates") as? [Double] {
            storedRates = rates
            currentRate = storedRates.last ?? 727.40
            previousRate = storedRates.dropLast().last
        }
    }

    // Função para realizar a conversão de moedas
    private func convertCurrency() {
        guard let value = Double(amount), !isLoading else {
            convertedAmount = "Por favor, insira um valor válido."
            return
        }

        isLoading = true // Indica que a conversão está em andamento
        conversor.fetchExchangeRate(from: fromCurrency, to: toCurrency) { rate in
            DispatchQueue.main.async {
                self.isLoading = false // Finaliza o carregamento
                if let rate = rate {
                    // Calcula o valor convertido
                    self.convertedAmount = String(format: "%.2f", value * rate)
                } else {
                    self.convertedAmount = "Erro na conversão"
                }
            }
        }
    }
}

// Componente do Gráfico
struct ExchangeRateChartView: View {
    let rates: [Double]

    var body: some View {
        Chart {
            ForEach(Array(rates.enumerated()), id: \.offset) { index, rate in
                LineMark(
                    x: .value("Dia", index),
                    y: .value("Taxa", rate)
                )
            }
        }
        .chartYAxis {
            AxisMarks(values: .stride(by: 10)) {
                AxisValueLabel()
            }
        }
        .chartYScale(domain: calculateYAxisDomain()) // Ajusta o limite inferior
        .chartXAxis {
            AxisMarks() // Sem rótulos no eixo X
        }
    }

    /// Calcula o domínio do eixo Y com base nos valores
    private func calculateYAxisDomain() -> ClosedRange<Double> {
        let minRate = rates.min() ?? 0.0
        let maxRate = rates.max() ?? 0.0
        return (minRate - 20)...(maxRate)
    }
}

#Preview {
    ContentView()
}
