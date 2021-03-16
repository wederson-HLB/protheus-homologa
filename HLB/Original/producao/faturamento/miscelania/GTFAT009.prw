#include "protheus.ch"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "APWIZARD.CH" 
#INCLUDE "FWBROWSE.CH"
#INCLUDE "XMLXFUN.CH"

/*
Funcao      : GTFAT009
Parametros  : 
Retorno     : 
Objetivos   : Importação de xml, para pedido de venda.
Autor       : Jean Victor Rocha
Data/Hora   : 24/07/2014
*/

*----------------------*
User Function GTFAT009()
*----------------------*
Private cCadastro := "Importação XML"
Private aLegenda := {	{"BR_VERDE"   	,"Importado"},;
		   		  		{"BR_VERMELHO"	,"Falha na importação."},;
		   		  		{"BR_AZUL"		,"Importado anteriormente"}} 
				  		
Private cMarca   := GetMark() 

//Chamo o wizard de processamento
InWizard()

Return .T.


/*
Metodo      : GravaRem
Classe      : 
Descrição   : Gravação do Arquivo de Remessa na Tabela de log
Autor       : Jean Victor Rocha
Data        : 09/09/2013
*/ 
/*
*------------------------*
Static Function GravaRem()
*------------------------*   
If Select("TMP") > 0
	("TMP")->(DbClosearea())
Endif				                                
cQryTmp := "Select * From "+RETSQLNAME("Z59")
cQryTmp += " Where D_E_L_E_T_ <> '*'"
cQryTmp += "       AND Z59_ROTINA = 'GTFAT005'"
cQryTmp += "       AND Z59_CHAVE = '"+(cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+"'"

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)
    
TMP->(DbGoTop())
While TMP->(!EOF())
	Z59->(DbGoTo(TMP->R_E_C_N_O_))
	Z59->(RecLock("Z59",.F.))
	Z59->(DbDelete())
	Z59->(MsUnlock())
	TMP->(DbSkip())	
EndDo
                  
//Realiza a gravação
Z59->(RecLock("Z59",.T.))
Z59->Z59_FILIAL := xFilial("Z59")
Z59->Z59_ID     := GetSXeNum("Z59","Z59_ID")
Z59->Z59_DATA   := dDataBase
Z59->Z59_HORA   := Time()
Z59->Z59_USER   := cUserName
Z59->Z59_NOMARQ := aArq[1]
Z59->Z59_CONARQ := aArq[2]
Z59->Z59_ROTINA := "GTFAT005"
Z59->Z59_LOG    := aChaveLog[aScan(aChaveLog, {|x|  x[1] == (cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)})][3]
Z59->Z59_SEQUEN := StrZero(1,3)
Z59->Z59_TABELA := "SF1"
Z59->Z59_ORDEM  := 1
Z59->Z59_CHAVE  := (cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)
Z59->Z59_TIPO   := aChaveLog[aScan(aChaveLog, {|x|  x[1] == (cAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)})][2]
Z59->(MsUnlock()) 

ConfirmSX8("Z59")

Return .T.
*/


/*
Funcao      : GetDir
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function GetDir()
*---------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := cDir
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD

cDir := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

Return

/*
Funcao      : InWizard()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard inicial para o usuário informar os dados básicos para o processamento
Autor       : Matheus Massarotto
Data/Hora   : 24/10/2013
*/
*--------------------------*
Static function InWizard()
*--------------------------*
Local oWizard
Local lWiz	:= .F.
Local aSize     := {}
Local aObjects	:= {}

Local aCores    := {{"CSTATUS == '1'", "BR_VERDE"   	},;
					{"CSTATUS == '2'", "BR_VERMELHO"	},;
					{"CSTATUS == '3'", "BR_AZUL"		},;
					{"CSTATUS == '4'", "BR_LARANJA"		},;
					{"CSTATUS == '5'", "BR_BRANCO"		}}
					
Private cAlias := "TMPNFTS"

Private oBrowse
Private cDir 	:= ""
                     
Private aHoBrw1 := {}
Private aCoBrw1 := {}
Private oBrw1

cGet1 := Space(5)
dGet2 := CTOD("  /  /  ")
dGet3 := CTOD("  /  /  ")
cGet4 := Space(3)
//cGet5 := "2"
cGet5:=space(30)
cGet6:=space(30)

cGet2_1:=space(200)
aItens1_1:={"xml"}
cGet7:=aItens1_1[1]

cMemo1_1:=""

// Faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize()
AAdd( aObjects, { 100, 20, .T., .T. } )
AAdd( aObjects, { 100, 60, .T., .T. } )    
AAdd( aObjects, { 100, 20, .T., .T. } )

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

chTitle	:= "Importação de pedido de venda"
chMsg	:= "Selecione os parâmetros para auxílio ao processamento."
cTitle	:= ""

cText	:= ""

bNext	:= {||  iif(empty(cGet2_1),(MsgInfo("Preencha o local do(s) arquivo(s)!","HLB BRASIL"),.F.) ,(Barpross(cGet2_1,oWizard,@oBrowse),.T.) )}
bFinish	:= {|| .T.}
lPanel	:= .T.
cResHead	:="fw_totvs_logo_61x27.png"
bExecute 	:= {||.T.}
lNoFirst	:= .T. 
aCoord		:= {aSize[7],0,aSize[6],aSize[5]}

oWizard:=ApWizard():New (  chTitle  ,  chMsg  ,  cTitle  ,  cText  ,  bNext  ,  bFinish  ,  lPanel  ,  cResHead  ,  bExecute  ,  lNoFirst , aCoord   )
	
nColIni1:=aPosObj[1][4]/4
nColIni2:=aPosObj[2][4]/4

oSay7     	:= TSay():New(aPosObj[2][1]+37,nColIni1+008,{||"Tipo arquivo:"},oWizard:oMPanel[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)

oCBox1_1	:= TComboBox():New(aPosObj[2][1]+37,nColIni1+088,{|u|if(PCount()>0,cGet7:=u,cGet7)},aItens1_1,100,010,oWizard:oMPanel[1],,,,,,.T.,,,,,,,,,"cGet7")

oGrp2      	:= TGroup():New( aPosObj[2][1],nColIni2,aPosObj[2][3]-50,aPosObj[2][4]- nColIni2,"",oWizard:oMPanel[1],CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay2_1     := TSay():New( aPosObj[2][1]+17,nColIni2+008,{||"Local do(s) arquivo(s):"},oWizard:oMPanel[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oGet2_1		:= TGet():New(aPosObj[2][1]+15,nColIni2+088,{|u| if(PCount()>0,cDir:=cGet2_1:=u,cDir:=cGet2_1)}, oWizard:oMPanel[1],150,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet2_1')

oTButton3 := TBtnBmp2():New( aPosObj[2][3]*0.7,nColIni2+248+400,25,25, 'FOLDER12' , , , , {||AbreArq(@cGet2_1,oGet2_1)}, oWizard:oMPanel[1], , ,.T.,.T.)//oTButton3 := TBtnBmp2():New( aPosObj[2][1]+190,nColIni2+248+390,25,25, 'FOLDER12' , , , , {||AbreArq(@cGet2_1,oGet2_1)}, oWizard:oMPanel[2], , ,.T.,.T.)
	
oGet2_1:Disable()


cTitle	:= "Resultado do processamento"
cMsg	:= ""
bBack 	:= {||.F.}
bNext   := {|| }
bFinish	:= {||(lWiz := .T.,.T.)}
lPanel	:= .T.
bExecute:= {|| .T.}

//Painel 2             
oWizard:NewPanel ( cTitle , cMsg , bBack , bNext , bFinish , lPanel , bExecute )

//Criação do temporário
aStruQry := {}

aAdd(aStruQry,{"CSTATUS"	,"C",1,0})
aAdd(aStruQry,{"TPNOTA"		,"C",10,0})
aAdd(aStruQry,{"NOTA"		,"C",Tamsx3("F2_DOC")[1],Tamsx3("F2_DOC")[2]})
aAdd(aStruQry,{"SERIE"		,"C",Tamsx3("F2_SERIE")[1],Tamsx3("F2_SERIE")[2]})
aAdd(aStruQry,{"CGCCLI"		,"C",Tamsx3("A1_CGC")[1],Tamsx3("A1_CGC")[2]})
aAdd(aStruQry,{"NOMECLI"	,"C",Tamsx3("A1_NOME")[1],Tamsx3("A1_NOME")[2]})
aAdd(aStruQry,{"TES"		,"C",Tamsx3("D2_TES")[1],Tamsx3("D2_TES")[2]})
aAdd(aStruQry,{"DATEMI"		,"D",Tamsx3("F2_EMISSAO")[1],Tamsx3("F2_EMISSAO")[2]})
aAdd(aStruQry,{"CFOP"		,"C",4,0})
aAdd(aStruQry,{"NATOPER"	,"C",30,0})
aAdd(aStruQry,{"ARQUIVO"	,"C",80,0})
aAdd(aStruQry,{"OBS"		,"C",30,0})
aAdd(aStruQry,{"MEMO"		,"M",8,0})
//aAdd(aStruQry,{"RECZ59"		,"C",6,0})

cArqTmp		:= CriaTrab(aStruQry,.T.)		

if select(cAlias)>0
	(cAlias)->(DbCloseArea())
endif

dbUseArea(.T.,__LocalDriver,cArqTmp,cAlias,.T.,.F.)
dbCreateInd(cArqTmp+OrdBagExt(),"NOTA+SERIE", {|| "NOTA+SERIE"})

	//Criação do browse
	Brow(oWizard:oMPanel[2],,@oBrowse)

oWizard:oDlg:lEscClose := .F.
//oWizard:OMPANEL[1]:OWND:LMAXIMIZED:=.T.
//oWizard:OMPANEL[2]:OWND:LMAXIMIZED:=.T.

//ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. } 
lCenter	:=.T.
bValid	:= {|| .T.}
bInit	:= {|| .T.}
bWhen	:= {|| .T.} 

aCordAnt:={oWizard:ODLG:NLEFT,oWizard:ODLG:NTOP,oWizard:ODLG:NRIGHT,oWizard:ODLG:NHEIGHT}

oWizard:Activate ( lCenter , bValid , bInit , bWhen )


if lWiz

//GeraRemMain()

endif

Return


/*
Funcao      : AbreArq()
Parametros  : 
Retorno     : 
Objetivos   : Função para abrir tela com o selecionador do local onde será salvo
Autor       : Matheus Massarotto
Data/Hora   : 24/10/2013	11:10
*/
*----------------------------------*
Static Function AbreArq(cGet2,oGet2)
*----------------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local cPastaTo    := ""
Local nDefaultMask := 0
Local cDefaultDir  := "C:\"
Local nOptions:= GETF_LOCALHARD+GETF_RETDIRECTORY

//Exibe tela para gravar o arquivo.
cGet2 := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

oGet2:Refresh()

Return


/*
Funcao      : Brow()
Parametros  : oMeter
Retorno     : 
Objetivos   : Função o browse
Autor       : Matheus Massarotto
Data/Hora   : 21/05/2013	11:10
*/

*-------------------------------------------*
Static function Brow(oWin,aCpos,oBrowse)
*-------------------------------------------*
Local oTBtnBmp1,oTBar
//Local cMarca   := GetMark() 
// Define o Browse	
DEFINE FWBROWSE oBrowse DATA TABLE ALIAS cAlias OF oWin			

//Adiciona coluna para status
ADD STATUSCOLUMN oColumn DATA { || iif(CSTATUS=='1','BR_VERDE',(iif(CSTATUS=='2','BR_VERMELHO',iif(CSTATUS=='3','BR_AZUL',iif(CSTATUS=='4','BR_LARANJA',iif(CSTATUS=='5','BR_BRANCO',) ) ) ) ) ) } DOUBLECLICK { |oBrowse| /* Função executada no duplo clique na coluna*/ } OF oBrowse

ADD COLUMN oColumn DATA { || TPNOTA   	} TITLE 'Tipo'	      DOUBLECLICK  {||  } ALIGN 1 SIZE 10 OF oBrowse
ADD COLUMN oColumn DATA { || NOTA   	} TITLE 'Nota'	      DOUBLECLICK  {||  } ALIGN 1 SIZE Tamsx3("F2_DOC")[1] OF oBrowse  
ADD COLUMN oColumn DATA { || SERIE 		} TITLE 'Serie'  	  DOUBLECLICK  {||  } ALIGN 1 SIZE Tamsx3("F2_SERIE")[1] OF oBrowse  
ADD COLUMN oColumn DATA { || CGCCLI   	} TITLE 'CPF/CNPJ'    DOUBLECLICK  {||  } ALIGN 1 SIZE Tamsx3("A1_CGC")[1] OF oBrowse  
ADD COLUMN oColumn DATA { || NOMECLI   	} TITLE 'Nome' 		  DOUBLECLICK  {||  } ALIGN 1 SIZE 30 OF oBrowse  
ADD COLUMN oColumn DATA { || TES   		} TITLE 'Tes' 		  DOUBLECLICK  {||  } ALIGN 1 SIZE Tamsx3("D2_TES")[1] OF oBrowse  
ADD COLUMN oColumn DATA { || DATEMI 	} TITLE 'Emissao'	  DOUBLECLICK  {||  } ALIGN 1 SIZE Tamsx3("F2_EMISSAO")[1] OF oBrowse  
ADD COLUMN oColumn DATA { || CFOP	    } TITLE 'CFOP'		  DOUBLECLICK  {||  } ALIGN 1 SIZE 4 OF oBrowse  
ADD COLUMN oColumn DATA { || NATOPER    } TITLE 'Nat. Oper.'  DOUBLECLICK  {||  } ALIGN 1 SIZE 30 OF oBrowse  
ADD COLUMN oColumn DATA { || ARQUIVO    } TITLE 'Arquivo'  	  DOUBLECLICK  {||  } ALIGN 1 SIZE 80 OF oBrowse 
ADD COLUMN oColumn DATA { || OBS    	} TITLE 'Observação'  DOUBLECLICK  {|| VerMemo((cAlias)->(MEMO))  } ALIGN 1 SIZE 30 OF oBrowse  


// Ativação do Browse	
ACTIVATE FWBROWSE oBrowse

//Bara de botões do browse esquerdo
oTBar := TBar():New( oWin,45,32,.T.,,,,.F. )
oTBtnBmp1 := TBtnBmp() :NewBar('SVM',,,,'Legenda',{||FAT009L()},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
oTBtnBmp1:cTooltip:="Legenda"  

//oTBtnBmp2 := TBtnBmp() :NewBar('BMPVISUAL',,,,'Visualizar Doc.',{||WaitAxVi()},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
//oTBtnBmp2:cTooltip:="Visualizar Doc."  

//oTBtnBmp3 := TBtnBmp() :NewBar('HISTORIC',,,,'Historico',{||VerLog()},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
//oTBtnBmp3:cTooltip:="Historico"  

//oTBtnBmp4 := TBtnBmp() :NewBar('SDURECALL',,,,'Transmitir',{||GeraRem()},.F.,oTBar,.T.,{||.T.},,.F.,,,1,,,,,.T. )
//oTBtnBmp4:cTooltip:="Transmitir"  


Return(.T.)

/*
Funcao      : Barpross()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 16/05/2013	15:14
*/
*---------------------------------------------------*
Static Function Barpross(cDiretorio,oWizard,oBrowse)
*---------------------------------------------------*
Local oDlg1
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.
Local oObjAux 	:= oWizard:GetPanel(1)
    
	//Desabilito a tela onde a barra de processamento esá sendo executada
	oObjAux:Disable()
	oObjAux:Refresh()

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg1 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg1,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(lRet:=ImportarNf(oMeter,cDiretorio,oDlg1,@oBrowse))
	  
	//***********************************************************

Return(lRet)


/*
Funcao      : GravaLog()
Parametros  : 
Retorno     : 
Objetivos   : Grava o log na tabela Z59
Autor       : Matheus Massarotto
Data/Hora   : 25/06/2013	15:14
*/
*------------------------------------------*
Static function GravaLog(cNomeArq,cConteudo,cRotina,cErroLog,aArray)
*------------------------------------------*
Local oLog

DEFAULT aArray	:= {}
DEFAULT cErroLog	:= ""
DEFAULT cRotina	:= ""

//AADD(aArray,{ERROTRB->TABELA,val(ERROTRB->ORDEM),ERROTRB->CHAVE,ERROTRB->TIPOLOG})

if !empty(aArray)
	oLog:=GtIntLog():New(cNomeArq,cConteudo,cRotina,cErroLog,aArray)
endif

Return

/*
#################### Novas funções
*/
                                  
/*
Funcao      : ImportarNf
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina Principal 
Autor       : Jean Victor Rocha
Data/Hora   : 08/07/2014
*/
*--------------------------------------------------*
Static Function ImportarNf(oRegua,cDiretorio,oDlg1,oBrowse)
*--------------------------------------------------*
Local oNFe
Local oXml
Local aNFS		  := {}
Local aNF		  := {}
Local lAuto 	  := .T.
Local lExibErro   := .F.
Local lNfe        := .F.
Local nX

Private _cMeuCnpj := SM0->M0_CGC
Private aNewClie  := {}
Private aNewForn  := {}

Private cDirXML := Alltrim(cDiretorio)
Private aArqXml := ExtraiArq(@cDirXml)

If Len(aArqXml) == 0
	MsgInfo("Não foi encontrado arquivo no diretorio informado, favor verificar!","HLB BRASIL")
	oDlg1:end()
	Return .F.
EndIf

//Inicia a régua
oRegua:Set(0)

//Tratamento Especifico no Arquivo XML.
EditTag("PUT")

//oRegua:SetRegua1(4)
If Len(aArqXml)>0
	//oRegua:IncRegua1("Importando XML...")
	//oRegua:SetRegua2(Len(aArqXml))

	nAumenta:=100/Len(aArqXml)

	For nX := 1 to Len(aArqXml)
		//oRegua:IncRegua2("Lendo e Importando XML "+AllTrim(Str(nX))+"/"+AllTrim(Str(Len(aArqXml)))+"...")
		 
  	    //Processamento da régua
		nCurrent:= Eval(oRegua:bSetGet) // pega valor corrente da régua
		nCurrent+=nAumenta 	// atualiza régua
		oRegua:Set(nCurrent) //seta o valor na régua
		
		lNfe := .F.
		oXml := OpenXml(cDirXml+aArqXml[nX,01])
		
		//--> Servico
		If XmlChildEx(oXML, "_COMPNFSE") <> Nil
			If oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CNPJ:TEXT == SM0->M0_CGC
				ExtrNfServ(oXml,@aNFS,cDirXml+aArqXml[nX,01])
			Else
				aAdd( aLogXML , { "SERVIÇO","NFS-e não pertence a este cliente",cDirXml+aArqXml[nX,01],.F.} )
			EndIf
		EndIf
		
		//--> Produto
		If XmlChildEx(oXML, "_NFEPROC")  <> Nil
			oNFe := IIf(Type("oXml:_nfeProc:_NFe:_infNFe")=="U",oXml:_nfeProc:_NFe:_infNFe,oXml:_NFe:_infNFe)
			If Alltrim(oNFe:_EMIT:_CNPJ:TEXT)<>Alltrim(_cMeuCnpj) .And.;
					 IIf(Type("oNFe:_DEST:_CNPJ:TEXT")=="U",oNFe:_DEST:_CPF:TEXT,oNFe:_DEST:_CNPJ:TEXT)==Alltrim(_cMeuCnpj)
				lNfe := .T.
			EndIf
			If Alltrim(oNFe:_EMIT:_CNPJ:TEXT)==Alltrim(_cMeuCnpj)
				lNfe := .T.
			EndIf
			If lNfe
				ExtrNfProd(oXml,@aNF ,cDirXml+aArqXml[nX,01])
			Else
				aAdd( aLogXML , { "PRODUTO","NF-e não petrence a este cliente",cDirXml+aArqXml[nX,01],.F.} )
			EndIf
			
		EndIf
		
	Next nX
EndIf
/*
If Len(aNFS)+Len(aNF) > 0
//	oRegua:IncRegua1("Montando os Dados Para Classificação das NF's...")
//	ClassNf(@aNF,@aNFS,@oRegua)
	If Len(aNFS)+Len(aNF) == 0
		//Tratamento Especifico no Arquivo XML.
		EditTag("REMOVE")
		Return
	EndIf
Else
	MsgAlert("Não Há Documentos XML para Importar !")
	//Tratamento Especifico no Arquivo XML.
	EditTag("REMOVE")
	Return
EndIf
*/

if Len(aNFS)+Len(aNF) > 0 //.And. MsgYesNo("Confirma a geração das notas fiscais importadas pela leitura dos XMLs ?")
	//oRegua:SetRegua1(Len(aNFS)+Len(aNF))
	//->> Notas de Serviço
	If Len(aNFS)>0
		ProcXmlServ(lAuto,aNFS,@oRegua,lExibErro)
	EndIf
	//->> Notas de Produto
	If Len(aNF)>0
		ProcXmlProd(lAuto,aNF,@oRegua,lExibErro)
	EndIf
/*	If Len(aNFS)+Len(aNF) <> nServ+nProd
		Aviso( "Atenção" , "Foram submetidas a importação "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos e "+Alltrim(Str(Len(aNFS)))+"  nota(s) de serviços, contudo foram importadas "+Alltrim(Str(nProd))+" de produtos e "+Alltrim(Str(nServ))+" de serviços."+CRLF+"Vide Log de Eventos.", { 'Ok' } , 2 , "Importações de XML" )
	Else
		Aviso( "Atenção" , "Foram submetidas a importação "+Alltrim(Str(Len(aNF)))+" nota(s) de produtos e "+Alltrim(Str(Len(aNFS)))+"  nota(s) de serviços, com 100% de aproveitamento nas importacoes.", { 'Ok' } , 2 , "Importações de XML" )
	EndIf
*/
else
	MsgAlert("Nenhum documento xml foi importado.")
endif

//Tratamento Especifico no Arquivo XML.
EditTag("REMOVE")

//Finaliza a barra de processamento
oDlg1:End()
oBrowse:Refresh(.T.)

Return .T.


/*
Funcao      : ExtraiArq
Parametros  : Nil
Retorno     : Nil
Objetivos   : VAI USAR - Rotina de identificação dos arquivos na pasta 
Autor       : Jean Victor Rocha
Data/Hora   : 08/07/2014
*/
*------------------------------------*
Static Function ExtraiArq(cDirOrigXml)
*------------------------------------*
Local aArquivos := {}
Local aArqTemp	:= {}
Local cArquivo	:= ""
Local cPasta	:= ""
Local nX		:= 0
Local cDirTmp 	:= ""

cDirTmp := Alltrim(cDirOrigXml)

If Right(cDirTmp,1)=="\"
	cDirTmp:=SubStr(cDirTmp,1,Len(cDirTmp)-1)
EndIf

If !File(cDirTmp)
	cPasta := cGetFile(cDirTmp,"Selecione a pasta para seleção automática dos XMLs...",,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
Else
	cPasta := cDirOrigXml
EndIf

aArqTemp := Directory(cPasta+'\*.xml')
ASort( aArqTemp ,,, {|x,y| x[1] < y[1]} )

For nX:=1 to Len(aArqTemp)
	aAdd(aArquivos,{aArqTemp[nX,01]})
Next nX

cDirOrigXml := cPasta

Return aArquivos

/*
Funcao      : EditTag
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina Especifica de ajuste de Arquivo
Autor       : Jean Victor Rocha
Data/Hora   : 08/07/2014
*/
*----------------------------*
Static Function EditTag(cTipo)
*----------------------------*
Local i
Local lNfeProc	:= .F.
Local oFT		:= fT():New()//FUNCAO GENERICA

Do Case
	Case cTipo == "PUT"   //----------------------------------------------------------------------------------
		If cEmpAnt $ "46"
			For i:=1 to len(aArqXml)
				If oFT:FT_FUse(cDirXML+aArqXml[i][1]) < 0
					loop
				EndIf
				oFT:FT_FGOTOP()// Posiciona no inicio do arquivo
				nLin := 0
				While !oFT:FT_FEof()
					oFT:NBUFFERSIZE := 9999999
				   	cLinha := oFT:FT_FReadln()
					nLin++

					//Tratamento da Tag de NFEPROC
					If nLin == 1 .and. AT(UPPER("<nfeProc"),UPPER(cLinha)) == 0
						If File(cDirXML+SUBSTR(aArqXml[i][1],1,LEN(aArqXml[i][1])-4)+"_GTFAT009.XML")
							FERASE(cDirXML+SUBSTR(aArqXml[i][1],1,LEN(aArqXml[i][1])-4)+"_GTFAT009.XML")
						EndIf
						lNfeProc := .T.
						GrvNewArq(SUBSTR(aArqXml[i][1],1,LEN(aArqXml[i][1])-4)+"_GTFAT009.XML",'<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="2.00">')
					EndIf
					
					//Tratamento do Conteudo da Tag, evitando vir caracter invalido.
					If AT(UPPER("<natOp>"),UPPER(cLinha)) <> 0
						GrvNewArq(SUBSTR(aArqXml[i][1],1,LEN(aArqXml[i][1])-4)+"_GTFAT009.XML",STRTRAN(cLinha,CHR(160),""))
					Else
						GrvNewArq(SUBSTR(aArqXml[i][1],1,LEN(aArqXml[i][1])-4)+"_GTFAT009.XML",cLinha)
					EndIf

					oFT:FT_FSkip()	//Proxima linha
				Enddo
				If lNfeProc
			   		GrvNewArq(SUBSTR(aArqXml[i][1],1,LEN(aArqXml[i][1])-4)+"_GTFAT009.XML",'</nfeProc>')
				EndIf				
				oFT:FT_FUse()//Fecha o arquivo
                oFT:New() //Reinicia o objeto
				
				aArqXml[i][1] := SUBSTR(aArqXml[i][1],1,LEN(aArqXml[i][1])-4)+"_GTFAT009.XML"
			Next i
		EndIf

	Case cTipo == "REMOVE"//----------------------------------------------------------------------------------
		If cEmpAnt $ "46"
			For i:=1 to len(aArqXml)
				If AT("_GTFAT009.XML",cDirXML+aArqXml[i][1]) <> 0
					FERASE(cDirXML+aArqXml[i][1])
				EndIf
			Next i
		EndIf
EndCase

Return .T.

/*
Funcao      : GrvNewArq
Parametros  : Nil
Retorno     : Nil
Objetivos   : Rotina de tratamento do arquivo temporario a ser criado, caso seja tratado o conteudo do arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 11/07/2014
*/
*----------------------------------*
Static Function GrvNewArq(cArq,cMsg)
*----------------------------------*
Local nHdl	:= Fopen(cDirXML+cArq)

If !File(cDirXML+cArq)
	nHdl	:= FCREATE(cDirXML+cArq,0 )  //Criação do Arquivo
	FWRITE(nHdl, cMsg )
	fclose(nHdl)
EndIf

FSeek(nHdl,0,2)
FWRITE(nHdl, cMsg )
fclose(nHdl)

Return            


/*
Funcao      : ProcXmlServ
Objetivos   : Processamento da Importacao.
*/
*-----------------------------------------------------*
Static Function ProcXmlServ(lAuto,aNF,oRegua,lExibErro)
*-----------------------------------------------------*
Local nX	:= 0
Local lOK	:= .T.
Local cNewArq := ""

Default lAuto := .F.
//Default oRegua:= ""

/*If !lAuto .And. Valtype(oRegua)=="O"
	oRegua:SetRegua2(Len(aNF))
EndIf
*/
For nX:=1 to Len(aNF)
 	If !lAuto
/*		If Valtype(oRegua)=="O"
			If oRegua:lEnd
				lEnd := .T.
				Exit
			EndIf
			oRegua:IncRegua1("Importação de XML...")
			oRegua:IncRegua2("Gerando notas...")
			lOK:=GeraNFS(aNF[nX],lAuto,lExibErro,oRegua)
		Else
			Processa( { || lOK:=GeraNFS(aNF[nX],lAuto,lExibErro,oRegua) } , 'Aguarde...' , 'Gerando Notas' )
		EndIf
*/
	Else
		lOK:=GeraNFS(aNF[nX],lAuto,.F.,oRegua)
	EndIf
	If lOK
		cNewArq := SubStr(aNF[nX,24],1,Len(aNF[nX,24])-3)+"PROC"
		FRename(aNF[nX,24],cNewArq)
	EndIf
Next nX

Return

/*
Funcao      : OpenXml
Objetivos   : Abertura do arquivo XML.
*/
*-------------------------------*
Static Function OpenXml(cArquivo)
*-------------------------------*
Local oXml
Local nTerHdl    := 0
Local nTamArq    := 0
Local xBuffer
Local cStrXml    := ''
Local cArqTmpXml := CriaTrab(,.F.)+".xml"
Local cStartPath := Alltrim(GetSrvProfString("StartPath",""))
Local cError     := ""
Local cWarning   := ""
Local aXml

cStartPath:=cStartPath+If(Right(cStartPath,1)=="\","","\")

nTerHdl := fOpen(cArquivo,2+64)
If nTerHdl <= 0
	MsgStop('O arquivo não pode ser encontrado no local indicado.'+CRLF+'"'+cArquivo+'"'+CRLF)
	Return(.F.)
EndIf

nTamArq := fSeek(nTerHdl,0,2)
xBuffer := Space(nTamArq)

fSeek(nTerHdl,0,0)
fRead(nTerHdl,@xBuffer,nTamArq)

cStrXml := xBuffer

fClose(nTerHdl)

nTerHdl := FCreate(cArqTmpXml)
fWrite(nTerHdl,cStrXml)
fClose(nTerHdl)

oXml := XmlParserFile( cStartPath+cArqTmpXml , "_" , @cError , @cWarning )

fClose(cArqTmpXml)

Return(oXml)

/*
Funcao      : ExtrNfServ
Objetivos   : Extrai dados da NF do XML de serviços.
VAI USAR
*/
*--------------------------------------------*
Static Function ExtrNfServ(oXml,aNFS,cArquivo)
*--------------------------------------------*
Local aPrestador 	:= {}
Local aTomador 		:= {}
Local aDados		:= {}

If Valtype(oXml)=="O" .And. !Empty(oXml:_COMPNFSE:_NFSE:_INFNFSE:_NUMERO:TEXT)
	//->> Dados do Prestador de Servico
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_CONTATO:_EMAIL:TEXT})  																					// 01 Email
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_CONTATO:_TELEFONE:TEXT}) 																				// 02 Telefone
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_BAIRRO:TEXT})																					// 03 Bairro
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_CEP:TEXT})																						// 04 CEP
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_CODIGOMUNICIPIO:TEXT})																			// 05 Codigo Municipio
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_CODIGOPAIS:TEXT})																				// 06 Codigo Pais
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_COMPLEMENTO:TEXT})																				// 07 Complemento Endereco
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_ENDERECO:TEXT})																				// 08 Endereco
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_NUMERO:TEXT}) 																					// 09 Numero
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_ENDERECO:_UF:TEXT})																						// 10 UF
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT})																		// 11 Cnpj
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_INSCRICAOMUNICIPAL:TEXT})														// 12 Insc. Municipal
	aAdd(aPrestador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_RAZAOSOCIAL:TEXT})																						// 13 Razao Social
	
	//->> Dados do Tomador de Servico
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_CONTATO:_EMAIL:TEXT}) 									// 01 Email
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_CONTATO:_TELEFONE:TEXT}) 								// 02 Telefone
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_BAIRRO:TEXT}) 								// 03 Bairro
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CEP:TEXT}) 									// 04 CEP
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CODIGOMUNICIPIO:TEXT}) 						// 05 Codigo Municipio
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_CODIGOPAIS:TEXT}) 							// 06 Codigo Pais
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_COMPLEMENTO:TEXT}) 							// 07 Complemento
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_ENDERECO:TEXT}) 								// 08 Endereco
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:_NUMERO:TEXT}) 								// 09 Numero
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_ENDERECO:TEXT}) 											// 10 UF
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CNPJ:TEXT}) 						// 11 CNPJ
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_INSCRICAOMUNICIPAL:TEXT}) 		// 12 Insc Municipal
	aAdd(aTomador,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_RAZAOSOCIAL:TEXT}) 										// 13 Razao Social
	
	//->> Dados da Nota de Servico
	If Alltrim(oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT)==Alltrim(_cMeuCnpj)
		/*01*/ aAdd(aDados,"SAIDA")	// 01 Tipo da geracao da NFS
	Else
		/*01*/ aAdd(aDados,"ENTRADA") 	// 01 Tipo da geracao da NFS
	EndIf
	/*02*/ aAdd(aDados, StrZero(Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_NUMERO:TEXT), Len(SF1->F1_DOC) ) ) 																		// 02 Numero da Nota
	/*03*/ aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_RPS:_IDENTIFICACAORPS:_SERIE:TEXT) 							// 03 Serie
	/*04*/ aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_ITEMLISTASERVICO:TEXT) 								// 04 Codigo Serviço
	/*05*/ aAdd(aDados,CtoD(Left(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DATAEMISSAO:TEXT,10)) )					 																	// 05 Emissao
	/*06*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORSERVICOS:TEXT)) 					// 06 Valor Total da Nota
	/*07*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_ALIQUOTA:TEXT))		 															   						// 07 Aliquota ISS
	/*08*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_BASECALCULO:TEXT))																   						// 08 Base Calculo
	/*09*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_VALORISS:TEXT))																	   						// 09 Valor ISS
	/*10*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_VALORESNFSE:_VALORLIQUIDONFSE:TEXT))																					// 10 Valor Liquido
	/*11*/ aAdd(aDados,oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_CODIGOCNAE:TEXT)										// 11 cNae
	//->> Montagem Geral do Array de Nota
	/*12*/ aAdd(aDados,aPrestador) 		// Dados do Prestador
	/*13*/ aAdd(aDados,aTomador)		// Dados do Tomador
	/*14*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORPIS:TEXT))							// 14 Valor do PIS
	/*15*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORCOFINS:TEXT))						// 15 Valor do Cofins
	/*16*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORCSLL:TEXT))							// 16 Valor do CSLL
	/*17*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORINSS:TEXT))							// 17 Valor do INSS
	/*18*/ aAdd(aDados,Val(oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORIR:TEXT))							// 18 Valor do IR
	/*19*/ aAdd(aDados,If(aDados[1]=="ENTRADA",	oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_IDENTIFICACAOTOMADOR:_CNPJ:TEXT,;
	oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_PRESTADOR:_CNPJ:TEXT)) 				//19 Cnpj da Filial pertencente a nota na Keeptrue
	/*20*/ aAdd(aDados,Criavar("D1_TES"))							// 20 TES
	/*21*/ aAdd(aDados,Criavar("F1_COND"))							// 21 Cond. Pgto
	/*22*/ aAdd(aDados,Criavar("E2_NATUREZ"))						// 22 Natureza
	/*23*/
	If Alltrim(oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CNPJ:TEXT)==Alltrim(_cMeuCnpj)
		aAdd(aDados,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_PRESTADORSERVICO:_RAZAOSOCIAL:TEXT})
	Else
		aAdd(aDados,{oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:_RAZAOSOCIAL:TEXT})
	EndIf
	/*Nota pertence a*/
	/*24*/ aAdd(aDados,cArquivo)									// 24 Arquivo
	
	aAdd(aNFS,aDados)
EndIf

Return




/*
Funcao      : ExtrNfProd
Objetivos   : Extrai dados da NF do XML de produtos.
VAI USAR
*/
*----------------------------------------------*
Static Function ExtrNfProd(oXml,aDados,cArquivo)
*----------------------------------------------*
Local oNFe 	:= IIf(Type("oXml:_nfeProc:_NFe:_infNFe")=="U",oXml:_nfeProc:_NFe:_infNFe,oXml:_NFe:_infNFe)
Local aItens:= {}
Local aNF	:= {}
Local aRet  := {}
Local cCFOP := ""
Local cTipo := ""
Local nX	:= 1
Local cTes	:= Criavar("D1_TES")
Local cCond	:= Criavar("F1_COND")
Local cNatu	:= Criavar("E2_NATUREZ")

aNewClie:={}

//-->> 01 Tipo da geracao da NF
If Alltrim(oNFe:_EMIT:_CNPJ:TEXT) == Alltrim(_cMeuCnpj) .And. oNFe:_DEST:_ENDERDEST:_UF:TEXT <> "EX"
	aAdd(aNF,"SAIDA")
	cTipo := "S"
Else
	aAdd(aNF,"ENTRADA")
	cTipo := "E"
EndIf

aAdd(aNF,StrZero(Val(oNFe:_IDE:_NNF:TEXT),Len(SF1->F1_DOC)))			//->> 02 - Numero da Nota
aAdd(aNF,oNFe:_IDE:_SERIE:TEXT)											//->> 03 - Serie
If cTipo == "S"
	//aAdd(aNF,IIf(Type("oNFe:_DEST:_CNPJ:TEXT")=="U", IIF(XmlChildEx(oNFe:_DEST,"_CPF")<>Nil,oNFe:_DEST:_CPF:TEXT,"") ,oNFe:_DEST:_CNPJ:TEXT))	//->> 04 - CNPJ CLIENTE
	aAdd(aNF,IIF(XmlChildEx(oNFe:_DEST,"_CNPJ")<>Nil,oNFe:_DEST:_CNPJ:TEXT, IIF(XmlChildEx(oNFe:_DEST,"_CPF")<>Nil,oNFe:_DEST:_CPF:TEXT,"")))	//->> 04 - CNPJ CLIENTE
	SA1->(dbSetOrder(3))
	//If !SA1->(dbSeek(xFilial("SA1")+IIf(Type("oNFe:_DEST:_CNPJ:TEXT")=="U",oNFe:_DEST:_CPF:TEXT,oNFe:_DEST:_CNPJ:TEXT)))
	if empty(aNF[4])
		cErroPro:="CPF/CNPJ não encontrado no XML"
		GravaResul("2",aNF[1],StrZero(Val(aNF[02]),Tamsx3("C5_NUM")[1]),aNF[3],"","","",StoD(StrTran(oNFe:_IDE:_DEMI:TEXT,"-","")),cCFOP,oNFe:_IDE:_NATOP:TEXT,cErroPro,cArquivo)
		Return(.T.)
	endif
	
	If !SA1->(dbSeek(xFilial("SA1")+aNF[4]))
		aAdd( aNewClie, { IIf(XmlChildEx(oNFe:_DEST, "_EMAIL")<>Nil,oNFe:_DEST:_EMAIL:TEXT," ")					,;	//------> 01 - E-mail
						IIf(XmlChildEx(oNFe:_DEST:_ENDERDEST, "_FONE")<>Nil, oNFe:_DEST:_ENDERDEST:_FONE:TEXT, " ") ,;	//------> 02 - Fone
						IIf(XmlChildEx(oNFe:_DEST:_ENDERDEST, "_XBAIRRO")<>Nil,oNFe:_DEST:_ENDERDEST:_XBAIRRO:TEXT, " ") ,;	//------> 03 - Bairro
						oNFe:_DEST:_ENDERDEST:_CEP:TEXT								,;	//------> 04 - CEP
						oNFe:_DEST:_ENDERDEST:_CMUN:TEXT							,;	//------> 05 - Cod Municipio
						oNFe:_DEST:_ENDERDEST:_CPAIS:TEXT							,;	//------> 06 - Cod Pais
						IIf(XmlChildEx(oNFe:_DEST:_ENDERDEST, "_XCPL")<>Nil,oNFe:_DEST:_ENDERDEST:_XCPL:TEXT," ") ,;	//------> 07 - Compl Endereco
						oNFe:_DEST:_ENDERDEST:_XLGR:TEXT							,;	//------> 08 - Endereco
						oNFe:_DEST:_ENDERDEST:_NRO:TEXT								,;	//------> 09 - Numero
						oNFe:_DEST:_ENDERDEST:_UF:TEXT								,;	//------> 10 - UF
						IIf(XmlChildEx(oNFe:_DEST,"_CNPJ")<>Nil,oNFe:_DEST:_CNPJ:TEXT,oNFe:_DEST:_CPF:TEXT),;	//------> 11 - CNPJ
						oNFe:_DEST:_IE:TEXT											,;	//------> 12 - IE
						oNFe:_DEST:_XNOME:TEXT										})	//------> 13 - Razao Social
	
		GetCliente(aNewClie)
		
		cCond:=SA1->A1_COND
		cNatu:=SA1->A1_NATUREZ
	EndIf
Else
//ENTRADA
/*	If oNFe:_DEST:_ENDERDEST:_UF:TEXT <> "EX"	
		aAdd(aNF,oNFe:_EMIT:_CNPJ:TEXT)										//->> 04 - CNPJ FORNECEDOR
		SA2->(dbSetOrder(3))
		If !SA2->(dbSeek(xFilial("SA2")+oNFe:_EMIT:_CNPJ:TEXT))
			aAdd( aNewForn, { 	" "										,;	//------> 01 - E-mail
						oNFe:_EMIT:_ENDEREMIT:_FONE:TEXT							,;	//------> 02 - Fone
						IIf(XmlChildEx(oXML, "oNFe:_EMIT:_ENDEREMIT:_FONE:TEXT")<>Nil, oNFe:_EMIT:_ENDEREMIT:_FONE:TEXT, " "),;	//------> 02 - Fone
						" "															,;	//------> 03 - Bairro
						oNFe:_EMIT:_ENDEREMIT:_CEP:TEXT								,;	//------> 04 - CEP
						oNFe:_EMIT:_ENDEREMIT:_CMUN:TEXT							,;	//------> 05 - Cod Municipio
						oNFe:_EMIT:_ENDEREMIT:_CPAIS:TEXT							,;	//------> 06 - Cod Pais
						" "                             							,;	//------> 07 - Compl Endereco
						oNFe:_EMIT:_ENDEREMIT:_XLGR:TEXT							,;	//------> 08 - Endereco
						oNFe:_EMIT:_ENDEREMIT:_NRO:TEXT								,;	//------> 09 - Numero
						oNFe:_EMIT:_ENDEREMIT:_UF:TEXT								,;	//------> 10 - UF
						oNFe:_EMIT:_CNPJ:TEXT										,;	//------> 11 - CNPJ
						oNFe:_EMIT:_IE:TEXT											,;	//------> 12 - IE
						oNFe:_EMIT:_XNOME:TEXT										})	//------> 13 - Razao Social
		EndIf
	Else
		SA2->(dbSetOrder(2))
		If !SA2->(dbSeek(xFilial("SA2")+PadR(Upper(oNFe:_DEST:_XNOME:TEXT),Len(SA2->A2_NOME))))
			aAdd(aNF,IIf(Type("oNFe:_DEST:_CNPJ:TEXT")=="U",oNFe:_DEST:_CPF:TEXT,oNFe:_DEST:_CNPJ:TEXT))	//->> 04 - CNPJ FORNECEDOR ESTRANGEIRO
			aAdd( aNewForn, { 	" "																				,;	//------> 01 - E-mail
						IIf(XmlChildEx(oXML, "NFe:_DEST:_ENDERDEST:_FONE")<>Nil, oNFe:_DEST:_ENDERDEST:_FONE:TEXT, " ") ,;	//------> 02 - Fone
						" "																								,;	//------> 03 - Bairro
						IIf(XmlChildEx(oXML, "NFe:_DEST:_ENDERDEST:_CEP" )<>Nil, oNFe:_DEST:_ENDERDEST:_CEP:TEXT , " ") ,;	//------> 04 - CEP
						IIf(XmlChildEx(oXML, "NFe:_DEST:_ENDERDEST:_CMUN")<>Nil, oNFe:_DEST:_ENDERDEST:_CMUN:TEXT, " ") ,;	//------> 05 - Cod Municipio
						IIf(XmlChildEx(oXML, "NFe:_DEST:_ENDERDEST:_CPAIS")<>Nil, oNFe:_DEST:_ENDERDEST:_CPAIS:TEXT," "),;	//------> 06 - Cod Pais
						" "                             																,;	//------> 07 - Compl Endereco
						IIf(XmlChildEx(oXML, "NFe:_DEST:_ENDERDEST:_XLGR")<>Nil, oNFe:_DEST:_ENDERDEST:_XLGR:TEXT, " ") ,;	//------> 08 - Endereco
						IIf(XmlChildEx(oXML, "NFe:_DEST:_ENDERDEST:_NRO" )<>Nil, oNFe:_DEST:_ENDERDEST:_NRO:TEXT , " ") ,;	//------> 09 - Numero  
						IIf(XmlChildEx(oXML, "NFe:_DEST:_ENDERDEST:_UF"  )<>Nil, oNFe:_DEST:_ENDERDEST:_UF:TEXT  , " ") ,;	//------> 10 - UF 
						IIf(XmlChildEx(oXML, "NFe:_DEST:_ENDERDEST:_CNPJ")<>Nil, oNFe:_DEST:_ENDERDEST:_CNPJ:TEXT, " ") ,;	//------> 11 - CNPJ 
						IIf(XmlChildEx(oXML, "NFe:_DEST:_ENDERDEST:_IE"  )<>Nil, oNFe:_DEST:_ENDERDEST:_IE:TEXT  , " ") ,;	//------> 12 - IE 
						Upper(oNFe:_DEST:_XNOME:TEXT)																	})	//------> 13 - Razao Social
		Else	
			aAdd(aNF,SA2->A2_COD)										//->> 04 - CNPJ FORNECEDOR ESTRANGEIRO
		EndIf
	EndIf	
*/

	cErroPro:="Não é possível importar nota de entrada"
	GravaResul("2",aNF[1],StrZero(Val(aNF[02]),Tamsx3("C5_NUM")[1]),aNF[3],"","","",StoD(StrTran(oNFe:_IDE:_DEMI:TEXT,"-","")),cCFOP,oNFe:_IDE:_NATOP:TEXT,cErroPro,cArquivo)
	Return(.T.)
EndIf

aAdd(aNF,StoD(StrTran(oNFe:_IDE:_DEMI:TEXT,"-","")))  					//->> 05 - Data de Emissão
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vFrete:TEXT))						//->> 06 - Frete
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vDesc:TEXT))							//->> 07 - Desconto
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vSeg:TEXT))							//->> 08 - Seguro
aAdd(aNF,Val(oNFe:_Total:_ICMSTot:_vNF:TEXT))							//->> 09 - Valor Bruto
If cEmpAnt $ "46" .or. Type("oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT")=="U"
	aAdd(aNF,"") 											//->> 10 - Chave da Nota Fiscal
Else
	aAdd(aNF,oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT)	//->> 10 - Chave da Nota Fiscal
EndIf

//-->> Monta o aDados para Importar os itens da NF-e
If ValType(oNFe:_DET) == "A"
	For nX := 1 To Len(oNFe:_DET)
		cCFOP := oNFe:_DET[nX]:_PROD:_CFOP:TEXT
		aAdd( aItens , {oNFe:_DET[nX]:_NITEM:TEXT				,;	//->> 01 - Item
						oNFe:_DET[nX]:_PROD:_CPROD:TEXT								,;	//->> 02 - Codigo do Produto no Fornec
						oNFe:_DET[nX]:_PROD:_UCOM:TEXT								,;	//->> 03 - Unidade de Medida
						Val(oNFe:_DET[nX]:_PROD:_QCOM:TEXT)						,;	//->> 04 - Quantidade
						Val(oNFe:_DET[nX]:_PROD:_VUNCOM:TEXT)						,;	//->> 05 - Valor Unitario
						Val(oNFe:_DET[nX]:_PROD:_VPROD:TEXT)						,;	//->> 06 - Valor Total do Total
						oNFe:_DET[nX]:_PROD:_XPROD:TEXT								,;	//->> 07 - Descricao do Produto
						oNFe:_DET[nX]:_PROD:_CFOP:TEXT								})	//->> 08 - CFOP
	Next nX
Else
	cCFOP := oNFe:_DET:_PROD:_CFOP:TEXT
	aAdd( aItens , {oNFe:_DET:_NITEM:TEXT				  		,;	//->> 01 - Item
					oNFe:_DET:_PROD:_CPROD:TEXT										,;	//->> 02 - Codigo do Produto no Fornec
					oNFe:_DET:_PROD:_UCOM:TEXT										,;	//->> 03 - Unidade de Medida
					Val(oNFe:_DET:_PROD:_QCOM:TEXT)									,;	//->> 04 - Quantidade
					Val(oNFe:_DET:_PROD:_VUNCOM:TEXT)								,;	//->> 05 - Valor Unitario
					Val(oNFe:_DET:_PROD:_VPROD:TEXT)								,;	//->> 06 - Valor Total do Total
					oNFe:_DET:_PROD:_XPROD:TEXT										,;	//->> 07 - Descricao do Produto
					oNFe:_DET:_PROD:_CFOP:TEXT								   		})	//->> 08 - CFOP
EndIf

//Tratamento para validação de produto.
cErroPro := ""
lErroProd := .F.
For i:=1 to Len(aItens)
	If !SB1->(dbSeek(xFilial("SB1")+aItens[i][2]))	
		cErroPro += "Produto não encontrado! - '"+ALLTRIM(aItens[i][2])+"'"+CHR(13)+CHR(10)
		lErroProd := .T.
	else
		cTes:=ALLTRIM(SB1->B1_TS)
	EndIf
Next i
If lErroprod    
	
	GravaResul("2",aNF[1],StrZero(Val(aNF[02]),Tamsx3("C5_NUM")[1]),aNF[3],aNF[4],SA1->A1_NOME,"",aNF[05],cCFOP,oNFe:_IDE:_NATOP:TEXT,cErroPro,cArquivo)

	//MsgInfo(cErroPro)
	Return .T.
EndIf

aAdd(aNF,aItens)														//->> 11 - Itens da Nota Fiscal

aAdd(aNF,cTes				)    										//->> 12 - TES
aAdd(aNF,cCond				)											//->> 13 - COND
aAdd(aNF,cNatu				) 									   		//->> 14 - NATUREZA
If oNFe:_DEST:_ENDERDEST:_UF:TEXT == "EX"
	aAdd(aNF,SA2->A2_COD)												//->> 15 - FORNECEDOR IMPORT
Else	
	aAdd(aNF,Criavar("A2_COD",.F.))										//->> 15 - FORNECEDOR IMPORT
EndIf	
If oNFe:_DEST:_ENDERDEST:_UF:TEXT == "EX"
	aAdd(aNF,SA1->A1_COD) 				  								//->> 16 - CLIENTE IMPORT
else
	aAdd(aNF,"")						  								//->> 16 - CLIENTE IMPORT
endif
aAdd(aNF,"N") 				   											//->> 17 - TIPO NOTA
aAdd(aNF,Criavar("D1_TOTAL"  ))    										//->> 18 - DESPESAS
aAdd(aNF,Criavar("D1_NFORI"  ))    										//->> 19 - NOTA ORIGEM
aAdd(aNF,Criavar("D1_SERIORI"))    										//->> 20 - SERIE ORIGEM
aAdd(aNF,Criavar("E2_CODRET" ))    										//->> 21 - CODIGO DE RETENCAO - DIRF
aAdd(aNF,cArquivo)														//->> 22 - Arquivo de Importacao
aAdd(aNF,StoD(StrTran(oNFe:_IDE:_DEMI:TEXT,"-","")))					//->> 23 - Data da Digitacao

If cTipo == "E" .And. oNFe:_DEST:_ENDERDEST:_UF:TEXT <> "EX"
	cCFOP := If( Left(cCFOP,1) == "5", "1", "2" ) + Right(cCFOP,3)
EndIf

aAdd(aNF,cCFOP)															//->> 24 - CFOP
aAdd(aNF,oNFe:_IDE:_NATOP:TEXT)											//->> 25 - Natureza de Operacao

//--> Valida a Chave da NFe
aRet := U_ValSefaz(IIF(Type("oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT")=="U","",oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT) )
aAdd(aNF,aRet[1])														//->> 26 - .T. Chave Valida / .F. Chave Invalida
aAdd(aNF,aRet[2])														//->> 27 - Mensagem da Validacao da Chave da NFe
aAdd(aNF,oNFe:_DEST:_ENDERDEST:_UF:TEXT)								//->> 28 - UF do Destinatario (importante para NF de Importacao)

aAdd(aDados,aNF)

Return

/*
Funcao      : ProcXmlProd
Objetivos   : Processamento da Importacao de notas de produtos.
*/
*-----------------------------------------------------*
Static Function ProcXmlProd(lAuto,aNF,oRegua,lExibErro)
*-----------------------------------------------------*
Local nX	:= 0
Local lOK	:= .T.
Local cNewArq := ""

Default lAuto := .F.
Default oRegua:= ""

/*If !lAuto .And. Valtype(oRegua)=="O"
	oRegua:SetRegua2(Len(aNF))
EndIf
*/
For nX := 1 To Len(aNF)
	If !lAuto
/*		oRegua:IncRegua1("Importação de XML de Produto...")
		oRegua:IncRegua2("Gerando N.Fiscal de "+aNF[nX,1]+" - "+aNF[nX,2]+"/"+aNF[nX,3]+"  ("+AllTrim(Str(nX))+"/"+AllTrim(Str(Len(aNF)))+")")
		If Valtype(oRegua)=="O"
			If oRegua:lEnd
				lEnd := .T.
				Exit
			EndIf
			lOK:=GeraNFP(aNF[nX],lAuto,lExibErro,@oRegua)
		Else
			Processa( { || lOK:=GeraNFP(aNF[nX],lAuto,lExibErro,@oRegua) } , 'Aguarde...' , 'Gerando Notas de Produtos' )
		EndIf
*/
	Else
		lOK:=GeraNFP(aNF[nX],lAuto,.F.,@oRegua)
	EndIf
	
Next nX

Return

/*
Funcao      : GeraNFP
Objetivos   : Geracao da NF de Produtos.
*/
*-------------------------------------------------*
Static Function GeraNFP(aNF,lAuto,lExibErro,oRegua)
*-------------------------------------------------*
Local nX		:= 1
Local aCabec    := {}
Local aItemNF   := {}
Local aItens    := {}
Local lRetorno  := .T.
Local lPreNF    := .F.
Local cCFOP     := " "
Local cTesE     := " "
Local cTesS     := " "
Local cAUTOISS  := GetMv( "MV_AUTOISS"  )
Local cItem     := "00"
Local dDataEmis := dDatabase
Local dDataAnt	:= dDatabase
Local nAditiv 	:= 1 
Local cTes		:= ""

Local cCondPaf	:= ""

Private lMsErroAuto:= .F.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

Default lExibErro := .F.

dDataEmis := aNF[05]
dDatabase := aNF[23]

If aNF[1]=="ENTRADA"
	//->> Documentos de Entrada

Else
	//->> Documentos de Saida
	cNumero := StrZero(Val(aNF[02]),Tamsx3("C5_NUM")[1])
	//cSerie	:= PadR(aNF[03],Tamsx3("F2_SERIE")[1])
	
	//-->> Posiciona no Cliente pelo CNPJ
   //	If Empty(aNF[17])
		DbSelectArea("SA1")
		SA1->(DbGoTop())
		SA1->(dbSetOrder(3))
		If !SA1->(dbSeek(xFilial("SA1")+aNF[04]))
		   /*	If lExibErro
				MsgStop('Não existe Cliente cadastrado com este CNPJ ' + aNF[04])
			EndIf
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Não existe Cliente cadastrado com este CNPJ")
			EndIf
			Return .F.
			*/
			cObs:="Não existe Cliente cadastrado com este CPF/CNPJ " + aNF[04]
			GravaResul("2",aNF[1],StrZero(Val(aNF[02]),Tamsx3("C5_NUM")[1]),aNF[3],aNF[4],"",cTes,aNF[05],aNF[24],aNF[25],cObs,aNF[22])			
		EndIf
/*	Else
		//--> Cliente Exportacao
		SA1->(dbSetOrder(1))
		If !SA1->(dbSeek(xFilial("SA1")+aNF[17]))
			
			cObs:="Fornecedor Não Encontrado, Verifique " + aNF[16]
			GravaResul("2",aNF[1],StrZero(Val(aNF[02]),Tamsx3("C5_NUM")[1]),aNF[3],aNF[4],"",cTes,aNF[05],aNF[24],aNF[25],cObs)			
			Return .F.
		EndIf
	Endif
*/	
	//-->> Valida existencia do Pedido de Venda
	
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial('SC5')+cNumero))
 /*		If lExibErro
			Aviso( 'Atenção' , 'Impossivel importar o Documento, pois o mesmo já foi cadastrado!' + CRLF + CRLF + ;
			'Cliente:    ' + SA1->(A1_COD+'/'+A1_LOJA+' '+A1_NOME) + CRLF + ;
			'Pedido: ' + cNumero , { 'Ok' } , 2 , 'Pedido já cadastrado!' )
		EndIf
*/
/*
		If Valtype(oRegua)=="O"
			oRegua:SaveLog("Pedido de produto:"+Alltrim(aNF[02])+" já cadastrado.")
		EndIf
*/

			cObs:='Impossivel importar o Documento, pois o mesmo já foi cadastrado!' + CRLF + CRLF  
			cObs+='Cliente:    ' + SA1->(A1_COD+'/'+A1_LOJA+' '+A1_NOME) + CRLF
			cObs+='Pedido: ' + cNumero
			
			GravaResul("3",aNF[1],StrZero(Val(aNF[02]),Tamsx3("C5_NUM")[1]),aNF[3],aNF[4],SA1->A1_NOME,cTes,aNF[05],aNF[24],aNF[25],cObs,aNF[22])
		Return .F.
	EndIf
    
	//Verifica a condição de pagamento
	if !empty(SA1->A1_COND)
		cCondPaf:=SA1->A1_COND
	else
		DbSelectArea("SE4")
		SE4->(DbGoTop())
		cCondPaf:=SE4->E4_CODIGO
	endif

	If Empty(aNF[13])
		//-->> Monta o cabecalho do Pedido de Vendas
		aCabec := {	{"C5_NUM"    ,Right(cNumero,6)		,Nil},; // Numero do pedido
					{"C5_TIPO"   ,aNF[17]				,Nil},; // Tipo de pedido
					{"C5_CLIENTE",SA1->A1_COD			,Nil},; // Codigo do cliente
					{"C5_LOJACLI",SA1->A1_LOJA			,Nil},; // Loja do cliente
					{"C5_LOJAENT",SA1->A1_LOJA			,Nil},; // Loja do cliente
					{"C5_EMISSAO",aNF[05]				,Nil},; // Data de emissao
					{"C5_CONDPAG",cCondPaf				,Nil}} // Codigo da condicao de pagamanto*
					//{"C5_DESC1"  ,0						,Nil},;  // Percentual de Desconto
				 	//{"C5_INCISS" ,"N"         			,Nil},; // ISS Incluso
				   	//{"C5_TIPLIB" ,"2"					,Nil},; // Tipo de Liberacao (2-Lib Por Pedido)
					//{"C5_MOEDA"  ,1						,Nil},; // Moeda
					//{"C5_LIBEROK","S"					,Nil}} // Liberacao Total

	EndIf	
		
	SB1->(dbSetOrder(1))
	For nX := 1 To Len(aNF[11])
		
		if SB1->(dbSeek(xFilial("SB1")+aNF[11,nX,02]))
		//cTes	:= aNF[13]
		//cTesS := IIf(Empty(aNF[13]),SB1->B1_TS,aNF[13])
		
			cTes	:= ALLTRIM(SB1->B1_TS)
		else
			cTes	:= ""
		endif                
		
		If Empty(cTes)
/*
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Pedido:"+Alltrim(aNF[02])+" não importado."+" "+"TES não cadastrado para o produto")
			EndIf
*/

			cObs:="Pedido:"+Alltrim(aNF[02])+" não importado."+" "+"TES não cadastrado para o produto: "+alltrim(SB1->B1_COD)
			GravaResul("2",aNF[1],StrZero(Val(aNF[02]),Tamsx3("C5_NUM")[1]),aNF[3],aNF[4],SA1->A1_NOME,cTes,aNF[05],aNF[24],aNF[25],cObs,aNF[22])			
			Return .F.
		EndIf
		
		//-->> Verifica se existe TE cadastrado para o Produto
		/*If Empty(cTesS)
			If lExibErro
				MsgStop('Tipo de Entrada padrão não cadastrado para o produto ' + SB1->B1_COD + '!')
			EndIf
			If Valtype(oRegua)=="O"
				oRegua:SaveLog("Nota fiscal de produto:"+Alltrim(aNF[02])+"/"+Alltrim(aNF[03])+" não importada."+" "+"Tipo de Entrada padrão não cadastrado para o produto")
			EndIf
			Return .F.
		EndIf*/
		
		aItens := {}
		cItem := Soma1(cItem)

		If Empty(aNF[13])
		
			//-->> Posiciona na TES conforme Operacao Fiscal
		   /*	cTes := "501"
			SF4->(dbGoTop())
			While !SF4->(Eof())
				If AllTrim(SF4->F4_CF) == AllTrim(aNF[11,nX,08])    
					cTES := SF4->F4_CODIGO
					Exit
				EndIf
				SF4->(dbSkip())
			EndDo
		    */
			//-->> Monta o array com os itens do Pedido de Vendas
			aItens  := {	{"C6_ITEM"   ,cItem											,Nil},; // Numero do Item no Pedido
						 	{"C6_PRODUTO",SB1->B1_COD									,Nil},; // Codigo do Produto
							{"C6_UM"     ,SB1->B1_UM									,Nil},; // Unidade de Medida Primar.						 	
						 	{"C6_QTDVEN" ,If(aNF[11,nX,04]>0,aNF[11,nX,04],1)			,Nil},; // Quantidade Vendida
						 	{"C6_PRCVEN" ,ROUND(If(aNF[11,nX,05]>0,aNF[11,nX,05],1),2)	,Nil},; // Preco Unitario Liquido
 						 	{"C6_PRUNIT" ,ROUND(If(aNF[11,nX,05]>0,aNF[11,nX,05],1),2)	,Nil},; // Preco de Lista
						 	{"C6_VALOR"  ,ROUND(aNF[11,nX,06],2)						,Nil},; // Valor Total do Item
						 	{"C6_TES"    ,cTes											,Nil}} // Tipo de Entrada/Saida do Item

//						 	{"C6_CLI"    ,SA1->A1_COD									,Nil},; // Cliente
//						 	{"C6_LOJA"   ,SA1->A1_LOJA									,Nil},; // Loja do Cliente
//						 	{"C6_NUM"    ,Right(cNumero,6)								,Nil},; // Numero do Pedido
						 	//{"C6_ENTREG" ,aNF[05]										,Nil},; // Data da Entrega
						 	//{"C6_LOCAL"  ,SB1->B1_LOCPAD								,Nil},; // Almoxarifado
						 	//{"C6_DESCONT",0												,Nil},; // Percentual de Desconto
						 	//{"C6_COMIS1" ,0												,Nil},; // Comissao Vendedor
						 	//{"C6_QTDEMP" ,If(aNF[11,nX,04]>0,aNF[11,nX,04],1)			,Nil},; // Quantidade Empenhada
						 	//{"C6_QTDLIB" ,If(aNF[11,nX,04]>0,aNF[11,nX,04],1)			,Nil} } // Quantidade Liberada

			aAdd( aItemNF, aItens )

		EndIf	
		
	Next nX

	If Empty(aNF[13])
		//-->> Processa a rotina automatica MATA410 - Pedido de Vendas
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItemNF,3)
	
		If lMsErroAuto
			DisarmTransaction()
			//If lExibErro
			//MostraErro()
			//EndIf
			
			cErroCon:=""
			aAutoErro := GETAUTOGRLOG()
		    cObs  := XLOG(aAutoErro) 
						
			GravaResul("2",aNF[1],StrZero(Val(aNF[02]),Tamsx3("C5_NUM")[1]),aNF[3],aNF[4],SA1->A1_NOME,cTes,aNF[05],aNF[24],aNF[25],XLOGMEMO(aAutoErro),aNF[22])
			lRetorno := .F.
		Else	
		   
			cObs:="Importado com sucesso"
			GravaResul("1",aNF[1],StrZero(Val(aNF[02]),Tamsx3("C5_NUM")[1]),aNF[3],aNF[4],SA1->A1_NOME,cTes,aNF[05],aNF[24],aNF[25],cObs,aNF[22])
			//nProd++
			lRetorno := .T.
		EndIf

	EndIf	

EndIf

dDatabase := dDataAnt

Return(lRetorno)


/*
Funcao		: ValSefaz
Objetivo	: Valida   a chave da NFe digitada na SEFAZ
Parametros	:	ExpC1 : Chave da NFe de 44 posicoes a ser validada          
				ExpC2 : Formulario Proprio                                  
				ExpC3 : Chave da NFe de 44 posicoes a ser validada          
				ExpL1 : .T. Exibe as mensagens dos erros   .F. Nao Exibe    
Retorno		: 	ExpA1 : [1] .T. Chave Valida   .F. Chave Nao Valida         
						[2] Mensagem do retorno da consulta       
*/
*---------------------------------------------------*
User Function ValSefaz(cChave,cFormul,cEspecie,lMsg)
*---------------------------------------------------*
Local cChaveNFe  := cChave
Local cCodRet	 := "Codigo de retorno: "
Local cIdEnt   	 := ""
Local cMensRet   := "Mensagem de retorno: "
Local cProt		 := "Protocolo: "
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMsgErro   := ""

Local lConChv 	 := .T. //GetNewPar("MV_CHVNFE",.F.)
Local lDigChv 	 := .T. //GetNewPar("MV_DCHVNFE",.F.)
Local lRet	  	 := .F.

Private oWS
Default cFormul  := "N"
Default cEspecie := "SPED"
Default lMsg     := .F.

//Aborta para empresas especificas, quando o XML não possui chave de autorização.
If cEmpAnt $ "46"
	Return({.T.,cMsgErro})
EndIf

If (lDigChv .and. cFormul == "N" .and. AllTrim(cEspecie) == "SPED") .Or. (lDigChv .and. cFormul == "N" .and. AllTrim(cEspecie) == "CTE")
	If lConChv
		If IsReady(cURL)
			//Obtem o codigo da entidade
			oWS := WsSPEDAdm():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
			oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
			oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
			oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
			oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
			oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
			oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
			oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
			oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
			oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
			oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
			oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
			oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
			oWS:oWSEMPRESA:cCEP_CP     := Nil
			oWS:oWSEMPRESA:cCP         := Nil
			oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
			oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
			oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
			oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
			oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
			oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
			oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cINDSITESP  := ""
			oWS:oWSEMPRESA:cID_MATRIZ  := ""
			oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
			oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	
			If oWs:ADMEMPRESAS()
				cIdEnt  := oWs:cADMEMPRESASRESULT
			Else
				If lMsg
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
				EndIf
				cMsgErro := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			EndIf
			
			oWs:= WsNFeSBra():New()
			oWs:cUserToken   := "TOTVS"
			oWs:cID_ENT      := cIdEnt
			ows:cCHVNFE		 := cChaveNFe
			oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
			
			If oWs:ConsultaChaveNFE()
				If Type ("oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO") == "U" .OR. Empty (oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
					cMsgErro := "A chave digitada não foi encontrada na Sefaz, favor verificar"
					If lMsg
						MsgAlert("A chave digitada não foi encontrada na Sefaz, favor verificar")
					EndIf
					lRet := .F.
				ElseIf AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "101"
					cMsgErro := cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE + "; " + cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE + "; " + cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO
					If lMsg
						If MsgNoYes(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
							cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
							cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF+CRLF+CRLF+;
							"Deseja inserir a chave mesmo assim?")
							lRet := .T.
						Else
							lRet := .F.
						EndIf
					Else
						lRet := .F.
					EndIf
				Else
					lRet := .T.
					cMsgErro := cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE + "; " + cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE + "; " + cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO
					If lMsg
						MsgAlert(cCodRet+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF+;
						cMensRet+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF+;
						cProt+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
					EndIf
				EndIf
			Else
				cMsgErro := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				If lMsg
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
				EndIf
				If len(Alltrim(cChaveNFE)) > 0 .and. len(Alltrim(cChaveNFE)) < 44
					cMsgErro := "A chave informada é menor que o permitido e impossibilita a consulta na Sefaz."
					If lMsg
						If MsgNoYes("A chave informada é menor que o permitido e impossibilita a consulta na Sefaz."+CRLF+CRLF+"Deseja APAGAR o conteúdo do campo para inserir uma nova chave?")
							lRet := .F.  //Limpa o campo caso tenha uma chave menor
						Else
							lRet := .T.
						EndIf
					Else
						lRet := .F.
					EndIf
				Else
					lRet := .T.
				EndIf
			EndIf
		Else
			cMsgErro := "TSS Inativo"
			If lMsg
				Help(" ",1,"TSSINATIVO")
			EndIf
			lRet := .F.
		EndIf
	Else
		lRet := .T.
	EndIf
Else
	lRet := .T.
EndIf

Return({lRet,cMsgErro})


Static Function GravaResul(cStatus,cTpNota,cNota,cSerie,cCGC,cNomeCli,cTes,dDataEmi,cCfpo,cNatOper,cObs,cArquivo)

	RecLock(cAlias,.T.)
		(cAlias)->CSTATUS	:=cStatus
		(cAlias)->TPNOTA	:=cTpNota
		(cAlias)->NOTA		:=cNota
		(cAlias)->SERIE		:=cSerie
		(cAlias)->CGCCLI	:=cCGC
		(cAlias)->NOMECLI	:=cNomeCli
		(cAlias)->TES		:=cTes
		(cAlias)->DATEMI	:=dDataEmi
		(cAlias)->CFOP		:=cCfpo
		(cAlias)->NATOPER	:=cNatOper
		(cAlias)->OBS		:=cObs
		(cAlias)->ARQUIVO	:=cArquivo
		(cAlias)->MEMO		:=cObs
	(cAlias)->(MsUnlock())

Return


/*
Funcao      : GetCliente
Objetivos   : Busca o cliente pelo cnpj e caso nao haja cadastra e retornando true mantem posicionado na SA1.
 01 Email
 02 Telefone
 03 Bairro
 04 CEP
 05 Codigo Municipio
 06 Codigo Pais
 07 Complemento Endereco
 08 Endereco
 09 Numero
 10 UF
 11 Cnpj
 12 Insc. Municipal
 13 Razao Social
*/
*----------------------------------*
Static Function GetCliente(aCliente)
*----------------------------------*
Local lRet 		:= .T.
Local cCodigo 	:= ""

If Len(aCliente)>0
	SA1->(dbSetOrder(3)) // por cnpj
	If !SA1->(dbSeek(xFilial("SA1")+Alltrim(aCliente[1][11])))
		cCodigo += GetSXENum("SA1","A1_COD")
		ConfirmSX8()
		Reclock("SA1",.T.)
		SA1->A1_FILIAL 	:= xFilial("SA1")
		SA1->A1_COD		:= cCodigo
		SA1->A1_LOJA	:= "01"
		SA1->A1_NOME	:= aCliente[1][13]
		SA1->A1_NREDUZ	:= aCliente[1][13]
		SA1->A1_PESSOA	:= IIF(len(aCliente[1][11])>=14,"J","F")
		SA1->A1_END		:= Alltrim(aCliente[1][08])+" - "+aCliente[1][09]+" - "+aCliente[1][07]
		SA1->A1_TIPO	:= "F" //Consumidor Final
		SA1->A1_EST		:= aCliente[1][10]
		SA1->A1_COD_MUN := aCliente[1][05]
		SA1->A1_BAIRRO	:= aCliente[1][03]
		SA1->A1_CEP		:= aCliente[1][04]
		SA1->A1_TEL		:= aCliente[1][02]
		SA1->A1_CGC		:= aCliente[1][11]
		SA1->A1_INSCRM	:= aCliente[1][12]
		SA1->A1_CODPAIS	:= aCliente[1][06]
		SA1->A1_EMAIL	:= aCliente[1][01]
		SA1->(MsUnlock())
	Else
		Reclock("SA1",.F.)
		SA1->A1_END		:= Alltrim(aCliente[1][08])+" - "+aCliente[1][09]+" - "+aCliente[1][07]
		SA1->A1_EST		:= aCliente[1][10]
		SA1->A1_COD_MUN := aCliente[1][05]
		SA1->A1_BAIRRO	:= aCliente[1][03]
		SA1->A1_CEP		:= aCliente[1][04]
		SA1->A1_TEL		:= aCliente[1][02]
		SA1->A1_EMAIL	:= aCliente[1][01]
		SA1->(MsUnlock())
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*
Funcao      : VerMemo()
Parametros  : 
Retorno     : 
Objetivos   : Função para visualizar o conteudo do memo
Autor       : Matheus Massarotto
Data/Hora   : 23/05/2013	17:10
*/

*------------------------------*
Static Function VerMemo(cTexto)
*------------------------------*
DEFINE MSDIALOG oDlgM TITLE "Observação" From 000,000 TO 300,320 PIXEL
	@ 005,005 GET oMemo VAR cTexto MEMO SIZE 150,120 OF oDlgM PIXEL
	oMemo:bRClicked := {||AllwaysFalse()}
	DEFINE SBUTTON FROM 135,70 TYPE 1 ACTION oDlgM:End() ENABLE OF oDlgM PIXEL
ACTIVATE MSDIALOG oDlgM CENTER

Return

/*
Funcao      : Xlog()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para tratar o log de erro, para todos.
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
Funcao      : FAT009L
Parametros  : 
Retorno     : 
Objetivos   : Legenda.
Autor       : Jean Victor Rocha
Data/Hora   : 05/09/2013
*/
*----------------------*
Static Function FAT009L()
*----------------------*
BrwLegenda(cCadastro, "Legenda", aLegenda)
Return .T.

