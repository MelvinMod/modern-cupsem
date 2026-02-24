# modern-cupsem
Il Consorzio per il Software di Fisica Avanzata ha creato il programma software Simulazioni di Elettricità e Magnetismo (CUPSEM), rilasciato nel 1995, che utilizza simulazioni interattive per aiutare gli utenti a comprendere i concetti di elettricità e magnetismo.  Contiene una gamma di risorse e strumenti per l'educazione alla fisica.  Questa applicazione è stata decifrata e riscritta manualmente in Ruby per i moderni Linux e Windows 10 da me, MelvinSGjr (conosciuto come MelvinMod (il mio secondo account, poiché il precedente non ha accesso ai post)).  **Tutto è stato riscritto manualmente in Ruby, senza intelligenza artificiale, ma l'intelligenza artificiale è stata utilizzata solo per comprendere il codice originale dall'applicazione decompilata!!!**

### Gemme Principali Utilizzate
- **Numo::Narray**  - Array numerici e operazioni su matrici
- **Numo::Gnuplot**  - Tracciamento 2D/3D (via gnuplot)
- **RubyInline** o **FFI**  - Per codice critico per le prestazioni
- **Racc** - Generazione del parser di espressioni
- **Ruby/GTK3** o **Shoes**  - Framework GUI

## Stato
Questo è un lavoro in corso.  Il codice Pascal originale è stato analizzato e il porting in Ruby è in fase di sviluppo.

## Compilazione dal sorgente
Vedi INSTALL.md per le dipendenze e le istruzioni di compilazione.

## Licenza
Originale: (c) 1994 di John Wiley & Sons
Port: Licenza MIT
