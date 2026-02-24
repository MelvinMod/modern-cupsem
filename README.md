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

## Building from Source
See INSTALL.md for dependencies and build instructions.

## License
Original: (c) 1994 by John Wiley & Sons
Port: MIT License
