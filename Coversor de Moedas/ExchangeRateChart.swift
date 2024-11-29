//
//  ExchangeRateChart.swift
//  Conversor de Moedas
//
//  Este módulo gerencia o componente do gráfico para exibir a variação das taxas de câmbio.
//  Criado por Bruno Maciel em 29/11/2024.
//

import SwiftUI
import Charts

struct ExchangeRateChartView: View {
    let rates: [Double]
    let dates: [String] // Datas correspondentes às taxas

    var body: some View {
        Chart {
            // Gráfico de linha simples
            ForEach(Array(rates.enumerated()), id: \.offset) { index, rate in
                LineMark(
                    x: .value("Data", dates[index]),
                    y: .value("Taxa", rate)
                )
                .interpolationMethod(.cardinal) // Suaviza a linha
                .foregroundStyle(Color.red) // Cor da linha
                .lineStyle(StrokeStyle(lineWidth: 2)) // Linha mais fina
            }
        }
        .chartYAxis {
            AxisMarks(values: .stride(by: 10)) { value in
                AxisValueLabel {
                    Text("\(value.as(Double.self) ?? 0.0, specifier: "%.0f")")
                        .font(.title3) // Fonte grande para o eixo Y
                        .foregroundColor(.primary) // Cor padrão para o texto
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: Array(stride(from: 0, to: dates.count, by: 10))) { value in
                AxisValueLabel {
                    if let index = value.as(Int.self), index < dates.count {
                        Text(dates[index])
                            .font(.title3) // Fonte grande para o eixo X
                            .foregroundColor(.primary) // Cor padrão para o texto
                    }
                }
            }
        }
        .chartYScale(domain: calculateYAxisDomain()) // Ajusta o limite do eixo Y
    }

    /// Calcula o domínio do eixo Y com base nos valores
    private func calculateYAxisDomain() -> ClosedRange<Double> {
        let minRate = rates.min() ?? 720.0
        let maxRate = rates.max() ?? 780.0
        return (minRate - 5)...(maxRate + 5)
    }
}
