#include "protheus.ch"
#include "SHELL.CH"
#include "topconn.ch" 

/*
Funcao      : RGTIS001
Parametros  : 
Retorno     : 
Objetivos   : Consolidação contabil ( apenas para três empresas YS, Y5 e YG )   
Autor       : Matheus Massarotto
Data/Hora   : 01/12/2011
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Contabil.
*/

*-----------------------*
  User function RGTIS001   
*-----------------------*


Private cHtml:=""
Private cArq  := ""
Private cDest :=  GetTempPath()
Private aCabEsq:={{"1","ASSETS",.F.},{"2","LIABILITIES",.F.},{"","",.T.}}
Private cHtmlL1:=""
Private cHtmlD1:=""
Private cHtmlD2:=""
Private cHtmlD3:=""
Private cHtmlD4:=""
Private nSeq:=1
Private cPerg:="P_RGTIS001"

Private aDadTemp:={}
Private aDadSald:={}
Private aContas:={}

Private aTot:={}
Private	nValA1:=0
Private	nValB1:=0
Private	nValC1:=0
Private	nValD1:=0
Private	nValA2:=0
Private	nValB2:=0
Private	nValC2:=0
Private	nValD2:=0
Private	nValA3:=0
Private	nValB3:=0
Private	nValC3:=0
Private	nValD3:=0
Private	nValA4:=0
Private	nValB4:=0
Private	nValC4:=0
Private	nValD4:=0


AADD(aDadTemp,{"CONTA","C",20,0})
AADD(aDadTemp,{"DESC","C",80,0})
AADD(aDadTemp,{"SLDANT1","N",17,2})
AADD(aDadTemp,{"DEBITO1","N",17,2})
AADD(aDadTemp,{"CREDITO1","N",17,2})
AADD(aDadTemp,{"SLDPOS1","N",17,2})
AADD(aDadTemp,{"SLDANT2","N",17,2})
AADD(aDadTemp,{"DEBITO2","N",17,2})
AADD(aDadTemp,{"CREDITO2","N",17,2})
AADD(aDadTemp,{"SLDPOS2","N",17,2})
AADD(aDadTemp,{"SLDANT3","N",17,2})
AADD(aDadTemp,{"DEBITO3","N",17,2})
AADD(aDadTemp,{"CREDITO3","N",17,2})
AADD(aDadTemp,{"SLDPOS3","N",17,2})


AADD(aDadSald,{"CONTA","C",20,0})
AADD(aDadSald,{"SLDANT1","N",17,2})
AADD(aDadSald,{"SLDANT2","N",17,2})
AADD(aDadSald,{"SLDANT3","N",17,2})

//-----------------------------------CONTAS---------------------------------------------------------
AADD(aContas,{.T.,"ASSETS","",""})
AADD(aContas,{.F.,"Cash","10350000","Operating Cash"})
AADD(aContas,{.F.,"Cash","10550000","Cash - Short term investment"})

AADD(aContas,{.F.,"Receivables","11600000","Accounts Receivable - Sales"})
AADD(aContas,{.F.,"Receivables","11600002","Accounts Receivable - Trade/Other"})
AADD(aContas,{.F.,"Receivables","11600003","Accounts Receivable / Accounts Payable - Intercompany Operations"})

AADD(aContas,{.F.,"Prepaid Expenses","12200000","Prepaid Insurance - Properties"})
AADD(aContas,{.F.,"Prepaid Expenses","12300000","Prepaid Development Fee"})
AADD(aContas,{.F.,"Prepaid Expenses","12400000","Prepaid Other Expenses - (Prop)"})
AADD(aContas,{.F.,"Prepaid Expenses","12400001","Prepaid Construction & Project Costs"})
AADD(aContas,{.F.,"Prepaid Expenses","12500001","Prepaid Taxes"})

AADD(aContas,{.F.,"Real Estate Investments","14050000","Land Basis - Original Cost"})
AADD(aContas,{.F.,"Real Estate Investments","14100000","Land Improvement"})
AADD(aContas,{.F.,"Real Estate Investments","14200000","Investment in a Subsidiary"})
AADD(aContas,{.F.,"Real Estate Investments","14250000","Equity Method Adjustment"})
AADD(aContas,{.F.,"Real Estate Investments","14300000","Construction In Progress"})
AADD(aContas,{.F.,"Real Estate Investments","14350000","Building Improvements - CEPACs"})

AADD(aContas,{.F.,"Fixed Assets","15100000","Fixed Assets"})
AADD(aContas,{.F.,"Fixed Assets","15200000","Fixed Assets - Depreciation"})

AADD(aContas,{.F.,"Intangible Assets","17300000","Goodwill"})
AADD(aContas,{.F.,"Intangible Assets","17400000","Amortization of Goodwill"})

AADD(aContas,{.T.,"LIABILITIES","",""})

AADD(aContas,{.F.,"Accounts Payable & Accrued Expenses","20150000","Accrued - Insurance - Properties"})
AADD(aContas,{.F.,"Accounts Payable & Accrued Expenses","20200000","Accrued - Real Estate Tax - Properties"})
AADD(aContas,{.F.,"Accounts Payable & Accrued Expenses","20450000","Accounts Payable - Construction & Project Costs"})
AADD(aContas,{.F.,"Accounts Payable & Accrued Expenses","20460000","Accounts Payable - Installments"})
AADD(aContas,{.F.,"Accounts Payable & Accrued Expenses","20470000","Accounts Payable - Income Tax"})
AADD(aContas,{.F.,"Accounts Payable & Accrued Expenses","20480000","Accounts Payable - Contingency"})
AADD(aContas,{.F.,"Accounts Payable & Accrued Expenses","20600000","Accrued - Other"})
AADD(aContas,{.F.,"Accounts Payable & Accrued Expenses","20600001","Accounts Payable - Intercompany Operations"})

AADD(aContas,{.F.,"Deferred Income","21550000","Deferred Miscellaneous - Properties"})

AADD(aContas,{.F.,"Tenant Deposits","22100000","Security Deposits - Properties - Liability"})

AADD(aContas,{.F.,"Equity","30400000","Common Stock"})
AADD(aContas,{.F.,"Equity","33100000","Contributions"})
AADD(aContas,{.F.,"Equity","30100000","Partners Equity - Properties"})
AADD(aContas,{.F.,"Equity","30150000","Distributions"})
//AADD(aContas,{.F.,"Equity","","GTIS Brasil São Bento LP"})
//AADD(aContas,{.F.,"Equity","","GTIS Brasil São Bento LLC"})
//AADD(aContas,{.F.,"Equity","","GTIS São Bento Participações Ltda"})

//AADD(aContas,{.F.,"Equity","","TOTAL WORKING CAPITAL"})

AADD(aContas,{.F.,"Realized Gains & Losses","33500000","Income - Net Realized Gain (Loss)"})

AADD(aContas,{.T.,"----------------------------------------------","",""})

AADD(aContas,{.F.,"Revenue","44300000","Sales Revenue - Options"})
AADD(aContas,{.F.,"Revenue","58750030","Taxes – Brazilian Sales Tax (PIS/COFINS)"})
AADD(aContas,{.F.,"Revenue","58750040","Taxes – Brazilian Sales Tax (IR)"})
AADD(aContas,{.F.,"Revenue","58750050","Taxes – Brazilian Sales Tax (CSLL)"})
//AADD(aContas,{.F.,"Revenue","","Taxes – Brazilian Sales Tax (RET)"})

AADD(aContas,{.F.,"Rental Income - Operating","40500001","Rental income Commercial"})

AADD(aContas,{.F.,"Costs","50910000","Costs"})

AADD(aContas,{.T.,"Gross Income","",""})

AADD(aContas,{.F.,"Interest Income","46100000","Interest Income"})

AADD(aContas,{.F.,"Common Area Maintenance","52150000","Equip - Rental"})
AADD(aContas,{.F.,"Common Area Maintenance","52570000","Management Office Telephone/Internet"})
AADD(aContas,{.F.,"Common Area Maintenance","52540000","Management Office Expenses"})
AADD(aContas,{.F.,"Common Area Maintenance","52510000","Management Office Rent"})

AADD(aContas,{.F.,"Utilities","53750000","Water/Sewer"})

AADD(aContas,{.F.,"Insurance","55350000","Property Insurance"})

AADD(aContas,{.F.,"Administrative Expenses","57450000","Professional & Consulting Fees"})
AADD(aContas,{.F.,"Administrative Expenses","55100000","Property Management Fees"})
AADD(aContas,{.F.,"Administrative Expenses","57100000","Audit & Accounting Fees"})
AADD(aContas,{.F.,"Administrative Expenses","57200000","Bank Fees"})
AADD(aContas,{.F.,"Administrative Expenses","57400000","Legal Fees"})

AADD(aContas,{.F.,"Undist Exp - Sales / Marketing","58400100","Sales & Mkt - Other - Postage"})
AADD(aContas,{.F.,"Undist Exp - Sales / Marketing","58400110","Sales & Mkt - Other - Photocopy"})
AADD(aContas,{.F.,"Undist Exp - Sales / Marketing","58400200","Sales & Mkt - Other - Promotion"})
AADD(aContas,{.F.,"Undist Exp - Sales / Marketing","58400220","Sales & Mkt - Other - T & E - Lodging & Trans"})

AADD(aContas,{.F.,"Undist Exp - Repairs & Maintenance","58450360","R & M - Other - Vehicles"})

AADD(aContas,{.F.,"Fixed / Other Taxes","58750060","Land Taxes"})
AADD(aContas,{.F.,"Fixed / Other Taxes","58750070","Syndicate"})
AADD(aContas,{.F.,"Fixed / Other Taxes","58750010","Taxes - Real Estate"})
AADD(aContas,{.F.,"Fixed / Other Taxes","58850020","Other - Conversion Expense"})

AADD(aContas,{.F.,"Fixed/Others - Insurance","58700020","Insurance - General"})

AADD(aContas,{.F.,"Corporate Expenses","61460000","Legal Expenses"})
AADD(aContas,{.F.,"Corporate Expenses","61240000","Electricity"})
AADD(aContas,{.F.,"Corporate Expenses","61222000","Parking"})
AADD(aContas,{.F.,"Corporate Expenses","61388000","Postage"})
AADD(aContas,{.F.,"Corporate Expenses","61820000","Interest Expense"})
AADD(aContas,{.F.,"Corporate Expenses","61522000","Meals & Entertainment- Corporate"})
AADD(aContas,{.F.,"Corporate Expenses","61683000","Printing Charges - Corporate"})
AADD(aContas,{.F.,"Corporate Expenses","61300000","Repairs & Maintenance - Corporate"})
AADD(aContas,{.F.,"Corporate Expenses","61722000","Delivery Costs-corporate"})
AADD(aContas,{.F.,"Corporate Expenses","61521000","Travel Expenses"})
AADD(aContas,{.F.,"Corporate Expenses","61480000","Consulting Fees-corporate"})
AADD(aContas,{.F.,"Corporate Expenses","61840000","Amortization Expense"})
AADD(aContas,{.F.,"Corporate Expenses","61860000","Depreciation Expense"})
AADD(aContas,{.F.,"Corporate Expenses","61870000","Miscellaneous - adjustments"})
AADD(aContas,{.F.,"Corporate Expenses","61880000","Taxes"})

//AADD(aContas,{.F.,"Foreign Currency Gain/Loss","","Foreign Currency Gain/Loss"})

AADD(aContas,{.F.,"Dividend Income","48100000","Dividend Income"})

AADD(aContas,{.F.,"Rollup Balancing Account","90000000","Rollup Balancing Account"})

AADD(aContas,{.T.,"NET INCOME","",""})
//-----------------------------------FIM CONTAS---------------------------------------------------------

//Monta a pergunta
U_PUTSX1( cPerg, "01", "Data De:", "Data De:", "Data De:", "", "D",08,00,00,"G","" , "","","","MV_PAR01")
U_PUTSX1( cPerg, "02", "Data Ate:", "Data Ate:", "Data Ate:", "", "D",08,00,00,"G","" , "","","","MV_PAR02")

if !Pergunte(cPerg,.T.)
	Return
endif

if select("TEMP")>0
	TEMP->(DbCloseArea())
endif

cNome := CriaTrab(aDadTemp,.t.)
dbUseArea(.T.,,cNome,"TEMP",.F.,.F.)
 
cIndex:=CriaTrab(Nil,.F.)
IndRegua("TEMP",cIndex,"CONTA",,,"Selecionando Registro...")

DbSelectArea("TEMP")
DbSetIndex(cIndex+OrdBagExt())


//***************************************@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//Montagem de tabela temporaria com saldos iniciais

if select("SLDINI")>0
	SLDINI->(DbCloseArea())
endif

cNome1 := CriaTrab(aDadSald,.t.)
dbUseArea(.T.,,cNome1,"SLDINI",.F.,.F.)
 
cIndSaldo:=CriaTrab(Nil,.F.)
IndRegua("SLDINI",cIndSaldo,"CONTA",,,"Selecionando Registro...")

DbSelectArea("SLDINI")
DbSetIndex(cIndSaldo+OrdBagExt())

//Preenche com a YS
queryYS1(MV_PAR01,MV_PAR02)

DbSelectArea("QGTIS1")
QGTIS1->(Dbgotop())

while QGTIS1->(!EOF())

	Reclock("SLDINI",.T.)
		SLDINI->CONTA:=QGTIS1->CT1_P_CONT
		SLDINI->SLDANT1:=QGTIS1->SLDANT
	SLDINI->(MsUnlock())

QGTIS1->(DbSkip())
enddo
//Preenche com a YC
queryYC1(MV_PAR01,MV_PAR02)
DbSelectArea("QGTIS1")
QGTIS1->(Dbgotop())

while QGTIS1->(!EOF())

DbSelectArea("SLDINI")
DbSetIndex(cIndSaldo+OrdBagExt())

if DBSeek(QGTIS1->CT1_P_CONT)
	Reclock("SLDINI",.F.)
		SLDINI->SLDANT2:=QGTIS1->SLDANT
	SLDINI->(MsUnlock())
else
	Reclock("SLDINI",.T.)
		SLDINI->CONTA:=QGTIS1->CT1_P_CONT
		SLDINI->SLDANT2:=QGTIS1->SLDANT
	SLDINI->(MsUnlock())
endif

QGTIS1->(DbSkip())
enddo

//Preenche com a Y5
queryY51(MV_PAR01,MV_PAR02)
DbSelectArea("QGTIS1")
QGTIS1->(Dbgotop())

while QGTIS1->(!EOF())

DbSelectArea("SLDINI")
DbSetIndex(cIndSaldo+OrdBagExt())

if DBSeek(QGTIS1->CT1_P_CONT)
	Reclock("SLDINI",.F.)
		SLDINI->SLDANT3:=QGTIS1->SLDANT
	SLDINI->(MsUnlock())
else
	Reclock("SLDINI",.T.)
		SLDINI->CONTA:=QGTIS1->CT1_P_CONT
		SLDINI->SLDANT3:=QGTIS1->SLDANT
	SLDINI->(MsUnlock())
endif

QGTIS1->(DbSkip())
enddo                                              

//***************************************@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//FIM Montagem de tabela temporaria com saldos iniciais


//*********************************************************
// Montagem da query YS
queryYS(MV_PAR01,MV_PAR02)   

//percorre a query de debito credito
DbSelectArea("QGTIS")
QGTIS->(Dbgotop())

while QGTIS->(!EOF())

	Reclock("TEMP",.T.)
	TEMP->CONTA:=QGTIS->CT1_P_CONT
	TEMP->DESC:=QGTIS->CT1_P_DESC
		DbSelectArea("SLDINI")
		DbSetIndex(cIndSaldo+OrdBagExt())
		SLDINI->(DbSeek(QGTIS->CT1_P_CONT))
			TEMP->SLDANT1:=SLDINI->SLDANT1
	TEMP->DEBITO1:=QGTIS->DEBITO
	TEMP->CREDITO1:=QGTIS->CREDITO
	TEMP->SLDPOS1:=SLDINI->SLDANT1+QGTIS->SLDPOS
	TEMP->(MsUnlock())

QGTIS->(DbSkip())
enddo

//*********************************************************
// Montagem da query YC
queryYC(MV_PAR01,MV_PAR02)   

DbSelectArea("QGTIS")
QGTIS->(Dbgotop())

while QGTIS->(!EOF())

DbSelectArea("TEMP")
DbSetIndex(cIndex+OrdBagExt())

if DBSeek(QGTIS->CT1_P_CONT)
	Reclock("TEMP",.F.)
		DbSelectArea("SLDINI")
		DbSetIndex(cIndSaldo+OrdBagExt())
		SLDINI->(DbSeek(QGTIS->CT1_P_CONT))
			TEMP->SLDANT2:=SLDINI->SLDANT2
	TEMP->DEBITO2:=QGTIS->DEBITO
	TEMP->CREDITO2:=QGTIS->CREDITO
	TEMP->SLDPOS2:=SLDINI->SLDANT2+QGTIS->SLDPOS
	TEMP->(MsUnlock())
else
	Reclock("TEMP",.T.)
	TEMP->CONTA:=QGTIS->CT1_P_CONT
	TEMP->DESC:=QGTIS->CT1_P_DESC
		DbSelectArea("SLDINI")
		DbSetIndex(cIndSaldo+OrdBagExt())
		SLDINI->(DbSeek(QGTIS->CT1_P_CONT))
			TEMP->SLDANT2:=SLDINI->SLDANT2
	TEMP->DEBITO2:=QGTIS->DEBITO
	TEMP->CREDITO2:=QGTIS->CREDITO
	TEMP->SLDPOS2:=SLDINI->SLDANT2+QGTIS->SLDPOS
	TEMP->(MsUnlock())
endif

QGTIS->(DbSkip())
enddo

//*********************************************************
// Montagem da query Y5
queryY5(MV_PAR01,MV_PAR02)

DbSelectArea("QGTIS")
QGTIS->(Dbgotop())

while QGTIS->(!EOF())

DbSelectArea("TEMP")
DbSetIndex(cIndex+OrdBagExt())

if DBSeek(QGTIS->CT1_P_CONT)
	Reclock("TEMP",.F.)
		DbSelectArea("SLDINI")
		DbSetIndex(cIndSaldo+OrdBagExt())
		SLDINI->(DbSeek(QGTIS->CT1_P_CONT))
			TEMP->SLDANT3:=SLDINI->SLDANT3
	TEMP->DEBITO3:=QGTIS->DEBITO
	TEMP->CREDITO3:=QGTIS->CREDITO
	TEMP->SLDPOS3:=SLDINI->SLDANT3+QGTIS->SLDPOS
	TEMP->(MsUnlock())
else
	Reclock("TEMP",.T.)
	TEMP->CONTA:=QGTIS->CT1_P_CONT
	TEMP->DESC:=QGTIS->CT1_P_DESC
		DbSelectArea("SLDINI")
		DbSetIndex(cIndSaldo+OrdBagExt())
		SLDINI->(DbSeek(QGTIS->CT1_P_CONT))
			TEMP->SLDANT3:=SLDINI->SLDANT3
	TEMP->DEBITO3:=QGTIS->DEBITO
	TEMP->CREDITO3:=QGTIS->CREDITO
	TEMP->SLDPOS3:=SLDINI->SLDANT3+QGTIS->SLDPOS
	TEMP->(MsUnlock())
endif

QGTIS->(DbSkip())
enddo 

//§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//percorre a Tabela de saldos iniciais, preenchendo a query temp com os saldos iniciais que não tem movimentação debito credito,
//ou alterando o saldos iniciais dos que não tem.
DbSelectArea("SLDINI")
SLDINI->(Dbgotop())

while SLDINI->(!EOF())

	DbSelectArea("TEMP")
	DbSetIndex(cIndex+OrdBagExt())
	
	if !TEMP->(DBSeek(SLDINI->CONTA))
		Reclock("TEMP",.T.)
			TEMP->CONTA:=SLDINI->CONTA
			TEMP->SLDANT1:=SLDINI->SLDANT1
			TEMP->DEBITO1:=0
			TEMP->CREDITO1:=0
			TEMP->SLDPOS1:=SLDINI->SLDANT1
			TEMP->SLDANT2:=SLDINI->SLDANT2
			TEMP->DEBITO2:=0
			TEMP->CREDITO2:=0
			TEMP->SLDPOS2:=SLDINI->SLDANT2
			TEMP->SLDANT3:=SLDINI->SLDANT3
			TEMP->DEBITO3:=0
			TEMP->CREDITO3:=0
			TEMP->SLDPOS3:=SLDINI->SLDANT3
		TEMP->(MsUnlock())
	else
		if TEMP->SLDANT1==0 .AND. TEMP->SLDPOS1==0
		Reclock("TEMP",.F.)
			TEMP->SLDANT1:=SLDINI->SLDANT1
			TEMP->SLDPOS1:=SLDINI->SLDANT1
		TEMP->(MsUnlock())
		endif			   
		
		if TEMP->SLDANT2==0 .AND. TEMP->SLDPOS2==0
		Reclock("TEMP",.F.)
			TEMP->SLDANT2:=SLDINI->SLDANT2
			TEMP->SLDPOS2:=SLDINI->SLDANT2
		TEMP->(MsUnlock())
		endif
		
		if TEMP->SLDANT3==0 .AND. TEMP->SLDPOS3==0
		Reclock("TEMP",.F.)
			TEMP->SLDANT3:=SLDINI->SLDANT3
			TEMP->SLDPOS3:=SLDINI->SLDANT3
		TEMP->(MsUnlock())
		endif
	endif

SLDINI->(DbSkip())
enddo
//FIM §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§

//?????? Tratamento para conta especifica: 33500000
nCtaEspA1:=0
nCtaEspB1:=0
nCtaEspC1:=0
nCtaEspA2:=0
nCtaEspB2:=0
nCtaEspC2:=0
nCtaEspA3:=0
nCtaEspB3:=0
nCtaEspC3:=0

for k:=1 to len(aContas)
	if aContas[k][2] $ "Revenue/Rental Income - Operating/Costs/Interest Income/Common Area Maintenance/Utilities/Insurance/Administrative Expenses/Undist Exp - Sales / Marketing/Undist Exp - Repairs & Maintenance/Fixed / Other Taxes/Fixed/Others - Insurance/Corporate Expenses/Foreign Currency Gain/Loss/Dividend Income/Rollup Balancing Account"	

		DbSelectArea("TEMP")
		TEMP->(DbSetIndex(cIndex+OrdBagExt()))
		TEMP->(DbSeek(aContas[k][3]))
			nCtaEspA1+=TEMP->DEBITO1
			nCtaEspB1+=TEMP->CREDITO1
			//tem q alterar
			nCtaEspC1+=TEMP->CREDITO1-(-TEMP->DEBITO1)
			nCtaEspA2+=TEMP->DEBITO2
			nCtaEspB2+=TEMP->CREDITO2
			//tem q alterar
			nCtaEspC2+=TEMP->CREDITO2-(-TEMP->DEBITO2)
			nCtaEspA3+=TEMP->DEBITO3
			nCtaEspB3+=TEMP->CREDITO3
			//tem q alterar
			nCtaEspC3+=TEMP->CREDITO3-(-TEMP->DEBITO3)
	endif
next

DbSelectArea("TEMP")
TEMP->(DbSetIndex(cIndex+OrdBagExt()))
TEMP->(DbSeek("33500000"))
	RecLock("TEMP",.F.)
			TEMP->DEBITO1:=nCtaEspA1
			TEMP->CREDITO1:=nCtaEspB1
			TEMP->SLDPOS1:=TEMP->SLDANT1+nCtaEspC1			
			TEMP->DEBITO2:=nCtaEspA2
			TEMP->CREDITO2:=nCtaEspB2
			TEMP->SLDPOS2:=TEMP->SLDANT2+nCtaEspC2
			TEMP->DEBITO3:=nCtaEspA3
			TEMP->CREDITO3:=nCtaEspB3
			TEMP->SLDPOS3:=TEMP->SLDANT3+nCtaEspC3
			
	TEMP->(MsUnlock())

//?????? FIM Tratamento para conta especifica: 33500000

DbSelectArea("TEMP")
TEMP->(DbSetIndex(cIndex+OrdBagExt()))
TEMP->(Dbgotop())

//********************************
// gera os totais de cima
//********************************
for i:=1 to len(aContas)
	if !aContas[i][1]
		TEMP->(DbSeek(aContas[i][3]))	
		nValA1+=TEMP->SLDANT1
		nValB1+=TEMP->DEBITO1
		nValC1+=TEMP->CREDITO1
		nValD1+=TEMP->SLDPOS1
		nValA2+=TEMP->SLDANT2
		nValB2+=TEMP->DEBITO2
		nValC2+=TEMP->CREDITO2
		nValD2+=TEMP->SLDPOS2
		nValA3+=TEMP->SLDANT3
		nValB3+=TEMP->DEBITO3
		nValC3+=TEMP->CREDITO3
		nValD3+=TEMP->SLDPOS3
		
		nValA4+=TEMP->SLDPOS1+TEMP->SLDPOS2+TEMP->SLDPOS3
		DbSelectArea("Z96")
		Z96->(DbSelectArea(1))
		DbSeek(xFilial("Z96")+PADR(alltrim(aContas[i][3]),20)+DTOS(MV_PAR02))
			//Se for débito
			if Z96->Z96_DEBCRE=='1' 
				nValB4+=Z96->Z96_VALOR	
			elseif Z96->Z96_DEBCRE=='2'
				nValC4+=Z96->Z96_VALOR
			endif
				
		nValD4+=TEMP->SLDPOS1+TEMP->SLDPOS2+TEMP->SLDPOS3+Z96->Z96_VALOR
			
	    if i<>len(aContas)
		    if aContas[i+1][2]<>aContas[i][2]
		    	AADD(aTot,{aContas[i][2],nValA1,nValB1,nValC1,nValD1,nValA2,nValB2,nValC2,nValD2,nValA3,nValB3,nValC3,nValD3,nValA4,nValB4,nValC4,nValD4})
				nValA1:=0
				nValB1:=0
				nValC1:=0
				nValD1:=0
				nValA2:=0
				nValB2:=0
				nValC2:=0
				nValD2:=0
				nValA3:=0
				nValB3:=0
				nValC3:=0
				nValD3:=0
				nValA4:=0
				nValB4:=0
				nValC4:=0
				nValD4:=0
		    endif	
		else
	
		    	AADD(aTot,{aContas[i][2],nValA1,nValB1,nValC1,nValD1,nValA2,nValB2,nValC2,nValD2,nValA3,nValB3,nValC3,nValD3,nValA4,nValB4,nValC4,nValD4})
				nValA1:=0
				nValB1:=0
				nValC1:=0
				nValD1:=0
				nValA2:=0
				nValB2:=0
				nValC2:=0
				nValD2:=0
				nValA3:=0
				nValB3:=0
				nValC3:=0
				nValD3:=0
				nValA4:=0
				nValB4:=0
				nValC4:=0
				nValD4:=0
		endif
    endif
next

//while TEMP->(!EOF())
for i:=1 to len(aContas)
    /*
    if SUBSTR(TEMP->CONTA,1,1)==aCabEsq[nSeq][1] .AND. !aCabEsq[nSeq][3]

	cHtmlL1+="         <tr>
	cHtmlL1+="           <td class='titesq'>&nbsp;</td>
	cHtmlL1+="           <td class='titesq'>&nbsp;</td>
	cHtmlL1+="         </tr> 
	
	cHtmlD1+="         <tr>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="         </tr>

	cHtmlD2+="         <tr>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="         </tr>

	cHtmlD3+="         <tr>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="         </tr>

	cHtmlL1+="         <tr>
	cHtmlL1+="           <td class='titesq'>&nbsp;</td>
	cHtmlL1+="           <td class='titesq'><font color='#0000FF'>"+aCabEsq[nSeq][2]+"</font></td>
	cHtmlL1+="         </tr> 
	
	cHtmlD1+="         <tr>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="         </tr>

	cHtmlD2+="         <tr>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="         </tr>

	cHtmlD3+="         <tr>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="         </tr>

	cHtmlL1+="         <tr>
	cHtmlL1+="           <td class='titesq'>&nbsp;</td>
	cHtmlL1+="           <td class='titesq'>&nbsp;</td>
	cHtmlL1+="         </tr> 
	
	cHtmlD1+="         <tr>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="         </tr>
	
	cHtmlD2+="         <tr>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="         </tr>
    
   	cHtmlD3+="         <tr>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="         </tr>
    	nSeq++
	endif

	cHtmlL1+="              <tr>
	cHtmlL1+="                <td class='titesq'>"+TEMP->CONTA+"</td>
	cHtmlL1+="                <td class='titesq'>"+TEMP->DESC+"</td>
	cHtmlL1+="              </tr>
	
	cHtmlD1+="          <tr>
	cHtmlD1+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDANT1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="            <td class='titesq'>"+TRANSFORM(TEMP->DEBITO1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="            <td class='titesq'>"+TRANSFORM(TEMP->CREDITO1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDPOS1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="          </tr>

	cHtmlD2+="          <tr>
	cHtmlD2+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDANT2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="            <td class='titesq'>"+TRANSFORM(TEMP->DEBITO2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="            <td class='titesq'>"+TRANSFORM(TEMP->CREDITO2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDPOS2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="          </tr>    

	cHtmlD3+="          <tr>
	cHtmlD3+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDANT3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="            <td class='titesq'>"+TRANSFORM(TEMP->DEBITO3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="            <td class='titesq'>"+TRANSFORM(TEMP->CREDITO3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDPOS3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="          </tr>
    */

if !aContas[i][1]
    if i<>1
	    if aContas[i-1][2]<>aContas[i][2]
	    		cHtmlL1+="         <tr>
				cHtmlL1+="           <td class='titesq'>&nbsp;</td>
				cHtmlL1+="           <td class='titesq'>&nbsp;</td>
				cHtmlL1+="         </tr> 
				
				cHtmlD1+="         <tr>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="         </tr>
				
				cHtmlD2+="         <tr>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="         </tr>
			    
			   	cHtmlD3+="         <tr>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="         </tr>

			   	cHtmlD4+="         <tr>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="         </tr>

	    		cHtmlL1+="         <tr>
				cHtmlL1+="           <td class='titesq'>&nbsp;</td>
				cHtmlL1+="           <td class='titesq'><strong>"+aContas[i][2]+"</strong></td>
				cHtmlL1+="         </tr> 
				
				nPos:=aScanX( aTot, { |X,Y| X[1] == aContas[i][2]})
				cHtmlD1+="         <tr>
				cHtmlD1+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][2],'@E 99,999,999,999.99')+"</td>
				cHtmlD1+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][3],'@E 99,999,999,999.99')+"</td>
				cHtmlD1+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][4],'@E 99,999,999,999.99')+"</td>
				cHtmlD1+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][5],'@E 99,999,999,999.99')+"</td>
				cHtmlD1+="         </tr>
				
				cHtmlD2+="         <tr>
				cHtmlD2+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][6],'@E 99,999,999,999.99')+"</td>
				cHtmlD2+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][7],'@E 99,999,999,999.99')+"</td>
				cHtmlD2+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][8],'@E 99,999,999,999.99')+"</td>
				cHtmlD2+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][9],'@E 99,999,999,999.99')+"</td>
				cHtmlD2+="         </tr>
			    
			   	cHtmlD3+="         <tr>
				cHtmlD3+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][10],'@E 99,999,999,999.99')+"</td>
				cHtmlD3+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][11],'@E 99,999,999,999.99')+"</td>
				cHtmlD3+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][12],'@E 99,999,999,999.99')+"</td>
				cHtmlD3+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][13],'@E 99,999,999,999.99')+"</td>
				cHtmlD3+="         </tr>

			   	cHtmlD4+="         <tr>
//				cHtmlD4+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][13]+aTot[nPos][9]+aTot[nPos][5],'@E 99,999,999,999.99')+"</td>
				cHtmlD4+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][14],'@E 99,999,999,999.99')+"</td>
				cHtmlD4+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][15],'@E 99,999,999,999.99')+"</td>
				cHtmlD4+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][16],'@E 99,999,999,999.99')+"</td>
				cHtmlD4+="           <td class='titesq'>"+TRANSFORM(aTot[nPos][17],'@E 99,999,999,999.99')+"</td>
				cHtmlD4+="         </tr>
				
	    endif
    else
				cHtmlL1+="         <tr>
				cHtmlL1+="           <td class='titesq'>&nbsp;</td>
				cHtmlL1+="           <td class='titesq'>&nbsp;</td>
				cHtmlL1+="         </tr> 
				
				cHtmlD1+="         <tr>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="         </tr>
				
				cHtmlD2+="         <tr>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="         </tr>
			    
			   	cHtmlD3+="         <tr>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="         </tr>
				
			   	cHtmlD4+="         <tr>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="         </tr>

	    		cHtmlL1+="         <tr>
				cHtmlL1+="           <td class='titesq'>&nbsp;</td>
				cHtmlL1+="           <td class='titesq'><strong>"+aContas[i][2]+"</strong></td>
				cHtmlL1+="         </tr> 
				
				cHtmlD1+="         <tr>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="           <td class='titesq'>&nbsp;</td>
				cHtmlD1+="         </tr>
				
				cHtmlD2+="         <tr>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="           <td class='titesq'>&nbsp;</td>
				cHtmlD2+="         </tr>
			    
			   	cHtmlD3+="         <tr>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="           <td class='titesq'>&nbsp;</td>
				cHtmlD3+="         </tr>    

			   	cHtmlD4+="         <tr>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="           <td class='titesq'>&nbsp;</td>
				cHtmlD4+="         </tr>				
    endif          
    
   	cHtmlL1+="              <tr>
	cHtmlL1+="                <td class='titesq'>"+aContas[i][3]+"</td>
	cHtmlL1+="                <td class='titesq'>"+aContas[i][4]+"</td>
	cHtmlL1+="              </tr>

	TEMP->(DbSeek(aContas[i][3]))
	
	cHtmlD1+="          <tr>
	cHtmlD1+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDANT1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="            <td class='titesq'>"+TRANSFORM(TEMP->DEBITO1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="            <td class='titesq'>"+TRANSFORM(TEMP->CREDITO1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDPOS1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="          </tr>

	cHtmlD2+="          <tr>
	cHtmlD2+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDANT2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="            <td class='titesq'>"+TRANSFORM(TEMP->DEBITO2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="            <td class='titesq'>"+TRANSFORM(TEMP->CREDITO2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDPOS2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="          </tr>    

	cHtmlD3+="          <tr>
	cHtmlD3+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDANT3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="            <td class='titesq'>"+TRANSFORM(TEMP->DEBITO3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="            <td class='titesq'>"+TRANSFORM(TEMP->CREDITO3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDPOS3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="          </tr>

	cHtmlD4+="          <tr>
	cHtmlD4+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDPOS1+TEMP->SLDPOS2+TEMP->SLDPOS3,'@E 99,999,999,999.99')+"</td>

	DbSelectArea("Z96")
	Z96->(DbSelectArea(1))
	DbSeek(xFilial("Z96")+PADR(alltrim(aContas[i][3]),20)+DTOS(MV_PAR02))
		//Se for débito
		if Z96->Z96_DEBCRE=='1' 
			cHtmlD4+="            <td class='titesq'>"+TRANSFORM(Z96->Z96_VALOR,'@E 99,999,999,999.99')+"</td>
		else
			cHtmlD4+="            <td class='titesq'>"+TRANSFORM(0,'@E 99,999,999,999.99')+"</td>
		endif
		//Se for crédito
		if Z96->Z96_DEBCRE=='2' 
			cHtmlD4+="            <td class='titesq'>"+TRANSFORM(Z96->Z96_VALOR,'@E 99,999,999,999.99')+"</td>
		else
			cHtmlD4+="            <td class='titesq'>"+TRANSFORM(0,'@E 99,999,999,999.99')+"</td>
		endif
		
	cHtmlD4+="            <td class='titesq'>"+TRANSFORM(TEMP->SLDPOS1+TEMP->SLDPOS2+TEMP->SLDPOS3+Z96->Z96_VALOR,'@E 99,999,999,999.99')+"</td>
	cHtmlD4+="          </tr>

else        
	nSomaA1:=0
	nSomaB1:=0
	nSomaC1:=0
	nSomaD1:=0
	nSomaA2:=0
	nSomaB2:=0
	nSomaC2:=0
	nSomaD2:=0
	nSomaA3:=0
	nSomaB3:=0
	nSomaC3:=0
	nSomaD3:=0
	nSomaA4:=0
	nSomaB4:=0
	nSomaC4:=0
	nSomaD4:=0
		
	if aContas[i][2]=="ASSETS"
    	for j:=1 to len(aTot)
    		if aTot[j][1] $ "Cash/Receivables/Prepaid Expenses/Real Estate Investments/Fixed Assets/Intangible Assets"
    			nSomaA1+=aTot[j][2]
				nSomaB1+=aTot[j][3]
				nSomaC1+=aTot[j][4]
				nSomaD1+=aTot[j][5]
				nSomaA2+=aTot[j][6]
				nSomaB2+=aTot[j][7]
				nSomaC2+=aTot[j][8]
				nSomaD2+=aTot[j][9]
				nSomaA3+=aTot[j][10]
				nSomaB3+=aTot[j][11]
				nSomaC3+=aTot[j][12]
				nSomaD3+=aTot[j][13]
				nSomaA4+=aTot[j][14]
				nSomaB4+=aTot[j][15]
				nSomaC4+=aTot[j][16]
				nSomaD4+=aTot[j][17]
			endif	
    	next
    endif
    if aContas[i][2]=="LIABILITIES"
    	for j:=1 to len(aTot)
    		if aTot[j][1] $ "Accounts Payable & Accrued Expenses/Deferred Income/Tenant Deposits/Equity/Realized Gains & Losses"
    			nSomaA1+=aTot[j][2]
				nSomaB1+=aTot[j][3]
				nSomaC1+=aTot[j][4]
				nSomaD1+=aTot[j][5]
				nSomaA2+=aTot[j][6]
				nSomaB2+=aTot[j][7]
				nSomaC2+=aTot[j][8]
				nSomaD2+=aTot[j][9]
				nSomaA3+=aTot[j][10]
				nSomaB3+=aTot[j][11]
				nSomaC3+=aTot[j][12]
				nSomaD3+=aTot[j][13]
				nSomaA4+=aTot[j][14]
				nSomaB4+=aTot[j][15]
				nSomaC4+=aTot[j][16]
				nSomaD4+=aTot[j][17]
			endif	
    	next
    endif
    if aContas[i][2]=="Gross Income"
    	for j:=1 to len(aTot)
    		if aTot[j][1] $ "Revenue/Rental Income - Operating/Costs"
    			nSomaA1+=aTot[j][2]
				nSomaB1+=aTot[j][3]
				nSomaC1+=aTot[j][4]
				nSomaD1+=aTot[j][5]
				nSomaA2+=aTot[j][6]
				nSomaB2+=aTot[j][7]
				nSomaC2+=aTot[j][8]
				nSomaD2+=aTot[j][9]
				nSomaA3+=aTot[j][10]
				nSomaB3+=aTot[j][11]
				nSomaC3+=aTot[j][12]
				nSomaD3+=aTot[j][13]
				nSomaA4+=aTot[j][14]
				nSomaB4+=aTot[j][15]
				nSomaC4+=aTot[j][16]
				nSomaD4+=aTot[j][17]				
			endif	
    	next
    endif
    if aContas[i][2]=="NET INCOME"
    	for j:=1 to len(aTot)
    		if aTot[j][1] $ "Revenue/Rental Income - Operating/Costs/Interest Income/Common Area Maintenance/Utilities/Insurance/Administrative Expenses/Undist Exp - Sales / Marketing/Undist Exp - Repairs & Maintenance/Fixed / Other Taxes/Fixed/Others - Insurance/Corporate Expenses/Foreign Currency Gain/Loss/Dividend Income/Rollup Balancing Account"
    			nSomaA1+=aTot[j][2]
				nSomaB1+=aTot[j][3]
				nSomaC1+=aTot[j][4]
				nSomaD1+=aTot[j][5]
				nSomaA2+=aTot[j][6]
				nSomaB2+=aTot[j][7]
				nSomaC2+=aTot[j][8]
				nSomaD2+=aTot[j][9]
				nSomaA3+=aTot[j][10]
				nSomaB3+=aTot[j][11]
				nSomaC3+=aTot[j][12]
				nSomaD3+=aTot[j][13]
				nSomaA4+=aTot[j][14]
				nSomaB4+=aTot[j][15]
				nSomaC4+=aTot[j][16]
				nSomaD4+=aTot[j][17]				
			endif	
    	next
    endif
	cHtmlL1+="         <tr>
	cHtmlL1+="           <td class='titesq'>&nbsp;</td>
	cHtmlL1+="           <td class='titesq'>&nbsp;</td>
	cHtmlL1+="         </tr> 
	
	cHtmlD1+="         <tr>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="           <td class='titesq'>&nbsp;</td>
	cHtmlD1+="         </tr>

	cHtmlD2+="         <tr>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="           <td class='titesq'>&nbsp;</td>
	cHtmlD2+="         </tr>

	cHtmlD3+="         <tr>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="           <td class='titesq'>&nbsp;</td>
	cHtmlD3+="         </tr>

	cHtmlD4+="         <tr>
	cHtmlD4+="           <td class='titesq'>&nbsp;</td>
	cHtmlD4+="           <td class='titesq'>&nbsp;</td>
	cHtmlD4+="           <td class='titesq'>&nbsp;</td>
	cHtmlD4+="           <td class='titesq'>&nbsp;</td>
	cHtmlD4+="         </tr>
	
	cHtmlL1+="         <tr>
	cHtmlL1+="           <td class='titesq'>&nbsp;</td>
	cHtmlL1+="           <td class='titesq'><font color='#0000FF'><strong>"+aContas[i][2]+"</strong></font></td>
	cHtmlL1+="         </tr> 
	
	cHtmlD1+="         <tr>
	cHtmlD1+="           <td class='titesq'>"+TRANSFORM(nSomaA1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="           <td class='titesq'>"+TRANSFORM(nSomaB1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="           <td class='titesq'>"+TRANSFORM(nSomaC1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="           <td class='titesq'>"+TRANSFORM(nSomaD1,'@E 99,999,999,999.99')+"</td>
	cHtmlD1+="         </tr>

	cHtmlD2+="         <tr>
	cHtmlD2+="           <td class='titesq'>"+TRANSFORM(nSomaA2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="           <td class='titesq'>"+TRANSFORM(nSomaB2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="           <td class='titesq'>"+TRANSFORM(nSomaC2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="           <td class='titesq'>"+TRANSFORM(nSomaD2,'@E 99,999,999,999.99')+"</td>
	cHtmlD2+="         </tr>

	cHtmlD3+="         <tr>
	cHtmlD3+="           <td class='titesq'>"+TRANSFORM(nSomaA3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="           <td class='titesq'>"+TRANSFORM(nSomaB3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="           <td class='titesq'>"+TRANSFORM(nSomaC3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="           <td class='titesq'>"+TRANSFORM(nSomaD3,'@E 99,999,999,999.99')+"</td>
	cHtmlD3+="         </tr>

	cHtmlD4+="         <tr>
	cHtmlD4+="           <td class='titesq'>"+TRANSFORM(nSomaA4,'@E 99,999,999,999.99')+"</td>
	cHtmlD4+="           <td class='titesq'>"+TRANSFORM(nSomaB4,'@E 99,999,999,999.99')+"</td>
	cHtmlD4+="           <td class='titesq'>"+TRANSFORM(nSomaC4,'@E 99,999,999,999.99')+"</td>
	cHtmlD4+="           <td class='titesq'>"+TRANSFORM(nSomaD4,'@E 99,999,999,999.99')+"</td>
	cHtmlD4+="         </tr>
endif
    
next
//TEMP->(DbSkip())

//enddo

cHtml:=geraxls(cHtmlL1,cHtmlD1,cHtmlD2,cHtmlD3,MV_PAR01,MV_PAR02)


/***********************GERANDO EXCEL************************************/


	cArq := "consolidado.xls"
	
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
	nBytesSalvo := FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
	
	if nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
	else
		fclose(nHdl) // Fecha o Arquivo que foi Gerado
		cExt := '.xls'
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
	endif
          
	FErase(cIndex+OrdBagExt())
         
         
Return




Static function geraxls(cHtmlL1,cHtmlD1,cHtmlD2,cHtmlD3,MV_PAR01,MV_PAR02)
Local cHtml:=""
Local cDtIni:=SubStr(cMonth(MV_PAR01-1),1,3)+" "+cvaltochar(day(MV_PAR01-1))+", "+cvaltochar(year(MV_PAR01-1))
Local cDtFim:=SubStr(cMonth(MV_PAR02),1,3)+" "+cvaltochar(day(MV_PAR02))+", "+cvaltochar(year(MV_PAR02))

cHtml+="<html>
cHtml+="<head>

cHtml+="<style type='text/css'>
cHtml+=".titazul {
cHtml+="	font-family: Tahoma, Geneva, sans-serif;
cHtml+="	font-size: 10px;
cHtml+="	color: #00F;
cHtml+="	text-align:center;
cHtml+="}
cHtml+=".tit {
cHtml+="	font-family: Tahoma, Geneva, sans-serif;
cHtml+="	font-size: 10px;
cHtml+="	text-align:center;
cHtml+="}
cHtml+=".titesq {
cHtml+="	font-family: Tahoma, Geneva, sans-serif;
cHtml+="	font-size: 10px;
cHtml+="}

cHtml+="</style>

cHtml+="</head>

cHtml+="<body>

cHtml+="<table border='1'>
cHtml+="	<tr>
cHtml+="		<td>
cHtml+="            <table width='200' border='0' cellpadding='1'>

cHtml+="              <tr>
cHtml+="              	<td>&nbsp;</td>
cHtml+="                <td>&nbsp;</td>
cHtml+="              </tr>
cHtml+="              <tr>
cHtml+="              	<td>&nbsp;</td>
cHtml+="                <td>&nbsp;</td>
cHtml+="              </tr>
cHtml+="              <tr>
cHtml+="              	<td>&nbsp;</td>
cHtml+="                <td>&nbsp;</td>
cHtml+="              </tr>
cHtml+="              <tr>
cHtml+="              	<td>&nbsp;</td>
cHtml+="                <td>&nbsp;</td>
cHtml+="              </tr>
cHtml+="              <tr>
cHtml+="              	<td>&nbsp;</td>
cHtml+="                <td>&nbsp;</td>
cHtml+="              </tr>
cHtml+="              <tr>
cHtml+="              	<td>&nbsp;</td>
cHtml+="                <td>&nbsp;</td>
cHtml+="              </tr>
cHtml+="              <tr>
cHtml+="              	<td>&nbsp;</td>
cHtml+="                <td>&nbsp;</td>
cHtml+="              </tr>
cHtml+=cHtmlL1              

cHtml+="            </table>
        
cHtml+="		</td>
        
        
        

cHtml+="		<td width='250'>
cHtml+="		<table width='250' border='1' >
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='titazul'><strong>Balance Sheet(R$)</strong></td>
cHtml+="          </tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='tit'><strong>GTIS São Bento Participações Ltda</strong></td>
cHtml+="          </tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='tit'>Movimentação</td>
cHtml+="          </tr>
cHtml+="          <tr>
                                      
cHtml+="            <td class='titazul'>"+cDtIni+"</td>
cHtml+="            <td class='titazul'>Debito</td>
cHtml+="            <td class='titazul'>Credito</td>
cHtml+="            <td class='titazul'>"+cDtFim+"</td>
          
cHtml+="          </tr>
cHtml+=cHtmlD1

cHtml+="        </table>

cHtml+="		</td> 



cHtml+="		<td width='250'>
cHtml+="		<table width='250' border='1' >
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='titazul'><strong>Balance Sheet(R$)</strong></td>
cHtml+="          </tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='tit'><strong>GTIS SB Empreendimentos Imobiliarios Ltda</strong></td>
cHtml+="          </tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='tit'>Movimentação</td>
cHtml+="          </tr>
cHtml+="          <tr>
                                      
cHtml+="            <td class='titazul'>"+cDtIni+"</td>
cHtml+="            <td class='titazul'>Debito</td>
cHtml+="            <td class='titazul'>Credito</td>
cHtml+="            <td class='titazul'>"+cDtFim+"</td>
          
cHtml+="          </tr>
cHtml+=cHtmlD2

cHtml+="        </table>

cHtml+="		</td>


cHtml+="		<td width='250'>
cHtml+="		<table width='250' border='1' >
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='titazul'><strong>Balance Sheet(R$)</strong></td>
cHtml+="          </tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='tit'><strong>GTIS XV Brasil Participações Ltda</strong></td>
cHtml+="          </tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='tit'>Movimentação</td>
cHtml+="          </tr>
cHtml+="          <tr>
                                      
cHtml+="            <td class='titazul'>"+cDtIni+"</td>
cHtml+="            <td class='titazul'>Debito</td>
cHtml+="            <td class='titazul'>Credito</td>
cHtml+="            <td class='titazul'>"+cDtFim+"</td>
          
cHtml+="          </tr>
cHtml+=cHtmlD3

cHtml+="        </table>

cHtml+="		</td>


cHtml+="		<td width='250'>
cHtml+="		<table width='250' border='1' >
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr><td colspan='4'>&nbsp;</td></tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='titazul'><strong>Balance Sheet(R$)</strong></td>
cHtml+="          </tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='tit'><strong>Elimination</strong></td>
cHtml+="          </tr>
cHtml+="          <tr>
cHtml+="          	<td colspan='4' class='tit'>Movimentação</td>
cHtml+="          </tr>
cHtml+="          <tr>
                                      
cHtml+="            <td class='titazul'>"+cDtFim+"</td>
cHtml+="            <td class='titazul'>Debito</td>
cHtml+="            <td class='titazul'>Credito</td>
cHtml+="            <td class='titazul'>"+cDtFim+"</td>
          
cHtml+="          </tr>
cHtml+=cHtmlD4

cHtml+="        </table>

cHtml+="		</td>

     
cHtml+="	</tr>
	
    
cHtml+="</table>



cHtml+="</body>
cHtml+="</html> 


Return(cHtml)        
//*************************************************************************
//	YS
//*************************************************************************
Static function queryYS(MV_PAR01,MV_PAR02)
Local cQry:=""
/*
cQry+=" SELECT CT1_P_CONT,CT1_P_DESC,SUM(SLDANT) AS SLDANT,SUM(DEBITO) AS DEBITO,SUM(CREDITO) AS CREDITO,SUM(SLDPOS) AS SLDPOS FROM (

cQry+=" SELECT CT7_CONTA
cQry+=" ,CT1_DESC04
cQry+=" ,(SELECT CASE WHEN SUBSTRING(CT7_CONTA,1,1)='1' THEN round(CT7_ATUDEB-CT7_ATUCRD,2) ELSE round(CT7_ATUCRD-CT7_ATUDEB,2) END  AS SLDANT FROM CT7YS0
cQry+=" WHERE D_E_L_E_T_='' 
//cQry+=" AND CT7_DATA = (SELECT MAX(CT7_DATA) AS ULTDATA FROM CT7YS0
//cQry+=" WHERE D_E_L_E_T_='' AND CT7_DATA LIKE '"+SUBSTR(DTOS(MV_PAR01-1),1,6)+"%' AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ') 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" AND R_E_C_N_O_=(

cQry+=" SELECT TOP 1(R_E_C_N_O_) FROM CT7YS0 
cQry+=" WHERE D_E_L_E_T_='' 
//cQry+=" AND CT7_DATA = (SELECT MAX(CT7_DATA) AS ULTDATA FROM CT7YS0
//cQry+=" WHERE D_E_L_E_T_='' AND CT7_DATA LIKE '"+SUBSTR(DTOS(MV_PAR01-1),1,6)+"%' AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ') 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" ORDER BY 1 DESC
cQry+=" )

cQry+="  ) AS SLDANT
//cQry+=" ,SUM(CT7_DEBITO) AS DEBITO
//cQry+=" ,SUM(CT7_CREDIT) AS CREDITO
cQry+=" ,CASE SUBSTRING(CT7_CONTA,1,1) WHEN '1' THEN SUM(CT7_DEBITO) ELSE SUM(-CT7_DEBITO) END AS DEBITO
cQry+=" ,CASE SUBSTRING(CT7_CONTA,1,1) WHEN '1' THEN SUM(-CT7_CREDIT) ELSE SUM(CT7_CREDIT) END AS CREDITO
cQry+=" , CASE SUBSTRING(CT7_CONTA,1,1) WHEN '1' THEN ROUND(SUM(CT7_DEBITO) - SUM(CT7_CREDIT),2) ELSE ROUND(SUM(CT7_CREDIT) - SUM(CT7_DEBITO),2) END  AS SLDPOS 
cQry+=" FROM CT7YS0 CT7P
cQry+=" JOIN CT1YS0 CT1 ON CT1_FILIAL=CT7_FILIAL AND CT1_CONTA=CT7_CONTA
cQry+=" WHERE CT7P.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' 
cQry+=" AND CT7_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'
cQry+=" AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" GROUP BY CT7_CONTA,CT1_DESC04 ) TAB1

cQry+=" JOIN CT1YS0 ON TAB1.CT7_CONTA= CT1_CONTA
cQry+=" WHERE CT1_P_CONT<>''
cQry+=" GROUP BY CT1_P_CONT,CT1_P_DESC
cQry+=" ORDER BY CT1_P_CONT
*/

cQry+=" SELECT CT1P.CT1_P_CONT,CT1P.CT1_P_DESC

cQry+=" ,SUM(DEBITO) AS DEBITO,SUM(CREDITO) AS CREDITO,SUM(SLDPOS) AS SLDPOS FROM (

cQry+=" SELECT CT7P.CT7_CONTA
cQry+=" ,CT1.CT1_DESC04
cQry+=" ,CASE SUBSTRING(CT7P.CT7_CONTA,1,1) WHEN '1' THEN SUM(CT7_DEBITO) ELSE SUM(-CT7_DEBITO) END AS DEBITO
cQry+=" ,CASE SUBSTRING(CT7P.CT7_CONTA,1,1) WHEN '1' THEN SUM(-CT7_CREDIT) ELSE SUM(CT7_CREDIT) END AS CREDITO
cQry+=" , CASE SUBSTRING(CT7P.CT7_CONTA,1,1) WHEN '1' THEN ROUND(SUM(CT7_DEBITO) - SUM(CT7_CREDIT),2) ELSE ROUND(SUM(CT7_CREDIT) - SUM(CT7_DEBITO),2) END  AS SLDPOS 
cQry+=" FROM CT7YS0 CT7P
cQry+=" JOIN CT1YS0 CT1 ON CT1_FILIAL=CT7_FILIAL AND CT1_CONTA=CT7_CONTA
cQry+=" WHERE CT7P.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' 
cQry+=" AND CT7_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'
cQry+=" AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" GROUP BY CT7P.CT7_CONTA,CT1.CT1_DESC04 ) TAB1
cQry+=" JOIN CT1YS0 CT1P ON TAB1.CT7_CONTA= CT1P.CT1_CONTA

cQry+=" WHERE CT1P.CT1_P_CONT<>''
cQry+=" GROUP BY CT1P.CT1_P_CONT,CT1P.CT1_P_DESC
cQry+=" ORDER BY CT1P.CT1_P_CONT

//memowrite("C:\REMESSA\sql.txt",cQry)

if select("QGTIS")>0
	QGTIS->(DbCloseArea())
endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QGTIS", .F., .F. )

return(cQry)                              

//*************************************************************************
//	YS Saldo Anterior
//*************************************************************************
Static function queryYS1(MV_PAR01,MV_PAR02)
Local cQry:=""

cQry+=" SELECT CT1_P_CONT,CT1_P_DESC,SUM(SLDANT) AS SLDANT FROM
cQry+=" (
cQry+=" SELECT CT7_CONTA
cQry+=" ,CT1_DESC04
cQry+=" ,(SELECT CASE WHEN SUBSTRING(CT7_CONTA,1,1)='1' THEN round(CT7_ATUDEB-CT7_ATUCRD,2) ELSE round(CT7_ATUCRD-CT7_ATUDEB,2) END  AS SLDANT FROM CT7YS0
cQry+=" WHERE D_E_L_E_T_='' 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" AND R_E_C_N_O_=(
//cQry+=" SELECT TOP 1(R_E_C_N_O_) FROM CT7YS0 
//cQry+=" WHERE D_E_L_E_T_='' 
//cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
//cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
//cQry+=" ORDER BY 1 DESC
cQry+=" SELECT TOP 1(R_E_C_N_O_) FROM CT7YS0 
cQry+=" WHERE D_E_L_E_T_='' 
cQry+=" AND CT7_DATA = (
cQry+=" SELECT MAX(CT7_DATA) FROM CT7YS0
cQry+=" WHERE D_E_L_E_T_='' 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ')
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" ORDER BY 1 DESC
cQry+=" )

cQry+="  ) AS SLDANT
cQry+=" FROM CT7YS0 CT7P
cQry+=" JOIN CT1YS0 CT1 ON CT1_FILIAL=CT7_FILIAL AND CT1_CONTA=CT7_CONTA
cQry+=" WHERE CT7P.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' 
cQry+=" AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" GROUP BY CT7_CONTA,CT1_DESC04 ) AS TAB2
cQry+=" JOIN CT1YS0 ON TAB2.CT7_CONTA= CT1_CONTA
cQry+=" WHERE CT1_P_CONT<>''
cQry+=" GROUP BY CT1_P_CONT,CT1_P_DESC
cQry+=" ORDER BY CT1_P_CONT

if select("QGTIS1")>0
	QGTIS1->(DbCloseArea())
endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QGTIS1", .F., .F. )


Return(cQry)

//*************************************************************************
//	YC
//*************************************************************************
Static function queryYC(MV_PAR01,MV_PAR02)
Local cQry:=""
/*
cQry+=" SELECT CT1_P_CONT,CT1_P_DESC,SUM(SLDANT) AS SLDANT,SUM(DEBITO) AS DEBITO,SUM(CREDITO) AS CREDITO,SUM(SLDPOS) AS SLDPOS FROM (

cQry+=" SELECT CT7_CONTA
cQry+=" ,CT1_DESC04
cQry+=" ,(SELECT CASE WHEN SUBSTRING(CT7_CONTA,1,1)='1' THEN round(CT7_ATUDEB-CT7_ATUCRD,2) ELSE round(CT7_ATUCRD-CT7_ATUDEB,2) END  AS SLDANT FROM CT7YC0
cQry+=" WHERE D_E_L_E_T_='' 
//cQry+=" AND CT7_DATA = (SELECT MAX(CT7_DATA) AS ULTDATA FROM CT7YC0
//cQry+=" WHERE D_E_L_E_T_='' AND CT7_DATA LIKE '"+SUBSTR(DTOS(MV_PAR01-1),1,6)+"%' AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ') 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" AND R_E_C_N_O_=(

cQry+=" SELECT TOP 1(R_E_C_N_O_) FROM CT7YC0 
cQry+=" WHERE D_E_L_E_T_='' 
//cQry+=" AND CT7_DATA = (SELECT MAX(CT7_DATA) AS ULTDATA FROM CT7YC0
//cQry+=" WHERE D_E_L_E_T_='' AND CT7_DATA LIKE '"+SUBSTR(DTOS(MV_PAR01-1),1,6)+"%' AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ') 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" ORDER BY 1 DESC
cQry+=" )

cQry+="  ) AS SLDANT
cQry+=" ,CASE SUBSTRING(CT7_CONTA,1,1) WHEN '1' THEN SUM(CT7_DEBITO) ELSE SUM(-CT7_DEBITO) END AS DEBITO
cQry+=" ,CASE SUBSTRING(CT7_CONTA,1,1) WHEN '1' THEN SUM(-CT7_CREDIT) ELSE SUM(CT7_CREDIT) END AS CREDITO
cQry+=" , CASE SUBSTRING(CT7_CONTA,1,1) WHEN '1' THEN ROUND(SUM(CT7_DEBITO) - SUM(CT7_CREDIT),2) ELSE ROUND(SUM(CT7_CREDIT) - SUM(CT7_DEBITO),2) END  AS SLDPOS
cQry+=" FROM CT7YC0 CT7P
cQry+=" JOIN CT1YC0 CT1 ON CT1_FILIAL=CT7_FILIAL AND CT1_CONTA=CT7_CONTA
cQry+=" WHERE CT7P.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' 
cQry+=" AND CT7_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'
cQry+=" AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" GROUP BY CT7_CONTA,CT1_DESC04 ) TAB1

cQry+=" JOIN CT1YC0 ON TAB1.CT7_CONTA= CT1_CONTA
cQry+=" WHERE CT1_P_CONT<>''
cQry+=" GROUP BY CT1_P_CONT,CT1_P_DESC
cQry+=" ORDER BY CT1_P_CONT
*/

cQry+=" SELECT CT1P.CT1_P_CONT,CT1P.CT1_P_DESC

cQry+=" ,SUM(DEBITO) AS DEBITO,SUM(CREDITO) AS CREDITO,SUM(SLDPOS) AS SLDPOS FROM (

cQry+=" SELECT CT7P.CT7_CONTA
cQry+=" ,CT1.CT1_DESC04
cQry+=" ,CASE SUBSTRING(CT7P.CT7_CONTA,1,1) WHEN '1' THEN SUM(CT7_DEBITO) ELSE SUM(-CT7_DEBITO) END AS DEBITO
cQry+=" ,CASE SUBSTRING(CT7P.CT7_CONTA,1,1) WHEN '1' THEN SUM(-CT7_CREDIT) ELSE SUM(CT7_CREDIT) END AS CREDITO
cQry+=" , CASE SUBSTRING(CT7P.CT7_CONTA,1,1) WHEN '1' THEN ROUND(SUM(CT7_DEBITO) - SUM(CT7_CREDIT),2) ELSE ROUND(SUM(CT7_CREDIT) - SUM(CT7_DEBITO),2) END  AS SLDPOS 
cQry+=" FROM CT7YC0 CT7P
cQry+=" JOIN CT1YC0 CT1 ON CT1_FILIAL=CT7_FILIAL AND CT1_CONTA=CT7_CONTA
cQry+=" WHERE CT7P.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' 
cQry+=" AND CT7_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'
cQry+=" AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" GROUP BY CT7P.CT7_CONTA,CT1.CT1_DESC04 ) TAB1
cQry+=" JOIN CT1YC0 CT1P ON TAB1.CT7_CONTA= CT1P.CT1_CONTA

cQry+=" WHERE CT1P.CT1_P_CONT<>''
cQry+=" GROUP BY CT1P.CT1_P_CONT,CT1P.CT1_P_DESC
cQry+=" ORDER BY CT1P.CT1_P_CONT

if select("QGTIS")>0
	QGTIS->(DbCloseArea())
endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QGTIS", .F., .F. )

return(cQry)

//*************************************************************************
//	YC Saldo Anterior
//*************************************************************************
Static function queryYC1(MV_PAR01,MV_PAR02)
Local cQry:=""

cQry+=" SELECT CT1_P_CONT,CT1_P_DESC,SUM(SLDANT) AS SLDANT FROM
cQry+=" (
cQry+=" SELECT CT7_CONTA
cQry+=" ,CT1_DESC04
cQry+=" ,(SELECT CASE WHEN SUBSTRING(CT7_CONTA,1,1)='1' THEN round(CT7_ATUDEB-CT7_ATUCRD,2) ELSE round(CT7_ATUCRD-CT7_ATUDEB,2) END  AS SLDANT FROM CT7YC0
cQry+=" WHERE D_E_L_E_T_='' 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" AND R_E_C_N_O_=(
//cQry+=" SELECT TOP 1(R_E_C_N_O_) FROM CT7YC0 
//cQry+=" WHERE D_E_L_E_T_='' 
//cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
//cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
//cQry+=" ORDER BY 1 DESC
cQry+=" SELECT TOP 1(R_E_C_N_O_) FROM CT7YC0 
cQry+=" WHERE D_E_L_E_T_='' 
cQry+=" AND CT7_DATA = (
cQry+=" SELECT MAX(CT7_DATA) FROM CT7YC0
cQry+=" WHERE D_E_L_E_T_='' 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ')
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" ORDER BY 1 DESC
cQry+=" )

cQry+="  ) AS SLDANT
cQry+=" FROM CT7YC0 CT7P
cQry+=" JOIN CT1YC0 CT1 ON CT1_FILIAL=CT7_FILIAL AND CT1_CONTA=CT7_CONTA
cQry+=" WHERE CT7P.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' 
cQry+=" AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" GROUP BY CT7_CONTA,CT1_DESC04 ) AS TAB2
cQry+=" JOIN CT1YC0 ON TAB2.CT7_CONTA= CT1_CONTA
cQry+=" WHERE CT1_P_CONT<>''
cQry+=" GROUP BY CT1_P_CONT,CT1_P_DESC
cQry+=" ORDER BY CT1_P_CONT


if select("QGTIS1")>0
	QGTIS1->(DbCloseArea())
endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QGTIS1", .F., .F. )


Return(cQry)


//*************************************************************************
//	Y5
//*************************************************************************
Static function queryY5(MV_PAR01,MV_PAR02)
Local cQry:=""
/*
cQry+=" SELECT CT1_P_CONT,CT1_P_DESC,SUM(SLDANT) AS SLDANT,SUM(DEBITO) AS DEBITO,SUM(CREDITO) AS CREDITO,SUM(SLDPOS) AS SLDPOS FROM (

cQry+=" SELECT CT7_CONTA
cQry+=" ,CT1_DESC04
//cQry+=" ,(SELECT round(CT7_ATUDEB-CT7_ATUCRD,2) AS SLDANT FROM CT7Y50
cQry+=" ,(SELECT CASE WHEN SUBSTRING(CT7_CONTA,1,1)='1' THEN round(CT7_ATUDEB-CT7_ATUCRD,2) ELSE round(CT7_ATUCRD-CT7_ATUDEB,2) END  AS SLDANT FROM CT7Y50
cQry+=" WHERE D_E_L_E_T_='' 
//cQry+=" AND CT7_DATA = (SELECT MAX(CT7_DATA) AS ULTDATA FROM CT7Y50
//cQry+=" WHERE D_E_L_E_T_='' AND CT7_DATA LIKE '"+SUBSTR(DTOS(MV_PAR01-1),1,6)+"%' AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ') 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" AND R_E_C_N_O_=(

cQry+=" SELECT TOP 1(R_E_C_N_O_) FROM CT7Y50 
cQry+=" WHERE D_E_L_E_T_='' 
//cQry+=" AND CT7_DATA = (SELECT MAX(CT7_DATA) AS ULTDATA FROM CT7Y50
//cQry+=" WHERE D_E_L_E_T_='' AND CT7_DATA LIKE '"+SUBSTR(DTOS(MV_PAR01-1),1,6)+"%' AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ') 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" ORDER BY 1 DESC
cQry+=" )

cQry+="  ) AS SLDANT
cQry+=" ,CASE SUBSTRING(CT7_CONTA,1,1) WHEN '1' THEN SUM(CT7_DEBITO) ELSE SUM(-CT7_DEBITO) END AS DEBITO
cQry+=" ,CASE SUBSTRING(CT7_CONTA,1,1) WHEN '1' THEN SUM(-CT7_CREDIT) ELSE SUM(CT7_CREDIT) END AS CREDITO
cQry+=" , CASE SUBSTRING(CT7_CONTA,1,1) WHEN '1' THEN ROUND(SUM(CT7_DEBITO) - SUM(CT7_CREDIT),2) ELSE ROUND(SUM(CT7_CREDIT) - SUM(CT7_DEBITO),2) END  AS SLDPOS
cQry+=" FROM CT7Y50 CT7P
cQry+=" JOIN CT1Y50 CT1 ON CT1_FILIAL=CT7_FILIAL AND CT1_CONTA=CT7_CONTA
cQry+=" WHERE CT7P.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' 
cQry+=" AND CT7_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' 
cQry+=" AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" GROUP BY CT7_CONTA,CT1_DESC04 ) TAB1

cQry+=" JOIN CT1Y50 ON TAB1.CT7_CONTA= CT1_CONTA
cQry+=" WHERE CT1_P_CONT<>''
cQry+=" GROUP BY CT1_P_CONT,CT1_P_DESC
cQry+=" ORDER BY CT1_P_CONT
*/
cQry+=" SELECT CT1P.CT1_P_CONT,CT1P.CT1_P_DESC

cQry+=" ,SUM(DEBITO) AS DEBITO,SUM(CREDITO) AS CREDITO,SUM(SLDPOS) AS SLDPOS FROM (

cQry+=" SELECT CT7P.CT7_CONTA
cQry+=" ,CT1.CT1_DESC04
cQry+=" ,CASE SUBSTRING(CT7P.CT7_CONTA,1,1) WHEN '1' THEN SUM(CT7_DEBITO) ELSE SUM(-CT7_DEBITO) END AS DEBITO
cQry+=" ,CASE SUBSTRING(CT7P.CT7_CONTA,1,1) WHEN '1' THEN SUM(-CT7_CREDIT) ELSE SUM(CT7_CREDIT) END AS CREDITO
cQry+=" , CASE SUBSTRING(CT7P.CT7_CONTA,1,1) WHEN '1' THEN ROUND(SUM(CT7_DEBITO) - SUM(CT7_CREDIT),2) ELSE ROUND(SUM(CT7_CREDIT) - SUM(CT7_DEBITO),2) END  AS SLDPOS 
cQry+=" FROM CT7Y50 CT7P
cQry+=" JOIN CT1Y50 CT1 ON CT1_FILIAL=CT7_FILIAL AND CT1_CONTA=CT7_CONTA
cQry+=" WHERE CT7P.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' 
cQry+=" AND CT7_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'
cQry+=" AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" GROUP BY CT7P.CT7_CONTA,CT1.CT1_DESC04 ) TAB1
cQry+=" JOIN CT1Y50 CT1P ON TAB1.CT7_CONTA= CT1P.CT1_CONTA

cQry+=" WHERE CT1P.CT1_P_CONT<>''
cQry+=" GROUP BY CT1P.CT1_P_CONT,CT1P.CT1_P_DESC
cQry+=" ORDER BY CT1P.CT1_P_CONT

if select("QGTIS")>0
	QGTIS->(DbCloseArea())
endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QGTIS", .F., .F. )

return(cQry)

//*************************************************************************
//	Y5 Saldo Anterior
//*************************************************************************
Static function queryY51(MV_PAR01,MV_PAR02)
Local cQry:=""

cQry+=" SELECT CT1_P_CONT,CT1_P_DESC,SUM(SLDANT) AS SLDANT FROM
cQry+=" (
cQry+=" SELECT CT7_CONTA
cQry+=" ,CT1_DESC04
cQry+=" ,(SELECT CASE WHEN SUBSTRING(CT7_CONTA,1,1)='1' THEN round(CT7_ATUDEB-CT7_ATUCRD,2) ELSE round(CT7_ATUCRD-CT7_ATUDEB,2) END  AS SLDANT FROM CT7Y50
cQry+=" WHERE D_E_L_E_T_='' 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" AND R_E_C_N_O_=(
//cQry+=" SELECT TOP 1(R_E_C_N_O_) FROM CT7Y50 
//cQry+=" WHERE D_E_L_E_T_='' 
//cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
//cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
//cQry+=" ORDER BY 1 DESC
cQry+=" SELECT TOP 1(R_E_C_N_O_) FROM CT7Y50 
cQry+=" WHERE D_E_L_E_T_='' 
cQry+=" AND CT7_DATA = (
cQry+=" SELECT MAX(CT7_DATA) FROM CT7Y50
cQry+=" WHERE D_E_L_E_T_='' 
cQry+=" AND CT7_DATA <= '"+DTOS(MV_PAR01-1)+"%'
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ')
cQry+=" AND CT7_CONTA = CT7P.CT7_CONTA AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" ORDER BY 1 DESC
cQry+=" )

cQry+="  ) AS SLDANT
cQry+=" FROM CT7Y50 CT7P
cQry+=" JOIN CT1Y50 CT1 ON CT1_FILIAL=CT7_FILIAL AND CT1_CONTA=CT7_CONTA
cQry+=" WHERE CT7P.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' 
cQry+=" AND CT7_MOEDA='01' AND CT7_FILIAL BETWEEN '' AND 'ZZ'
cQry+=" GROUP BY CT7_CONTA,CT1_DESC04 ) AS TAB2
cQry+=" JOIN CT1Y50 ON TAB2.CT7_CONTA= CT1_CONTA
cQry+=" WHERE CT1_P_CONT<>''
cQry+=" GROUP BY CT1_P_CONT,CT1_P_DESC
cQry+=" ORDER BY CT1_P_CONT

if select("QGTIS1")>0
	QGTIS1->(DbCloseArea())
endif

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QGTIS1", .F., .F. )


Return(cQry)

//AXCADASTRO Z96
User function RGTIS002()
AXCADASTRO("Z96")
return
