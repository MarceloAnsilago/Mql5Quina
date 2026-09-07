#ifndef CANVAS_GUI_APP_MQH
#define CANVAS_GUI_APP_MQH
#include "GuiLayout.mqh"
#include "Controls/GuiField.mqh"
#include "Controls/GuiButton.mqh"
class CGuiApp
  {
private:
   long m_chart;
   string m_name,m_message;
   bool m_debug,m_ready,m_saved,m_dirty,m_full,m_card_dirty[2],m_status_dirty,m_error;
   long m_old_show,m_old_mouse,m_old_scroll,m_old_keyboard;
   int m_open,m_edit;
   CGuiRenderer m_renderer;
   CGuiLayout m_layout;
   CGuiState m_state;
   CGuiField m_fields[10];
   CGuiButton m_apply;
   void Log(const string value) { if(m_debug) Print("[GUI] ",value); }
   void Status(const string value,const bool error=false)
     { m_message=value; m_error=error; m_status_dirty=true; m_dirty=true; }
   void BindField(const int card,const int slot,const ENUM_GUI_FIELD key,const string title,const string options="")
     {
      GuiRect r;
      if(slot==0) m_layout.IndicatorBounds(card,r); else m_layout.ParameterBounds(card,slot-1,r);
      m_fields[card*5+slot].Bind(m_state,card,key,title,r,options);
     }
   void BuildCard(const int card)
     {
      BindField(card,0,GUI_TYPE,"Indicador","Média Móvel|RSI");
      BindField(card,1,GUI_PERIOD,"Período");
      if(m_state.indicators[card].type==GUI_INDICATOR_MA)
        {
         BindField(card,2,GUI_METHOD,"Método","SMA|EMA|SMMA|LWMA");
         BindField(card,3,GUI_PRICE,"Preço aplicado","Close|Open|High|Low|Median|Typical|Weighted");
         BindField(card,4,GUI_SHIFT,"Shift");
        }
      else
        {
         BindField(card,2,GUI_PRICE,"Preço aplicado","Close|Open|High|Low|Median|Typical|Weighted");
         BindField(card,3,GUI_LOWER,"Nível inferior");
         BindField(card,4,GUI_UPPER,"Nível superior");
        }
      m_card_dirty[card]=true; m_dirty=true;
     }
   void Reflow()
     {
      BuildCard(0); BuildCard(1);
      GuiRect r=m_layout.apply; m_apply.SetBounds(r.x,r.y,r.w,r.h);
      m_full=true; m_dirty=true;
     }
   void CloseSelect()
     { if(m_open<0) return; m_fields[m_open].select.Close(); m_open=-1; m_dirty=true; }
   bool FinishEdit(const bool save)
     {
      if(m_edit<0) return true;
      int i=m_edit;
      if(save)
        {
         string error;
         if(!m_state.Commit(m_fields[i].card,m_fields[i].field,m_fields[i].edit.Buffer(),error))
           { m_fields[i].edit.invalid=true; m_fields[i].edit.dirty=true; Status(error,true); return false; }
         m_fields[i].edit.SetValue(m_state.Value(m_fields[i].card,m_fields[i].field));
        }
      m_fields[i].edit.End(); m_edit=-1; m_dirty=true;
      Status(save ? "Valor atualizado. Aplique para registrar." : "Edição cancelada.");
      return true;
     }
   void SelectOption(const int option)
     {
      if(m_open<0 || option<0) return;
      int i=m_open,card=m_fields[i].card;
      bool changed=m_fields[i].select.selected!=option;
      m_state.Choose(card,m_fields[i].field,option);
      m_fields[i].select.SetSelected(option); CloseSelect();
      if(changed && m_fields[i].field==GUI_TYPE)
        {
         BuildCard(card);
         Log(StringFormat("Indicator%d alterado para %s",card+1,option==0 ? "Média Móvel" : "RSI"));
        }
      if(changed) Status("Configuração alterada. Clique em APLICAR.");
     }
   void Click(const int x,const int y)
     {
      if(m_layout.too_small) return;
      if(m_apply.active) { m_apply.active=false; m_apply.dirty=true; m_dirty=true; }
      if(m_open>=0)
        {
         int option=m_fields[m_open].select.OptionAt(x,y);
         if(option>=0) { SelectOption(option); return; }
         bool same=m_fields[m_open].ContainsPoint(x,y);
         CloseSelect(); if(same) return;
        }
      int hit=-1;
      for(int i=0;i<10;i++) if(m_fields[i].ContainsPoint(x,y)) { hit=i; break; }
      if(hit==m_edit && m_edit>=0) return;
      if(!FinishEdit(true)) return;
      if(hit>=0)
        {
         if(m_fields[hit].is_select)
           { m_open=hit; m_fields[hit].select.Open(m_layout.height); Log("Select aberto"); }
         else
           { m_edit=hit; m_fields[hit].edit.Begin(); Status("Digite o valor. Enter salva; Esc cancela."); }
         m_dirty=true;
        }
      else if(m_apply.ContainsPoint(x,y))
        { m_state.PrintConfiguration(); Status("Configuração registrada no log do EA."); Log("Configuração aplicada"); }
     }
   void Mouse(const int x,const int y,const string flags)
     {
      if(m_layout.too_small) return;
      bool overlay=(m_open>=0 && m_fields[m_open].select.popup.Contains(x,y));
      for(int i=0;i<10;i++) if(m_fields[i].Hover(!overlay && m_fields[i].ContainsPoint(x,y))) m_dirty=true;
      if(m_apply.SetHover(!overlay && m_apply.ContainsPoint(x,y))) m_dirty=true;
      bool down=((StringToInteger(flags)&1)!=0 && m_apply.hover && m_open<0);
      if(down!=m_apply.active) { m_apply.active=down; m_apply.dirty=true; m_dirty=true; }
      if(m_open>=0)
        {
         int hot=m_fields[m_open].select.OptionAt(x,y);
         if(hot!=m_fields[m_open].select.hot) { m_fields[m_open].select.hot=hot; m_dirty=true; }
        }
     }
   void Key(const int key)
     {
      if(m_layout.too_small) return;
      if(m_open>=0)
        {
         if(key==27) CloseSelect();
         else if(key==38 || key==40) { m_fields[m_open].select.MoveHot(key==38 ? -1 : 1); m_dirty=true; }
         else if(key==13) SelectOption(m_fields[m_open].select.hot);
         return;
        }
      if(m_edit<0) return;
      if(key==27) { FinishEdit(false); return; }
      if(key==13 || key==9) { FinishEdit(true); return; }
      if(m_fields[m_edit].edit.Key(key)) { m_dirty=true; if(m_error) Status("Digite o valor. Enter salva; Esc cancela."); }
     }
   void Resize()
     {
      int w=(int)ChartGetInteger(m_chart,CHART_WIDTH_IN_PIXELS,0);
      int h=(int)ChartGetInteger(m_chart,CHART_HEIGHT_IN_PIXELS,0);
      if(w<1 || h<1 || (w==m_layout.width && h==m_layout.height)) return;
      if(!m_renderer.Resize(w,h)) { Print("[GUI] Falha ao redimensionar Canvas: ",GetLastError()); return; }
      CloseSelect();
      if(!FinishEdit(true)) { FinishEdit(false); Status("Edição inválida descartada ao redimensionar.",true); }
      m_layout.Calculate(w,h); Reflow(); Log(StringFormat("Canvas redimensionado: %dx%d",w,h));
     }
public:
   CGuiApp() { m_ready=false; m_saved=false; m_dirty=false; m_open=-1; m_edit=-1; m_error=false; }
   bool Create(const long chart,const bool debug)
     {
      m_chart=chart; m_debug=debug; m_state.Reset(); m_name="CanvasGUI_"+IntegerToString(chart)+"_"+IntegerToString((long)GetTickCount64());
      int w=(int)ChartGetInteger(chart,CHART_WIDTH_IN_PIXELS,0),h=(int)ChartGetInteger(chart,CHART_HEIGHT_IN_PIXELS,0);
      if(w<1 || h<1 || !m_renderer.Create(chart,m_name,w,h)) { Print("[GUI] Falha ao criar Canvas: ",GetLastError()); m_renderer.Destroy(); return false; }
      m_old_show=ChartGetInteger(chart,CHART_SHOW);
      m_old_mouse=ChartGetInteger(chart,CHART_EVENT_MOUSE_MOVE);
      m_old_scroll=ChartGetInteger(chart,CHART_MOUSE_SCROLL);
      m_old_keyboard=ChartGetInteger(chart,CHART_KEYBOARD_CONTROL); m_saved=true;
      if(!ChartSetInteger(chart,CHART_SHOW,false) || !ChartSetInteger(chart,CHART_EVENT_MOUSE_MOVE,true)
         || !ChartSetInteger(chart,CHART_MOUSE_SCROLL,false) || !ChartSetInteger(chart,CHART_KEYBOARD_CONTROL,false))
        { Print("[GUI] Falha ao configurar eventos do gráfico: ",GetLastError()); Destroy(); return false; }
      m_layout.Calculate(w,h); m_apply.caption="APLICAR";
      m_ready=true; Reflow(); Status("Experimento visual · sem operações."); Render();
      Log("Inicializada"); Log(StringFormat("Tamanho: %dx%d",w,h)); return true;
     }
   void Destroy()
     {
      m_ready=false; m_renderer.Destroy();
      if(m_saved)
        {
         ChartSetInteger(m_chart,CHART_SHOW,m_old_show);
         ChartSetInteger(m_chart,CHART_EVENT_MOUSE_MOVE,m_old_mouse);
         ChartSetInteger(m_chart,CHART_MOUSE_SCROLL,m_old_scroll);
         ChartSetInteger(m_chart,CHART_KEYBOARD_CONTROL,m_old_keyboard);
         m_saved=false; ChartRedraw(m_chart);
        }
     }
   void Render()
     {
      if(!m_ready || !m_dirty) return;
      m_renderer.RestoreOverlay();
      if(m_full)
        {
         m_renderer.Clear();
         if(m_layout.too_small)
           {
            m_renderer.Text(24,32,"Amplie a área do gráfico",GUI_TEXT,22,true);
            m_renderer.Text(24,72,"Mínimo: 600 x 610 ou 1000 x 490 pixels.",GUI_MUTED,14,false,(int)MathMax(60,m_layout.width-48));
           }
         else
           {
            m_renderer.Text(m_layout.left,26,"STRATEGY BUILDER",GUI_TEXT,26,true);
            m_renderer.Text(m_layout.left,65,"Configure os indicadores da estratégia",GUI_MUTED,15);
           }
        }
      if(!m_layout.too_small)
        {
         for(int card=0;card<2;card++)
           {
            bool all=m_full || m_card_dirty[card];
            if(all)
              {
               m_renderer.Box(m_layout.cards[card],GUI_CARD,GUI_BORDER);
               m_renderer.Text(m_layout.cards[card].x+20,m_layout.cards[card].y+17,"INDICADOR "+IntegerToString(card+1),GUI_TEXT,14,true);
              }
            for(int j=0;j<5;j++) m_fields[card*5+j].Draw(m_renderer,all);
           }
         if(m_full || m_apply.dirty) m_apply.Draw(m_renderer);
         if(m_full || m_status_dirty)
           {
            m_renderer.Fill(m_layout.status,GUI_BG);
            m_renderer.Text(m_layout.status.x,m_layout.status.y,m_message,m_error ? GUI_ERROR : GUI_MUTED,13,false,m_layout.status.w);
            m_renderer.Text(m_layout.status.x,m_layout.status.y+22,"Canvas GUI / 01",GUI_MUTED,11);
           }
         if(m_open>=0) { m_renderer.SaveOverlay(m_fields[m_open].select.popup); m_fields[m_open].select.DrawOverlay(m_renderer); }
        }
      m_renderer.Present();
      m_full=false; m_card_dirty[0]=false; m_card_dirty[1]=false; m_status_dirty=false; m_dirty=false;
     }
   void Event(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
      if(!m_ready) return;
      if(id==CHARTEVENT_CHART_CHANGE) Resize();
      else if(id==CHARTEVENT_MOUSE_MOVE) Mouse((int)lparam,(int)dparam,sparam);
      else if(id==CHARTEVENT_CLICK) Click((int)lparam,(int)dparam);
      else if(id==CHARTEVENT_KEYDOWN) Key((int)lparam);
      Render();
     }
  };
#endif
