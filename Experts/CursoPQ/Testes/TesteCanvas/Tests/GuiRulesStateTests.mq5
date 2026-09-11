#property script_show_inputs
#include "../Include/CanvasGUI/GuiState.mqh"
#include "../Include/CanvasGUI/GuiLayout.mqh"
int checks=0,failures=0;
void Check(const bool ok,const string message)
  { checks++; if(!ok) { failures++; Print("FAIL: ",message); } }
void OnStart()
  {
   CGuiState state; state.Reset(); string error;
   Check(state.rules.order_mode==GUI_ORDER_MARKET && state.rules.candle_filter==GUI_CANDLE_DISABLED,"Default entry rules");
   Check(state.rules.stop_loss==0 && state.rules.take_profit==0 && state.rules.Validate(error),"Disabled exits are valid");
   Check(state.rules.Choose(0,1) && state.rules.Choose(1,2),"Pending order and bearish candle");
   Check(!state.rules.Choose(0,2) && !state.rules.Choose(1,3) && !state.rules.Choose(1,-1),"Invalid options rejected");
   Check(state.rules.order_mode==GUI_ORDER_PENDING && state.rules.candle_filter==GUI_CANDLE_BEARISH,"Invalid options preserve state");
   Check(state.rules.Commit(2,"150,25",error) && state.rules.Commit(3,"300.50",error),"Comma and decimal point accepted");
   string invalid[]={"","-1","1e3","NaN","1.2.3","1.001","100000001","abc","."};
   for(int i=0;i<ArraySize(invalid);i++)
     {
      Check(!state.rules.Commit(2,invalid[i],error) && error!="","Reject invalid stop: "+invalid[i]);
      Check(!state.rules.Commit(3,invalid[i],error) && error!="","Reject invalid target: "+invalid[i]);
      Check(state.rules.stop_loss==150.25 && state.rules.take_profit==300.5,"Invalid edits preserve exits");
     }
   state.setup.name="Rules snapshot"; state.indicators[0].maPeriod=42;
   Check(state.Apply(),"Save combined configuration");
   state.rules.Choose(0,0); state.rules.Choose(1,0); state.rules.Commit(2,"0",error); state.rules.Commit(3,"0",error);
   Check(state.applications[0].rules.order_mode==GUI_ORDER_PENDING && state.applications[0].rules.candle_filter==GUI_CANDLE_BEARISH,"Snapshot preserves entry rules");
   Check(state.applications[0].rules.stop_loss==150.25 && state.applications[0].rules.take_profit==300.5,"Snapshot preserves exits");
   Check(state.applications[0].setup.name=="Rules snapshot" && state.applications[0].indicators[0].maPeriod==42,"Snapshot includes setup and indicators");
   Check(state.rules.Commit(2,"100000000",error),"Upper boundary accepted");
   state.rules.stop_loss=-1;
   Check(!state.Apply() && ArraySize(state.applications)==1,"Invalid state cannot enter history");
   state.Reset();
   Check(state.rules.stop_loss==0 && ArraySize(state.applications)==0,"Reset clears rules and history");
   int widths[]={600,960,1120,1600};
   for(int i=0;i<ArraySize(widths);i++)
     {
      CGuiLayout layout; layout.Calculate(widths[i],1200,false,true);
      Check(!layout.too_small && layout.status.y+layout.status.h+8<=1200,"Rules footer fits supported viewport");
      Check(layout.cards[1].y+196<=layout.cards[1].y+layout.cards[1].h-28,"Inputs leave room for card hint");
      Check(layout.apply.x>=layout.left+172+16,"Navigation buttons do not overlap");
     }
   PrintFormat("[GuiRulesStateTests] %d checks, %d failures",checks,failures);
  }
