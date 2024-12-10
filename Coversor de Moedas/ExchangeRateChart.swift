//
//  ExchangeRateChart.swift
//  Conversor de Moedas
//
//  Este módulo gerencia o componente do gráfico para exibir a variação das taxas de câmbio.
//  Criado por Bruno Maciel.
//

import SwiftUI
import Charts

struct ExchangeRateChartView: View {
    let rates: [Double]
    let indices: [Int] // Índices numéricos correspondentes às taxas

    var body: some View {
        Chart {
            // Gráfico de linha
            ForEach(Array(rates.enumerated()), id: \.offset) { index, rate in
                LineMark(
                    x: .value("Índice", indices[safe: index] ?? 0),
                    y: .value("Taxa", rate)
                )
                .interpolationMethod(.linear) // Linha reta entre os pontos
                .foregroundStyle(.blue) // Cor da linha
                .lineStyle(StrokeStyle(lineWidth: 2)) // Espessura da linha
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    Text("\(value.as(Double.self) ?? 0.0, specifier: "%.2f")")
                        .font(.footnote) // Ajusta o tamanho da fonte do eixo Y
                        .foregroundColor(.secondary) // Cor secundária
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let index = value.as(Int.self) {
                        Text("\(index)")
                            .font(.footnote) // Ajusta o tamanho da fonte do eixo X
                            .foregroundColor(.secondary) // Cor secundária
                    }
                }
            }
        }
        .chartYScale(domain: calculateYAxisDomain()) // Ajusta o domínio do eixo Y
        .frame(height: 250) // Altura do gráfico
        .padding() // Adiciona espaçamento ao redor do gráfico
    }

    /// Calcula o domínio do eixo Y com base nos valores
    private func calculateYAxisDomain() -> ClosedRange<Double> {
        let minRate = rates.min() ?? 0.0
        let maxRate = rates.max() ?? 1.0
        let padding = (maxRate - minRate) * 0.1
        return (minRate - padding)...(maxRate + padding)
    }
}

// Extensão para acessar arrays de forma segura
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
