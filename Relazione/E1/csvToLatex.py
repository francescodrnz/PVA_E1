import pandas as pd
import numpy as np

# Leggi il CSV
df = pd.read_csv('matrice_configurazioni_modificato.csv')

# Funzione per formattare i numeri
def format_number(x):
    if pd.isna(x):
        return ""
    if isinstance(x, (int, float)):
        if abs(x) < 0.01:
            return f"{x:.2e}"
        elif abs(x) < 0.1:
            return f"{x:.4f}"
        elif abs(x) < 1:
            return f"{x:.3f}"
        elif abs(x) < 10:
            return f"{x:.2f}"
        elif abs(x) < 100:
            return f"{x:.1f}"
        else:
            return f"{x:.2f}"
    return str(x)

# Funzione per verificare se una riga è vuota
def is_empty_row(row):
    return row.isna().all()

# Crea il codice LaTeX con corretta indentazione e formattazione
latex_output = []
latex_output.append("\\begin{landscape}")
latex_output.append("\\begin{table}[htbp]")
latex_output.append("    \\centering")
latex_output.append("    \\caption{Configurazioni e parametri}")
latex_output.append("    \\resizebox{\\linewidth}{!}{%")

# Crea il formato della tabella con una colonna per ogni campo
column_format = "|" + "|".join(["c"] * len(df.columns)) + "|"
latex_output.append("    \\begin{tabular}{" + column_format + "}")
latex_output.append("    \\hline")

# Aggiungi le intestazioni
headers = " & ".join([f"\\textbf{{{col}}}" for col in df.columns])
latex_output.append("    " + headers + " \\\\")
latex_output.append("    \\hline")

# Aggiungi i dati riga per riga
for _, row in df.iterrows():
    if is_empty_row(row):
        # Se la riga è vuota, inserisci \cdots al centro
        dots_line = "    \\multicolumn{" + str(len(df.columns)) + "}{|c|}{\\cdots} \\\\"
        latex_output.append(dots_line)
    else:
        # Altrimenti, procedi normalmente con i dati
        formatted_values = [format_number(row[col]) for col in df.columns]
        latex_output.append("    " + " & ".join(formatted_values) + " \\\\")

latex_output.append("    \\hline")
latex_output.append("    \\end{tabular}%")
latex_output.append("    }")
latex_output.append("    \\label{tab:configurazioni}")
latex_output.append("\\end{table}")
latex_output.append("\\end{landscape}")

# Scrivi il file con una riga vuota alla fine
with open('tabella_configurazioni.tex', 'w') as f:
    f.write('\n'.join(latex_output) + '\n')

print("File LaTeX generato con successo!")