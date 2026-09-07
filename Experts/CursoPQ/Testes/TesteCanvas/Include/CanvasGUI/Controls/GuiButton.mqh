#ifndef CANVAS_GUI_BUTTON_MQH
#define CANVAS_GUI_BUTTON_MQH
#include "GuiControl.mqh"
class CGuiButton : public CGuiControl
  {
public:
   virtual void Draw(CGuiRenderer &r)
     {
      if(visible)
        {
         uint bg=!enabled ? GUI_BORDER_DISABLED : (active ? 0xFF163C99 : (hover ? 0xFF1D4ED8 : GUI_ACCENT));
         r.Round(bounds,bg);
         r.Text(bounds.x+24,bounds.y+(bounds.h-18)/2,caption,GUI_CARD,15,true,bounds.w-36);
        }
      dirty=false;
     }
  };
#endif
