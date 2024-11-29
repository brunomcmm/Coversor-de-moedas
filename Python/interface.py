import PySimpleGUI as sg

def criar_interface():
    layout = [
        [sg.Text("Conversor de Moedas", font=("Helvetica", 16), justification="center", expand_x=True)],
        [sg.Text("Valor:"), sg.Input(key="-VALOR-")],
        [sg.Text("Moeda de Origem:"), sg.Combo(["USD", "BRL", "EUR", "COP"], key="-MOEDA_ORIGEM-", default_value="BRL")],
        [sg.Text("Moeda de Destino:"), sg.Combo(["USD", "BRL", "EUR", "COP"], key="-MOEDA_DESTINO-", default_value="COP")],
        [sg.Button("Converter"), sg.Button("Sair")],
        [
            sg.Text(
                "", 
                key="-RESULTADO-", 
                size=(30, 2), 
                justification="center",  # Centraliza o texto
                font=("Helvetica", 14),  # Define um tamanho de fonte maior
                expand_x=True,           # Faz o texto ocupar o centro do layout
                text_color="blue"        # Opcional: adiciona uma cor para destacar
            )
        ]
    ]

    return sg.Window("Conversor de Moedas", layout)