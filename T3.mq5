float lastT3;

void OnInit() {
   lastT3 = calculateT3(); 
}

input float volumeFactor = 0.7;

//doğru hesaplanıyor mu bilmiyorum
float calculateT3() { 
   float lastEMA = getLastEma();
   
   float alfa = 2 / (emaPeriod + 1);
   
   float valuesForT3[6];
   loadValuesForT3(valuesForT3, alfa, lastEMA);
   
   for (int i = 1; i < valuesForT3.Size(); i++) 
      valuesForT3[i] = alfa *  valuesForT3[i - 1] + (1 - alfa) * lastEMA;
   
   float a = volumeFactor;
   float c1 = -a * a * a;
   float c2 = 3 * a * a + 3 * a * a * a;
   float c3 = -6 * a * a - 3 * a - 3 * a * a * a;
   float c4 = 1 + 3 * a + a * a * a + 3 * a * a;
   
   return (c1 * valuesForT3[5]) + (c2 * valuesForT3[4]) + (c3 * valuesForT3[3]) + (c4 * valuesForT3[2]);
}

input int emaPeriod = 8;

float getLastEma() {
   double emaValues[];
   int emaHandle = iMA(_Symbol, _Period, emaPeriod, 0, MODE_EMA, PRICE_CLOSE);   
   ArraySetAsSeries(emaValues, true);
   CopyBuffer(emaHandle, 0, 0, 2, emaValues);
   
   return emaValues[1];
}

void loadValuesForT3(float& valuesForT3[], float alfa, float lastEMA) {
   for (int i = 0; i < valuesForT3.Size(); i++) 
      valuesForT3[i] = 0;
      
   MqlRates priceValues[];
   loadPriceValues(priceValues);
   float highPrice = priceValues[1].high;
   float lowPrice = priceValues[1].low;
   float closePrice = priceValues[1].close;
      
   valuesForT3[0] = alfa * ((highPrice + lowPrice + 2 * closePrice) / 4) + (1 - alfa) * lastEMA; 
}

void loadPriceValues(MqlRates& priceValues[]) {
   ArraySetAsSeries(priceValues, true);
   CopyRates(_Symbol, _Period, 0, 2, priceValues);
}

input bool runAtNight = true;

#include<Trade\Trade.mqh>
CTrade cTrade;

input double lot = 0.5;

void OnTick() { 
   if(!runAtNight && isNight()) {
      if(PositionSelect(_Symbol)) 
         cTrade.PositionClose(PositionGetTicket(0));
      
      return;
   }
   
   float T3 = calculateT3();
   Comment("T3: " + T3);
   
   ENUM_POSITION_TYPE openPositionType = -1;
   ulong openPositionTicket = 0;
   
   if(PositionSelect(_Symbol)) {
      openPositionType = PositionGetInteger(POSITION_TYPE);
      openPositionTicket = PositionGetTicket(0);     
   }
   
   if(openPositionType != POSITION_TYPE_BUY && T3 > lastT3) {
      if(openPositionTicket) 
         cTrade.PositionClose(openPositionTicket);
         
      cTrade.Buy(lot);
   } else if(openPositionType != POSITION_TYPE_SELL && T3 < lastT3) {
      if(openPositionTicket) 
         cTrade.PositionClose(openPositionTicket);
      
      cTrade.Sell(lot);
   } 
  
   lastT3 = T3;
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