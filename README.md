# Ilha da Aurora — área inicial jogável

Abra **Studio/IlhaDaAurora.rbxlx** no Roblox Studio. O terreno e os modelos já estão montados e podem ser editados antes de apertar Play.

## Implementado nesta versão

- Ilha com terreno orgânico, estrada de terra, rio, colinas e gruta de cristais.
- Vila com três casas, telhados azuis, madeira aparente, janelas, lanternas, poço e cercas.
- Árvores com copas facetadas, raízes, rochas e flores.
- Paladino com capa, ombreiras, escudo e martelo; movimento do martelo e indicação de impacto.
- Instrutor Aldric, boneco de treino, três slimes e duas missões com EXP, moedas e martelo raro.
- HUD azul e dourada, missão atual, vida, EXP, moedas, mapa esquemático e barra de ações.

## Abrir e jogar

1. No Studio, use **Arquivo > Abrir do arquivo** e escolha `Studio/IlhaDaAurora.rbxlx`.
2. Clique em **Play** (F5).
3. Converse com Aldric usando **E**, acerte o boneco usando **F** e volte a Aldric.
4. Derrote três slimes no campo: aproxime-se e **clique no inimigo**, ou aponte o mouse para ele e pressione **1**. Volte a Aldric para receber a recompensa.

O guia de edição está em [Studio/GUIA.md](Studio/GUIA.md).

## Arquivos

| Caminho | Finalidade |
| --- | --- |
| `Studio/IlhaDaAurora.rbxlx` | Lugar completo, editável e pronto para abrir. |
| `src/ServerScriptService/AuroraPrototype/` | Fontes dos dez scripts e módulos. O nome da pasta é legado. |
| `Studio/ServerScriptService/AuroraPrototype.rbxmx` | Pacote somente de scripts, para instalação em outro lugar. |
| `tools/Build-Model.ps1` | Atualiza o pacote de scripts e verifica a serialização XML. |
| `tools/Build-Place.ps1` | Gera um lugar inicial em `build/IlhaDaAurora.source.rbxlx`; não altera o lugar completo em Studio. |
| `tools/Studio-SmokeTest.luau` | Teste de integração para uma sessão local sem salvamento. |

## Verificação realizada

Testado no Roblox Studio com um jogador: carregamento do cenário, equipamento após carregar o avatar, teclas E e F e atualização da HUD. O teste executado como Script temporário no servidor confirmou Q01 e Q02, três abates, alcance, intervalo entre ataques, recompensas únicas, nível 2, martelo raro e reaparecimento dos slimes. Resultado: `AURORA_SMOKE_OK`.

Sem DataStore disponível, a sessão permite jogar e avisa que o progresso não será salvo. Persistência após reconexão, multiplayer e controles/desempenho em celular ainda precisam de teste.

## Próxima etapa

Esta é a primeira área em desenvolvimento. Ainda faltam inventário utilizável, poções, outras habilidades, mais missões, chefes, áudio e animações completas. A referência visual orienta a composição; modelos e materiais ainda precisam de refinamento e otimização, especialmente as copas das árvores.
