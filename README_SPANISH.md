# modern-cupsem

El Consorcio para el Software de Física de Nivel Superior creó el programa de software Simulaciones de Electricidad y Magnetismo (CUPSEM), que se lanzó en 1995 y utiliza simulaciones interactivas para ayudar a los usuarios a comprender los conceptos de electricidad y magnetismo.  Contiene una variedad de recursos y herramientas para la educación en física.  Esta aplicación fue decodificada y reescrita manualmente en Ruby para Linux moderno y Windows 10 por mí, MelvinSGjr (conocido como MelvinMod (mi segunda cuenta, ya que la anterior no tiene acceso a las publicaciones)).  Todo se reescribió manualmente en Ruby, sin inteligencia artificial, ¡pero la inteligencia artificial solo se usó para comprender el código original de la aplicación descompilada!

### Gemas centrales utilizadas
- **Numo::Narray**  - Arreglos numéricos y operaciones matriciales
- **Numo::Gnuplot**  - Gráficos 2D/3D (vía gnuplot)
- **RubyInline** o **FFI**  - Para código crítico para el rendimiento
- **Racc** - Generación de analizadores de expresiones
- **Ruby/GTK3** o **Shoes**  - Marco de interfaz gráfica

## Estado
Esto es un trabajo en progreso.  El código Pascal original ha sido analizado y se está desarrollando la versión en Ruby.

## Cómo instalar
Obtén el lenguaje de programación Ruby funcionando (y Chocolatey para Windows).

**Estado actual**: El código se ejecuta en modo terminal/texto (solo escribiendo texto). 
**Para obtener gráficos reales (como los originales de CUPS)**: Instale Gnuplot:
```bash
# En EndeavourOS (Arch Linux)
sudo pacman -S gnuplot
```
```powershell
# En Windows 10/11 (usando Chocolatey)
choco install gnuplot
```

Después de instalar gnuplot, puedes:

- Trazar funciones 2D con curvas
- Trazar superficies 3D
- Trazar mapas de contorno
- Trazar campos vectoriales
- Mostrar las distribuciones de carga visualmente

**Cómo ejecutar:**

```bash
# Ejecutar la configuración primero
ruby bin/setup.rb

# Ejecutar el menú principal
ruby -Ilib lib/cupsem/main.rb

# Ejecutar simulación específica
ruby -Ilib lib/cupsem/main.rb --gauss

# Mostrar ayuda
ruby -Ilib lib/cupsem/main.rb --help
```

## Lo que funciona:
- Funciones matemáticas (pwr, sin, cos, tan, sinh, etc.) 
- Operaciones matriciales

- Analizador de expresiones

- Integración numérica (Simpson, trapezoidal, gaussiana)
- Búsqueda de raíces
- Interpolación 
- Simulaciones básicas (Campos, Gauss)

## Licencia
Original: (c) 1994 por John Wiley & Sons
Puerto: Licencia MIT
