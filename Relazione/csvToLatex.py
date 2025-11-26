import pandas as pd
import os
import glob
import math

def trova_file_csv_piu_recente():
    """Trova il file CSV più recente nella cartella corrente."""
    list_of_files = glob.glob('*.csv') 
    if not list_of_files:
        return None
    latest_file = max(list_of_files, key=os.path.getctime)
    return latest_file

def format_value(val, col_name):
    """Formatta il valore in base al nome della colonna secondo le specifiche."""
    # Controllo stringa vuota o NaN
    if pd.isna(val) or str(val).strip() == "":
        return "..."
    
    # Colonne intere
    int_cols = ['n', 'W_S', 'sweep25', 'V_fuel', 'AR'] 
    if col_name in int_cols: 
        return "{:.0f}".format(val)
    
    if col_name == 'M':
        return "{:.2f}".format(val)

    if 'CD' in col_name or 'Cd' in col_name:
        if val < 0.0001 and val > 0:
             return "\\num{{ {:.2e} }}".format(val)
        return "{:.4f}".format(val)
    
    if 'CL' in col_name:
        return "{:.3f}".format(val)
    
    if col_name == 'DOC':
        return "{:.4f}".format(val)
    
    if col_name == 'PREE':
        return "{:.3f}".format(val)
        
    if isinstance(val, float):
        return "{:.2f}".format(val)
    
    return str(val)

def is_target_configuration(row):
    """Verifica se la riga corrisponde alla configurazione target."""
    target_WS = 600
    target_AR = 9
    target_tc = 0.1
    target_M = 0.76
    target_sweep = 20
    target_lambda = 0.23 
    
    tol = 0.001
    
    if 'W_S' in row and not pd.isna(row['W_S']):
        if abs(row['W_S'] - target_WS) > 1: return False
    else: return False

    if 'AR' in row and not pd.isna(row['AR']):
        if abs(row['AR'] - target_AR) > tol: return False
    else: return False

    if 't_c' in row and not pd.isna(row['t_c']):
        if abs(row['t_c'] - target_tc) > tol: return False
    else: return False

    if 'M' in row and not pd.isna(row['M']):
        if abs(row['M'] - target_M) > tol: return False
    else: return False

    if 'sweep25' in row and not pd.isna(row['sweep25']):
        if abs(row['sweep25'] - target_sweep) > 1: return False
    else: return False

    if 'lambda' in row and not pd.isna(row['lambda']): 
         if abs(row['lambda'] - target_lambda) > tol: return False
    else: return False

    return True

def main():
    csv_file = trova_file_csv_piu_recente()
    if not csv_file:
        print("Nessun file CSV trovato nella cartella corrente.")
        return

    print(f"Elaborazione del file: {csv_file}")
    df = pd.read_csv(csv_file)
    df.columns = df.columns.str.strip()

    # Configurazione Colori
    color_target = "cyan!30"       # Riga configurazione scelta
    color_design = "yellow!30"     # Colonne variabili di design
    color_mix    = "green!30"      # Incrocio (Ciano + Giallo)

    # Variabili di Design da colorare (nomi colonne CSV)
    design_vars_csv = ['W_S', 'lambda', 'AR', 't_c', 'sweep25', 'M']

    # Struttura Colonne
    table_structure = [
        (r'\textbf{n}', 'n'),            
        (r'\textbf{W/S}', 'W_S'),       
        (r'\textbf{S}', 'S'),           
        (r'\textbf{S}$\mathbf{_{wet}}$', 'S_wet'), 
        (r'\textbf{S}$\mathbf{_{vert}}$', 'S_vert'), 
        (r'\textbf{S}$\mathbf{_{orizz}}$', 'S_orizz'), 
        (r'\textbf{b}', 'b'),           
        (r'$\mathbf{\lambda}$', 'lambda'),  
        (r'\textbf{c}$\mathbf{_{root}}$', 'c_root'), 
        (r'\textbf{c}$\mathbf{_{tip}}$', 'c_tip'), 
        (r'\textbf{MAC}', 'MAC'),       
        (r'\textbf{AR}', 'AR'),         
        (r'\textbf{t/c}', 't_c'),       
        (r'$\mathbf{\Lambda_{25}}$', 'sweep25'), 
        (r'\textbf{V}$\mathbf{_{fuel}}$ [l]', 'V_fuel'), 
        
        (r'\textbf{M}', 'M'),           
        (r'\textbf{W}$\mathbf{_{fuel}}$', 'W_fuel'), 
        (r'\textbf{W}$\mathbf{_{block\,fuel}}$', 'W_block_fuel'), 
        (r'\textbf{E}$\mathbf{_{cruise}}$', 'E_crociera'), 
        (r'\textbf{C}$\mathbf{_{D}}$', 'CD'), 
        (r'\textbf{C}$\mathbf{_{D_0}}$', 'Cd0'), 
        (r'\textbf{C}$\mathbf{_{D_i}}$', 'Cdi'), 
        (r'\textbf{C}$\mathbf{_{D_W}}$', 'Cdw'), 
        (r'\textbf{C}$\mathbf{_{L_{cruise}}}$', 'CL_crociera'), 
        (r'\textbf{C}$\mathbf{_{L_{max}}}$', 'CL_max'), 
        (r'\textbf{T} [kg]', 'T'),      
        (r'\textbf{T/W}', 'T_W'),       
        
        (r'\textbf{MTOW}', 'WTO'),      
        (r'\textbf{OEW}', 'OEW'),       
        (r'\textbf{Wing}', 'W_wing'),   
        (r'\textbf{Tail}', 'W_tail'),   
        (r'\textbf{Land.Gear}', 'W_LG'), 
        (r'\textbf{Prop.}', 'W_propuls'), 
        (r'\textbf{Fuel Sys.}', 'W_fuelsys'), 
        (r'\textbf{Hydraulic}', 'W_hydr'), 
        
        (r'\textbf{ADP}', 'ADP'),       
        (r'\textbf{Flight Cost}', 'flight_cost'), 
        (r'\textbf{Maint. Cost}', 'maintenance_cost'), 
        (r'\textbf{DOC}', 'DOC'),       
        (r'\textbf{PREE}', 'PREE')      
    ]

    # Generazione LaTeX
    latex_code = []
    
    # Setup
    latex_code.append(r"\begin{landscape}")
    latex_code.append(r"    \vspace*{\fill}")
    latex_code.append(r"    \begin{table}[H]")
    latex_code.append(r"        \centering")
    latex_code.append(r"        \renewcommand{\arraystretch}{1.5}")
    latex_code.append(r"        \setlength{\tabcolsep}{3pt}")
    latex_code.append(r"        \adjustbox{max width=0.855 \paperheight, max height=\paperheight}{%")
    
    n_cols = len(table_structure)
    latex_code.append(r"        \begin{tabular}{|" + "c|"*n_cols + "}")
    latex_code.append(r"            \hline")
    
    # Header 1
    geom_len = 14
    perf_len = 12
    pesi_len = 8
    costi_len = 5
    
    header1 = (
        r"            \multicolumn{1}{|c|}{} & " + 
        r"\multicolumn{" + str(geom_len) + r"}{c|}{\textbf{Geometria}} & " +
        r"\multicolumn{" + str(perf_len) + r"}{c|}{\textbf{Performance}} & " +
        r"\multicolumn{" + str(pesi_len) + r"}{c|}{\textbf{Pesi}} & " +
        r"\multicolumn{" + str(costi_len) + r"}{c|}{\textbf{Costi}} \\"
    )
    latex_code.append(header1)
    latex_code.append(r"            \hline")
    
    # Header 2 (CON COLORAZIONE CELLE INTESTAZIONE)
    header2_cells = []
    for latex_head, csv_col in table_structure:
        if csv_col in design_vars_csv:
            # Colora l'intestazione se è una variabile di design
            cell = r"\cellcolor{" + color_design + r"}" + latex_head
        else:
            cell = latex_head
        header2_cells.append(cell)
        
    header2 = "            " + " & ".join(header2_cells) + r" \\"
    latex_code.append(header2)
    latex_code.append(r"            \hline")
    
    # Dati
    for index, row in df.iterrows():
        row_cells = []
        is_target = is_target_configuration(row)
        
        for latex_header, csv_col in table_structure:
            # Valore formattato
            if csv_col in df.columns:
                val = row[csv_col]
                formatted_val = format_value(val, csv_col)
            else:
                formatted_val = "..."
            
            # Gestione Colore Cella Dati
            cell_content = formatted_val
            is_design_col = csv_col in design_vars_csv
            
            if is_target and is_design_col:
                # Incrocio: Verde
                cell_content = r"\cellcolor{" + color_mix + r"}" + formatted_val
            elif is_target:
                # Solo Riga Target: Ciano
                cell_content = r"\cellcolor{" + color_target + r"}" + formatted_val
            elif is_design_col:
                # Solo Colonna Design: Giallo
                cell_content = r"\cellcolor{" + color_design + r"}" + formatted_val
            
            row_cells.append(cell_content)
        
        latex_code.append("            " + " & ".join(row_cells) + r" \\")
        latex_code.append(r"            \hline")

    # Chiusura
    latex_code.append(r"        \end{tabular}")
    latex_code.append(r"        }")
    latex_code.append(r"        \caption{Matrice delle Configurazioni}")
    latex_code.append(r"        \label{tab:configurazioni}")
    latex_code.append(r"    \end{table}")
    latex_code.append(r"    \vspace*{\fill}")
    latex_code.append(r"\end{landscape}")

    # Scrittura
    output_filename = 'tabella_latex_generata.tex'
    with open(output_filename, "w") as f:
        f.write("\n".join(latex_code))
    
    print(f"Fatto! Codice LaTeX salvato in: {output_filename}")
    print("NOTA: Assicurati di avere \\usepackage[table]{xcolor} nel tuo preambolo LaTeX.")

if __name__ == "__main__":
    main()