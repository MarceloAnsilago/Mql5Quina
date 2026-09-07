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
   int m_open,m_edit,m_focus;
   int m_active_indicator;
   bool m_summary_dirty,m_summary_draft;
   int m_first_application;
   CGuiButton m_slots[4];
   void DrawSummary()
     {
      GuiRect r=m_layout.summary;
      m_renderer.Box(r,GUI_CARD,GUI_BORDER);
      string heading=m_state.has_applied && !m_summary_draft ? "CONFIGURAÇÃO SALVA / "+IntegerToString(m_first_application+1) : "RESUMO DOS INDICADORES";
      m_renderer.Icon(GUI_ICON_REVIEW,r.x+20,r.y+12,GUI_ACCENT,18);
      m_renderer.Text(r.x+46,r.y+14,heading,GUI_TEXT,13,true,r.w-66);
      int cw=(r.w-40)/4;
      for(int i=0;i<4;i++)
        {
         IndicatorConfig c=m_state.indicators[i];
         if(m_state.has_applied && !m_summary_draft) c=m_state.applications[m_first_application].indicators[i];
         if(c.type==GUI_INDICATOR_NONE) continue;
         bool ma=c.type==GUI_INDICATOR_MA;
         int x=r.x+20+i*cw;
         if(i>0) { GuiRect line; line.Set(x-10,r.y+44,1,r.h-58); m_renderer.Fill(line,GUI_BORDER); }
         m_renderer.Text(x,r.y+44,"INDICADOR "+IntegerToString(i+1),GUI_ACCENT,12,true,cw-16);
         m_renderer.Icon(ma ? GUI_ICON_MA : GUI_ICON_RSI,x,r.y+63,ma ? GUI_MA_COLOR : GUI_RSI_COLOR,16);
         m_renderer.Text(x+22,r.y+63,ma ? "Média Móvel" : "RSI",GUI_TEXT,13,true,cw-38);
         m_renderer.Text(x,r.y+84,"Período: "+IntegerToString(ma ? c.maPeriod : c.rsiPeriod),GUI_TEXT,12,false,cw-16);
         m_renderer.Text(x,r.y+102,"Preço: "+GuiPriceName((int)(ma ? c.maPrice : c.rsiPrice)-1),GUI_MUTED,12,false,cw-16);
         m_renderer.Text(x,r.y+120,ma ? "Método: "+GuiMethodName((int)c.maMethod) : "Inferior: "+DoubleToString(c.rsiLower,2),GUI_MUTED,12,false,cw-16);
         m_renderer.Text(x,r.y+138,ma ? "Shift: "+IntegerToString(c.maShift) : "Superior: "+DoubleToString(c.rsiUpper,2),GUI_MUTED,12,false,cw-16);
        }
     }
   void DrawWindowFrame()
     {
      int w=m_layout.width,h=m_layout.height;
      if(w<4 || h<4) return;
      GuiRect edge;
      edge.Set(0,0,w,4); m_renderer.Fill(edge,GUI_ACCENT);
      edge.Set(0,4,2,h-4); m_renderer.Fill(edge,GUI_WINDOW_BORDER);
      edge.Set(w-2,4,2,h-4); m_renderer.Fill(edge,GUI_WINDOW_BORDER);
      edge.Set(0,h-2,w,2); m_renderer.Fill(edge,GUI_WINDOW_BORDER);
     }
   // Wizard shell is presentation only. Future steps have no hit targets.
   void DrawShell()
     {
      GuiRect r; r.Set(0,0,m_layout.width,76); m_renderer.Fill(r,GUI_CARD);
      r.Set(0,75,m_layout.width,1); m_renderer.Fill(r,GUI_BORDER);
      m_renderer.Text(28,27,"UNIVERSAL EA",GUI_TEXT,19,true);
      if(m_layout.width>=880)
        {
         r.Set(m_layout.width-356,25,8,8); m_renderer.Round(r,0xFF16A085,4);
         m_renderer.Text(m_layout.width-338,22,"CONFIGURAÇÃO",GUI_MUTED,12,true);
        }
      string steps[6]={"Indicadores","Regras","Gestão","Filtros","Revisão","Ativação"};
      if(m_layout.sidebar>0)
        {
         r.Set(0,76,m_layout.sidebar,m_layout.height-76); m_renderer.Fill(r,GUI_CARD);
         r.Set(m_layout.sidebar-1,76,1,m_layout.height-76); m_renderer.Fill(r,GUI_BORDER);
         m_renderer.Text(24,108,"SUA ESTRATÉGIA",GUI_MUTED,11,true);
         for(int i=0;i<6;i++)
           {
            int y=144+i*(m_layout.dense ? 48 : 58);
            if(i==0) { r.Set(12,y-8,m_layout.sidebar-24,44); m_renderer.Round(r,GUI_HOVER); }
            m_renderer.Icon((ENUM_GUI_ICON)i,24,y-2,i==0 ? GUI_ACCENT : GUI_MUTED,20);
            m_renderer.Text(52,y,steps[i],i==0 ? GUI_ACCENT : GUI_MUTED,14,i==0);
           }
         m_renderer.Text(24,m_layout.dense ? 458 : 516,"Etapas 2–6 em breve",GUI_MUTED,11);
        }
      else
        {
         m_renderer.Text(m_layout.left,90,"Indicadores  /  Regras  /  Gestão  /  Filtros  /  Revisão  /  Ativação",GUI_MUTED,12,false,m_layout.content_width);
        }
      int y=m_layout.sidebar>0 ? 92 : (m_layout.dense ? 116 : 130);
      m_renderer.Text(m_layout.left,y,"PASSO 1 DE 6",GUI_ACCENT,12,true);
      if(m_layout.dense)
        {
         m_renderer.Text(m_layout.left,y+21,"Configure os indicadores da sua estratégia",GUI_TEXT,24,true,m_layout.content_width);
         m_renderer.Text(m_layout.left,y+49,"Selecione um dos quatro indicadores e ajuste seus parâmetros.",GUI_MUTED,13,false,m_layout.content_width);
        }
      else
        {
         m_renderer.Text(m_layout.left,y+30,"Configure os indicadores",GUI_TEXT,28,true,m_layout.content_width);
         m_renderer.Text(m_layout.left,y+65,"da sua estratégia",GUI_TEXT,28,true,m_layout.content_width);
         m_renderer.Text(m_layout.left,y+100,"Selecione um dos quatro indicadores e ajuste seus parâmetros.",GUI_MUTED,14,false,m_layout.content_width);
        }
     }
   bool FieldVisible(const int index)
     { return index>=0 && index<20 && index/5==m_active_indicator && (index%5==0 || m_state.indicators[m_active_indicator].type!=GUI_INDICATOR_NONE); }
   bool FocusAvailable(const int id)
     { return id>=0 && id<=10 && (id<4 || id>8 || FieldVisible(m_active_indicator*5+id-4)); }
   void SetFocus(const int id)
     {
      m_focus=id;
      for(int i=0;i<4;i++) { m_slots[i].focused=id==i; m_slots[i].dirty=true; }
      for(int i=0;i<20;i++)
        {
         bool focused=i/5==m_active_indicator && id==4+i%5;
         m_fields[i].select.focused=focused; m_fields[i].select.dirty=true;
         m_fields[i].edit.focused=focused; m_fields[i].edit.dirty=true;
        }
      m_apply.focused=id==9; m_apply.dirty=true;
      m_toggle.focused=id==10; m_toggle.dirty=true;
      m_card_dirty[0]=true; m_card_dirty[1]=true; m_dirty=true;
     }
   void TabFocus(const bool backward)
     {
      if(!FinishEdit(true)) return;
      if(m_open>=0)
        {
         int option=m_fields[m_open].select.hot;
         if(option>=0) SelectOption(option); else CloseSelect();
        }
      int id=m_focus;
      if(id<0) id=backward ? 0 : 10;
      for(int i=0;i<11;i++)
        {
         id=(id+(backward ? 10 : 1))%11;
         if(FocusAvailable(id)) break;
        }
      SetFocus(id);
      if(id>=4 && id<=8)
        {
         int field=m_active_indicator*5+id-4;
         if(!m_fields[field].is_select)
           { m_edit=field; m_fields[field].edit.Begin(); }
        }
     }
   void ActivateFocus()
     {
      GuiRect r;
      if(m_focus>=0 && m_focus<4) r=m_slots[m_focus].bounds;
      else if(m_focus>=4 && m_focus<=8) r=m_fields[m_active_indicator*5+m_focus-4].select.bounds;
      else if(m_focus==9) r=m_apply.bounds;
      else if(m_focus==10) r=m_toggle.bounds;
      else return;
      Click(r.x+r.w/2,r.y+r.h/2);
     }
   void ActivateIndicator(const int indicator)
     {
      if(m_active_indicator==indicator) return;
      m_active_indicator=indicator;
      for(int i=0;i<20;i++) m_fields[i].Hover(false);
      m_card_dirty[0]=true; m_card_dirty[1]=true; m_dirty=true;
     }
   CGuiRenderer m_renderer;
   CGuiLayout m_layout;
   CGuiState m_state;
   CGuiField m_fields[20];
   CGuiButton m_apply;
   CGuiButton m_toggle;
   bool m_collapsed;
   void ToggleInterface()
     {
      // Keep uncommitted text and focus in memory while the chart is visible.
      bool collapse=!m_collapsed;
      int w=collapse ? 176 : (int)ChartGetInteger(m_chart,CHART_WIDTH_IN_PIXELS,0);
      int h=collapse ? 40 : (int)ChartGetInteger(m_chart,CHART_HEIGHT_IN_PIXELS,0);
      if(w<1 || h<1 || !m_renderer.Resize(w,h))
        { Print("[GUI] Falha ao alternar interface: ",GetLastError()); return; }
      CloseSelect();
      m_collapsed=collapse;
      ChartSetInteger(m_chart,CHART_SHOW,collapse ? true : false);
      ChartSetInteger(m_chart,CHART_MOUSE_SCROLL,collapse ? m_old_scroll : false);
      ChartSetInteger(m_chart,CHART_KEYBOARD_CONTROL,collapse ? m_old_keyboard : false);
      m_toggle.hover=false; m_toggle.active=false;
      m_apply.hover=false; m_apply.active=false; m_apply.dirty=true;
      for(int i=0;i<20;i++) m_fields[i].Hover(false);
      if(collapse)
        { m_toggle.caption="EXIBIR INTERFACE"; m_toggle.SetBounds(0,0,176,40); }
      else
        {
         m_layout.Calculate(w,h);
         // Reposition without rebinding: preserve even the current edit buffer.
         for(int i=0;i<20;i++)
           {
            GuiRect r;
            if(i%5==0) m_layout.IndicatorBounds(i/5,r);
            else m_layout.ParameterBounds(i/5,i%5-1,r);
            m_fields[i].label.SetBounds(r.x,r.y-22,r.w,18);
            m_fields[i].edit.SetBounds(r.x,r.y,r.w,r.h);
            m_fields[i].select.SetBounds(r.x,r.y,r.w,r.h);
           }
         GuiRect r=m_layout.apply; m_apply.SetBounds(r.x,r.y,r.w,r.h);
         PlaceToggle();
        }
      m_full=true; m_dirty=true;
      Log(collapse ? "Interface recolhida" : "Interface reexibida");
     }
   void PlaceToggle()
     {
      for(int i=0;i<4;i++)
        {
         GuiRect r; m_layout.SlotBounds(i,r);
         m_slots[i].caption=IntegerToString(i+1);
         m_slots[i].SetBounds(r.x,r.y,r.w,r.h);
        }
      m_toggle.caption="Recolher"; m_toggle.secondary=true;
      m_toggle.SetBounds((int)MathMax(0,m_layout.width-172),m_layout.too_small ? 110 : 18,148,40);
     }
   void Log(const string value) { if(m_debug) Print("[GUI] ",value); }
   void Status(const string value,const bool error=false)
     { m_message=value; m_error=error; m_status_dirty=true; m_dirty=true; }
   void BindField(const int card,const int slot,const ENUM_GUI_FIELD key,const string title,const string options="")
     {
      GuiRect r;
      if(slot==0) m_layout.IndicatorBounds(card,r); else m_layout.ParameterBounds(card,slot-1,r);
      m_fields[card*5+slot].Bind(m_state,card,key,title,r,options);
      m_fields[card*5+slot].select.indicator_icons=(key==GUI_TYPE);
     }
   void BuildIndicator(const int card)
     {
      BindField(card,0,GUI_TYPE,"Indicador","Não usar|Média Móvel|RSI");
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
      m_card_dirty[0]=true; m_card_dirty[1]=true; m_dirty=true;
     }
   void Reflow()
     {
      for(int i=0;i<4;i++) BuildIndicator(i);
      GuiRect r=m_layout.apply; m_apply.SetBounds(r.x,r.y,r.w,r.h);
      PlaceToggle();
      SetFocus(FocusAvailable(m_focus) ? m_focus : -1);
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
      m_fields[i].edit.End(); m_edit=-1; m_dirty=true; m_summary_dirty=true;
      if(save) m_summary_draft=true;
      Status(save ? "Valor atualizado. Salve para registrar." : "Edição cancelada.");
      return true;
     }
   void SelectOption(const int option)
     {
      if(m_open<0 || option<0) return;
      int i=m_open,card=m_fields[i].card;
      bool changed=m_fields[i].select.selected!=option;
      m_state.Choose(card,m_fields[i].field,option);
      m_fields[i].select.SetSelected(option); CloseSelect();
      if(m_fields[i].field==GUI_TYPE) ActivateIndicator(card);
      if(changed && m_fields[i].field==GUI_TYPE)
        {
         BuildIndicator(card);
         Log(StringFormat("Indicator%d alterado para %s",card+1,option==0 ? "Não usar" : (option==1 ? "Média Móvel" : "RSI")));
        }
      SetFocus(4+i%5);
      if(changed) { m_summary_dirty=true; m_summary_draft=true; }
      if(changed) Status("Configuração alterada. Salve para registrar.");
     }
   void Click(const int x,const int y)
     {
      if(m_toggle.ContainsPoint(x,y)) { SetFocus(10); ToggleInterface(); return; }
      if(m_collapsed) return;
      if(m_layout.too_small) return;
      if(m_apply.active) { m_apply.active=false; m_apply.dirty=true; m_dirty=true; }
      if(m_open>=0)
        {
         int option=m_fields[m_open].select.OptionAt(x,y);
         if(option>=0) { SelectOption(option); return; }
         bool same=m_fields[m_open].ContainsPoint(x,y);
         CloseSelect(); if(same) return;
        }
      for(int slot=0;slot<4;slot++)
         if(m_slots[slot].ContainsPoint(x,y))
           {
            if(!FinishEdit(true)) return;
            ActivateIndicator(slot); SetFocus(slot);
            Status("Editando indicador "+IntegerToString(slot+1)+".");
            return;
           }
      int hit=-1;
      for(int i=0;i<20;i++) if(FieldVisible(i) && m_fields[i].ContainsPoint(x,y)) { hit=i; break; }
      if(hit==m_edit && m_edit>=0) return;
      if(!FinishEdit(true)) return;
      if(hit>=0)
        {
         SetFocus(4+hit%5);
         if(m_fields[hit].field==GUI_TYPE) ActivateIndicator(m_fields[hit].card);
         if(m_fields[hit].is_select)
           { m_open=hit; m_fields[hit].select.Open(m_layout.height); Log("Select aberto"); }
         else
           { m_edit=hit; m_fields[hit].edit.Begin(); Status("Digite o valor. Enter salva; Esc cancela."); }
         m_dirty=true;
        }
      else if(m_apply.ContainsPoint(x,y))
        {
         SetFocus(9);
         if(!m_state.Apply()) { Status("Não foi possível guardar a aplicação.",true); return; }
         m_first_application=(int)MathMax(0,ArraySize(m_state.applications)-1);
         m_summary_dirty=true; m_summary_draft=false;
         m_state.PrintConfiguration(); Status("Os quatro indicadores foram salvos no histórico."); Log("Configuração aplicada");
        }
     }
   void Mouse(const int x,const int y,const string flags)
     {
      if(m_toggle.SetHover(m_toggle.ContainsPoint(x,y))) m_dirty=true;
      bool toggle_down=((StringToInteger(flags)&1)!=0 && m_toggle.hover);
      if(toggle_down!=m_toggle.active) { m_toggle.active=toggle_down; m_toggle.dirty=true; m_dirty=true; }
      if(m_collapsed) return;
      if(m_layout.too_small) return;
      bool overlay=(m_open>=0 && m_fields[m_open].select.popup.Contains(x,y));
      for(int slot=0;slot<4;slot++)
         if(m_slots[slot].SetHover(!overlay && m_slots[slot].ContainsPoint(x,y)))
           { m_card_dirty[0]=true; m_dirty=true; }
      for(int i=0;i<20;i++) if(m_fields[i].Hover(FieldVisible(i) && !overlay && m_fields[i].ContainsPoint(x,y))) m_dirty=true;
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
      if(m_collapsed)
        { if(key==13 || key==32) ToggleInterface(); return; }
      if(m_layout.too_small) return;
      if(key==9)
        {
         TabFocus((TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT)&0x8000)!=0);
         return;
        }
      if(m_open>=0)
        {
         if(key==27) CloseSelect();
         else if(key==38 || key==40) { m_fields[m_open].select.MoveHot(key==38 ? -1 : 1); m_dirty=true; }
         else if(key==13) SelectOption(m_fields[m_open].select.hot);
         return;
        }
      if(m_edit>=0)
        {
         if(key==27) { FinishEdit(false); return; }
         if(key==13) { FinishEdit(true); return; }
         if(m_fields[m_edit].edit.Key(key)) { m_dirty=true; if(m_error) Status("Digite o valor. Enter salva; Esc cancela."); }
         return;
        }
      if(key==13 || key==32) { ActivateFocus(); return; }
      if(m_focus>=4 && m_focus<=8)
        {
         int field=m_active_indicator*5+m_focus-4;
         if(m_fields[field].is_select)
           { if(key==38 || key==40) ActivateFocus(); }
         else if((key>=48 && key<=57) || (key>=96 && key<=105) || key==189 || key==109 || key==8 || key==46 || key==190 || key==188 || key==110)
           {
            m_edit=field; m_fields[field].edit.Begin();
            m_fields[field].edit.Key(key); m_dirty=true;
           }
        }
     }
   void Resize()
     {
      // The small launcher does not depend on chart size. Reopen reads it anew.
      if(m_collapsed) return;
      int w=(int)ChartGetInteger(m_chart,CHART_WIDTH_IN_PIXELS,0);
      int h=(int)ChartGetInteger(m_chart,CHART_HEIGHT_IN_PIXELS,0);
      if(w<1 || h<1 || (w==m_layout.width && h==m_layout.height)) return;
      if(!m_renderer.Resize(w,h)) { Print("[GUI] Falha ao redimensionar Canvas: ",GetLastError()); return; }
      CloseSelect();
      if(!FinishEdit(true)) { FinishEdit(false); Status("Edição inválida descartada ao redimensionar.",true); }
      m_layout.Calculate(w,h); Reflow(); Log(StringFormat("Canvas redimensionado: %dx%d",w,h));
     }
public:
   CGuiApp() { m_ready=false; m_saved=false; m_dirty=false; m_open=-1; m_edit=-1; m_focus=-1; m_error=false; m_collapsed=false; m_active_indicator=0; m_summary_dirty=false; m_summary_draft=true; m_first_application=0; }
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
      m_layout.Calculate(w,h); m_apply.caption="Salvar indicadores";
      m_ready=true; Reflow(); Status("Selecione o indicador que deseja configurar."); Render();
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
      if(m_collapsed)
        {
         if(m_full) m_renderer.Clear();
         m_toggle.Draw(m_renderer); m_renderer.Present();
         m_full=false; m_dirty=false; return;
        }
      m_renderer.RestoreOverlay();
      if(m_full)
        {
         m_renderer.Clear();
         if(m_layout.too_small)
           {
            m_renderer.Text(24,32,"Amplie a área do gráfico",GUI_TEXT,22,true);
            m_renderer.Text(24,72,"Área atual: "+IntegerToString(m_layout.width)+" x "+IntegerToString(m_layout.height)+". Altura necessária: "+IntegerToString(m_layout.status.y+m_layout.status.h+8)+" px.",GUI_MUTED,14,false,(int)MathMax(60,m_layout.width-48));
           }
         else
           {
            DrawShell();
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
               GuiRect c=m_layout.cards[card];
               string title=card==0 ? "INDICADORES" : "PARÂMETROS / INDICADOR "+IntegerToString(m_active_indicator+1);
               if(card==0 || m_state.indicators[m_active_indicator].type!=GUI_INDICATOR_NONE)
                  {
                   m_renderer.Icon(card==0 ? GUI_ICON_INDICATORS : GUI_ICON_PARAMETERS,c.x+24,c.y+12,GUI_ACCENT,20);
                   m_renderer.Text(c.x+52,c.y+14,title,GUI_TEXT,14,true,c.w-76);
                  }
               if(card==0)
                 {
                  m_renderer.Text(c.x+24,c.y+38,"Qual indicador deseja configurar?",GUI_MUTED,12,false,c.w-48);
                  for(int slot=0;slot<4;slot++)
                    {
                     m_slots[slot].secondary=slot!=m_active_indicator;
                     m_slots[slot].Draw(m_renderer);
                    }
                 }
               else if(m_state.indicators[m_active_indicator].type!=GUI_INDICATOR_NONE)
                 {
                  bool ma=m_state.indicators[m_active_indicator].type==GUI_INDICATOR_MA;
                  m_renderer.Icon(ma ? GUI_ICON_MA : GUI_ICON_RSI,c.x+24,c.y+38,ma ? GUI_MA_COLOR : GUI_RSI_COLOR,16);
                  m_renderer.Text(c.x+46,c.y+38,m_state.indicators[m_active_indicator].type==GUI_INDICATOR_MA ? "Média Móvel" : "RSI",GUI_ACCENT,14,true,c.w-70);
                 }
              }
            if(card==0) m_fields[m_active_indicator*5].Draw(m_renderer,all);
            else if(m_state.indicators[m_active_indicator].type!=GUI_INDICATOR_NONE) for(int j=1;j<5;j++) m_fields[m_active_indicator*5+j].Draw(m_renderer,all);
           }
         if(m_full || m_apply.dirty) m_apply.Draw(m_renderer);
         if(m_full || m_summary_dirty) DrawSummary();
         if(m_full || m_status_dirty)
           {
            m_renderer.Fill(m_layout.status,GUI_BG);
            m_renderer.Text(m_layout.status.x,m_layout.status.y,m_message,m_error ? GUI_ERROR : GUI_MUTED,13,false,m_layout.status.w);
            m_renderer.Text(m_layout.status.x,m_layout.status.y+22,"Próxima etapa: Regras · em breve",GUI_MUTED,11);
           }
         if(m_open>=0) { m_renderer.SaveOverlay(m_fields[m_open].select.popup); m_fields[m_open].select.DrawOverlay(m_renderer); }
        }
      if(m_full || m_toggle.dirty) m_toggle.Draw(m_renderer);
      DrawWindowFrame();
      m_renderer.Present();
      m_full=false; m_card_dirty[0]=false; m_card_dirty[1]=false; m_status_dirty=false; m_summary_dirty=false; m_dirty=false;
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
