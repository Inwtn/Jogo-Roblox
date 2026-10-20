# Ilha da Aurora — primeira fatia jogável

Este repositório começa a implementar o MVP do RPG. O arquivo `MeuJogoRoblox.rbxl.rbxl` já contém o protótipo testado no Roblox Studio. O pacote `Studio/ServerScriptService/AuroraPrototype.rbxmx` permite instalar a mesma versão em outro lugar.

O plano cita `IlhaInicial.rbxlx`, mas esse arquivo não está nesta pasta. Ainda precisamos conferir no Studio se o lugar binário disponível contém a ilha descrita.

## Conteúdo desta etapa

- Prado de teste gerado ao iniciar o servidor: vila medieval, estrada, cercas, árvores, penhascos e caverna, afastado da baseplate original.
- Paladino com ataque básico validado no servidor; boneco de treino e três slimes com perseguição, ataque, retorno e reaparecimento.
- Q01 (falar com instrutor e acertar o boneco) e Q02 (derrotar três slimes e voltar ao instrutor), recompensas únicas, nível, moedas e martelo raro.
- Perfil salvo em `AuroraProfiles_Dev_v1` com bloqueio de sessão, salvamento periódico e modo somente leitura se o carregamento falhar.
- HUD de RPG no PC com localização, minimapa, missão, barras de vida e EXP, moedas e barra de ações. O paladino recebe capa, escudo e martelo visuais; o martelo fica dourado ao conquistar a versão rara.

A direção visual foi registrada em `DIRECAO_VISUAL.md`. Esta versão usa peças e materiais nativos do Roblox para definir composição e jogabilidade. Modelos, texturas e animações finais ainda serão produzidos.

## Como testar no Studio

1. Abra `MeuJogoRoblox.rbxl.rbxl` no Roblox Studio e aperte **Play**. O pacote já está instalado nesse arquivo. Se aparecer uma janela **Servidor** sem personagem, escolha **Teste > Adicionar clientes** e continue na janela do cliente.
2. O instrutor azul e o boneco de madeira aparecem à frente do jogador. Pressione **E** perto do instrutor, aproxime-se do boneco e clique nele ou pressione **F**. Volte ao instrutor, derrote três slimes verdes e converse com ele novamente. O painel **MISSÕES**, à direita, indica cada passo. Clique ou pressione **1** para atacar os slimes.
3. Para instalar em outro lugar, importe `Studio/ServerScriptService/AuroraPrototype.rbxmx` diretamente em `ServerScriptService`. Se o pacote não existir, execute `powershell -ExecutionPolicy Bypass -File tools/Build-Model.ps1` na pasta do projeto.
4. Para testar persistência, publique apenas uma **experiência de teste separada** e habilite **Game Settings > Security > Enable Studio Access to API Services** nela. Sem acesso a DataStore, a sessão abre em modo somente leitura e as mudanças não são gravadas.
5. Teste em **2 Players**: ambos devem ver os mesmos slimes. Saia e entre novamente para conferir nível, moedas, conclusão das missões e martelo raro.

Os arquivos em `src` são a fonte do pacote. Depois de alterar algum deles, execute `tools/Build-Model.ps1` e reimporte o modelo. Exclua a instância antiga de `AuroraPrototype` antes de importar outra cópia para não iniciar dois servidores de jogo. O gerador da arena cria apenas peças temporárias durante o Play; ele não salva geometria no lugar.

## Estado dos marcos

| Marco | Estado |
| --- | --- |
| M01 | Mapa original ainda precisa de revisão visual e teste de rotas no Studio. A arena provisória permite testar os sistemas sem depender dessa revisão. |
| M02 | Prado, slimes e HUD iniciam no Studio; combate com dois jogadores ainda precisa de teste. |
| M03 | Modo sem salvamento verificado em lugar não publicado; conclusão das missões e reconexão com DataStore ainda precisam de teste. |

## Próximo trabalho

Substituir as peças provisórias por modelos e texturas próprios, adicionar animações de ataque e ligar os spawns e o instrutor à Ilha da Aurora definitiva. Depois avançar para inventário e poção (M04).
