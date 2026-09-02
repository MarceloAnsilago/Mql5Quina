# Curso MQL5 Completo — Pedro Quina

## Objetivo

Este repositório organiza os exercícios, exemplos e testes desenvolvidos durante o estudo do curso **MQL5 Completo**, de Pedro Quina. Ele fica diretamente na pasta de dados do MetaTrader 5 para permitir a edição, compilação e execução dos códigos no ambiente da plataforma.

## Estrutura das pastas

- `Experts/PQ/Aulas/`: Expert Advisors desenvolvidos nas aulas.
- `Experts/PQ/Testes/`: testes e experimentos com Expert Advisors.
- `Scripts/PQ/Aulas/`: scripts desenvolvidos nas aulas.
- `Scripts/PQ/Testes/`: testes e experimentos com scripts.
- `Indicators/PQ/Aulas/`: indicadores desenvolvidos nas aulas.
- `Indicators/PQ/Testes/`: testes e experimentos com indicadores.
- `Include/PQ/`: arquivos reutilizáveis de cabeçalho (`.mqh`) do curso.

## Padrão de nomes

Use nomes descritivos, sem espaços ou acentos, com numeração de três dígitos. Exemplos:

- `Aula001_PrimeiroScript.mq5`
- `Aula002_TiposDeVariaveis.mq5`
- `Aula003_Operadores.mq5`
- `Teste001_OrdensDeCompra.mq5`
- `EA001_CruzamentoDeMedias.mq5`

## Abrir, compilar e executar

1. No MetaTrader 5, abra o MetaEditor pressionando `F4` ou usando **Ferramentas > Editor de Linguagem MetaQuotes**.
2. No Navegador do MetaEditor, localize o código dentro de `MQL5` na categoria correspondente: `Experts`, `Scripts` ou `Indicators`.
3. Abra o arquivo `.mq5` e pressione `F7` para compilar. Corrija eventuais erros exibidos na aba **Erros**. O arquivo compilado `.ex5` é local e não é versionado.
4. Volte ao MetaTrader 5. No painel **Navegador**, atualize a categoria correspondente caso o novo código ainda não apareça.
5. Para executar, arraste o Expert Advisor, script ou indicador para um gráfico. Revise as entradas e permissões antes de confirmar. Para Expert Advisors, habilite a negociação algorítmica somente quando necessário e, de preferência, faça os primeiros testes em uma conta de demonstração ou no Testador de Estratégias.

## Aviso

Este repositório destina-se exclusivamente a estudos e não possui vínculo oficial, associação ou representação do autor do curso.
