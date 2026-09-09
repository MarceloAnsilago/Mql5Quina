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

class CGuiSetupState
  {
public:
   string name;
   long magic;
   int market;
   ENUM_TIMEFRAMES timeframe;
   int direction;

   void Reset(const ENUM_TIMEFRAMES chart_period)
     {
      name="Meu setup";
      magic=1;
      market=GUI_SETUP_FOREX;
      timeframe=chart_period;
      direction=GUI_SETUP_BUY_SELL;
     }

   // Text indexes: 0 = optional name, 1 = positive magic number.
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
      return false;
     }

   int Choice(const int index)
     {
      if(index==2) return market>=GUI_SETUP_FOREX && market<=GUI_SETUP_B3 ? market : -1;
      if(index==3) return GuiSetupTimeframeIndex(timeframe);
      if(index==4) return direction>=GUI_SETUP_BUY_SELL && direction<=GUI_SETUP_SELL_ONLY ? direction : -1;
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
      return true;
     }
  };
#endif
