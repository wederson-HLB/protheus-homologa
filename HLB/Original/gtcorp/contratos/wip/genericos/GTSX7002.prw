#Include "Protheus.ch"

/*
Funcao      : GTSX7002
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gatilhar o imposto
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 19/11/2013    14:28
Módulo      : Genérico
*/

*-------------------------*
User Function GTSX7002()
*-------------------------*
Local nRet	:= val(STRTRAN(GETMV("MV_P_IMPOS"),",",".")) 
   //referenciado           //Tp. cobrança
if M->Z55_GLOBAL=="1" .AND. M->Z55_GLOCOB =="2"

	nRet:=5
	   //referenciado           //Tp. cobrança
elseif M->Z55_GLOBAL=="2" //.AND. M->Z55_GLOCOB =="1"
       //Tipo de cobrança
	if M->Z55_COBTIP =="2"
		nRet:=5
       //Tipo de cobrança
    elseif empty(M->Z55_COBTIP) .OR. M->Z55_COBTIP =="1"
	    //se for cliente
	    if !empty(M->Z55_CLIENT)
	    	DbSelectArea("SA1")
	    	SA1->(DbSetOrder(1))
	    	if DbSeek(xFilial("SA1")+M->Z55_CLIENT+M->Z55_LOJA)
	    		//pessoa fisica
	    		if SA1->A1_PESSOA=="F"
					nRet:=5
	    		else
				    nRet:=val(STRTRAN(GETMV("MV_P_IMPOS"),",","."))   		
	    		endif
	    		
	    	endif
	    //Se for prospect
	    elseif !empty(M->Z55_PROSPE)
	    	DbSelectArea("SUS")
	    	SUS->(DbSetOrder(1))
	    	if DbSeek(xFilial("SUS")+M->Z55_PROSPE+M->Z55_PLOJA)
	    		//pessoa fisica	    		
	    		if SUS->US_TPESSOA=="PF"
					nRet:=5
	    		else
				    nRet:=val(STRTRAN(GETMV("MV_P_IMPOS"),",","."))   		
	    		endif
	    		
	    	endif
	    else
		    nRet:=val(STRTRAN(GETMV("MV_P_IMPOS"),",","."))
	    endif
	    
    endif
else
   nRet:=val(STRTRAN(GETMV("MV_P_IMPOS"),",","."))  
endif


Return(ROUND(nRet,2))