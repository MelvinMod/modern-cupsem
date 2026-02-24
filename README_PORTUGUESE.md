# modern-cupsem
O Consórcio para Software de Física de Nível Superior criou o programa de software Simulações de Eletricidade e Magnetismo (CUPSEM), que foi lançado em 1995 e utiliza simulações interativas para ajudar os usuários a compreenderem os conceitos de eletricidade e magnetismo.  Contém uma variedade de recursos e ferramentas para a educação em física.  Este aplicativo foi decodificado e reescrito manualmente em Ruby para Linux moderno e Windows 10 por mim, MelvinSGjr (conhecido como MelvinMod (minha segunda conta, pois a anterior não tem acesso a postagens)).  **Tudo foi reescrito manualmente em Ruby, sem inteligência artificial, mas a inteligência artificial foi usada apenas para entender o código original da aplicação decompilada!!!**

### Gems Principais Usadas
- **Numo::Narray**  - Arrays numéricos e operações com matrizes
- **Numo::Gnuplot**  - Gráficos 2D/3D (via gnuplot)
- **RubyInline** ou **FFI**  - Para código crítico de desempenho
- **Racc** - Geração de analisador de expressões
- **Ruby/GTK3** ou **Shoes**  - Framework de interface gráfica

## Status
Este é um trabalho em andamento.  O código original em Pascal foi analisado e a porta para Ruby está sendo desenvolvida.

## Compilando a Partir do Código-Fonte
Veja INSTALL.md para dependências e instruções de construção.

## Licença
Original: (c) 1994 by John Wiley & Sons
Port: Licença MIT
