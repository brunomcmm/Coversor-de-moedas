//
//  ContentView.swift
//  Conversor de Moedas
//
//  Este módulo gerencia a interface do usuário, permitindo que o usuário insira o valor,
//  escolha as moedas de origem e destino, e veja o resultado da conversão.
//  Criado por Bruno Maciel em 28/11/2024.
//

import SwiftUI

struct ContentView: View {
    // Estados para gerenciar os dados inseridos pelo usuário e os resultados
    @State private var amount: String = "" // Valor digitado pelo usuário
    @State private var fromCurrency: String = "BRL" // Moeda de origem padrão
    @State private var toCurrency: String = "COP" // Moeda de destino padrão
    @State private var convertedAmount: String = "" // Resultado da conversão
    @State private var isLoading: Bool = false // Indica se a conversão está em andamento

    private let currencies = ["USD", "BRL", "EUR", "COP"] // Lista de moedas disponíveis
    private let conversor = ConversorDeMoedas() // Instância do módulo de conversão

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Título do aplicativo
                Text("Conversor de Moedas")
                    .font(.largeTitle)
                    .bold()

                // Campo de entrada para o valor a ser convertido
                TextField("Digite o valor", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                // Seletores de moeda (origem e destino)
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

                // Botão para iniciar a conversão
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
                .disabled(isLoading) // Desativa o botão durante o carregamento

                // Resultado da conversão
                if !convertedAmount.isEmpty {
                    Text("\(convertedAmount) \(toCurrency)")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                }

                Spacer() // Empurra o conteúdo para o topo
            }
            .padding()
        }
    }

    /// Função para realizar a conversão de moedas
    private func convertCurrency() {
        guard let value = Double(amount), !isLoading else {
            convertedAmount = "Valor inválido"
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

#Preview {
    ContentView()
}
