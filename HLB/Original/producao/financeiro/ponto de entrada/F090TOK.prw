#Include "Protheus.ch"

/*
Funcao      : F090TOK
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Ponto de entrada, para bloquear a baixa do contas a pagar automatico de acordo com a data
TDN			: 
Autor       : Matheus Massarotto
Revis?o	    :
Data/Hora   : 11/11/2015  18:39
M?dulo      : Financeiro
*/                      
*----------------------*
User Function F090TOK
*----------------------*
Local lRet		:= .T.
Local dDataBlq	:= SUPERGETMV("MV_P_00061", .F. , CTOD("//") )
Local dDataBx	:= dBaixa

if !empty(dDataBlq)

	DbSelectArea("SX6")
	SX6->(DbSetOrder(1))
	if SX6->(DbSeek(xFilial("SX6")+"MV_P_00061"))
		if SX6->X6_TIPO == "D" 
		
			if dDataBx<=dDataBlq
			    Aviso("Bloqueio Fiscal/Cont?bil (MV_P_00061) - HLB","Baixas bloqueadas para datas anteriores a "+DTOC(dDataBlq),{"Ok"})
			    lRet := .F.
		    endif
	    
	    else
			Aviso("Bloqueio Fiscal/Cont?bil (MV_P_00061) - HLB","Par?metro MV_P_00061 n?o ? do tipo data!",{"Ok"})	    	
	    endif
	endif
    
endif

Return(lRet)