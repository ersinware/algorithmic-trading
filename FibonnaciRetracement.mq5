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
   
   MqlRates priceValues[];
   loadPriceValues(priceValues);
   float highestPrice = priceValues[getHighestPriceIndex()].high;
   float lowestPrice = priceValues[getLowestPriceIndex()].low;
   
   float offsetHigh = highestPrice - priceValues[0].high;
   float offsetLow = priceValues[0].low - lowestPrice;
   
   if (offsetHigh > offsetLow) {
      float downtrendRetracement236 = lowestPrice + ((highestPrice - lowestPrice) * 0.236);
      float downtrendRetracement382 = lowestPrice + ((highestPrice - lowestPrice) * 0.382);
      float downtrendRetracement5 = lowestPrice + ((highestPrice - lowestPrice) * 0.5);
      float downtrendRetracement618 = lowestPrice + ((highestPrice - lowestPrice) * 0.618);
      float downtrendRetracement786 = lowestPrice + ((highestPrice - lowestPrice) * 0.786);
      float downtrendRetracement1 = lowestPrice + ((highestPrice - lowestPrice) * 1);
      float downtrendRetracement1618 = lowestPrice + ((highestPrice - lowestPrice) * 1.618);
      Comment("DOWNTREND - 236: " + downtrendRetracement236 + " - 382: " + downtrendRetracement382 + " - 5: " + downtrendRetracement5 + " - 618: " + downtrendRetracement618 + " - 786: " + downtrendRetracement786 + " - 1: " + downtrendRetracement1 + " - 1618: " + downtrendRetracement1618);
   } else {
      float uptrendRetracement236 = highestPrice - ((highestPrice - lowestPrice) * 0.236);
      float uptrendRetracement382 = highestPrice - ((highestPrice - lowestPrice) * 0.382);
      float uptrendRetracement5 = highestPrice - ((highestPrice - lowestPrice) * 0.5);
      float uptrendRetracement618 = highestPrice - ((highestPrice - lowestPrice) * 0.618);
      float uptrendRetracement786 = highestPrice - ((highestPrice - lowestPrice) * 0.786);
      float uptrendRetracement1 = highestPrice - ((highestPrice - lowestPrice) * 1);
      float uptrendRetracement1618 = highestPrice - ((highestPrice - lowestPrice) * 1.618);
      Comment("UPTREND - 236: " + uptrendRetracement236 + " - 382: " + uptrendRetracement382 + " - 5: " + uptrendRetracement5 + " - 618: " + uptrendRetracement618 + " - 786: " + uptrendRetracement786 + " - 1: " + uptrendRetracement1 + " - 1618: " + uptrendRetracement1618);
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

input int fibonacciPeriod = 10;

void loadPriceValues(MqlRates& priceValues[]) {
   ArraySetAsSeries(priceValues, true);
   CopyRates(_Symbol, _Period, 0, fibonacciPeriod, priceValues);
}

int getHighestPriceIndex() {
   double highPrices[];
   ArraySetAsSeries(highPrices, true);
   CopyHigh(_Symbol, _Period, 0, fibonacciPeriod, highPrices);
   
   return ArrayMaximum(highPrices, 0, fibonacciPeriod);
}

int getLowestPriceIndex() {
   double lowPrices[];
   ArraySetAsSeries(lowPrices, true);
   CopyLow(_Symbol, _Period, 0, fibonacciPeriod, lowPrices);
   
   return ArrayMinimum(lowPrices, 0, fibonacciPeriod);
}