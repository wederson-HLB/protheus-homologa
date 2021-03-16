#include "Protheus.ch"
#Include "Topconn.ch"

/*
Funcao      : GTGEN001
Parametros  : __cUserId ,cUserName,cCompName,cCgc,cDoc,cSerie,cEspecie,cEmp,cFil,aCond,aItensD2,cCliSF2,cLojaSF2,cEmpNome,dData,aErros,nOpc,cPara
Retorno     : aErros
Objetivos   : Função do execauto do MATA103, utilizado no faturamento para os clientes GT, onde é executado na base do cliente para gerar automaticamente o documento de entrada, o contas a pagar, e a contabilidade.
Autor       : Matheus Massarotto
Data/Hora   : 25/04/2012    15:41
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/
*---------------------------------------------------------------------------------------------------------------------------------------------------------*
User Function GTGEN001(__cUserId ,cUserName,cCompName,cCgc,cDoc,cSerie,cEspecie,cEmp,cFil,aCond,aItensD2,cCliSF2,cLojaSF2,cEmpNome,dData,aErros,nOpc,cPara)
*---------------------------------------------------------------------------------------------------------------------------------------------------------*
Local aTotItem:={}
Local lRet1:=.T.	//variável para controle de processamento
Local nOpc:=nOpc
Local cEmp:=cEmp
Local cFil:=cFil

Local lContabil:=.T.
Local cPreSel:=""		//para tratar a exibição dos lançamentos contábeis
Local cPreSel1:=""	//para tratar a contabilização on-line
Local aDadTemp:={}
Local lContinua:=.T.

Local cCodFor:=""
Local cLojaFor:=""
Local cCondPag:="" //para armazenar a condição de pagamento

Local cItem:="0000"

Local cNomEmpDes:=SM0->M0_NOME
//Local dDataGer:=IIF(nOpc==3,ddatabase,dData)
Local dDataGer:=dData

Local nMeter1:=1,oMeter1,nProReg:=1
//Local oDlg, oSay                 

Private aItem 		:= {}
Private cEspecie	:=IIF(UPPER(ALLTRIM(cEspecie))=="RPS","NFS",cEspecie) //MSM - 04/11/2013 - Alterado para NFS, Chamado: 014701
Private cNatureza	:=IIF(UPPER(ALLTRIM(cEspecie))=="ND","2601","4602")

Private cProduto	:= ""
Private cItemCont	:= ""
Private cClvl		:= ""
Private cCentroC	:= ""

conout("Entrou no process")

/*++++++++++++++++++++++ Tratamento para fornecedor +++++++++++++++++++++++++++++++++++*/                                                                                   
DbSelectArea("SA2")
SA2->(DbSetOrder(3))
if DbSeek(xFilial("SA2")+cCgc)
	cCodFor:=SA2->A2_COD
	cLojaFor:=SA2->A2_LOJA
else
	AADD(aErros,{"ERRO",cmodulo,cFil,cDoc,cSerie,cCliSF2,cLojaSF2,"",0,"Cadastro de fornecedor para o cnpj:"+alltrim(cCgc)+" não encontrado.",date(), dDataGer ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmp, cFil,cEmpAnt,cFilAnt,cCliSF2,cLojaSF2,cEmpNome,cNomEmpDes,cCodFor,cLojaFor}) 
	lContinua:=.F.
endif

//** tratamento para a condição de pagamento
cQry:=" SELECT E4_CODIGO,E4_TIPO,E4_COND FROM "+RETSQLNAME("SE4")+CRLF
cQry+=" WHERE D_E_L_E_T_='' AND E4_TIPO='"+aCond[2]+"' AND E4_COND='"+aCond[3]+"' AND E4_FILIAL='"+xFilial("SE4")+"'"
			
if select("TRBSE4_")>0
	TRBSE4_->(DbCloseArea())
endif
						
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBSE4_",.T.,.T.)

COUNT TO nRecCount
        
if nRecCount>0
	TRBSE4_->(DbGotop())
	cCondPag:=TRBSE4_->E4_CODIGO
else
	//** Se não encontrar a condição no cliente insere.
	If select("TRBSE41")>0
		TRBSE41->(DbCloseArea())
	EndIf
	cQry := " SELECT MAX(E4_CODIGO) AS COND FROM "+RETSQLNAME("SE4")
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBSE41",.T.,.T.)
	COUNT TO nRecCount
	If nRecCount>0
		TRBSE41->(DbGotop())
		SE4->(DbSetOrder(1))
		SE4->(RECLOCK("SE4",.T.))
		SE4->E4_FILIAL	:= xFilial("SE4")
		SE4->E4_CODIGO	:= SOMA1(TRBSE41->COND)
		SE4->E4_TIPO	:= aCond[2]
		SE4->E4_COND	:= aCond[3]
		SE4->E4_DESCRI	:= aCond[4]
		SE4->E4_ACRES	:= "N"
		SE4->(MsUnlock())
		cCondPag:=SE4->E4_CODIGO
	EndIf
EndIf

if lContinua    
     //validacao da data (nOpc, Data, exibe ou n a mensagem de erro)
	if !CtbValiDt(nOpc,dDataGer,.F.)
		lContabil:=.F.
		/*ocorrência | Módulo | descrição | Data do computador | Data sistema | hora | Código do usuário | usuário | ambiente | nome computador | Empresa Logada | Filial Logada | Empresa Destino | Filial Destino */
		AADD(aErros,{"ERRO","CTB",cFil,cDoc,cSerie,cCliSF2,cLojaSF2,"",0,"Contabilidade: Calendário fechado, periodo não permite digitação, data: "+DtoC(dDataGer),date(), dDataGer ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmp, cFil,cEmpAnt,cFilAnt,cCliSF2,cLojaSF2,cEmpNome,cNomEmpDes,cCodFor,cLojaFor})
	endif     

	aCab := {{"F1_FILIAL"       ,xFilial("SF1")     ,Nil},;
		     {"F1_TIPO"			,"N"                ,Nil},;
		     {"F1_DOC"          ,cDoc               ,Nil},;
		     {"F1_SERIE"		,cSerie             ,Nil},;
		     {"F1_EMISSAO"      ,dDataGer          	,Nil},;
		     {"F1_FORNECE"      ,cCodFor            ,Nil},;
		     {"F1_LOJA"         ,cLojaFor           ,Nil},;
		     {"F1_ESPECIE"      ,cEspecie           ,Nil},;
		     {"F1_FORMUL"       ,"N"               	,Nil},;
		     {"F1_COND"			,cCondPag			,NIL},;
			 {"E2_NATUREZ"		,cNatureza			,NIL}}
          
	for nJ_:=1 to len(aItensD2)
		cProduto	:=QualProd(aItensD2[nJ_][1],cSerie)	
		cItemCont	:= ""
		cClvl		:= ""
		cCentroC	:= ""
		SB1->(DbSetOrder(1))
		if SB1->(DbSeek(xFilial("SB1")+cProduto))
			cItemCont	:= SB1->B1_ITEMCC
			cClvl		:= SB1->B1_CLVL
			cCentroC	:= SB1->B1_CC
		endif
		aItem := {}	          
		cItem:=SOMA1(cItem)
		aadd(aItem,{"D1_FILIAL" 	,xFilial("SD1")						,Nil})
		aadd(aItem,{"D1_ITEM" 		,cItem								,Nil})
		aadd(aItem,{"D1_COD"     	,cProduto							,Nil})
		aadd(aItem,{"D1_QUANT"   	,aItensD2[nJ_][2]					,Nil})
		aadd(aItem,{"D1_VUNIT"   	,aItensD2[nJ_][3]					,Nil})
		aadd(aItem,{"D1_TOTAL"   	,aItensD2[nJ_][4]					,Nil})
		aadd(aItem,{"D1_TES"     	,"1BF"          					,Nil})
		aadd(aItem,{"D1_ITEMCTA"    ,cItemCont         					,Nil})
		aadd(aItem,{"D1_CC"     	,cCentroC          					,Nil})
		aadd(aItem,{"D1_CLVL"     	,cClvl          					,Nil})			        			     
		AADD(aTotItem,aItem)
	next

	//tratamento para exibição dos lançamentos contábeis.
	SX1->(DbSetOrder(1))
	if SX1->(DbSeek("MTA103    01"))
		cPreSel := SX1->X1_PRESEL
		SX1->(RecLock("SX1",.F.))
		SX1->X1_PRESEL:=2
		SX1->(MsUnlock())
	endif
	//contabiliza off-line
	If !lContabil
		If SX1->(DbSeek("MTA103    06"))
			cPreSel1 := SX1->X1_PRESEL
			SX1->(RecLock("SX1",.F.))
			SX1->X1_PRESEL := 2
			SX1->(MsUnlock())
		endif
	endif
	
	Private lMsErroAuto:=.F.
	Private lMSHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	
	BEGIN TRANSACTION
		MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aTotItem,nOpc)
		//tratamento para voltar a exibição dos lançamentos contábeis.
		SX1->(DbSetOrder(1))
		If SX1->(DbSeek("MTA103    01"))
			SX1->(RecLock("SX1",.F.))
			SX1->X1_PRESEL := cPreSel
			SX1->(MsUnlock())
		endif
		//tratamento para voltar a contabilização on/off-line como estava
		If !lContabil
			If SX1->(DbSeek("MTA103    06"))
				SX1->(RecLock("SX1",.F.))
				SX1->X1_PRESEL := cPreSel1
				SX1->(MsUnlock())
			endif
		endif
		
		IF lMsErroAuto
			//MostraErro('SYSTEM','CSISVOO.LOG')
		    aAutoErro := GETAUTOGRLOG()
	        CONOUT("GTGEN001 - ERRO NO PROCESSAMENTO DO EXECAUTO")
	  	    cErroCon:=XLOG(aAutoErro) 
		  	AADD(aErros,{"ERRO",cmodulo,cFil,cDoc,cSerie,cCliSF2,cLojaSF2,"",0,STRTRAN(cErroCon,CHR(13)+CHR(10)),date(), dDataGer ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmp, cFil,cEmpAnt,cFilAnt,cCliSF2,cLojaSF2,cEmpNome,cNomEmpDes,cCodFor,cLojaFor}) 
	        CONOUT(STRTRAN(cErroCon,CHR(13)+CHR(10)))
	        CONOUT(GetComputerName())
	        DisarmTransaction()
			// MostraErro()
		    lRet1:=.F.      
		ELSE
			ConfirmSX8()
			CONOUT("GTGEN001 - NOTA GERADA VIA EXECAUTO")
		    if nOpc==3
		    	AADD(aErros,{"","FAT",SF1->F1_FILIAL,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_TIPO,SF1->(RECNO()),;
		    				"Nota Fiscal Gerada, nota: "+SF1->F1_DOC+", série: "+SF1->F1_SERIE,;
		    				date(), dDataGer ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmp, cFil,cEmpAnt,cFilAnt,cCliSF2,cLojaSF2,cEmpNome,cNomEmpDes,cCodFor,cLojaFor})
			else
				AADD(aErros,{"","FAT",SF1->F1_FILIAL,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_TIPO,SF1->(RECNO()),;
							"Nota Fiscal Excluída, nota: "+SF1->F1_DOC+", série: "+SF1->F1_SERIE,;
							date(), dDataGer ,time(), __cUserId ,cUserName,GetEnvServer(),cCompName,cEmp, cFil,cEmpAnt,cFilAnt,cCliSF2,cLojaSF2,cEmpNome,cNomEmpDes,cCodFor,cLojaFor})
			endif
		ENDIF
	END TRANSACTION            
EndIf

if len(aErros)>0
	if empty(aErros[len(aErros)][1])
		CONOUT("GTGEN001 - ENVIO DE EMAIL, sem erros")
		U_GTGEN002(cPara,aErros,nOpc,1)
	endif
endif

AADD(aErros,{lRet1})

Return(aErros)

/*
Funcao      : XLOG()  
Parametros  : aAutoErro
Retorno     : cRet
Objetivos   : Busca o erro gerado no msexecauto
Autor       : Matheus Massarotto
Data/Hora   : 13/02/2012
*/
*-----------------------------*
Static Function XLOG(aAutoErro)
*-----------------------------*
LOCAL cRet := ""
LOCAL nX := 1
FOR nX := 1 to Len(aAutoErro)
 	If nX==1
		cRet+=substr(aAutoErro[nX],at(CHR(13)+CHR(10),aAutoErro[nX]),len(aAutoErro[nX]))+"; "
	else
   		If at("Invalido",aAutoErro[nX])>0
			cRet += alltrim(aAutoErro[nX])+"; "
		EndIf
		If at("Erro",aAutoErro[nX])>0
			cRet += alltrim(aAutoErro[nX])+"; "
		EndIf
	EndIf
NEXT nX
RETURN cRet

/*
Funcao      : XLOG()  
Parametros  : cSerie
Retorno     : cRet
Objetivos   : Verificar qual produto deve ser utilizado
Autor       : Matheus Massarotto
Data/Hora   : 29/05/2012
*/
*------------------------------------*
Static Function QualProd(cProd,cSerie)
*------------------------------------*
Local cRet:=""

/*   DE										Para
200001	LOCOMOCAO                     		DE000004       
200002	TELEFONE                      		DE000038       
200003	MATL ESCRITORIO               		DE000001       
200004	DESP.LEGAIS                   		DE000040       
200005	CORREIO/MALOTE                		DE000039       
200007	GUARDA DE DOCUMENTO           		DE000012       
200008  SERVICOS TERCEIROS            		DE000050       
200010	MOTOBOY                       		DE000039       
200011	REFEICOES                     		DE000032       
200020	IMPRESSAO                     		DE000001       
*/
if UPPER(alltrim(cSerie))=="ND"
	if UPPER(alltrim(cProd))=="200001"
		cRet:="DE000004"
	elseif UPPER(alltrim(cProd))=="200002"
		cRet:="DE000038"
	elseif UPPER(alltrim(cProd))=="200003"
		cRet:="DE000001"
	elseif UPPER(alltrim(cProd))=="200004"
		cRet:="DE000040"
	elseif UPPER(alltrim(cProd))=="200005"
		cRet:="DE000039"
	elseif UPPER(alltrim(cProd))=="200007"
		cRet:="DE000012"
	elseif UPPER(alltrim(cProd))=="200008"
		cRet:="DE000051"
	elseif UPPER(alltrim(cProd))=="200010"
		cRet:="DE000039"
	elseif UPPER(alltrim(cProd))=="200011"
		cRet:="DE000032"
	elseif UPPER(alltrim(cProd))=="200020"
		cRet:="DE000001"
	else
		cRet:="DE000051"
	endif								
else
	cRet:="DE000050"
endif

Return(cRet)