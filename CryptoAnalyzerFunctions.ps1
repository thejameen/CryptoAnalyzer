## CRYPTOANALYZER 
## 
## Instructions 
## 
## 1. Modify Below variables to suit needs
## 2. Right click - Run with Powershell
## 3. Follow instructions


## Display Info
# Data for LTC/USDT - Last Updated : 08/01/2018 18:36:25                   -- shows Currency Pair, and last updated time
# + / -       -3.98                                                        -- shows change (+/-) 
# Last Price  253.50000001 0.0000000% (253.50000000)                       -- 1.shows current "Last Price" ; 2.shows percentage change between current "Last Price" and Previous "Last Price" ; 3.shows previous "Last Price"
# Ask Price   253.99999995 0.0000000% (253.99999995)                       -- 1.shows current "Ask Price" ; 2.shows percentage change between current "Ask Price" and Previous "Ask Price" ; 3.shows previous "Ask Price"
# Bid Price   253.50000001 0.0000000% (253.50000000)                       -- 1.shows current "Bid Price" ; 2.shows percentage change between current "Bid Price" and Previous "Bid Price" ; 3.shows previous "Bid Price"
# Buy Vol     107674457.62786773 0.0000019% (107674459.62786773)           -- 1.shows current "Buy Volume" ; 2.shows percentage change between current "Buy Volume" and Previous "Buy Volume" ; 3.shows previous "Buy Volume"
# Sell Vol    722.70946885 0.2767364% (722.70946885)                       -- 1.shows current "Sell Volume" ; 2.shows percentage change between current "Sell Volume" and Previous "Sell Volume" ; 3.shows previous "Sell Volume"
# Volume      499689.86331688                                              -- Shows Volume
# ----                                                                     -- Timer, dashes equivalent to "SleepDefault" Variable






######### Variables #########


## Amount of time inbetween each API update (Default 15 seconds)

$SleepDefault = 15


## Steps back to reference for previous value (  in 15 seconds intervals - Default 4 (1 minute) )
$HistSteps = 4


## Output Folder Path ( Set this to where you want the output files to be. You will need to create any file structure before runnning )
$OutputFolderPath = "C:\Users\$($ENV:USERNAME)\Documents\CryptoAnalyzer\OutputData\"



######### Functions #########



## API Functions

Function Return-AllUSDTTradePairs {
	$JSON = Invoke-WebRequest "https://www.cryptopia.co.nz/api/GetMarkets"
	$Result = $JSON.Content | ConvertFrom-JSON
	$FinalOutput = $Result.Data | Where-Object {$_.Label -match "USDT"}
	Return $FinalOutput
}


Function Return-USDTTradePair($TradePair) {
	$TradePair = $TradePair.Replace("/","_")
	$JSON = Invoke-WebRequest "https://www.cryptopia.co.nz/api/GetMarket/$TradePair"
	$Result = $JSON.Content | ConvertFrom-JSON
	$FinalOutput = $Result.Data
	Return $FinalOutput
}

## Local Functions

Function Display-AllUSDTTradePairs {
	$Result = Return-AllUSDTTradePairs
	$Result | Select Label, Change, LastPrice, AskPrice, BidPrice, BuyVolume, SellVolume, @{Name="Volume";Expression={$_.BaseVolume}} | Sort-Object Volume -descending | Out-GridView -Title "USDT Trade Pairs : Cryptopia"
}





Function Monitor-TradePair($TradePair)  {
	cls
	$Result = $Null
	$HistResults = @()
	$TradePairOutputFile = $OutputFolderPath + $TradePair.Replace("/","_") + ".csv"
	## Check Output Log folder structure
	if ((Test-Path $TradePairOutputFile) -eq $False) {
		try {
			New-Item -Path $TradePairOutputFile -Type File
		} catch {
			## If Folder Structure not complete, notify and break"
			Write-Host "ERROR:" -ForegroundColor Yellow
			$_.ErrorMessage
			Write-Host "Folder Structure may be missing. Please check" -ForegroundColor Yellow
			#break
		}
	}
	while ($i -lt 999) {
		$LastResult = $HistResults[-$HistSteps]
		$Result = Return-USDTtradePair $TradePair
		$DateTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
		cls
		Write-Host "Data for " -NoNewLine -ForegroundColor Yellow
		Write-Host "$($Result.Label) " -NoNewLine 
		Write-Host "- Last Updated : $DateTime" -ForegroundColor Yellow
		## Output Change 
		Write-Host '+ / -       ' -NoNewLine -ForegroundColor Cyan
		if ($Result.Change -lt $LastResult.Change) {
			Write-Host "$($Result.Change)" -ForegroundColor Red
		} elseif ($Result.Change -gt $Lastresult.Change) {
			Write-host "$($Result.Change)" -ForegroundColor Green
		} else {
			write-Host "$($Result.Change)"
		}
		## Output Last Price
		Write-Host "Last Price  " -NoNewLine -ForegroundColor Cyan 
		if ($Result.LastPrice -lt $LastResult.LastPrice) {
			Write-Host "$($Result.LastPrice)" -ForegroundColor Red -NonewLine
			$ChangeAMT = $LastResult.LastPrice - $Result.LastPrice
		} elseif ($Result.LastPrice -gt $LastResult.LastPrice) {
			Write-Host "$($Result.LastPrice)" -ForegroundColor Green -NoNewLine
			$ChangeAMT = $Result.LastPrice - $LastResult.LastPrice
		} else {
			Write-Host "$($Result.LastPrice)" -NoNewLine
			$ChangeAMT = 0
		}
		Write-Host " $([math]::Round($ChangeAMT / $Result.LastPrice * 100, 7))% ($($LastResult.LastPrice))"
		## Output Ask Price
		Write-Host "Ask Price   " -NoNewLine -ForegroundColor Cyan
		if ($Result.AskPrice -lt $Lastresult.AskPrice) {
			Write-Host "$($Result.AskPrice)" -ForegroundColor Red -NoNewLine
			$ChangeAMT = $LastResult.AskPrice - $Result.AskPrice
		} elseif ($Result.ASkPrice -gt $LastResult.ASkPrice) {
			Write-Host "$($Result.AskPrice)" -ForegroundColor Green -NoNewLine
			$ChangeAMT = $Result.AskPrice - $LastResult.AskPrice
		} else {
			Write-Host "$($Result.ASkPrice)" -NonewLine
		}
		Write-Host " $([math]::Round($ChangeAMT / $Result.AskPrice * 100, 7))% ($($LastResult.AskPrice))"
		## Output Bid Price
		Write-Host "Bid Price   " -NoNewLine -ForegroundColor Cyan
		if ($Result.BidPrice -lt $Lastresult.BidPrice) {
			Write-Host "$($Result.BidPrice)" -ForegroundColor Red -NoNewLine
			$ChangeAMT = $LastResult.BidPrice - $Result.BidPrice
		} elseif ($Result.BidPrice -gt $LastResult.BidPrice) {
			Write-Host "$($Result.BidPrice)" -ForegroundColor Green -NoNewLine
			$ChangeAMT = $Result.BidPrice - $LastResult.BidPrice
		} else {
			Write-Host "$($Result.BidPrice)" -NoNewLine
		}
		Write-Host " $([math]::Round($ChangeAMT / $Result.BidPrice * 100, 7))% ($($LastResult.BidPrice))" 
		## Output Buy Volume
		Write-Host "Buy Vol     " -NoNewLine -ForegroundColor Cyan
		if ($Result.BuyVolume -lt $Lastresult.BuyVolume) {
			Write-Host "$($Result.BuyVolume)" -ForegroundColor Red -NoNewLine
			$ChangeAMT = $LastResult.BuyVolume - $Result.BuyVolume
		} elseif ($Result.BuyVolume -gt $LastResult.BuyVolume) {
			Write-Host "$($Result.BuyVolume)" -ForegroundColor Green -NoNewLine
			$ChangeAMT = $Result.BuyVolume - $LastResult.BuyVolume
		} else {
			Write-Host "$($Result.BuyVolume)" -NoNewLine
		}
		Write-Host " $([math]::Round($ChangeAMT / $Result.BuyVolume * 100, 7))% ($($LastResult.BuyVolume))" 
		## Output Sell Volume
		Write-Host "Sell Vol    " -NoNewLine -ForegroundColor Cyan
		if ($Result.SellVolume -lt $Lastresult.SellVolume) {
			Write-Host "$($Result.SellVolume)" -ForegroundColor Red -NonewLine
			$ChangeAMT = $LastResult.SellVolume - $Result.SellVolume
		} elseif ($Result.SellVolume -gt $LastResult.SellVolume) {
			Write-Host "$($Result.SellVolume)" -ForegroundColor Green -NonewLine
			$ChangeAMT = $Result.SellVolume - $LastResult.SellVolume
		} else {
			Write-Host "$($Result.SellVolume)" -NoNewLine
		}
		Write-Host " $([math]::Round($ChangeAMT / $Result.SellVolume * 100, 7))% ($($LastResult.SellVolume))" 
		## Output Volume
		Write-Host "Volume      " -NoNewLine -ForegroundColor Cyan
		Write-Host "$($Result.BaseVolume)" 
		$SleepTimer = 0
		While ($SleepTimer -lt $SleepDefault) {
			Write-Host "-" -NoNewLine
			Start-Sleep 0.99
			$SleepTimer ++
		}
			$HistResults += $Result
			$Result | Select @{Name="Time";Expression={$DateTime}}, Change, LastPrice, AskPrice, BidPrice, BuyVolume, SellVolume, Volume | Export-CSV -Path $TradePairOutputFile -NoTypeInformation -Append
	}
}


## RUN

Write-Host "#### CRYPTOANALYZER ####"
Write-Host "Please Enter Trade Pair (EG : ETN/USDT)"
$TradePairInput = Read-Host "Trade Pair : "

Monitor-TradePair $TradePairInput



