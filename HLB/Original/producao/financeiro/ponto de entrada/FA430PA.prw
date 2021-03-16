#Include "Protheus.ch"

/*
Funcao      : FA430PA
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada, retorno cnab a pagar, para bloquear a baixa do contas a pagar automatico de acordo com a data
TDN			: 
Autor       : Matheus Massarotto
Revisão	    : Leandro Brito ( adaptação através do fonte F090TOK.PRW )
Data/Hora   : 15/01/2016  18:39
Módulo      : Financeiro
*/                                        
Static lPrimeira
*----------------------*
User Function FA430PA
*----------------------*
Local lRet		:= .T.
Local dDataBlq	:= SUPERGETMV("MV_P_00061", .F. , CTOD("//") )
Local dDataBx	:= dBaixa

If !Empty( dDataBlq ) //.And. ( cEmpAnt $ '40/49' ) .And. Upper( AllTrim( GetEnvServer() ) ) == 'P11_TESTED'  

	If ( lPrimeira == Nil )
		lPrimeira := .T.
	EndIf
		
	SX6->(DbSetOrder(1))
	if SX6->(DbSeek(xFilial("SX6")+"MV_P_00061"))
		if SX6->X6_TIPO == "D" 
		
			if dDataBx<=dDataBlq
			    If lPrimeira
			    	Aviso("Bloqueio Fiscal/Contábil (MV_P_00061) - HLB","Baixas bloqueadas para datas anteriores a "+DTOC(dDataBlq),{"Ok"})
			    	lPrimeira := .F.
			    EndIf
			    lRet := .F.
		    endif
	    
	    else
			If lPrimeira
				Aviso("Bloqueio Fiscal/Contábil (MV_P_00061) - HLB","Parâmetro MV_P_00061 não é do tipo data!",{"Ok"})	    	
				lPrimeira := .F.
			EndIf
	    endif
	endif
    
endif

Return(lRet)