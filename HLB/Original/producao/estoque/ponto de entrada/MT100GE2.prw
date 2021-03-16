#Include 'Protheus.ch'

/*
Funcao      : MT100GE2()
Objetivos   : Localização.: Function A103AtuSE2 - Rotina que efetua a integração entre o documento de entrada e os títulos financeiros a pagar. 
Finalidade  : Complementar a gravação na tabela dos títulos financeiros a pagar. 
Autor       : João Silva	
Data/Hora   : 30/09/2015
*/       

*-----------------------*
User Function MT100GE2()
*-----------------------*
Local aCols		:= PARAMIXB[1]
Local aHeadSE2	:= PARAMIXB[3]
Local aAreaSD1	:= {}
Local aAreaSE2	:= {}        

Local nOpc		:= PARAMIXB[2]
Local nPos		:= Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_HIST'})
Local nPos1		:= Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_P_FOPAG'})//AOA - 28/08/2017 - Solaris inclusão do campo forma de pagamento

Local cQuery	:= ""
Local cCentCus	:= ""

If nOpc == 1 //.. inclusao
	SE2->E2_HIST:=aCols[nPos]
EndIf

//AOA - 28/08/2017 - Solaris inclusão do campo forma de pagamento
If nOpc == 1 .AND. cEmpAnt $ "HH/HJ"//.. inclusao
	SE2->E2_P_FOPAG:=aCols[nPos1]
EndIf

//RRP - 11/10/2015 - Tratamento para empresa Zoom (Mosaico)
If cEmpAnt == "B1"
	If nOpc == 1 //Inclusão
	    
	    //Inicio da gravação do centro de custo no título do Financeiro
		aAreaSD1 :=	SD1->(GetArea("SD1"))
		aAreaSE2 :=	SE2->(GetArea("SE2"))
		
		//Carregar o centro de custo do Documento de Entrada
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			cCentCus := SD1->D1_CC
		EndIf
		SD1->(DbCloseArea())				
		
		//Verificando se o Alias está em uso
		If Select("QSE2")>0
			QSE2->(DbCloseArea())
		EndIf                                 
		
		//Procurando títulos gerados pela nota listando o R_E_C_N_O_
		cQuery:=" SELECT R_E_C_N_O_ FROM "+RETSQLNAME("SE2")
		cQuery+="  WHERE E2_FILIAL='"+xFilial("SE2")+"' AND E2_PREFIXO='"+SE2->E2_PREFIXO+"' AND E2_NUM='"+SE2->E2_NUM+"'"
			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "QSE2" ,.T.,.F.)
		
		//Preenchendo o Centro de Custo no Financeiro
		QSE2->(DbGoTop())
		While QSE2->(!EOF())
			//Utilizando o DbGoTo para posicionar em um registro através do R_E_C_N_O_
			SE2->(DbGoTo(QSE2->R_E_C_N_O_))
			SE2->(RecLock("SE2"),.F.)
				SE2->E2_CCC := cCentCus
			SE2->(MsUnLock())
			QSE2->(DbSkip())
		EndDo				
		
		QSE2->(DbCloseArea())
		
		RestArea(aAreaSD1)
		RestArea(aAreaSE2)
	EndIf
EndIf

Return Nil