#property strict
#property script_show_inputs
#include "../Include/CanvasGUI/GuiSetupState.mqh"

int failures=0,checks=0;
void Check(const bool condition,const string label)
  { checks++; if(!condition) { failures++; Print("FAIL: ",label); } }

void CheckSchedule()
  {
   CGuiSetupState state,other;
   state.Reset(PERIOD_M5);
   other.Reset(PERIOD_H1);
   string error;
   Check(state.entry_start==0 && state.entry_end==1439 && state.close_time==1439 && !state.close_enabled,
         "Horários iniciais cobrem o dia sem encerramento");
   Check(state.Value(5)=="00:00" && state.Value(6)=="23:59" && state.Value(8)=="23:59",
         "Horários exibem HH:MM com zeros iniciais");
   Check(state.Choice(7)==0 && state.Value(7)=="Não encerrar" && state.Validate(error),
         "Encerramento desligado por padrão");
   Check(state.CommitText(5,"09:05",error) && state.entry_start==545 && state.Value(5)=="09:05",
         "Editar início das entradas");
   Check(state.CommitText(6,"17:00",error) && state.entry_end==1020,"Editar fim das entradas");
   Check(state.CommitText(8,"17:30",error) && state.close_time==1050,"Editar horário de encerramento");
   Check(state.Choose(7,1) && state.close_enabled && state.Choice(7)==1 && state.Value(7)=="Encerrar no horário",
         "Habilitar encerramento");
   Check(state.Validate(error) && error=="","Encerramento após fim das entradas é válido");
   Check(other.entry_start==0 && other.entry_end==1439 && other.close_time==1439 && !other.close_enabled,
         "Instâncias mantêm horários independentes");
   Check(state.name=="Meu setup" && state.magic==1 && state.market==GUI_SETUP_FOREX &&
         state.direction==GUI_SETUP_BUY_SELL && state.timeframe==PERIOD_M5,
         "Horários preservam os demais campos do setup");

   string invalid_times[]={"", "9:05", "09:5", "009:05", "24:00", "23:60", "99:99", "-1:00",
                           "+1:00", "09.05", "09,05", "09 05", "09:0a", "aa:00", " 09:05", "09:05 ",
                           "09:05:00", "\t9:05"};
   int time_fields[]={5,6,8};
   for(int field=0;field<ArraySize(time_fields);field++)
      for(int i=0;i<ArraySize(invalid_times);i++)
         Check(!state.CommitText(time_fields[field],invalid_times[i],error) && error!="" &&
               state.entry_start==545 && state.entry_end==1020 && state.close_time==1050 && state.close_enabled,
               "Horário inválido preserva estado no campo "+IntegerToString(time_fields[field])+": "+invalid_times[i]);
   Check(!state.Choose(7,-1) && !state.Choose(7,2) && state.close_enabled,"Encerramento inválido preserva seleção");
   Check(!state.CommitText(7,"0",error) && state.close_enabled,"Texto não altera modo de encerramento");

   for(int field=0;field<ArraySize(time_fields);field++)
     {
      Check(state.CommitText(time_fields[field],"00:00",error) && state.Value(time_fields[field])=="00:00",
            "Horário mínimo no campo "+IntegerToString(time_fields[field]));
      Check(state.CommitText(time_fields[field],"23:59",error) && state.Value(time_fields[field])=="23:59",
            "Horário máximo no campo "+IntegerToString(time_fields[field]));
     }
   Check(!state.Validate(error) && error!="","Início e fim iguais rejeitados na validação global");
   Check(state.CommitText(5,"09:00",error) && state.CommitText(6,"17:00",error) &&
         state.CommitText(8,"16:59",error),"Edição isolada permite corrigir horários em qualquer ordem");
   Check(!state.Validate(error) && error!="","Rejeitar encerramento antes do fim das entradas");
   Check(state.Choose(7,0) && state.Validate(error) && state.close_time==1019,
         "Encerramento desligado ignora a relação e preserva o horário");
   Check(state.Choose(7,1) && !state.Validate(error),"Reativação valida o horário preservado");
   Check(state.CommitText(8,"17:00",error) && state.Validate(error),"Encerramento no fim das entradas é permitido");

   Check(state.CommitText(5,"22:00",error) && state.CommitText(6,"02:00",error) &&
         state.CommitText(8,"03:00",error) && state.Validate(error),"Janela e encerramento atravessam a meia-noite");
   Check(state.CommitText(8,"23:00",error) && !state.Validate(error),"Rejeitar encerramento antes da meia-noite em janela noturna");
   Check(state.CommitText(8,"01:59",error) && !state.Validate(error),"Rejeitar encerramento antes do fim da janela noturna");
   Check(state.CommitText(8,"02:00",error) && state.Validate(error),"Encerramento no fim da janela noturna é permitido");
   Check(state.CommitText(8,"21:59",error) && state.Validate(error),"Encerramento no fim do ciclo diário é permitido");
   Check(state.CommitText(8,"22:00",error) && !state.Validate(error),"Encerramento no início do ciclo antecede o fim das entradas");
   Check(state.CommitText(5,"09:00",error) && state.CommitText(6,"17:00",error) &&
         state.CommitText(8,"00:30",error) && state.Validate(error),"Janela diurna permite encerramento após meia-noite");

   state.Reset(PERIOD_M1); state.entry_start=-1;
   Check(!state.Validate(error) && state.Value(5)=="","Rejeitar início negativo");
   state.entry_start=1440;
   Check(!state.Validate(error) && state.Value(5)=="","Rejeitar início acima de 23:59");
   state.Reset(PERIOD_M1); state.entry_end=-1;
   Check(!state.Validate(error) && state.Value(6)=="","Rejeitar fim negativo");
   state.entry_end=1440;
   Check(!state.Validate(error) && state.Value(6)=="","Rejeitar fim acima de 23:59");
   state.Reset(PERIOD_M1); state.close_time=-1;
   Check(!state.Validate(error) && state.Value(8)=="","Rejeitar encerramento negativo");
   state.close_time=1440;
   Check(!state.Validate(error) && state.Value(8)=="","Rejeitar encerramento acima de 23:59");
   state.Reset(PERIOD_H4);
   Check(state.Validate(error) && error=="" && state.entry_start==0 && state.entry_end==1439 &&
         state.close_time==1439 && !state.close_enabled,"Reset restaura horários válidos");
  }

void OnStart()
  {
   CGuiSetupState state,other;
   state.Reset(PERIOD_M5);
   other.Reset(PERIOD_H1);
   string error;
   Check(state.name=="Meu setup" && state.magic==1,"Identificação inicial");
   Check(state.market==GUI_SETUP_FOREX && state.direction==GUI_SETUP_BUY_SELL,"Mercado e direção iniciais");
   Check(state.timeframe==PERIOD_M5 && state.Value(3)=="M5","Timeframe inicial acompanha o gráfico");
   Check(state.Validate(error) && error=="","Padrões válidos");
   Check(state.CommitText(0,"  Setup B3  ",error) && state.name=="Setup B3","Nome preserva texto e remove espaços externos");
   Check(state.CommitText(1,"123456",error) && state.magic==123456,"Editar magic number");
   Check(state.Choose(2,1) && state.Value(2)=="B3","Escolher B3");
   Check(state.Choose(4,1) && state.Value(4)=="Somente compra","Escolher somente compra");
   Check(state.Choose(4,2) && state.Value(4)=="Somente venda","Escolher somente venda");
   Check(state.Choose(4,0) && state.Value(4)=="Compra e venda","Escolher compra e venda");
   Check(state.name=="Setup B3" && state.magic==123456 && state.timeframe==PERIOD_M5,"Seleções preservam campos independentes");
   Check(other.name=="Meu setup" && other.magic==1 && other.market==GUI_SETUP_FOREX && other.timeframe==PERIOD_H1,"Instâncias independentes");

   string max_name="123456789012345678901234567890123456789012345678";
   Check(StringLen(max_name)==48 && state.CommitText(0,max_name,error),"Nome com 48 caracteres");
   Check(!state.CommitText(0,max_name+"9",error) && state.name==max_name && error!="","Rejeitar nome longo sem mutação");
   Check(state.CommitText(0,"",error) && state.name=="" && error=="","Nome opcional");
   Check(state.Validate(error),"Identificação por magic number com nome vazio");
   Check(state.CommitText(1,"2147483647",error) && state.magic==2147483647,"Magic number máximo");
   Check(state.Value(1)=="2147483647","Resumo mantém magic number completo");
   string invalid_magic[]={"", "0", "000", "-1", "+1", "1.5", "1,5", "1e3", "1 2", " 12", "12 ", "12a", "2147483648", "99999999999999999999999999999999"};
   for(int i=0;i<ArraySize(invalid_magic);i++)
      Check(!state.CommitText(1,invalid_magic[i],error) && state.magic==2147483647 && error!="",
            "Magic inválido preserva estado: "+invalid_magic[i]);
   Check(state.CommitText(1,"0001",error) && state.magic==1 && error=="","Magic mínimo e zeros iniciais");
   Check(!state.CommitText(2,"9",error) && state.market==GUI_SETUP_B3,"Texto não altera campos de seleção");

   ENUM_TIMEFRAMES expected[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,
                              PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,
                              PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,
                              PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
   string labels[];
   Check(StringSplit(GuiSetupTimeframeOptions(),'|',labels)==ArraySize(expected),"Opções incluem todos os 21 timeframes");
   for(int option=0;option<ArraySize(expected);option++)
     {
      Check(state.Choose(3,option) && state.timeframe==expected[option] && state.Choice(3)==option,
            "Mapeamento timeframe "+IntegerToString(option));
      if(option<ArraySize(labels)) Check(state.Value(3)==labels[option],"Rótulo timeframe "+IntegerToString(option));
      Check(state.Validate(error),"Timeframe selecionado válido "+IntegerToString(option));
     }
   Check(!state.Choose(3,-1) && !state.Choose(3,21) && state.timeframe==PERIOD_MN1,"Timeframe fora da lista preserva seleção");
   Check(!state.Choose(2,-1) && !state.Choose(2,2) && state.market==GUI_SETUP_B3,"Mercado inválido preserva seleção");
   Check(!state.Choose(4,-1) && !state.Choose(4,3) && state.direction==GUI_SETUP_BUY_SELL,"Direção inválida preserva seleção");
   Check(!state.Choose(0,0) && !state.Choose(5,0),"Rejeitar índices sem seleção");
   Check(state.Choice(0)==-1 && state.Choice(5)==-1 && state.Value(9)=="","Índices inválidos não exibem valores");

   state.timeframe=PERIOD_CURRENT;
   Check(!state.Validate(error) && error!="" && state.Choice(3)==-1 && state.Value(3)=="","Rejeitar CURRENT não resolvido");
   state.timeframe=(ENUM_TIMEFRAMES)7;
   Check(!state.Validate(error),"Rejeitar timeframe inexistente");
   state.Reset(PERIOD_M1); state.magic=0;
   Check(!state.Validate(error),"Validação global rejeita magic zero");
   state.magic=2147483648;
   Check(!state.Validate(error),"Validação global rejeita magic acima do limite");
   state.Reset(PERIOD_M1); state.market=2;
   Check(!state.Validate(error) && state.Value(2)=="","Validação global rejeita mercado desconhecido");
   state.Reset(PERIOD_M1); state.direction=3;
   Check(!state.Validate(error) && state.Value(4)=="","Validação global rejeita direção desconhecida");
   state.Reset(PERIOD_M1); state.name=max_name+"9";
   Check(!state.Validate(error),"Validação global rejeita nome longo");
   state.Reset(PERIOD_H4);
   Check(state.Validate(error) && error=="" && state.name=="Meu setup" && state.magic==1 && state.timeframe==PERIOD_H4,
         "Reset restaura configuração válida com timeframe do gráfico");
   CheckSchedule();
   PrintFormat("[GuiSetupStateTests] %d verificações, %d falhas",checks,failures);
  }
