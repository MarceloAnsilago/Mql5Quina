#ifndef CANVAS_GUI_LAYOUT_MQH
#define CANVAS_GUI_LAYOUT_MQH
#include "GuiTheme.mqh"
class CGuiLayout
  {
public:
   int width,height,left,content_width,columns;
   bool compact,too_small;
   GuiRect cards[2],apply,status;
   void Calculate(const int w,const int h)
     {
      width=w; height=h; compact=(w>=1000 && h<780); columns=compact ? 2 : 4;
      too_small=(w<600 || h<(compact ? 490 : 610));
      content_width=(int)MathMin(w-48,1120); left=(w-content_width)/2;
      if(compact)
        { int cw=(content_width-20)/2; cards[0].Set(left,112,cw,276); cards[1].Set(left+cw+20,112,cw,276); }
      else { cards[0].Set(left,112,content_width,230); cards[1].Set(left,360,content_width,178); }
      int bottom=cards[1].y+cards[1].h;
      apply.Set(left+content_width-148,bottom+24,148,44);
      status.Set(left,bottom+26,content_width-168,48);
     }
   void IndicatorBounds(const int indicator,GuiRect &r)
     { r.Set(cards[0].x+20,cards[0].y+65+indicator*78,cards[0].w-40,40); }
   void ParameterBounds(const int card,const int index,GuiRect &r)
     {
      int w=(cards[1].w-40-(columns-1)*16)/columns;
      r.Set(cards[1].x+20+(index%columns)*(w+16),cards[1].y+75+(index/columns)*78,w,40);
     }
  };
#endif
