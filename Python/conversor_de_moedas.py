import requests

API_KEY = "efebc6d955f06f85ecba2d8a1490b358"
BASE_URL = "https://api.exchangeratesapi.io/v1/latest"

def converter_moeda(valor, moeda_origem, moeda_destino):
    try:
        # Construir a URL para buscar taxas em relação ao EUR
        url = f"{BASE_URL}?access_key={API_KEY}&symbols={moeda_origem},{moeda_destino}"
        print(f"URL gerada: {url}")  # Verificar URL gerada

        # Fazer a requisição HTTP
        response = requests.get(url)
        print(f"Status da resposta: {response.status_code}")  # Verificar status

        # Validar status da resposta
        if response.status_code != 200:
            raise Exception(f"Erro na API: {response.status_code}")

        # Decodificar o JSON retornado
        dados = response.json()
        print(f"Resposta JSON: {dados}")  # Log da resposta JSON

        # Verificar sucesso na resposta
        if not dados.get("success", False):
            raise Exception(f"Erro na resposta da API: {dados.get('error', {}).get('info', 'Desconhecido')}")

        # Obter as taxas para moeda_origem e moeda_destino
        taxa_origem = dados["rates"].get(moeda_origem)
        taxa_destino = dados["rates"].get(moeda_destino)

        if not taxa_origem or not taxa_destino:
            raise Exception(f"Taxas para {moeda_origem} ou {moeda_destino} não encontradas.")

        # Converter o valor
        valor_em_eur = float(valor) / taxa_origem  # Converter para EUR
        valor_convertido = valor_em_eur * taxa_destino  # Converter de EUR para moeda_destino

        return round(valor_convertido, 2)

    except Exception as e:
        print(f"Erro ao converter moeda: {str(e)}")
        raise