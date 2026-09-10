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
   Check(state.entry_start==0 && state.entry_end==1435 && state.close_time==1435 && !state.close_enabled,
         "Horários iniciais vão de 00:00 a 23:55 sem encerramento");
   Check(state.Value(5)=="00:00" && state.Value(6)=="23:55" && state.Value(8)=="23:55",
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
   Check(other.entry_start==0 && other.entry_end==1435 && other.close_time==1435 && !other.close_enabled,
         "Instâncias mantêm horários independentes");
   Check(state.name=="Meu setup" && state.magic==1 && state.market==GUI_SETUP_FOREX &&
         state.direction==GUI_SETUP_BUY_SELL && state.timeframe==PERIOD_M5,
         "Horários preservam os demais campos do setup");

   string invalid_times[]={"", "9:05", "09:5", "009:05", "24:00", "23:60", "99:99", "-1:00",
                           "+1:00", "09.05", "09,05", "09 05", "09:0a", "aa:00", " 09:05", "09:05 ",
                           "09:05:00", "\t9:05", "00:01", "09:01", "12:34", "23:59"};
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
      Check(state.CommitText(time_fields[field],"23:55",error) && state.Value(time_fields[field])=="23:55",
            "Horário máximo no campo "+IntegerToString(time_fields[field]));
     }
   Check(!state.Validate(error) && error!="","Início e fim iguais rejeitados na validação global");
   Check(state.CommitText(5,"09:00",error) && state.CommitText(6,"17:00",error) &&
         state.CommitText(8,"16:55",error),"Edição isolada permite corrigir horários em qualquer ordem");
   Check(!state.Validate(error) && error!="","Rejeitar encerramento antes do fim das entradas");
   Check(state.Choose(7,0) && state.Validate(error) && state.close_time==1015,
         "Encerramento desligado ignora a relação e preserva o horário");
   Check(state.Choose(7,1) && !state.Validate(error),"Reativação valida o horário preservado");
   Check(state.CommitText(8,"17:00",error) && state.Validate(error),"Encerramento no fim das entradas é permitido");

   Check(state.CommitText(5,"22:00",error) && state.CommitText(6,"02:00",error) &&
         state.CommitText(8,"03:00",error) && state.Validate(error),"Janela e encerramento atravessam a meia-noite");
   Check(state.CommitText(8,"23:00",error) && !state.Validate(error),"Rejeitar encerramento antes da meia-noite em janela noturna");
   Check(state.CommitText(8,"01:55",error) && !state.Validate(error),"Rejeitar encerramento antes do fim da janela noturna");
   Check(state.CommitText(8,"02:00",error) && state.Validate(error),"Encerramento no fim da janela noturna é permitido");
   Check(state.CommitText(8,"21:55",error) && state.Validate(error),"Encerramento no fim do ciclo diário é permitido");
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
   Check(state.Validate(error) && error=="" && state.entry_start==0 && state.entry_end==1435 &&
         state.close_time==1435 && !state.close_enabled,"Reset restaura horários válidos");
  }

void CheckTimeSelections()
  {
   CGuiSetupState state;
   state.Reset(PERIOD_M5);
   Check(state.Choice(5)==0 && state.Choice(6)==287 && state.Choice(8)==287,
         "Seleções iniciais correspondem a 00:00 e 23:55");
   string labels[],error;
   int option_count=StringSplit(GuiSetupTimeOptions(),'|',labels);
   Check(option_count==288,"Lista de horários contém exatamente 288 opções");
   int time_fields[]={5,6,8};
   for(int field=0;field<ArraySize(time_fields);field++)
     {
      state.Reset(PERIOD_M5);
      int index=time_fields[field];
      for(int option=0;option<288;option++)
        {
         int expected_minutes=option*5;
         string expected_label=StringFormat("%02d:%02d",expected_minutes/60,expected_minutes%60);
         if(option<option_count)
            Check(labels[option]==expected_label,"Opção em intervalos de 5 minutos: "+IntegerToString(option));
         Check(state.Choose(index,option) && state.Choice(index)==option && state.Value(index)==expected_label,
               "Seleção e exibição do horário no campo "+IntegerToString(index)+": "+expected_label);
         Check(state.entry_start==(index==5 ? expected_minutes : 0) &&
               state.entry_end==(index==6 ? expected_minutes : 1435) &&
               state.close_time==(index==8 ? expected_minutes : 1435) && !state.close_enabled,
               "Seleção altera somente o horário escolhido: "+IntegerToString(index));
        }
      int previous_start=state.entry_start,previous_end=state.entry_end,previous_close=state.close_time;
      Check(!state.Choose(index,-1) && !state.Choose(index,288) && !state.Choose(index,2147483647) &&
            state.entry_start==previous_start && state.entry_end==previous_end && state.close_time==previous_close,
            "Opção fora da lista preserva todos os horários no campo "+IntegerToString(index));
      Check(state.name=="Meu setup" && state.magic==1 && state.market==GUI_SETUP_FOREX &&
            state.timeframe==PERIOD_M5 && state.direction==GUI_SETUP_BUY_SELL,
            "Escolher horários preserva os demais campos do setup");

      int invalid_minutes[]={-1,1,546,1439,1440,2147483647};
      for(int i=0;i<ArraySize(invalid_minutes);i++)
        {
         state.Reset(PERIOD_M5);
         if(index==5) state.entry_start=invalid_minutes[i];
         else if(index==6) state.entry_end=invalid_minutes[i];
         else state.close_time=invalid_minutes[i];
         Check(state.Choice(index)==-1 && !state.Validate(error) && error!="",
               "Estado fora da grade rejeitado no campo "+IntegerToString(index)+": "+IntegerToString(invalid_minutes[i]));
        }
     }
   int parsed_minutes=-1;
   Check(GuiSetupParseTime("23:59",parsed_minutes) && parsed_minutes==1439,
         "Parser HH:MM genérico continua aceitando qualquer minuto válido");
   state.Reset(PERIOD_M5);
   Check(state.Choose(5,264) && state.Choose(6,24) && state.Choose(7,1) && state.Choose(8,36) && state.Validate(error),
         "Seleções preservam janela noturna e encerramento após meia-noite");
   Check(state.Choose(8,23) && !state.Validate(error),"Seleção rejeita encerramento antes do fim da janela noturna");
   Check(state.Choose(7,0) && state.Validate(error) && state.Choice(8)==23,
         "Desligar encerramento preserva horário e ignora sua relação com a janela");
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
   Check(!state.Choose(0,0) && !state.Choose(9,0),"Rejeitar índices sem seleção");
   Check(state.Choice(0)==-1 && state.Choice(9)==-1 && state.Value(9)=="","Índices inválidos não exibem valores");

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
   CheckTimeSelections();
   PrintFormat("[GuiSetupStateTests] %d verificações, %d falhas",checks,failures);
  }
