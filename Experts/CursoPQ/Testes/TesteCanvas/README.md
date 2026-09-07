# TesteCanvas

Experimento de interface MQL5 com `CCanvas`, sem dependências externas além da biblioteca padrão do MT5. Não envia ordens, não cria handles de indicadores e não implementa estratégia.

## Compilar e testar

1. Abra `TesteCanvas.mqproj` no MetaEditor e compile `TesteCanvas.mq5` com F7.
2. No Navegador do MT5, atualize a lista de Experts e arraste `TesteCanvas` para um gráfico. Não é necessário habilitar negociação algorítmica.
3. O card **Indicadores** oferece quatro botões numerados com seleção exclusiva. Escolha 1, 2, 3 ou 4 e selecione Não usar, Média Móvel ou RSI. O card **Parâmetros / Indicador N** mostra o nome e os quatro campos do indicador ativo. Os quatro indicadores iniciam em Não usar. Nessa opção, o painel de parâmetros e a coluna correspondente do resumo ficam vazios. Os parâmetros anteriores são preservados em memória ao desabilitar e reativar um indicador.
4. Configure períodos diferentes nos quatro indicadores e alterne entre eles. Troque MA ↔ RSI: os valores de cada tipo permanecem independentes por indicador. Uma edição inválida bloqueia a troca até ser corrigida ou cancelada com Escape. As etapas 2–6 continuam apenas visuais.
5. Clique num campo e digite: o primeiro dígito substitui o valor anterior. Enter, Tab ou clique fora confirmam; Escape cancela. Setas, Home, End, Backspace e Delete permitem edição por posição. Ponto, vírgula e decimal do teclado numérico são aceitos.
6. Teste período zero, texto vazio, níveis fora de 0–100 e inferior ≥ superior: o campo deve ficar vermelho, sem alterar o estado. Corrija ou use Escape para continuar.
7. Selecione cada indicador e abra sua lista de preço no card de parâmetros. Verifique sobreposição, abertura para cima perto da borda, fechamento por clique externo e navegação por setas/Enter/Escape.
8. Clique Salvar indicadores e confira os valores no log de Experts da Caixa de Ferramentas. `Print()` de EA é exibido em **Experts**, não necessariamente na aba separada **Diário/Journal**. O botão sempre imprime a configuração; `DebugGUI=false` desativa apenas mensagens de diagnóstico.
9. Redimensione o gráfico e remova o EA: o Canvas deve acompanhar o tamanho e as propriedades do gráfico alteradas pelo experimento devem ser restauradas na remoção.
10. Clique **Recolher**, no canto superior direito. O gráfico reaparece e seus controles de rolagem e teclado voltam à configuração original. Clique **EXIBIR INTERFACE**, no canto superior esquerdo, para retornar. Teste também redimensionar o gráfico enquanto a interface está recolhida.

Recolher preserva as configurações e até uma edição ainda não confirmada; dropdowns são fechados. O mesmo Canvas é reduzido a 176 × 40 pixels para desenhar o botão de retorno, mantendo apenas um objeto gráfico e liberando o restante do gráfico para interação. Ao reabrir, as dimensões atuais são lidas novamente.

O script `Tests/GuiStateTests.mq5` contém verificações do estado: valores iniciais, independência, preservação MA/RSI, validação e mapeamentos. Para executar, copie o script para `MQL5/Scripts`, ajustando seu include para o caminho de `GuiState.mqh`, compile e arraste para um gráfico. Ele não cria objetos nem opera. Resultado esperado: `0 falhas`. A compilação do script não equivale à sua execução.

## Arquivos e responsabilidades

- `TesteCanvas.mq5`: entrada do EA; OnInit, OnDeinit, OnChartEvent e OnTick vazio.
- `TesteCanvas.mqproj`: projeto existente, atualizado com os arquivos da biblioteca.
- `Include/CanvasGUI/GuiApp.mqh`: ciclo de vida, despacho de eventos, bindings e invalidação.
- `Include/CanvasGUI/GuiTheme.mqh`: cores ARGB e retângulos.
- `Include/CanvasGUI/GuiRenderer.mqh`: Canvas, primitivas, apresentação e backup da região do dropdown.
- `Include/CanvasGUI/GuiState.mqh`: configuração definitiva dos quatro indicadores, validação e impressão.
- `Include/CanvasGUI/GuiLayout.mqh`: medidas e distribuição responsiva.
- `Include/CanvasGUI/Controls/GuiControl.mqh`: base, bounds, visibilidade, habilitação, hover, active e dirty.
- `Include/CanvasGUI/Controls/GuiLabel.mqh`: rótulos.
- `Include/CanvasGUI/Controls/GuiButton.mqh`: botão e estados visuais.
- `Include/CanvasGUI/Controls/GuiTextField.mqh`: editor numérico Canvas; buffer temporário separado do estado.
- `Include/CanvasGUI/Controls/GuiSelectBox.mqh`: seletor e camada de opções.
- `Include/CanvasGUI/Controls/GuiField.mqh`: adaptação reutilizável entre componentes e campos do estado.
- `Tests/GuiStateTests.mq5`: verificações de estado executáveis como script.
- `README.md`: arquitetura, limites e roteiro de validação.
- `TesteCanvas.ex5`, `TesteCanvas.compile.log`, `Tests/GuiStateTests.ex5` e `Tests/GuiStateTests.compile.log`: artefatos locais de compilação.

## Renderização e objetos

A GUI cria **1 objeto MT5**, um `OBJ_BITMAP_LABEL`, inclusive durante edição e dropdowns. Objetos preexistentes no gráfico não entram nessa contagem. Nenhum `OBJ_EDIT` é utilizado.

`Render()` sai imediatamente quando `m_dirty=false`. Hover só invalida ao mudar de controle/opção. Edição redesenha o campo e a mensagem; troca de tipo redesenha o card afetado. O fundo inteiro é desenhado apenas na inicialização ou mudança de dimensões. A região sob o dropdown é copiada antes de desenhá-lo e restaurada antes da próxima composição. O dropdown é sempre desenhado por último.

Há uma chamada `CCanvas.Update(true)` por atualização visual efetiva. A biblioteca padrão ainda transfere o bitmap inteiro para o recurso nessa chamada; a otimização parcial economiza desenho, não promete upload parcial. Não há timer, animação contínua ou trabalho em OnTick.

O teclado numérico foi implementado em Canvas porque o escopo não exige edição de texto geral. Não há criação/destruição de objetos auxiliares nem cursor piscante. Os eventos seguem a [documentação oficial de teclado MQL5](https://www.mql5.com/en/book/applications/events/events_keyboard).

## Limitações conhecidas

- Layout adaptável à altura: em áreas mais baixas, reduz os espaçamentos e mantém campos, ação e histórico. Exemplos mínimos: 1120 × 628 com navegação lateral; 960 × 652 com cards lado a lado e etapas no topo; 600 × 904 com cards empilhados. Abaixo do espaço necessário, o aviso informa a área atual e a altura calculada. Não há rolagem. A navegação lateral aparece a partir de 1120 pixels de largura.
- Medidas em pixels; escala de DPI não é ajustada automaticamente.
- Edição numérica limitada a 12 caracteres; períodos 1–100000, shift ±100000 e níveis RSI 0–100 com até duas casas decimais e inferior < superior.
- Sem clipboard, seleção arbitrária, Ctrl+A ou navegação completa por Tab. Tab confirma a edição. O gráfico deve estar com foco para receber teclado.
- Uma edição inválida impede mudar de campo ou aplicar até corrigir/cancelar. Ao redimensionar, uma edição válida é confirmada; uma inválida é descartada com aviso.
- Estado apenas em memória; reinicialização do EA, troca de símbolo/timeframe ou remoção retorna aos valores iniciais.
- Ocupa a janela principal do gráfico, não sub-janelas de indicadores existentes. Destina-se preferencialmente a um gráfico limpo.
- Compilação verificada no MetaEditor instalado. O roteiro de interação visual e o script de estado devem ser executados no terminal; não foram executados automaticamente nesta entrega.

## Resumo e histórico de aplicações

A área inferior tem quatro colunas fixas, uma por indicador, com tipo, período, preço e método/shift ou níveis RSI. Ao editar, acompanha os valores confirmados, inclusive a seleção Não usar. **Salvar indicadores** registra uma cópia dos quatro indicadores e imprime seus parâmetros no log. Depois de salvar, o resumo exibe a aplicação selecionada, identificada no título; uma nova edição volta ao resumo atual, sem modificar o histórico; as setas navegam por aplicações anteriores sem alterar a edição. Um novo salvamento mostra a aplicação mais recente.

O histórico e os parâmetros permanecem em memória, inclusive ao recolher/reabrir. Reinicializar ou remover o EA restaura os padrões. Continua existindo apenas um objeto Canvas.

## Validação da configuração de quatro indicadores

EA e script de estado compilados no MetaEditor. Os testes incluem independência dos quatro slots, preservação de valores MA/RSI, captura do indicador 4 no histórico e reset. Compilar o script não equivale a executá-lo; sua execução no terminal continua pendente.

Roteiro visual: selecionar 1–4, editar períodos distintos, alternar tipos, tentar trocar de indicador com valor inválido, abrir dropdowns, salvar duas configurações, navegar pelo histórico e recolher/reabrir com edição pendente.
