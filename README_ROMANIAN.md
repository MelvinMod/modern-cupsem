# modern-cupsem

Consorțiul pentru Software de Fizică Avansată a creat programul software Simulări de Electricitate și Magnetism (CUPSEM), care a fost lansat în 1995 și folosește simulări interactive pentru a ajuta utilizatorii să înțeleagă conceptele de electricitate și magnetism.  Conține o gamă variată de resurse și instrumente pentru educația în fizică.  Această aplicație a fost decodată și rescrisă manual în Ruby pentru Linux modern și Windows 10 de mine, MelvinSGjr (cunoscut ca MelvinMod (al doilea meu cont, deoarece primul nu are acces la postări)).  **Totul a fost rescris manual în Ruby, fără inteligență artificială, dar inteligența artificială a fost folosită doar pentru a înțelege codul original din aplicația decompilată!!!**

### Bijuterii de bază utilizate
- **Numo::Narray**  - Arregi numerice și operații cu matrice
- **Numo::Gnuplot**  - Graficare 2D/3D (prin gnuplot)
- **RubyInline** sau **FFI**  - Pentru codul critic pentru performanță
- **Racc** - Generarea parserului de expresii
- **Ruby/GTK3** sau **Shoes**  - Cadru GUI

## Status
Acesta este un proiect în curs de desfășurare.  Codul original Pascal a fost analizat și portul Ruby este în curs de dezvoltare.

## Cum să instalați
Obțineți limbajul de programare Ruby funcțional (și Chocolatey pentru Windows).

**Starea actuală**: Codul rulează în modul terminal/text (introducând doar text). 
**Pentru a obține grafica reală (ca în CUPS original)**: Instalați Gnuplot:
```bash
# Pe EndeavourOS (Arch Linux)
sudo pacman -S gnuplot
```
```powershell
# Pe Windows 10/11 (folosind Chocolatey)
choco install gnuplot
```

După instalarea gnuplot, poți:

- Plotează funcții 2D cu curbe
- Plotează suprafețe 3D
- Trasează hărți de contur
- Trasați câmpuri vectoriale
- Afișați distribuțiile de sarcină vizual

**Cum să alergi:**

```bash
# Rulați mai întâi setup
ruby bin/setup.rb

# Rulează meniul principal
ruby -Ilib lib/cupsem/main.rb

# Rulați simularea specifică
ruby -Ilib lib/cupsem/main.rb --gauss

# Afișează ajutorul
ruby -Ilib lib/cupsem/main.rb --help
```

### Ce este necesar pentru grafica completă:
Instalați gnuplot așa cum este arătat mai sus, apoi funcțiile de graficare din 
`graphics_gnuplot.rb`
vor funcționa pentru ieșirea vizuală!

## Ce funcționează:
- Funcții matematice (pwr, sin, cos, tan, sinh, etc.) 
-  Operații cu matrice

- Parser de expresii

- Integrare numerică (Simpson, trapezoidală, gaussiană)
- Găsirea rădăcinilor
- Interpolare 
- Simulări de bază (Fields, Gauss)

## Licență
Original: (c) 1994 de John Wiley & Sons
Port: Licența MIT
