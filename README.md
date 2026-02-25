[Portuguese](https://github.com/MelvinMod/modern-cupsem/blob/main/README_PORTUGUESE.md)
[Spanish](https://github.com/MelvinMod/modern-cupsem/blob/main/README_SPANISH.md)
[Romanian](https://github.com/MelvinMod/modern-cupsem/blob/main/README_ROMANIAN.md)
[Italian](https://github.com/MelvinMod/modern-cupsem/blob/main/README_ITALIAN.md)
[Russian](https://github.com/MelvinMod/modern-cupsem/blob/main/README_RUSSIAN.md)

# modern-cupsem

The Consortium for Upper Level Physics Software created the software program Electricity and Magnetism Simulations (CUPSEM), which was released in 1995 and uses interactive simulations to help users comprehend electricity and magnetism concepts. It contains a range of resources and tools for physics education. This application was decoded and manually rewritten in Ruby for modern Linux and Windows 10 by me, MelvinSGjr (known as MelvinMod (my second account, as the previous one does not have access to posts)). **Everything was rewritten manually in Ruby, without artificial intelligence, but artificial intelligence was used only to understand the original code from the decompiled application!!!**

### Core Gems Used
- **Numo::Narray** - Numerical arrays and matrix operations
- **Numo::Gnuplot** - 2D/3D plotting (via gnuplot)
- **RubyInline** or **FFI** - For performance-critical code
- **Racc** - Expression parser generation
- **Ruby/GTK3** or **Shoes** - GUI framework

## Status
This is a work in progress. The original Pascal code has been analyzed
and the Ruby port is being developed.

## How to install
Get working Ruby programming language (and Chocolatey for Windows).

**Current state**: The code runs in terminal/text mode (typing text only).
**To get real graphics (like original CUPS)**: Install Gnuplot:
```bash
# On EndeavourOS (Arch Linux)
sudo pacman -S gnuplot
```
```powershell
# On Windows 10/11 (using Chocolatey)
choco install gnuplot
```

After installing gnuplot, you can:

- Plot 2D functions with curves
- Plot 3D surfaces
- Plot contour maps
- Plot vector fields
- Display charge distributions visually

**How to run:**

```bash
# Run setup first
ruby bin/setup.rb

# Run the main menu
ruby -Ilib lib/cupsem/main.rb

# Run specific simulation
ruby -Ilib lib/cupsem/main.rb --gauss

# Show help
ruby -Ilib lib/cupsem/main.rb --help
```

### What's needed for full graphics:
Install gnuplot as shown above, then the plotting functions in 
`graphics_gnuplot.rb`
 will work for visual output!

## What's working:
-  Math functions (pwr, sin, cos, tan, sinh, etc.)
-  Matrix operations
- Expression parser
- Numerical integration (Simpson, trapezoidal, Gaussian)
- Root finding
- Interpolation
- Basic simulations (Fields, Gauss)

## License
Original: (c) 1994 by John Wiley & Sons
Port: MIT License
