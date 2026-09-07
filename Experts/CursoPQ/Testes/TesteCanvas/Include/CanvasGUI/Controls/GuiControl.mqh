#ifndef CANVAS_GUI_CONTROL_MQH
#define CANVAS_GUI_CONTROL_MQH
#include "../GuiRenderer.mqh"
class CGuiControl
  {
public:
   GuiRect bounds;
   bool visible,enabled,hover,active,dirty;
   string caption;
   CGuiControl() { visible=true; enabled=true; hover=false; active=false; dirty=true; }
   void SetBounds(const int x,const int y,const int width,const int height) { bounds.Set(x,y,width,height); dirty=true; }
   bool ContainsPoint(const int x,const int y) const { return visible && enabled && bounds.Contains(x,y); }
   bool SetHover(const bool value) { if(hover==value) return false; hover=value; dirty=true; return true; }
   virtual void Draw(CGuiRenderer &r) { dirty=false; }
   void Frame(CGuiRenderer &r) { r.Box(bounds,!enabled ? GUI_DISABLED : (hover ? GUI_HOVER : GUI_CARD),active ? GUI_ACCENT : GUI_BORDER); }
  };
#endif
