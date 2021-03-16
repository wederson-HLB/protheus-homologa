#include 'totvs.ch'
#Include "topconn.ch"
#Include "rwmake.ch"
#include "fileio.ch"  
#include "protheus.ch"

/*
Funcao      : LGFAT004()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Importação Integração pedido de venda IMS
Autor       : Anderson Arrais
Cliente		: Exeltis
Data/Hora   : 23/10/2017
*/    
*------------------------*
User Function LGFAT004() 
*------------------------*     
Local lOk 			:= .F.
Local cPerg 		:= "LGFAT004"

Private cDirArq		:= ""

If !cEmpAnt $ "SU/LG"//Verifica se é a empresa Exeltis
	MsgInfo("Essa rotina não esta disponivel para essa empresa! Favor entra em contato com a equipe de TI.","HLB BRASIL") 
	Return(.F.)
EndIf

//Verifica os parâmetros do relatório
CriaPerg(cPerg)

If Pergunte(cPerg,.T.)

	//Grava os parâmetros
	cDirArq		:= Alltrim(mv_par01)
    
	If EMPTY(cDirArq)
		MsgInfo("O Diretorio deve ser informado!")
		Return (.F.)
	ElseIf !ExistDir(cDirArq)
		MsgInfo("Diretorio informado não encontrado!")
		Return (.F.)
	EndIf
	
	//Verifica se possir arquivos no diretorio.
	If Len(Directory ( cDirArq+"*.TXT")) == 0
		MsgInfo("Não foi encontrado nenhum arquivo no diretorio informado!")
		Return (.F.)
	EndIf 

	//Gera o Relatório
	Processa({|| lOk := IntPed(cDirArq)},"Importando o txt...")

EndIf

Return Nil  

/*
Função  : IntPed
Objetivo: Integra pedido de venda.
Autor   : Anderson Arrais
Data    : 23/10/2017
*/
*------------------------------*
 Static Function IntPed(cDirArq)
*------------------------------*
Local aCabec	:= {}
Local aLinha	:= {}
Local aItens	:= {}
Local lErro		:= .F.
Local lRet		:= .F.
Local aCpos		:= {}

//Incio Tabela temporária para armazenar os erros
AADD(aCpos,{"SITUACAO","C",10,0})
AADD(aCpos,{"CODIGO","C",10,0})
AADD(aCpos,{"DESCRICAO","C",100,0})
AADD(aCpos,{"MEMO","M",500,0})

If select("WWW")>0
	WWW->(DbCloseArea())
Endif 

Private cArqErro := CriaTrab(aCpos,.t.)   
dbUseArea(.t.,,cArqErro,"WWW",.F.,.F.) 
cArqTErro := CriaTrab(nil,.F.)
IndRegua("WWW", cArqTErro, ("CODIGO"),,,"Selecionando Registros ...",.T.)

cDirArq := ALLTRIM(cDirArq)

//Validação de no minimo um arquivo na pasta
aArquivos := Directory ( cDirArq+"*.TXT")

For i:=1 to Len(aArquivos)  
	cArqAtu := cDirArq+aArquivos[i][1]
	
	FT_FUse(cArqAtu)	 // Abre o arquivo
	FT_FGOTOP()      	 // Posiciona no inicio do arquivo
	
	While !FT_FEof()
	   	cLinha := FT_FReadln()        // Le a linha
		cCod   := SUBSTR(cLinha,1,2)
		
		//Chama execauto
		If cCod $ "02" .AND. LEN(aCabec) <> 0
			lErro 	:= GravPed(aCabec,aItens)
			aCabec	:= {}
			aLinha	:= {}
			aItens	:= {}
		EndIf
		
		If cCod $ "01" //Header
			cCnpj := SUBSTR(cLinha,17,14) 
		EndIf
		
		If cCod $ "02" //Capa
			cSeqNumC5	:= GETSXENUM("SC5","C5_NUM") 
			cTipCli 	:= Posicione("SA1", 1, xFilial("SA1") + SUBSTR(cLinha,22,8), "A1_TIPO")
			cDatEmis 	:= SUBSTR(cLinha,54,4)+SUBSTR(cLinha,52,2)+SUBSTR(cLinha,50,2)
			cDatEnt 	:= SUBSTR(cLinha,128,4)+SUBSTR(cLinha,126,2)+SUBSTR(cLinha,124,2)
			ROLLBACKSXE()
					
			aAdd( aCabec,{"C5_NUM"    	, cValToChar(cSeqNumC5)			,NIL})
			aAdd( aCabec,{"C5_TIPO"   	, SUBSTR(cLinha,21,1)			,NIL})
			aAdd( aCabec,{"C5_TIPOCLI"  , cTipCli  			 			,NIL})
			aAdd( aCabec,{"C5_CLIENTE"	, SUBSTR(cLinha,22,6)			,NIL})
			aAdd( aCabec,{"C5_LOJACLI"	, SUBSTR(cLinha,28,2)			,NIL})
			aAdd( aCabec,{"C5_CONDPAG"	, Alltrim(SUBSTR(cLinha,38,3))	,NIL})    
			aAdd( aCabec,{"C5_VEND1"	, STRZERO(VAL(Alltrim(SUBSTR(cLinha,44,6))),6)  ,NIL})    
			aAdd( aCabec,{"C5_EMISSAO"	, STOD(cDatEmis)				,NIL})    
			aAdd( aCabec,{"C5_FECENT"	, STOD(cDatEnt)					,NIL})    
			aAdd( aCabec,{"C5_MENNOTA"	, Alltrim(SUBSTR(cLinha,58,60))	,NIL})    
			aAdd( aCabec,{"C5_P_REF"	, Alltrim(SUBSTR(cLinha,11,10))	,NIL})    
			aAdd( aCabec,{"C5_TABELA"	, STRZERO(VAL(Alltrim(SUBSTR(cLinha,41,3))),3)	,NIL})    
			aAdd( aCabec,{"C5_TPFRETE"	, "C"	 						,NIL})//precisa colocar no layout    
			aAdd( aCabec,{"C5_ESPECI1"	, "CAIXA" 						,NIL})//precisa colocar no layout    
	
	    EndIf
	        
		If cCod $ "03" //Itens         
			cDescPro 	:= Posicione("SB1", 1, xFilial("SB1") + Alltrim(SUBSTR(cLinha,7,15)), "B1_DESC")
			cQtdVen		:= Alltrim(SUBSTR(cLinha,24,7))+"."+Alltrim(SUBSTR(cLinha,31,2))
			cPrcVen		:= Alltrim(SUBSTR(cLinha,41,10))+"."+Alltrim(SUBSTR(cLinha,51,8))
			cPerDes		:= Alltrim(SUBSTR(cLinha,60,3))+"."+Alltrim(SUBSTR(cLinha,63,2))
			cValDes		:= Alltrim(SUBSTR(cLinha,65,12))+"."+Alltrim(SUBSTR(cLinha,77,2))
			nValTot		:= NOROUND(Val(cQtdVen)*Val(cPrcVen), 2) 
			cLocPro 	:= Posicione("SB1", 1, xFilial("SB1") + Alltrim(SUBSTR(cLinha,7,15)), "B1_LOCPAD")
			
			aLinha := {}				
			aAdd( aLinha,{"C6_ITEM"		, SUBSTR(cLinha,5,2)			,NIL})
			aAdd( aLinha,{"C6_PRODUTO"	, Alltrim(SUBSTR(cLinha,7,15))	,NIL})
			aAdd( aLinha,{"C6_DESCRI"	, Alltrim(cDescPro)				,NIL})
			aAdd( aLinha,{"C6_QTDVEN"	, Val(cQtdVen)					,NIL})
			aAdd( aLinha,{"C6_PRCVEN"	, Val(cPrcVen)					,NIL})
			aAdd( aLinha,{"C6_VALOR"	, nValTot 						,NIL})
			aAdd( aLinha,{"C6_OPER"		, "01"							,Nil})
			aAdd( aLinha,{"C6_LOCAL"	, cLocPro 						,NIL})
			aAdd( aLinha,{"C6_PEDCLI"	, Alltrim(SUBSTR(cLinha,82,12))	,NIL})
			aAdd( aLinha,{"C6_XDESCO1"	, Val(cPerDes)					,NIL})
			aAdd( aLinha,{"C6_VALDES1"	, Val(cValDes) 					,NIL})
	        aAdd( aItens,aLinha)  
	
		EndIf
		
		FT_FSkip()	//Proxima linha	
		
	EndDo
	
	If LEN(aCabec) <> 0
		lErro 	:= GravPed(aCabec,aItens)
		aCabec	:= {}
		aLinha	:= {}
		aItens	:= {}
	EndIf

Next i
	
If lErro
	Situacao2()	
Else
	lRet := .T.
	msginfo("PROCESSADO COM SUCESSO!","HLB")
EndIf
	
Return lRet 
 
/*
Função  : GravPed
Objetivo: Grava pedido de venda na base via execauto
Autor   : Anderson Arrais
Data    : 24/10/2017
*/
*-------------------------------------*
 Static Function GravPed(aCabec,aItens)
*-------------------------------------*
Local lErro	   		:= .F.

Private lMsErroAuto:= .F.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

	MSExecAuto( {|x,y,z| MATA410(x,y,z) }, aCabec, aItens, 3)

	If lMsErroAuto
		ROLLBACKSXE()		  		
	  	cErroCon	:= ""
		aAutoErro 	:= GETAUTOGRLOG()
	    cErroCon	:= XLOG(aAutoErro)
	    
	    lErro:=.T.
	    DisarmTransaction()
    		Reclock("WWW",.T.)
	    	WWW->SITUACAO	:= "Erro"
	    	WWW->CODIGO		:= alltrim(aCabec[1][1])
	    	WWW->DESCRICAO	:= STRTRAN(cErroCon,CHR(13)+CHR(10))
	    	WWW->MEMO		:= XLOGMEMO(aAutoErro) 
	    WWW->(MsUnlock())
  	Else
	    Confirmsx8()    	
	EndIF //lMsErroAuto

Return(lErro)

/*
Funcao      : XlogMEMO()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar o log de erro para campo memo, para todos.
Autor       : Matheus Massaroto
Data/Hora   : 12/07/212 18:15
*/
*----------------------------------*
Static Function XLOGMEMO(aAutoErro)  
*----------------------------------*     
LOCAL cRet := ""
LOCAL nX := 1

FOR nX := 1 to Len(aAutoErro)
	cRet+=aAutoErro[nX]+CRLF
NEXT nX                        

RETURN cRet
 
/*
Funcao      : Situacao2()
Parametros  : aErros,aGravado
Retorno     : Nenhum
Objetivos   : Gera um Dialog com ListBox, com arquivos que deram ERRO, e OK. Para todos Versão 2.
Autor       : Matheus Massaroto
Data/Hora   : 12/07/2012 18:15
*/
*------------------------------------------*
Static Function Situacao2()
*------------------------------------------*
Private _oDlg,oListBox
Private aListBox:={}
Private cNick   := "Pedido" 
Private aHeader	:={}
Private aAlter	:={"M_MEMO"}
Private	nUsado	:=0
Private aCols	:={}
Private cTipo   := "2"

Private aRotina := {{"Pesquisar"	, "AxPesqui", 0, 1},;
					{"Visualizar"	, "AxVisual", 0, 2},;
					{"Incluir"		, "AxInclui", 0, 3},;
					{"Alterar"		, "AxAltera", 0, 4},;
					{"Excluir"		, "AxDeleta", 0, 5}}

//--Montagem do aHeader com os campos que serão apresentados--//
			AADD(aHeader,{ TRIM("Situacao"),;
								 "M_SITU",;
								 "@X  ",;
								 10,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Codigo"),;
								 "M_COD",;
								 "@X  ",;
								 10,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    
		    nUsado:=nUsado+1
			
			AADD(aHeader,{ TRIM("Descricao"),;
								 "M_DESC",;
								 "@X  ",;
								 100,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("Detalhes_Dois_Cliques"),;
								 "M_MEMO",;
								 "@X  ",;
								 0,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "M",;
			 					 "",;
			 					 "" } )			 					 
			nUsado:=nUsado+1
//--Fim Montagem do aHeader com os campos que serão apresentados--//

DbSelectArea("WWW")
WWW->(DbGoTop())

While WWW->(!EOF())
	AADD(aCols,Array(nUsado+1))
		for nI:=1 to nUsado
			if ALLTRIM(aHeader[nI,2]) =="M_SITU"
				aCols[Len(aCols)][nI]:=WWW->SITUACAO
			elseif ALLTRIM(aHeader[nI,2]) =="M_COD"
				aCols[Len(aCols)][nI]:=WWW->CODIGO
			elseif ALLTRIM(aHeader[nI,2]) =="M_DESC"
				aCols[Len(aCols)][nI]:=WWW->DESCRICAO
			elseif ALLTRIM(aHeader[nI,2]) =="M_MEMO"
				aCols[Len(aCols)][nI]:=WWW->MEMO
			endif
		next
	aCols[Len(aCols)][nUsado+1] := .F.
	WWW->(DbSkip())
Enddo

DEFINE MSDIALOG _oDlg TITLE cNick FROM C(178),C(180) TO C(565),C(966) PIXEL

	@ C(180),C(250) Button "&Excel" Size C(037),C(012) PIXEL OF _oDlg action(ImprimeEx(cNick,cTipo))
	@ C(180),C(300) Button "&Imprimir" Size C(037),C(012) PIXEL OF _oDlg action(Imprime(cNick,cTipo))
	@ C(180),C(350) Button "&Sair" Size C(037),C(012) PIXEL OF _oDlg action(_oDlg:end())

  	oGetDados := MsGetDados():New(15, 05, 210, 500, 2, "AllwaysTrue()", "AllwaysTrue()",;
	"", .T., aAlter, , .F., 999, "AllwaysTrue()", "AllwaysTrue()",,;
	"AllwaysTrue()", _oDlg)
   
ACTIVATE MSDIALOG _oDlg CENTERED 

Return

/*
Funcao      : Xlog()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar o log de erro, para todos
Autor       : Matheus Massaroto
Data/Hora   : 09/02/11 18:15
*/
*-------------------------------*
 Static Function XLOG(aAutoErro)  
*-------------------------------*     
    LOCAL cRet := ""
    LOCAL nX := 1
 	FOR nX := 1 to Len(aAutoErro)
 		If nX==1
 			cRet+=alltrim(substr(aAutoErro[nX],at(CHR(13)+CHR(10),aAutoErro[nX]),len(aAutoErro[nX]))+"; ")
    	else
    		If at("Invalido",aAutoErro[nX])>0
    			cRet += alltrim(aAutoErro[nX])+"; "
            EndIf
        EndIf
    NEXT nX
RETURN cRet 

/*
Função  : CriaPerg
Objetivo: Verificar se os parametros estão criados corretamente.
Autor   : Anderson Arrais
Data    : 23/10/2017
*/
*--------------------------------*
 Static Function CriaPerg(cPerg)
*--------------------------------*
Local lAjuste := .F.

Local nI := 0

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
Local aSX1    := {{"01","Diretorio do Arquivo?"  }}
  					
//Verifica se o SX1 está correto
SX1->(DbSetOrder(1))
For nI:=1 To Len(aSX1)
	If SX1->(DbSeek(PadR(cPerg,10)+aSX1[nI][1]))
		If AllTrim(SX1->X1_PERGUNT) <> AllTrim(aSX1[nI][2])
			lAjuste := .T.
			Exit	
		EndIf
	Else
		lAjuste := .T.
		Exit
	EndIf	
Next

If lAjuste

    SX1->(DbSetOrder(1))
    If SX1->(DbSeek(AllTrim(cPerg)))
    	While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)

			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(MsUnlock())
    	
    		SX1->(DbSkip())
    	EndDo
	EndIf	
	
	aHlpPor := {}
	Aadd( aHlpPor,"Diretorio dos arquivos de origem ")
	Aadd( aHlpPor,"Para ser integrado.")
	
	U_PUTSX1(cPerg,"01","Diretorio do Arquivo?","Diretorio do Arquivo ?","Diretorio do Arquivo ?","mv_ch1","C",60,0,0,"G","","","","S","mv_par01","","","","C:\","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
			
EndIf
	
Return Nil
