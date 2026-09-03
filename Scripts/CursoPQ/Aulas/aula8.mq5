//+------------------------------------------------------------------+
//|                                                        aula8.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#property script_show_inputs        //apresenta a janela de parâmetros do script
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
// parametros de entrada
input int INP_VEZES = 10;
input int INT_PAUSA = 3;


//   variavel global
string nome      ="Maria";




void OnStart()
  {
//---
    ImprimeNome();//chamada da função
    Print("script finalizado");
    Print("script finalizado aula 09");
    Print("script finalizado aula 10");
    Print("script finalizado aula 11");
    Print("script finalizado aula 12");
    Print("script finalizado aula 13");
  }
//+------------------------------------------------------------------+
void ImprimeNome()
{
   for(int i = 0; i < INP_VEZES; i++)
   {
      Print(i + 1, " vez, nome: ", nome,
            ", impresso às ", TimeCurrent());

      Sleep(INT_PAUSA * 1000); // cada 100 equivale a um segundo
   }
}