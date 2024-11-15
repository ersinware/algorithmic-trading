int OnInit() {
   OnTick();
   
   return 0;
}

input bool runAtNight = true;

bool firstTime = true;
bool below;

#include<Trade\Trade.mqh>
CTrade cTrade;

input double lot = 0.2;
input double stopLoss = 1500;
input double takeProfit = 4500;

void OnTick() {
   if(!runAtNight && isNight()) {
      if(PositionSelect(_Symbol)) 
         cTrade.PositionClose(PositionGetTicket(0));
      
      return;
   }
   
   float lastPrice = getLastPrice();
   float sarValue = getSarValue();
   
   if (firstTime) {
      below = sarValue < lastPrice;
      firstTime = false;
      
      return;
   }
   
   if (below && sarValue > lastPrice) {
      below = false;
   
      if(PositionSelect(_Symbol))
         cTrade.PositionClose(PositionGetTicket(0));
         
      double sl = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits) + stopLoss * _Point;
      double tp = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits) - takeProfit * _Point;
      
      cTrade.Sell(lot, _Symbol, NULL, sl, tp);
      
      return;
   } 
   
   if (!below && sarValue < lastPrice) {
      below = true;
      
      if(PositionSelect(_Symbol))
         cTrade.PositionClose(PositionGetTicket(0));
      
      double sl = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits) - stopLoss * _Point;
      double tp = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits) + takeProfit * _Point;
      
      cTrade.Buy(lot, _Symbol, NULL, sl, tp);
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

float getLastPrice() {
   MqlRates priceValues[];
   ArraySetAsSeries(priceValues, true);
   CopyRates(_Symbol, _Period, 0, 2, priceValues);
   
   return priceValues[1].close;
}

input double step = 0.02;
input double maximum = 0.2;

float getSarValue() {
   int sarHandle = iSAR(_Symbol, _Period, step, maximum);
   double sarValues[];
   ArraySetAsSeries(sarValues, true);
   CopyBuffer(sarHandle, 0, 0, 1, sarValues);

   return sarValues[0];
}