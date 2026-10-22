---
name: roblox-ui-design
description: Design and improve the in-game interface of this Roblox project. Use for HUD, menus, quest panels, buttons, mobile controls, ScreenGui, and Roblox universal styling; exclude browser CSS.
---

# Interface dentro do Roblox

Inspecione a HUD em Play e leia `src/ServerScriptService/AuroraPrototype/Client.client.luau` antes de editar. Use `DIRECAO_VISUAL.md` para manter a paleta azul e dourada, com hierarquia clara para vida, missão e ataque.

Projete a interface para telas de computador e celular. Use os componentes do Roblox (`ScreenGui`, `GuiObject`, `UDim2`, `UIScale`, `UIPadding`, layouts e constraints) conforme a necessidade. Considere o Universal Styling do Roblox para valores compartilhados, quando compatível com o projeto; CSS de navegador não é aplicado ao `ScreenGui`. Respeite as áreas ocupadas pelos controles padrão do Roblox e mantenha os alvos de toque confortáveis. O texto deve permanecer legível em tamanhos menores.

Defina estados visuais para ações disponíveis, indisponíveis, carregamento e progresso. Mantenha a informação ligada ao estado real do jogo; não apresente botões decorativos como habilidades prontas. Garanta contraste, foco e feedback após interações.

Atualize a fonte Luau e o lugar jogável salvo. Teste em Play nos tamanhos de tela relevantes, registre capturas e corrija sobreposição, corte de texto e perda de legibilidade antes de concluir.
