int OnInit() {
   OnTick();
   
   return 0;
}

input bool runAtNight = true;

#include<Trade\Trade.mqh>
CTrade cTrade;

input double lot = 0.5;
input float percentage = 0.12;

void OnTick() {
   if(!runAtNight && isNight()) {
      if(PositionSelect(_Symbol)) 
         cTrade.PositionClose(PositionGetTicket(0));
      
      return;
   }
   
   ENUM_POSITION_TYPE openPositionType = -1;
   ulong openPositionTicket = 0;
   
   if(PositionSelect(_Symbol)) {
      openPositionType = PositionGetInteger(POSITION_TYPE);
      openPositionTicket = PositionGetTicket(0);     
   }
   
   MqlRates priceValues[];
   loadPriceValues(priceValues);
   float currentPrice = priceValues[0].close;
   float lastClosePrice = priceValues[1].close;
   
   if(openPositionType != POSITION_TYPE_BUY && currentPrice >= (lastClosePrice + lastClosePrice * percentage / 100)) {
      if(openPositionTicket)
         cTrade.PositionClose(openPositionTicket);
      
      cTrade.Buy(lot);
   } else if(openPositionType != POSITION_TYPE_SELL && currentPrice <= (lastClosePrice - lastClosePrice * percentage / 100)) {
      if(openPositionTicket)
         cTrade.PositionClose(openPositionTicket);
      
      cTrade.Sell(lot);
   } 
} 

input int startRunningTime = 9;
input int stopRunningTime = 18;

bool isNight() {
   MqlDateTime currentTime;
   TimeToStruct(TimeCurrent(), currentTime);
   
   if(currentTime.hour > stopRunningTime || currentTime.hour < startRunningTime) 
      return true;
   
   return false;
}

void loadPriceValues(MqlRates& priceValues[]) {
   ArraySetAsSeries(priceValues, true);
   CopyRates(_Symbol, _Period, 0, 2, priceValues);
}