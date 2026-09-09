#ifndef CANVAS_GUI_LAYOUT_MQH
#define CANVAS_GUI_LAYOUT_MQH
#include "GuiTheme.mqh"
class CGuiLayout
  {
public:
   int width,height,left,content_width,columns,sidebar;
   bool compact,too_small,dense;
   GuiRect cards[2],apply,status,summary,schedule;
   void Calculate(const int w,const int h,const bool setup=false)
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
      summary.Set(left,bottom+(dense ? 8 : 20),content_width,dense ? 160 : 180);
      int footer=summary.y+summary.h+(dense ? 8 : 24);
      apply.Set(left+content_width-204,footer,204,44);
      status.Set(left,footer,content_width-224,48);
      // Include the footer below the summary in the viewport guard.
      too_small=(w<600 || h<status.y+status.h+8);
      if(setup)
        {
         if(compact)
           {
            int cw=(content_width-32)/3;
            cards[0].Set(left,top,cw,330);
            cards[1].Set(left+cw+16,top,cw,330);
            schedule.Set(left+2*(cw+16),top,content_width-2*(cw+16),330);
           }
         else
           {
            int cw=(content_width-16)/2;
            cards[0].Set(left,top,cw,316);
            cards[1].Set(left+cw+16,top,content_width-cw-16,316);
            schedule.Set(left,top+332,content_width,236);
           }
         int footer=schedule.y+schedule.h+20;
         apply.Set(left+content_width-204,footer,204,44);
         status.Set(left,footer,content_width-224,48);
         too_small=(w<600 || h<status.y+status.h+8);
        }
     }
   void SlotBounds(const int slot,GuiRect &r)
     {
      int w=(cards[0].w-72)/4;
      r.Set(cards[0].x+24+slot*(w+8),cards[0].y+60,w,36);
     }
   void IndicatorBounds(const int indicator,GuiRect &r)
     { r.Set(cards[0].x+24,cards[0].y+136,cards[0].w-48,42); }
   void ParameterBounds(const int card,const int index,GuiRect &r)
     {
      int w=(cards[1].w-64)/2;
      r.Set(cards[1].x+24+(index%2)*(w+16),cards[1].y+90+(index/2)*76,w,42);
     }
  };
#endif
