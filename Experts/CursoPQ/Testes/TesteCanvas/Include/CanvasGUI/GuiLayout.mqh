#ifndef CANVAS_GUI_LAYOUT_MQH
#define CANVAS_GUI_LAYOUT_MQH
#include "GuiTheme.mqh"
class CGuiLayout
  {
public:
   int width,height,left,content_width,columns,sidebar;
   bool compact,too_small,dense;
   GuiRect cards[2],apply,status,summary;
   void Calculate(const int w,const int h)
     {
      width=w; height=h; compact=(w>=960); columns=2;
      dense=h<(compact ? (w>=1120 ? 794 : 832) : 1144);
      sidebar=w>=1120 ? 196 : 0;
      content_width=(int)MathMin(w-sidebar-48,1120);
      left=sidebar+(w-sidebar-content_width)/2;
      int top=dense ? (sidebar>0 ? 160 : 184) : (sidebar>0 ? 222 : 260);
      int card_height=dense ? 236 : 292;
      int gap=dense ? 16 : 20;
      if(compact)
        {
         int cw=(content_width-24)/2;
         cards[0].Set(left,top,cw,card_height);
         cards[1].Set(left+cw+24,top,cw,card_height);
        }
      else
        {
         cards[0].Set(left,top,content_width,card_height);
         cards[1].Set(left,top+card_height+gap,content_width,card_height);
        }
      int bottom=cards[1].y+cards[1].h;
      apply.Set(left+content_width-204,bottom+(dense ? 12 : 24),204,44);
      status.Set(left,bottom+(dense ? 12 : 28),content_width-224,48);
      summary.Set(left,bottom+(dense ? 64 : 92),content_width,dense ? 160 : 180);
      // Guard actual content bounds, not an arbitrary desktop resolution.
      too_small=(w<600 || h<summary.y+summary.h+8);
     }
   void IndicatorBounds(const int indicator,GuiRect &r)
     { r.Set(cards[indicator].x+24,cards[indicator].y+(dense ? 56 : 72),cards[indicator].w-48,dense ? 36 : 42); }
   void ParameterBounds(const int card,const int index,GuiRect &r)
     {
      int w=(cards[card].w-64)/2;
      r.Set(cards[card].x+24+(index%2)*(w+16),cards[card].y+(dense ? 118 : 148)+(index/2)*(dense ? 62 : 76),w,dense ? 36 : 42);
     }
  };
#endif
