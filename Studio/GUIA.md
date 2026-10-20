# Instalar a primeira versão no Roblox Studio

## Arquivo pronto para importar

`C:\Users\isaac\OneDrive\Documentos\Jogo Roblox\Studio\ServerScriptService\AuroraPrototype.rbxmx`

1. Abra `C:\Users\isaac\OneDrive\Documentos\Jogo Roblox\MeuJogoRoblox.rbxl.rbxl` no Roblox Studio e salve uma cópia para testes.
2. Ative **Explorer**. Clique com o botão direito em **ServerScriptService** e escolha **Insert > Import Roblox Model**.
3. Selecione o arquivo `.rbxmx` acima. Deve aparecer `ServerScriptService > AuroraPrototype`, contendo `Bootstrap`, `Config`, `DataService`, `EnemyService`, `QuestService`, `TestArena` e `Client`.
4. Clique em **Play**. O servidor cria a arena de teste e três slimes. Converse com o instrutor, acerte o boneco, converse novamente, derrote três slimes e entregue Q02.

Este pacote contém os scripts necessários para essa primeira sequência. Importe apenas o `.rbxmx`; as outras pastas locais mostram onde os sistemas vão crescer. Ao iniciar o Play, o pacote cria `Workspace > AuroraTestArena`, `Workspace > AuroraEnemies` e `ReplicatedStorage > AuroraRemotes`. Ele também coloca a HUD em `PlayerGui`. Esses objetos temporários são gerados durante o jogo.

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

O teste de salvamento exige uma experiência de teste publicada separada com acesso do Studio a serviços de API. Sem esse acesso, o jogo avisa na HUD que o progresso da sessão não será gravado. A execução no Studio ainda precisa ser validada.
