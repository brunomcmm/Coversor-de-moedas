//
//  ContentView.swift
//  Conversor de Moedas
//
//  Este módulo gerencia a interface do usuário, incluindo a atualização diária,
//  armazenamento de até 30 valores e exibição de um gráfico de variação.
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
    @State private var storedDates: [String] = [] // Datas simuladas

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
                    .background(Color(isLoading ? .systemGray4 : .systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isLoading ? Color.red : Color.blue, lineWidth: 1)
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
                let validCount = min(storedRates.count, storedDates.count)
                let validRates = Array(storedRates.prefix(validCount))
                let validDates = Array(storedDates.prefix(validCount))
                
                ExchangeRateChartView(
                    rates: validRates,
                    dates: validDates
                )
                .frame(height: 200)
                .padding()

                Spacer()
            }
            .padding()
            .onAppear {
                NotificationManager.shared.requestPermission()
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
        NotificationManager.shared.scheduleDailyUpdate {
            fetchDailyExchangeRate()
        }
    }

    // Buscar e salvar a taxa diária
    private func fetchDailyExchangeRate() {
        conversor.fetchExchangeRate(from: "BRL", to: "COP") { rate in
            DispatchQueue.main.async {
                if let rate = rate {
                    previousRate = currentRate
                    currentRate = rate

                    // Atualiza taxas e datas
                    storedRates.append(rate)
                    storedDates.append(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))

                    if storedRates.count > 30 {
                        storedRates.removeFirst()
                        storedDates.removeFirst()
                    }

                    saveStoredRates()
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
            currentRate = storedRates.last ?? 727.40
            previousRate = storedRates.dropLast().last
        } else {
            // Gera valores iniciais se os dados não existirem
            storedRates = Array(repeating: 727.40, count: 30)
            storedDates = generateDates(for: storedRates.count)
        }
    }

    // Função para realizar a conversão de moedas
    private func convertCurrency() {
        guard let value = Double(amount), !isLoading else {
            convertedAmount = "Por favor, insira um valor válido."
            return
        }

        isLoading = true
        conversor.fetchExchangeRate(from: fromCurrency, to: toCurrency) { rate in
            DispatchQueue.main.async {
                self.isLoading = false
                if let rate = rate {
                    self.convertedAmount = String(format: "%.2f", value * rate)
                } else {
                    self.convertedAmount = "Erro na conversão"
                }
            }
        }
    }

    // Gera as últimas `count` datas para o gráfico
    private func generateDates(for count: Int) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"

        var dates = [String]()
        for i in stride(from: count - 1, through: 0, by: -1) {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                dates.append(formatter.string(from: date))
            }
        }
        return dates
    }
}

#Preview {
    ContentView()
}
