//+------------------------------------------------------------------+
//|                                            Aula16_enumstruct.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---valores     0          1        2     3
   enum meses{ janeiro, fevereiro, março,abril };
   Print( fevereiro );
   Print( EnumToString(fevereiro) );
   
   struct Pessoa{
     string endereco;
     int idade;
     double altura;
   
   };
   
   Pessoa alice;
   
   alice.endereco = "Rua new jersey";
   alice.idade = 10;   
   alice.altura = 1.35;
   
   Pessoa maria;
   
   maria.endereco = "rua dele";
   maria.endereco = 10;
   maria.altura = 1.80;
   
   Print("alice idade ", alice.idade);
   Print("maria endereço", maria.endereco);
  }
//+------------------------------------------------------------------+
