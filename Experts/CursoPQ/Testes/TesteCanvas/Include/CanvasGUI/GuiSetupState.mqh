#ifndef CANVAS_GUI_SETUP_STATE_MQH
#define CANVAS_GUI_SETUP_STATE_MQH

enum ENUM_GUI_SETUP_MARKET { GUI_SETUP_FOREX=0, GUI_SETUP_B3=1 };
enum ENUM_GUI_SETUP_DIRECTION { GUI_SETUP_BUY_SELL=0, GUI_SETUP_BUY_ONLY=1, GUI_SETUP_SELL_ONLY=2 };

string GuiSetupTimeframeOptions()
  { return "M1|M2|M3|M4|M5|M6|M10|M12|M15|M20|M30|H1|H2|H3|H4|H6|H8|H12|D1|W1|MN1"; }

ENUM_TIMEFRAMES GuiSetupTimeframeByIndex(const int index)
  {
   ENUM_TIMEFRAMES periods[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,
                             PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,
                             PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,
                             PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
   if(index<0 || index>=ArraySize(periods)) return PERIOD_CURRENT;
   return periods[index];
  }

int GuiSetupTimeframeIndex(const ENUM_TIMEFRAMES period)
  {
   if(period==PERIOD_CURRENT) return -1;
   for(int i=0;i<21;i++) if(GuiSetupTimeframeByIndex(i)==period) return i;
   return -1;
  }

string GuiSetupTimeLabel(const int minutes)
  {
   if(minutes<0 || minutes>=1440) return "";
   return StringFormat("%02d:%02d",minutes/60,minutes%60);
  }

bool GuiSetupParseTime(const string value,int &minutes)
  {
   if(StringLen(value)!=5 || StringGetCharacter(value,2)!=':') return false;
   for(int i=0;i<5;i++)
     {
      if(i==2) continue;
      ushort character=StringGetCharacter(value,i);
      if(character<'0' || character>'9') return false;
     }
   int hours=(int)StringToInteger(StringSubstr(value,0,2));
   int minute=(int)StringToInteger(StringSubstr(value,3,2));
   if(hours>23 || minute>59) return false;
   minutes=hours*60+minute;
   return true;
  }

class CGuiSetupState
  {
public:
   string name;
   long magic;
   int market;
   ENUM_TIMEFRAMES timeframe;
   int direction;
   int entry_start;
   int entry_end;
   bool close_enabled;
   int close_time;

   void Reset(const ENUM_TIMEFRAMES chart_period)
     {
      name="Meu setup";
      magic=1;
      market=GUI_SETUP_FOREX;
      timeframe=chart_period;
      direction=GUI_SETUP_BUY_SELL;
      entry_start=0;
      entry_end=1439;
      close_enabled=false;
      close_time=1439;
     }

   // Text indexes: 0 = optional name, 1 = positive magic number.
   // 5 = entry start, 6 = entry end, 8 = closing time (server HH:MM).
   // Never change the stored value until the complete input is valid.
   bool CommitText(const int index,string value,string &error)
     {
      error="";
      if(index==0)
        {
         if(StringLen(value)>48) { error="Nome: use no máximo 48 caracteres."; return false; }
         StringTrimLeft(value);
         StringTrimRight(value);
         name=value;
         return true;
        }
      if(index==5 || index==6 || index==8)
        {
         int minutes=0;
         if(!GuiSetupParseTime(value,minutes))
           { error="Horário: use HH:MM, de 00:00 a 23:59."; return false; }
         if(index==5) entry_start=minutes;
         else if(index==6) entry_end=minutes;
         else close_time=minutes;
         return true;
        }
      if(index!=1) { error="Campo de configuração inválido."; return false; }
      if(StringLen(value)==0) { error="Informe o magic number."; return false; }
      long candidate=0;
      for(int i=0;i<StringLen(value);i++)
        {
         ushort character=StringGetCharacter(value,i);
         if(character<'0' || character>'9')
           { error="Magic number: use apenas números inteiros positivos."; return false; }
         int digit=(int)character-'0';
         if(candidate>(2147483647-digit)/10)
           { error="Magic number: 1 a 2147483647."; return false; }
         candidate=candidate*10+digit;
        }
      if(candidate<1) { error="Magic number: 1 a 2147483647."; return false; }
      magic=candidate;
      return true;
     }

   // Select indexes: 2 = market, 3 = timeframe option, 4 = direction.
   // 7 = closing mode: 0 = disabled, 1 = close at the selected time.
   bool Choose(const int index,const int option)
     {
      if(index==2 && option>=GUI_SETUP_FOREX && option<=GUI_SETUP_B3)
        { market=option; return true; }
      if(index==3)
        {
         ENUM_TIMEFRAMES period=GuiSetupTimeframeByIndex(option);
         if(period==PERIOD_CURRENT) return false;
         timeframe=period;
         return true;
        }
      if(index==4 && option>=GUI_SETUP_BUY_SELL && option<=GUI_SETUP_SELL_ONLY)
        { direction=option; return true; }
      if(index==7 && option>=0 && option<=1)
        { close_enabled=(option==1); return true; }
      return false;
     }

   int Choice(const int index)
     {
      if(index==2) return market>=GUI_SETUP_FOREX && market<=GUI_SETUP_B3 ? market : -1;
      if(index==3) return GuiSetupTimeframeIndex(timeframe);
      if(index==4) return direction>=GUI_SETUP_BUY_SELL && direction<=GUI_SETUP_SELL_ONLY ? direction : -1;
      if(index==7) return close_enabled ? 1 : 0;
      return -1;
     }

   string Value(const int index)
     {
      if(index==0) return name;
      if(index==1) return IntegerToString(magic);
      if(index==2 && Choice(index)>=0) return market==GUI_SETUP_B3 ? "B3" : "Forex";
      if(index==3 && Choice(index)>=0)
        {
         string label=EnumToString(timeframe);
         StringReplace(label,"PERIOD_","");
         return label;
        }
      if(index==4 && Choice(index)>=0)
        {
         if(direction==GUI_SETUP_BUY_ONLY) return "Somente compra";
         if(direction==GUI_SETUP_SELL_ONLY) return "Somente venda";
         return "Compra e venda";
        }
      if(index==5) return GuiSetupTimeLabel(entry_start);
      if(index==6) return GuiSetupTimeLabel(entry_end);
      if(index==7) return close_enabled ? "Encerrar no horário" : "Não encerrar";
      if(index==8) return GuiSetupTimeLabel(close_time);
      return "";
     }

   bool Validate(string &error)
     {
      error="";
      if(StringLen(name)>48) { error="Nome: use no máximo 48 caracteres."; return false; }
      if(magic<1 || magic>2147483647) { error="Magic number: 1 a 2147483647."; return false; }
      if(Choice(2)<0) { error="Selecione o mercado: Forex ou B3."; return false; }
      if(Choice(3)<0) { error="Selecione um timeframe válido."; return false; }
      if(Choice(4)<0) { error="Selecione a direção permitida."; return false; }
      if(entry_start<0 || entry_start>=1440)
        { error="Início das entradas: use um horário de 00:00 a 23:59."; return false; }
      if(entry_end<0 || entry_end>=1440)
        { error="Fim das entradas: use um horário de 00:00 a 23:59."; return false; }
      if(close_time<0 || close_time>=1440)
        { error="Encerramento: use um horário de 00:00 a 23:59."; return false; }
      if(entry_start==entry_end)
        { error="Início e fim das entradas devem ser diferentes."; return false; }
      // Measure both times from the entry start to support overnight windows.
      // Validate the relationship here so each field can be edited in any order.
      if(close_enabled && (close_time-entry_start+1440)%1440<(entry_end-entry_start+1440)%1440)
        { error="Encerramento deve ocorrer no fim das entradas ou depois, no mesmo ciclo diário."; return false; }
      return true;
     }
  };
#endif
