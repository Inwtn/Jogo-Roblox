# Jogar e instalar a primeira versão no Roblox Studio

## Testar o jogo que já está aberto

O arquivo `C:\Users\isaac\OneDrive\Documentos\Jogo Roblox\MeuJogoRoblox.rbxl.rbxl` já contém `ServerScriptService > AuroraPrototype` atualizado. Abra esse arquivo e clique em **Play**. A arena aparece somente durante a partida; no modo de edição, a baseplate vazia é normal.

1. O **instrutor azul** e o **boneco de madeira** ficam à frente do personagem, com nomes sobre eles.
2. Pressione **E** perto do instrutor azul.
3. Aproxime-se do boneco de madeira e **clique nele** ou pressione **F** para atacar.
4. Volte ao instrutor e pressione **E**. Depois derrote **3 slimes verdes** no campo e converse com ele mais uma vez.

O painel **MISSÕES**, à direita, mostra a ação atual. **E** conversa com o instrutor, **F** acerta o boneco de perto, e **clique** ou **1** ataca os slimes. A barra inferior mostra apenas o ataque básico disponível; as outras ações ainda estão em desenvolvimento. Se aparecer “Teste local: progresso não será salvo”, a missão ainda funciona nessa partida, mas reinicia no próximo Play.

## Arquivo pronto para importar

`C:\Users\isaac\OneDrive\Documentos\Jogo Roblox\Studio\ServerScriptService\AuroraPrototype.rbxmx`

Para usar o pacote em outro lugar, abra esse lugar no Roblox Studio e salve uma cópia para testes.

1. Ative **Explorer**. Clique com o botão direito em **ServerScriptService** e escolha **Insert > Import Roblox Model**.
2. Selecione o arquivo `.rbxmx` acima. Deve aparecer `ServerScriptService > AuroraPrototype`, contendo `Bootstrap`, `Config`, `DataService`, `EnemyService`, `QuestService`, `TestArena` e `Client`.
3. Clique em **Play**. Se abrir uma janela chamada **Servidor**, use **Teste > Adicionar clientes** e jogue na janela **Place1**. A câmera da janela Servidor pode continuar apontando para a baseplate: a arena foi criada longe dela. No Explorer do servidor, confira `Workspace > AuroraTestArena` e `Workspace > AuroraEnemies`.

Este pacote contém os scripts necessários para essa primeira sequência. Importe apenas o `.rbxmx`; as outras pastas locais mostram onde os sistemas vão crescer. Ao iniciar o Play, o pacote cria `Workspace > AuroraTestArena`, `Workspace > AuroraEnemies` e `ReplicatedStorage > AuroraRemotes`. Ele também coloca a HUD em `PlayerGui`. Vila, caminho, caverna e vegetação são gerados durante o jogo. Por isso, a baseplate continua vazia no modo de edição.

## Organização das pastas

| Pasta local | Uso |
| --- | --- |
| `ServerScriptService` | Pacote importável com a lógica do servidor e o script de cliente que será copiado ao jogador. |
| `Workspace` | Reservada para a ilha editável após revisar o lugar original. A arena atual é provisória. |
| `ReplicatedStorage` | Reservada para configurações compartilhadas e remotes permanentes; `AuroraRemotes` é criado pelo servidor nesta etapa. |
| `ServerStorage` | Reservada para modelos futuros de inimigos, equipamentos e montaria. |
| `StarterGui` | Reservada para a HUD final; a HUD provisória é criada pelo cliente. |
| `StarterPlayer/StarterPlayerScripts` | Reservada para controles e câmera finais. |

Para atualizar os scripts, edite os arquivos em `src/ServerScriptService/AuroraPrototype`, execute `powershell -ExecutionPolicy Bypass -File tools/Build-Model.ps1`, remova a cópia antiga de `AuroraPrototype` no Studio e importe o novo `.rbxmx`. A pasta `Studio` local não sincroniza automaticamente com o Studio.

O teste de salvamento exige uma experiência de teste publicada separada com acesso do Studio a serviços de API. Sem esse acesso, o jogo avisa na HUD que o progresso da sessão não será gravado. No Studio, o cenário visual, os slimes, a HUD e a primeira conversa com o instrutor foram verificados; o fluxo completo com **F**, as missões completas e a reconexão ainda precisam de teste.
