#Include "Protheus.ch" 

/*
Funcao      : M030INC 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E.  
Autor       : 
Data/Hora   :   
Obs         : 
TDN         : Este Ponto de Entrada � chamado ap�s a inclus�o dos dados do cliente no Arquivo.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 18/07/2012
Obs         :
M�dulo      : Faturamento.
Cliente     : GTCorp	
*/


*----------------------*
 User Function M030INC          
*----------------------*

//RRP - 10/06/2013 - Altera��o conforme chamado 012604.
//If cEmpAnt $ "Z4|ZB|Z8|ZG|CH|Z6|Z5|ZP|RH"
If !(cEmpAnt) $ "Z3/1T/Z5/ZD"
 
	If ParamIXB == 1 

			DbSelectArea("CTD")
			DbGotop()
			DbSetOrder(1)
			If (DbSeek(xFilial("CTD")+SA1->A1_COD))
	        	Alert("O c�digo: "+SA1->A1_COD+" j� existe no Item Cont�bil;"+CRLF+"Os dados n�o ser�o inseridos no Item Cont�bil!")
			    Return(.T.)
			EndIf
					
			xAutoCab:={}
			
			AADD(xAutoCab,{"CTD_ITEM" 	, SUBSTR(SA1->A1_COD,1,6) 	, Nil})
			AADD(xAutoCab,{"CTD_CLASSE" , "2" 						, Nil})
			AADD(xAutoCab,{"CTD_DESC01" , SUBSTR(SA1->A1_NOME,1,40) 	, Nil})
			AADD(xAutoCab,{"CTD_BLOQ" 	, SUBSTR(SA1->A1_MSBLQL,1,1) 	, Nil})
			AADD(xAutoCab,{"CTD_DTEXIS" , CTOD("01/01/80") 			, Nil})
			AADD(xAutoCab,{"CTD_ITLP" 	, SUBSTR(SA1->A1_COD,1,6) 	, Nil})
			
			lMsErroAuto:= .f.
			
			MsExecAuto({|x,y| Ctba040(x,y)}, xAutoCab, 3)
			                 
			If lMsErroAuto
				//msginfo("N�o foi possivel gerar item cont�bil referente!")
			    //MOSTRAERRO()
			EndIf    
	EndIf
EndIf
	
Return(.T.)