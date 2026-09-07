#property strict
#property script_show_inputs
#include "../Include/CanvasGUI/GuiState.mqh"
int failures=0,checks=0;
void Check(const bool condition,const string label)
  { checks++; if(!condition) { failures++; Print("FAIL: ",label); } }
void OnStart()
  {
   CGuiState state; state.Reset(); string error;
   Check(state.indicators[0].type==GUI_INDICATOR_MA && state.indicators[0].maPeriod==20 && state.indicators[0].maMethod==MODE_EMA,"MA inicial");
   Check(state.indicators[1].type==GUI_INDICATOR_RSI && state.indicators[1].rsiPeriod==14 && state.indicators[1].rsiLower==30 && state.indicators[1].rsiUpper==70,"RSI inicial");
   Check(state.Commit(0,GUI_PERIOD,"55",error),"Editar MA");
   state.Choose(0,GUI_TYPE,1);
   Check(state.Commit(0,GUI_PERIOD,"9",error),"Editar RSI");
   state.Choose(0,GUI_TYPE,0);
   Check(state.indicators[0].maPeriod==55 && state.indicators[0].rsiPeriod==9,"Preservar parâmetros ao alternar tipo");
   Check(state.indicators[1].rsiPeriod==14,"Independência dos cards");
   Check(!state.Commit(0,GUI_PERIOD,"0",error) && state.indicators[0].maPeriod==55,"Rejeitar zero sem alterar estado");
   Check(!state.Commit(0,GUI_PERIOD,"2.5",error),"Rejeitar período fracionário");
   Check(!state.Commit(0,GUI_PERIOD,"100001",error),"Limite superior de período");
   Check(!state.Commit(0,GUI_PERIOD,"12x",error),"Rejeitar lixo após número");
   Check(!state.Commit(0,GUI_PERIOD,"",error),"Rejeitar campo vazio");
   Check(state.Commit(0,GUI_SHIFT,"-12",error) && state.indicators[0].maShift==-12,"Shift negativo");
   Check(!state.Commit(0,GUI_SHIFT,"-100001",error),"Limite de shift");
   Check(state.Commit(1,GUI_LOWER,"25,75",error) && state.indicators[1].rsiLower==25.75,"Vírgula decimal");
   Check(!state.Commit(1,GUI_LOWER,"25.755",error),"Precisão visível corresponde ao estado");
   Check(!state.Commit(1,GUI_LOWER,"70",error) && state.indicators[1].rsiLower==25.75,"Rejeitar níveis iguais");
   Check(!state.Commit(1,GUI_UPPER,"20",error) && state.indicators[1].rsiUpper==70,"Rejeitar níveis invertidos");
   Check(!state.Commit(1,GUI_UPPER,"101",error),"Limite RSI");
   Check(state.Commit(1,GUI_LOWER,"0",error) && state.Commit(1,GUI_UPPER,"100",error),"Extremos RSI");
   for(int p=0;p<7;p++)
     {
      state.Choose(0,GUI_PRICE,p); state.Choose(1,GUI_PRICE,p);
      Check(state.Choice(0,GUI_PRICE)==p && state.Choice(1,GUI_PRICE)==p,"Mapeamento preço "+IntegerToString(p));
     }
   for(int m=0;m<4;m++)
     { state.Choose(0,GUI_METHOD,m); Check(state.Choice(0,GUI_METHOD)==m,"Mapeamento método "+IntegerToString(m)); }
   PrintFormat("[GuiStateTests] %d verificações, %d falhas",checks,failures);
  }
