#ifndef CANVAS_GUI_SETUP_PAGE_MQH
#define CANVAS_GUI_SETUP_PAGE_MQH
#include "GuiSetupState.mqh"
#include "GuiLayout.mqh"
#include "Controls/GuiLabel.mqh"
#include "Controls/GuiTextField.mqh"
#include "Controls/GuiSelectBox.mqh"
#include "Controls/GuiButton.mqh"

// The first step reuses Canvas controls; indicator editing keeps its own bindings.
class CGuiSetupPage
  {
private:
   CGuiLabel m_labels[5];
   CGuiTextField m_text[2];
   CGuiSelectBox m_select[3];
   CGuiButton m_continue;
   GuiRect m_cards[2],m_status;
   int m_open,m_edit,m_focus,m_height;
   bool m_dirty,m_error;
   string m_message;
   void Status(const string message,const bool error=false)
     { m_message=message; m_error=error; m_dirty=true; }
   void Focus(const int index)
     {
      m_focus=index;
      for(int i=0;i<2;i++) { m_text[i].focused=index==i; m_text[i].dirty=true; }
      for(int i=0;i<3;i++) { m_select[i].focused=index==i+2; m_select[i].dirty=true; }
      m_continue.focused=index==5; m_continue.dirty=true; m_dirty=true;
     }
   void SelectOption(const int option)
     {
      if(m_open<0 || option<0) return;
      if(state.Choose(m_open+2,option))
        { m_select[m_open].SetSelected(option); Status("Configuração atualizada."); }
      CloseSelect();
     }
   void Begin(const int index)
     {
      Focus(index);
      if(index<2) { m_edit=index; m_text[index].Begin(); Status("Tab avança; Enter confirma; Esc cancela."); }
      else if(index<5) { m_open=index-2; m_select[m_open].Open(m_height); }
     }
public:
   CGuiSetupState state;
   CGuiSetupPage() { m_open=-1; m_edit=-1; m_focus=-1; m_dirty=true; m_error=false; }
   void Create(const ENUM_TIMEFRAMES chart_period)
     {
      state.Reset(chart_period);
      m_labels[0].caption="Nome do setup (opcional)";
      m_labels[1].caption="Magic Number";
      m_labels[2].caption="Mercado";
      m_labels[3].caption="Timeframe da estratégia";
      m_labels[4].caption="Direção permitida";
      m_text[0].text_mode=true; m_text[0].max_length=48;
      m_text[1].max_length=10;
      for(int i=0;i<2;i++) m_text[i].SetValue(state.Value(i));
      m_select[0].SetOptions("Forex|B3");
      m_select[1].SetOptions(GuiSetupTimeframeOptions());
      m_select[2].SetOptions("Compra e venda|Somente compra|Somente venda");
      for(int i=0;i<3;i++) m_select[i].SetSelected(state.Choice(i+2));
      m_continue.caption="Continuar  >";
      Status("Defina a identificação e as preferências do setup.");
     }
   void Place(CGuiLayout &layout)
     {
      m_cards[0]=layout.cards[0]; m_cards[1]=layout.cards[1];
      m_status=layout.status; m_height=layout.height;
      for(int i=0;i<5;i++)
        {
         GuiRect c=m_cards[i<2 ? 0 : 1];
         int row=i<2 ? i : i-2;
         int y=c.y+78+row*76;
         m_labels[i].SetBounds(c.x+24,y-22,c.w-48,18);
         if(i<2) m_text[i].SetBounds(c.x+24,y,c.w-48,42);
         else m_select[i-2].SetBounds(c.x+24,y,c.w-48,42);
        }
      GuiRect r=layout.apply; m_continue.SetBounds(r.x,r.y,r.w,r.h);
      m_dirty=true;
     }
   bool Dirty() { return m_dirty; }
   void CloseSelect()
     { if(m_open>=0) { m_select[m_open].Close(); m_open=-1; m_dirty=true; } }
   void ClearHover()
     {
      for(int i=0;i<2;i++) m_text[i].SetHover(false);
      for(int i=0;i<3;i++) m_select[i].SetHover(false);
      m_continue.SetHover(false); m_continue.active=false; m_dirty=true;
     }
   bool Finish(const bool save)
     {
      if(m_edit<0) return true;
      int index=m_edit;
      if(save)
        {
         string error;
         if(!state.CommitText(index,m_text[index].Buffer(),error))
           { m_text[index].invalid=true; m_text[index].dirty=true; Status(error,true); return false; }
         m_text[index].SetValue(state.Value(index));
        }
      m_text[index].End(); m_edit=-1;
      Status(save ? "Configuração atualizada." : "Edição cancelada.");
      return true;
     }
   bool Ready()
     {
      if(!Finish(true)) return false;
      string error;
      if(!state.Validate(error)) { Status(error,true); return false; }
      CloseSelect(); return true;
     }
   bool Click(const int x,const int y)
     {
      if(m_open>=0)
        {
         int option=m_select[m_open].OptionAt(x,y);
         if(option>=0) { SelectOption(option); return false; }
         bool same=m_select[m_open].ContainsPoint(x,y);
         CloseSelect(); if(same) return false;
        }
      int hit=-1;
      for(int i=0;i<2;i++) if(m_text[i].ContainsPoint(x,y)) hit=i;
      for(int i=0;i<3;i++) if(m_select[i].ContainsPoint(x,y)) hit=i+2;
      if(hit==m_edit && m_edit>=0) return false;
      if(!Finish(true)) return false;
      if(hit>=0) Begin(hit);
      else if(m_continue.ContainsPoint(x,y)) { Focus(5); return Ready(); }
      return false;
     }
   void Mouse(const int x,const int y,const string flags)
     {
      bool overlay=m_open>=0 && m_select[m_open].popup.Contains(x,y);
      for(int i=0;i<2;i++) if(m_text[i].SetHover(!overlay && m_text[i].ContainsPoint(x,y))) m_dirty=true;
      for(int i=0;i<3;i++) if(m_select[i].SetHover(!overlay && m_select[i].ContainsPoint(x,y))) m_dirty=true;
      if(m_continue.SetHover(!overlay && m_continue.ContainsPoint(x,y))) m_dirty=true;
      bool down=(StringToInteger(flags)&1)!=0 && m_continue.hover;
      if(down!=m_continue.active) { m_continue.active=down; m_dirty=true; }
      if(m_open>=0)
        {
         int hot=m_select[m_open].OptionAt(x,y);
         if(hot!=m_select[m_open].hot) { m_select[m_open].hot=hot; m_dirty=true; }
        }
     }
   // Return 1 to advance, 2 to focus the shared Recolher button.
   int Key(const int key)
     {
      if(key==9)
        {
         if(!Finish(true)) return 0;
         if(m_open>=0) { int option=m_select[m_open].hot; if(option>=0) SelectOption(option); else CloseSelect(); }
         bool back=(TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT)&0x8000)!=0;
         int next=m_focus<0 ? (back ? 5 : 0) : m_focus+(back ? -1 : 1);
         if(next<0 || next>5) { Focus(-1); return 2; }
         Focus(next);
         if(next<2) { m_edit=next; m_text[next].Begin(); }
         return 0;
        }
      if(m_open>=0)
        {
         if(key==27) CloseSelect();
         else if(key==38 || key==40) { m_select[m_open].MoveHot(key==38 ? -1 : 1); m_dirty=true; }
         else if(key==13) SelectOption(m_select[m_open].hot);
         return 0;
        }
      if(m_edit>=0)
        {
         if(key==27) Finish(false);
         else if(key==13) Finish(true);
         else if(m_text[m_edit].Key(key)) { m_dirty=true; if(m_error) Status("Tab avança; Enter confirma; Esc cancela."); }
         return 0;
        }
      if(m_focus<0) return 0;
      if(key==13 || key==32)
        { if(m_focus==5) return Ready() ? 1 : 0; Begin(m_focus); return 0; }
      if(m_focus<2)
        {
         // Ignore modifier keys until a printable/editing key arrives.
         if(key==16 || key==17 || key==18 || key==20) return 0;
         Begin(m_focus); if(m_text[m_edit].Key(key)) m_dirty=true;
        }
      else if(m_focus<5 && (key==38 || key==40)) Begin(m_focus);
      return 0;
     }
   void EnterFocus(const bool last)
     {
      if(!Finish(true)) { Focus(m_edit); return; }
      Focus(last ? 5 : 0);
      if(!last) { m_edit=0; m_text[0].Begin(); }
     }
   void Render(CGuiRenderer &r,const bool full)
     {
      if(!full && !m_dirty) return;
      for(int card=0;card<2;card++)
        {
         GuiRect c=m_cards[card]; r.Box(c,GUI_CARD,GUI_BORDER);
         r.Icon(card==0 ? GUI_ICON_REVIEW : GUI_ICON_PARAMETERS,c.x+24,c.y+18,GUI_ACCENT,20);
         r.Text(c.x+52,c.y+20,card==0 ? "IDENTIFICAÇÃO" : "MERCADO E OPERAÇÃO",GUI_TEXT,14,true,c.w-76);
        }
      for(int i=0;i<5;i++)
        { m_labels[i].Draw(r); if(i<2) m_text[i].Draw(r); else m_select[i-2].Draw(r); }
      r.Text(m_cards[0].x+24,m_cards[0].y+211,"Magic Number identifica as ordens deste setup.",GUI_MUTED,12,false,m_cards[0].w-48);
      r.Fill(m_status,GUI_BG);
      r.Text(m_status.x,m_status.y,m_message,m_error ? GUI_ERROR : GUI_MUTED,13,false,m_status.w);
      r.Text(m_status.x,m_status.y+24,"Próxima etapa: Indicadores",GUI_MUTED,11,false,m_status.w);
      m_continue.Draw(r);
      m_dirty=false;
     }
   void DrawOverlay(CGuiRenderer &r)
     { if(m_open>=0) { r.SaveOverlay(m_select[m_open].popup); m_select[m_open].DrawOverlay(r); } }
  };
#endif
