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
   
   float smaValue = getLastSma();
   float emaValue = getLastEma();
   float lwmaValue = getLastLwma();
   float osmaValue = getLastOsma();
   
   
   Comment("SMA: " + smaValue + " - EMA: " + emaValue + " - LWMA: " + lwmaValue + " - OSMA: " + osmaValue);
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

input int smaPeriod = 7;

float getLastSma() {
   double smaValues[];
   int smaHandle = iMA(_Symbol, _Period, smaPeriod, 0, MODE_SMA, PRICE_CLOSE);   
   ArraySetAsSeries(smaValues, true);
   CopyBuffer(smaHandle, 0, 0, 1, smaValues);
   
   return smaValues[0];
}

input int emaPeriod = 7;

float getLastEma() {
   double emaValues[];
   int emaHandle = iMA(_Symbol, _Period, emaPeriod, 0, MODE_EMA, PRICE_CLOSE);   
   ArraySetAsSeries(emaValues, true);
   CopyBuffer(emaHandle, 0, 0, 1, emaValues);
   
   return emaValues[0];
}

input int lwmaPeriod = 7;

float getLastLwma() {
   double lwmaValues[];
   int lwmaHandle = iMA(_Symbol, _Period, lwmaPeriod, 0, MODE_LWMA, PRICE_CLOSE);   
   ArraySetAsSeries(lwmaValues, true);
   CopyBuffer(lwmaHandle, 0, 0, 1, lwmaValues);
   
   return lwmaValues[0];
}

input int fastEmaPeriod = 12;
input int slowEmaPeriod = 26;
input int signalPeriod = 9;

float getLastOsma() {
   double osmaValues[];
   int osmaHandle = iOsMA(_Symbol, _Period, fastEmaPeriod, slowEmaPeriod, signalPeriod, PRICE_CLOSE);
   
   ArraySetAsSeries(osmaValues, true);
   CopyBuffer(osmaHandle, 0, 0, 1, osmaValues);
   
   return osmaValues[0];
}