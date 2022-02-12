int OnInit() {
   OnTick();
   
   return 0;
}

input bool runAtNight = true;

#include<Trade\Trade.mqh>
CTrade cTrade;

void OnTick() {
    if(!runAtNight && isNight()) {
      if(PositionSelect(_Symbol)) 
         cTrade.PositionClose(PositionGetTicket(0));
      
      return;
   }
   
   float rsiValue = getRsiValue();
   Comment("RSI: " + rsiValue);
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

input int maPeriod = 14;

float getRsiValue() {
   int rsiHandle = iRSI(_Symbol, _Period, maPeriod, PRICE_CLOSE);
   double rsiValues[];
   ArraySetAsSeries(rsiValues, true);
   CopyBuffer(rsiHandle, 0, 0, 1, rsiValues);

   return rsiValues[0];
}
