# modern-cupsem

O Consórcio para Software de Física de Nível Superior criou o programa de software Simulações de Eletricidade e Magnetismo (CUPSEM), que foi lançado em 1995 e utiliza simulações interativas para ajudar os usuários a compreender os conceitos de eletricidade e magnetismo.  Contém uma variedade de recursos e ferramentas para a educação em física.  Este aplicativo foi decodificado e reescrito manualmente em Ruby para Linux moderno e Windows 10 por mim, MelvinSGjr (conhecido como MelvinMod (minha segunda conta, pois a anterior não tem acesso a postagens)).  **Tudo foi reescrito manualmente em Ruby, sem inteligência artificial, mas a inteligência artificial foi usada apenas para entender o código original da aplicação decompilada!!!**

### Gems Principais Usadas
- **Numo::Narray**  - Arrays numéricos e operações com matrizes
- **Numo::Gnuplot**  - Gráficos 2D/3D (via gnuplot)
- **RubyInline** ou **FFI**  - Para código crítico de desempenho
- **Racc** - Geração de analisador de expressões
- **Ruby/GTK3** ou **Shoes**  - Framework de interface gráfica

## Status
Isto é um trabalho em andamento.  O código original em Pascal foi analisado e a porta para Ruby está sendo desenvolvida.

## Como instalar
Instale a linguagem de programação Ruby (e o Chocolatey para Windows).

**Estado atual**: O código roda em modo terminal/texto (digitando apenas texto). 
**Para obter gráficos reais (como o CUPS original)**: Instale o Gnuplot:
```bash
# No EndeavourOS (Arch Linux)
sudo pacman -S gnuplot
```
```powershell
# No Windows 10/11 (usando Chocolatey)
choco install gnuplot
```
# No Windows 10/11 (usando Chocolatey)
choco install gnuplot

Após instalar o gnuplot, você pode:

- Plotar funções 2D com curvas
- Traçar superfícies 3D
- Plotar mapas de contorno
- Traçar campos vetoriais
- Exibir distribuições de carga visualmente

**Como correr:**

```bash
# Execute o setup primeiro
ruby bin/setup.rb


# Execute o menu principal
ruby -Ilib lib/cupsem/main.rb

# Executar simulação específica
ruby -Ilib lib/cupsem/main.rb --gauss

# Mostrar ajuda
ruby -Ilib lib/cupsem/main.rb --help
```

## O que está funcionando:
-  Funções matemáticas (pwr, sin, cos, tan, sinh, etc.) 
-  Operações de matriz

- Analisador de expressões

- Integração numérica (Simpson, trapezoidal, Gaussiana)
- Encontrar raízes
- Interpolação 
- Simulações básicas (Campos, Gauss)

## Licença
Original: (c) 1994 by John Wiley & Sons
Port: Licença MIT
