import pandas as pd

# Leggi il file CSV
csv_path = input("Inserisci il nome del file csv da processare (inclusa estensione .csv): ")
df = pd.read_csv(csv_path)  # Rimosso l'apostrofo extra

# Formatta le colonne numeriche con due cifre decimali
for col in df.select_dtypes(include=['float', 'int']).columns:
    df[col] = df[col].map(lambda x: f'{x:.2f}')

# Salva il file CSV modificato
df.to_csv(csv_path.replace('.csv', '_modificato.csv'), index=False)  # Aggiustato il nome del file di output

print(f"Il file modificato è stato salvato come {csv_path.replace('.csv', '_modificato.csv')}")
