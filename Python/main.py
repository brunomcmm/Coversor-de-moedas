import PySimpleGUI as sg
from interface import criar_interface
from conversor_de_moedas import converter_moeda

def main():
    # Cria a interface
    window = criar_interface()

    while True:
        event, values = window.read()

        if event == sg.WINDOW_CLOSED or event == "Sair":
            break

        if event == "Converter":
            valor = values["-VALOR-"]
            moeda_origem = values["-MOEDA_ORIGEM-"]
            moeda_destino = values["-MOEDA_DESTINO-"]

            try:
                resultado = converter_moeda(valor, moeda_origem, moeda_destino)
                window["-RESULTADO-"].update(f"Resultado: {resultado} {moeda_destino}")
            except Exception as e:
                window["-RESULTADO-"].update(f"Erro: {str(e)}")

    window.close()

if __name__ == "__main__":
    main()