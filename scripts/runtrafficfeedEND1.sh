#!/bin/bash

commandstorun="mamalistenc -S NYSE -s BAC -tport ota_cta
mamalistenc -S AMEX -s SPY -tport ota_cta
mamalistenc -S AMEX -s GLD -tport ota_ctasm
mamalistenc -S AMEX -s XLV -tport ota_ctasm
mamalistenc -S AMEX -s SCO -tport ota_ctasm
mamalistenc -S NYSE -s BAC -tport ota_ctasm
mamalistenc -S NYSE -s C -tport ota_ctasm
mamalistenc -S NYSE -s ORCL -tport ota_ctasm
mamalistenc -S NYSE -s TWTR -tport ota_ctasm
mamalistenc -S NOTCBB -tport ota_notcbb -s FMCC
mamalistenc -S OTCMKTS -tport ota_otcrealtimeplus -s ANCUF.IQ
mamalistenc -S NASDAQ -s AAPL -tport ota_utp
mamalistenc -S NASDAQ -s AAPL -tport ota_utpsm
mamalistenc -S NASDAQ -s FB -tport ota_utpsm
mamalistenc -S NASDAQ -s QQQ -tport ota_utpsm
mamalistenc -S NASDAQ -s SIRI -tport ota_utpsm
mamalistenc -S OPRAV5 -tport ota_opra -s AAPL__211217C00190000"

echo -e "$commandstorun" 
	
