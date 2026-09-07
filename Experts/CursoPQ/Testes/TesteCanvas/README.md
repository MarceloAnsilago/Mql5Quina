# TesteCanvas

Experimento de interface MQL5 com `CCanvas`, sem dependências externas além da biblioteca padrão do MT5. Não envia ordens, não cria handles de indicadores e não implementa estratégia.

## Compilar e testar

1. Abra `TesteCanvas.mqproj` no MetaEditor e compile `TesteCanvas.mq5` com F7.
2. No Navegador do MT5, atualize a lista de Experts e arraste `TesteCanvas` para um gráfico. Não é necessário habilitar negociação algorítmica.
3. O primeiro card contém os seletores **Indicador 1** e **Indicador 2**, um abaixo do outro. O segundo card mostra apenas os parâmetros do indicador ativo, identificado no título. Inicialmente aparece o indicador 1: MA / 20 / EMA / Close / 0.
4. Clique no seletor Indicador 2 para exibir seus parâmetros: RSI / 14 / Close / 30 / 70. Abrir um seletor já ativa o indicador correspondente, mesmo sem trocar o tipo. Alterne MA ↔ RSI e volte ao Indicador 1; os valores dos dois indicadores e de cada tipo permanecem independentes em memória.
5. Clique num campo e digite: o primeiro dígito substitui o valor anterior. Enter, Tab ou clique fora confirmam; Escape cancela. Setas, Home, End, Backspace e Delete permitem edição por posição. Ponto, vírgula e decimal do teclado numérico são aceitos.
6. Teste período zero, texto vazio, níveis fora de 0–100 e inferior ≥ superior: o campo deve ficar vermelho, sem alterar o estado. Corrija ou use Escape para continuar.
7. Ative cada indicador no primeiro card e abra sua lista de preço no segundo card. Verifique sobreposição, abertura para cima perto da borda, fechamento por clique externo e navegação por setas/Enter/Escape.
8. Clique APLICAR e confira os valores no log de Experts da Caixa de Ferramentas. `Print()` de EA é exibido em **Experts**, não necessariamente na aba separada **Diário/Journal**. O botão sempre imprime a configuração; `DebugGUI=false` desativa apenas mensagens de diagnóstico.
9. Redimensione o gráfico e remova o EA: o Canvas deve acompanhar o tamanho e as propriedades do gráfico alteradas pelo experimento devem ser restauradas na remoção.
10. Clique **RECOLHER**, no canto superior direito. O gráfico reaparece e seus controles de rolagem e teclado voltam à configuração original. Clique **EXIBIR INTERFACE**, no canto superior esquerdo, para retornar. Teste também redimensionar o gráfico enquanto a interface está recolhida.

Recolher preserva as configurações e até uma edição ainda não confirmada; dropdowns são fechados. O mesmo Canvas é reduzido a 176 × 40 pixels para desenhar o botão de retorno, mantendo apenas um objeto gráfico e liberando o restante do gráfico para interação. Ao reabrir, as dimensões atuais são lidas novamente.

O script `Tests/GuiStateTests.mq5` contém 34 verificações do estado: valores iniciais, independência, preservação MA/RSI, validação e mapeamentos. Para executar, copie o script para `MQL5/Scripts`, ajustando seu include para o caminho de `GuiState.mqh`, compile e arraste para um gráfico. Ele não cria objetos nem opera. Resultado esperado: `34 verificações, 0 falhas`. A compilação do script não equivale à sua execução.

## Arquivos e responsabilidades

- `TesteCanvas.mq5`: entrada do EA; OnInit, OnDeinit, OnChartEvent e OnTick vazio.
- `TesteCanvas.mqproj`: projeto existente, atualizado com os arquivos da biblioteca.
- `Include/CanvasGUI/GuiApp.mqh`: ciclo de vida, despacho de eventos, bindings e invalidação.
- `Include/CanvasGUI/GuiTheme.mqh`: cores ARGB e retângulos.
- `Include/CanvasGUI/GuiRenderer.mqh`: Canvas, primitivas, apresentação e backup da região do dropdown.
- `Include/CanvasGUI/GuiState.mqh`: configuração definitiva dos dois indicadores, validação e impressão.
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

- Área mínima: 600 × 770 pixels com cards empilhados, ou 1000 × 630 com cards lado a lado. Abaixo disso aparece uma instrução para ampliar. Não há rolagem.
- Medidas em pixels; escala de DPI não é ajustada automaticamente.
- Edição numérica limitada a 12 caracteres; períodos 1–100000, shift ±100000 e níveis RSI 0–100 com até duas casas decimais e inferior < superior.
- Sem clipboard, seleção arbitrária, Ctrl+A ou navegação completa por Tab. Tab confirma a edição. O gráfico deve estar com foco para receber teclado.
- Uma edição inválida impede mudar de campo ou aplicar até corrigir/cancelar. Ao redimensionar, uma edição válida é confirmada; uma inválida é descartada com aviso.
- Estado apenas em memória; reinicialização do EA, troca de símbolo/timeframe ou remoção retorna aos valores iniciais.
- Ocupa a janela principal do gráfico, não sub-janelas de indicadores existentes. Destina-se preferencialmente a um gráfico limpo.
- Compilação verificada no MetaEditor instalado. O roteiro de interação visual e o script de estado devem ser executados no terminal; não foram executados automaticamente nesta entrega.

## Lista aplicada

Abaixo dos cards e do botão APLICAR, a lista mostra a última configuração aplicada dos dois indicadores, incluindo todos os parâmetros do tipo escolhido. Antes da primeira aplicação, aparece uma orientação. Cada aplicação substitui a lista; não acumula histórico. Alterar os campos não muda a lista até aplicar novamente. Recolher/reabrir e redimensionar preservam essa cópia em memória. Um valor inválido impede a aplicação e mantém a lista anterior.

Para validar, aplique os valores iniciais, altere um período e confira que a lista só muda ao aplicar novamente. Verifique também a troca MA/RSI e o botão recolher. O script de estado inclui verificações da cópia aplicada, independência em relação à edição e atualização ao reaplicar.

