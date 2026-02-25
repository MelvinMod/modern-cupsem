# modern-cupsem

Il Consorzio per il Software di Fisica Avanzata ha creato il programma software Electricity and Magnetism Simulations (CUPSEM), rilasciato nel 1995, che utilizza simulazioni interattive per aiutare gli utenti a comprendere i concetti di elettricità e magnetismo.  Contiene una gamma di risorse e strumenti per l'educazione alla fisica.  Questa applicazione è stata decifrata e riscritta manualmente in Ruby per i moderni Linux e Windows 10 da me, MelvinSGjr (conosciuto come MelvinMod (il mio secondo account, poiché il precedente non ha accesso ai post)).  **Tutto è stato riscritto manualmente in Ruby, senza intelligenza artificiale, ma l'intelligenza artificiale è stata utilizzata solo per comprendere il codice originale dell'applicazione decompilata!!!**

### Gemme principali utilizzate
- **Numo::Narray**  - Array numerici e operazioni su matrici
- **Numo::Gnuplot**  - Tracciamento 2D/3D (via gnuplot)
- **RubyInline** o **FFI**  - Per codice critico per le prestazioni
- **Racc** - Generazione del parser di espressioni
- **Ruby/GTK3** o **Shoes**  - Framework GUI

## Stato
Questo è un lavoro in corso.  Il codice Pascal originale è stato analizzato e il porting in Ruby è in fase di sviluppo.

## Come installare
Ottieni il linguaggio di programmazione Ruby funzionante (e Chocolatey per Windows).

**Stato attuale**: Il codice viene eseguito in modalità terminale/testo (digitando solo testo). 
**Per ottenere grafica reale (come l'originale CUPS)**: Installa Gnuplot:
```bash
# Su EndeavourOS (Arch Linux)
sudo pacman -S gnuplot
```
```powershell
# Su Windows 10/11 (utilizzando Chocolatey)
choco install gnuplot
```

Dopo aver installato gnuplot, puoi:

- Tracciare funzioni 2D con curve
- Tracciare superfici 3D
- Tracciare mappe di contorno
- Tracciare i campi vettoriali
- Visualizzare le distribuzioni di carica

**Come correre:**

```bash
# Esegui prima la configurazione
ruby bin/setup.rb

# Esegui il menu principale
ruby -Ilib lib/cupsem/main.rb

# Esegui simulazione specifica
ruby -Ilib lib/cupsem/main.rb --gauss

# Mostra aiuto
ruby -Ilib lib/cupsem/main.rb --help
```

## Cosa funziona:
-  Funzioni matematiche (pwr, sin, cos, tan, sinh, ecc.) 
-  Operazioni sulle matrici

- Analizzatore di espressioni

- Integrazione numerica (Simpson, trapezoidale, gaussiana)
- Ricerca delle radici
- Interpolazione 
- Simulazioni di base (Campi, Gauss)

## Licenza
Originale: (c) 1994 di John Wiley & Sons
Port: Licenza MIT
