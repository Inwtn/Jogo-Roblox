# Abrir e editar a Ilha da Aurora

## Arquivo para usar agora

`C:\Users\isaac\OneDrive\Documentos\Jogo Roblox\Studio\IlhaDaAurora.rbxlx`

1. No Roblox Studio, abra **Arquivo > Abrir do arquivo**.
2. Escolha **IlhaDaAurora.rbxlx** dentro da pasta **Studio**.
3. A vila já aparece no modo de edição. Aperte **Play / F5** para jogar.

Não é necessário importar os scripts para esse arquivo: eles já estão instalados.

## Controles e missão

| Ação | Controle |
| --- | --- |
| Andar | W, A, S, D |
| Pular | Espaço |
| Conversar com Aldric | E, perto dele |
| Acertar o boneco | F, perto dele |
| Atacar um slime | Clique nele, ou aponte para ele e pressione 1, estando próximo |
| Parar o teste | Shift + F5 |

Siga o painel **MISSÕES**: conversar, treinar, voltar ao instrutor, derrotar três slimes e voltar para receber o martelo raro. As posições 2 a 5 da barra ainda são futuras habilidades. O mapa do canto é esquemático.

O aviso de teste local significa que o progresso vale somente naquela partida. O cenário salvo permanece no arquivo ao parar o teste.

## Onde editar no Explorer

| Local no Studio | Conteúdo |
| --- | --- |
| `Workspace > Terrain` | Relevo, chão, água e grama; use o Editor de terreno. |
| `Workspace > AuroraWorld > VilaDaAurora` | Casas. |
| `Workspace > AuroraWorld > Vegetacao` | Árvores e flores. |
| `Workspace > AuroraWorld > Rochas` | Pedras do campo. |
| `Workspace > AuroraWorld > Aderecos` | Cercas, lanternas, barris e poço. |
| `Workspace > AuroraWorld > Personagens` | Aldric e boneco de treinamento. |
| `Workspace > AuroraWorld > GrutaDosCristais` | Pedras e cristais da entrada. |
| `Workspace > AuroraWorld > Marcadores` | Posição inicial e três pontos de nascimento de slimes. |
| `ServerScriptService > AuroraGame` | Código do jogo. |

Edite com o teste parado e use **Arquivo > Salvar em arquivo**. As alterações de cenário são preservadas: o gerador reconhece `AuroraWorld` e não refaz a ilha ao apertar Play. Slimes e interface são criados durante a partida.

## Atualizar o código

As fontes ficam em `src/ServerScriptService/AuroraPrototype`. `Art` contém os modelos, `WorldBuilder` cria o terreno e distribui objetos, `PaladinVisual` monta o equipamento e `Client` cria a interface. Os outros módulos cuidam de perfil, missões e inimigos.

Depois de editar fontes locais, execute na pasta do projeto:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Build-Model.ps1
```

O comando atualiza `Studio/ServerScriptService/AuroraPrototype.rbxmx`. Ele não sincroniza automaticamente com o lugar aberto. Para atualizar, salve uma cópia do lugar, desative o Bootstrap da pasta antiga, importe o pacote novo em ServerScriptService e mantenha apenas um Bootstrap ativo. Depois de conferir a atualização, a pasta antiga pode ser arquivada fora de ServerScriptService. O mapa em Workspace pode continuar o mesmo.

Alterar `Art` ou a geração em `WorldBuilder` não reconstrói automaticamente um cenário já salvo. Para experimentar uma geração nova, use um lugar separado:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Build-Place.ps1
```

Abra `build/IlhaDaAurora.source.rbxlx`, ainda sem o cenário montado. Antes de Play, execute na Command Bar:

```lua
require(game.ServerScriptService.AuroraGame.WorldBuilder).Build()
```

Salve essa experiência com outro nome para comparar com a ilha editada.

## Testes

Já verificados: cenário, equipamento, E/F, fluxo das duas missões, combate, recompensas únicas e respawn. Para repetir o teste automático, inicie Play local com Q01 e sem DataStore; no contexto Servidor, insira um Script temporário em ServerScriptService e cole `tools/Studio-SmokeTest.luau`. O resultado esperado na Saída é `AURORA_SMOKE_OK`. Pare o teste ao concluir; esse Script não deve fazer parte do lugar publicado.

Ainda pendentes: dois jogadores, salvamento/reconexão em experiência de teste publicada, celulares e otimização. O lugar local não foi publicado.
