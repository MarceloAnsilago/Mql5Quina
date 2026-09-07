#ifndef CANVAS_GUI_BUTTON_MQH
#define CANVAS_GUI_BUTTON_MQH
#include "GuiControl.mqh"
class CGuiButton : public CGuiControl
  {
public:
   bool secondary;
   CGuiButton() { secondary=false; }
   virtual void Draw(CGuiRenderer &r)
     {
      if(visible)
        {
         uint bg=!enabled ? GUI_BORDER_DISABLED : (active ? 0xFF163C99 : (hover ? 0xFF1D4ED8 : GUI_ACCENT));
         if(secondary) r.Box(bounds,hover && enabled ? GUI_HOVER : GUI_CARD,GUI_BORDER);
         else r.Round(bounds,bg);
         r.Text(bounds.x+24,bounds.y+(bounds.h-18)/2,caption,!enabled ? GUI_MUTED : (secondary ? GUI_TEXT : GUI_CARD),14,true,bounds.w-36);
        }
      dirty=false;
     }
  };
#endif
