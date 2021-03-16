#INCLUDE "PROTHEUS.CH"
/*
Funcao      : MATUCOMP
Parametros  : Nil
Retorno     : 
Objetivos   : 
TDN         : Utilizado para alterações automáticas nos complementos dos documentos fiscais após a emissão das Notas Fiscais.
Autor       : INFINIT TECNOLOGIA
Data/Hora   : 
Revisão		: Jean Victor Rocha
Data/Hora   : 05/06/2014
Módulo      : 
*/
*----------------------*
User Function MATUCOMP()
*----------------------*
Local lExiste := .F.

cEntSai := ParamIXB[1]
cSerie  := ParamIXB[2]
cDoc    := ParamIXB[3]
cClifor := ParamIXB[4]
cLoja   := ParamIXB[5]

//AOA - 06/11/2018 - Customização para gravação de código da anvisa de forma automatica na Exeltis
If cEmpAnt $ "LG"
	dbSelectArea("CD7")
	CD7->(dbSetOrder(1))
	//lExiste := CD7->(MsSeek(xFilial("CD7")+ParamIXB[1]+ParamIXB[2]+PADR(ParamIXB[3],TamSX3("CD7_DOC")[1])+ParamIXB[4]+ParamIXB[5]))
	CD7->( dbSeek( xFilial("CD7")+cEntSai+cSerie+cDoc+cClifor+cLoja,.T. ) )	
	While !CD7->( EOF() ) .And. CD7->(CD7_FILIAL+CD7->CD7_TPMOV+CD7_SERIE+CD7_DOC+CD7_CLIFOR+CD7_LOJA) == xFilial("CD7")+cEntSai+cSerie+cDoc+cClifor+cLoja
 
		dbSelectArea("F2Q")
		F2Q->(dbSetOrder(1))
		If FieldPos("F2Q_CODANV") > 0
			If F2Q->(MsSeek(xFilial("F2Q")+CD7->CD7_COD))
				RecLock("CD7",.F.)
				CD7->CD7_CODANV	:= F2Q->F2Q_CODANV
				MsUnlock("CD7")
			EndIf
		EndIf
   		CD7->( dbSkip() )
	EndDo
EndIf
                    
//RRP - 23/07/2014 - Inclusão empresa Exeltis. Chamado 020282 
If !(cEmpAnt $ "JK/SU")
	Return .T.
EndIf
     
If cEntSai == 'S'             
	SB1->( dbSetOrder(1) )
	CD7->( dbSetOrder(1) )
	CD7->( dbSeek( xFilial("CD7")+cEntSai+cSerie+cDoc+cClifor+cLoja,.T. ) )	
	While !CD7->( EOF() ) .And. CD7->(CD7_FILIAL+CD7->CD7_TPMOV+CD7_SERIE+CD7_DOC+CD7_CLIFOR+CD7_LOJA) == xFilial("CD7")+cEntSai+cSerie+cDoc+cClifor+cLoja
        _nAliq  := Posicione("SD2",3, xFilial("SD2")+CD7_DOC+CD7_SERIE+CD7_CLIFOR+CD7_LOJA+CD7->CD7_COD+CD7->CD7_ITEM, "D2_PICM")     
        If _nAliq == 0 .or. _nAliq == 12 .or. _nAliq == 17 .or. _nAliq == 18 .or. _nAliq == 19                                                                            
			_cAliq  := STR((_nAliq))
			SB1->( dbSeek( xFilial("SB1")+CD7->CD7_COD ) )
			// Atualiza preço fabrica
			RecLock("CD7",.F.)
			CD7->CD7_PRECO := &("SB1->B1_XPF"+AllTrim(_cAliq))
			MsUnLock()		
		EndIf
		CD7->( dbSkip() )
	EndDo
EndIf
	
Return .T.