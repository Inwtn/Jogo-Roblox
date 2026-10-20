# Ilha da Aurora — primeira fatia jogável

Este repositório começa a implementar o MVP do RPG. O arquivo `MeuJogoRoblox.rbxl.rbxl` é o lugar original e permanece intacto. O pacote `Studio/ServerScriptService/AuroraPrototype.rbxmx` contém um protótipo independente para importar nesse lugar pelo Roblox Studio.

O plano cita `IlhaInicial.rbxlx`, mas esse arquivo não está nesta pasta. Ainda precisamos conferir no Studio se o lugar binário disponível contém a ilha descrita.

## Conteúdo desta etapa

- Arena de teste gerada ao iniciar o servidor, afastada do mapa original.
- Paladino com ataque básico validado no servidor; boneco de treino e três slimes com perseguição, ataque, retorno e reaparecimento.
- Q01 (falar com instrutor e acertar o boneco) e Q02 (derrotar três slimes e voltar ao instrutor), recompensas únicas, nível, moedas e martelo raro.
- Perfil salvo em `AuroraProfiles_Dev_v1` com bloqueio de sessão, salvamento periódico e modo somente leitura se o carregamento falhar.
- HUD provisória no PC. As demais classes, missões, mapa final, itens equipáveis e celular continuam para marcos posteriores.

## Como testar no Studio

1. Abra `MeuJogoRoblox.rbxl.rbxl` no Roblox Studio e salve uma **cópia de teste**. Não publique esta versão por enquanto.
2. No **Explorer**, clique com o botão direito em `ServerScriptService`, escolha **Insert > Import Roblox Model** e selecione `Studio/ServerScriptService/AuroraPrototype.rbxmx`. Confirme que a pasta `AuroraPrototype` ficou diretamente em `ServerScriptService`. Se o pacote não existir, execute `powershell -ExecutionPolicy Bypass -File tools/Build-Model.ps1` na pasta do projeto.
3. Aperte **Play**. O protótipo leva o personagem à arena de teste. Fale com o instrutor usando o prompt, acerte o boneco com clique esquerdo ou tecla `1`, fale novamente, derrote três slimes e volte ao instrutor.
4. Para testar persistência, publique apenas uma **experiência de teste separada** e habilite **Game Settings > Security > Enable Studio Access to API Services** nela. Sem acesso a DataStore, a sessão abre em modo somente leitura e as mudanças não são gravadas.
5. Teste em **2 Players**: ambos devem ver os mesmos slimes. Saia e entre novamente para conferir nível, moedas, conclusão das missões e martelo raro.

Os arquivos em `src` são a fonte do pacote. Depois de alterar algum deles, execute `tools/Build-Model.ps1` e reimporte o modelo. Exclua a instância antiga de `AuroraPrototype` antes de importar outra cópia para não iniciar dois servidores de jogo. O gerador da arena cria apenas peças temporárias durante o Play; ele não salva geometria no lugar.

## Estado dos marcos

| Marco | Estado |
| --- | --- |
| M01 | Mapa original ainda precisa de revisão visual e teste de rotas no Studio. A arena provisória permite testar os sistemas sem depender dessa revisão. |
| M02 | Implementado em código; teste com dois jogadores no Studio pendente. |
| M03 | Implementado em código; reconexão com DataStore em experiência de teste pendente. |

## Próximo trabalho

Após validar esta fatia no Studio, ligar os spawns e o instrutor à Ilha da Aurora real, remover a arena provisória e avançar para inventário e poção (M04). Registre defeitos encontrados no teste antes de ampliar o combate.
