#ifndef CANVAS_GUI_SELECT_MQH
#define CANVAS_GUI_SELECT_MQH
#include "GuiControl.mqh"
class CGuiSelectBox : public CGuiControl
  {
private:
   string m_options[];
public:
   int selected,hot,row_height;
   bool indicator_icons;
   GuiRect popup;
   CGuiSelectBox() { selected=0; hot=-1; row_height=30; indicator_icons=false; }
   void SetOptions(const string values) { StringSplit(values,'|',m_options); dirty=true; }
   void SetSelected(const int index) { selected=index; dirty=true; }
   void Open(const int screen_height)
     {
      active=true; hot=selected; dirty=true;
      int h=ArraySize(m_options)*row_height+8;
      int y=bounds.y+bounds.h+4;
      if(y+h>screen_height-8) y=bounds.y-h-4;
      popup.Set(bounds.x,(int)MathMax(4,y),bounds.w,h);
     }
   void Close() { active=false; hot=-1; dirty=true; }
   int OptionAt(const int x,const int y) const
     {
      if(!active || !popup.Contains(x,y) || y<popup.y+4) return -1;
      int index=(y-popup.y-4)/row_height;
      return index<ArraySize(m_options) ? index : -1;
     }
   void MoveHot(const int delta) { hot=(hot+delta+ArraySize(m_options))%ArraySize(m_options); }
   virtual void Draw(CGuiRenderer &r)
     {
      if(visible)
        {
         Frame(r);
         bool show_icon=indicator_icons && selected>0;
         if(show_icon) r.Icon(GUI_ICON_INDICATOR,bounds.x+12,bounds.y+(bounds.h-16)/2,GUI_ACCENT,16);
         int inset=show_icon ? 36 : 12;
         if(selected>=0 && selected<ArraySize(m_options)) r.Text(bounds.x+inset,bounds.y+11,m_options[selected],enabled ? GUI_TEXT : GUI_MUTED,15,false,bounds.w-inset-30);
         r.Chevron(bounds.x+bounds.w-18,bounds.y+bounds.h/2,GUI_MUTED);
        }
      dirty=false;
     }
   // Invoked after ordinary controls: dropdown always owns the top layer.
   void DrawOverlay(CGuiRenderer &r)
     {
      if(!active) return;
      GuiRect shadow; shadow.Set(popup.x+2,popup.y+3,popup.w,popup.h); r.Round(shadow,0xFFE2E7EE);
      r.Box(popup,GUI_CARD,GUI_BORDER);
      for(int i=0;i<ArraySize(m_options);i++)
        {
         GuiRect row; row.Set(popup.x+4,popup.y+4+i*row_height,popup.w-8,row_height);
         if(i==hot || i==selected) r.Round(row,GUI_HOVER,3);
         bool show_icon=indicator_icons && i>0;
         if(show_icon) r.Icon(GUI_ICON_INDICATOR,row.x+8,row.y+7,GUI_ACCENT,16);
         int inset=show_icon ? 32 : 8;
         r.Text(row.x+inset,row.y+6,m_options[i],i==selected ? GUI_ACCENT : GUI_TEXT,14,i==selected,row.w-inset-8);
        }
     }
  };
#endif
