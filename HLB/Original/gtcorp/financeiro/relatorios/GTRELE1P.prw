#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTRELE1P  ºAutor  ³Eduardo C. Romanini º Data ³  01/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibição de informações de contas a receber que possuem     º±±
±±º          ³saldo positivo.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------*
User Function GTRELE1P()
*----------------------*         

Local cTitulo := "Contas a Receber em Aberto por periodo."
Local cArqTmp := ""
Local cArqTot := ""
Local cIndSE1 := ""

Local nI   := 0

Local aSizeAut := {}
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local aButtons := {}
Local aCampos  := {}
Local aExibe   := {}
Local aExbTot  := {}
Local aCord    := {}
Local aCrdTot  := {}

Local bOk     := {|| oDlg:End()}
Local bCancel := {|| oDlg:End()}

Local oDlg
Local oSCli
Local oSTot
Local oFont

Private cMarca  := GetMark()

Private nTotal  := 0 

Private dDataDe  := AvCtoD("  /  /  ")
Private dDataAte := AvCtoD("  /  /  ")

Private oBrw
Private oTot
Private oGetTot

// Maximizacao da tela em relação a area de trabalho
aSizeAut := MsAdvSize()

aAdd(aObjects,{100,250,.T.,.F.})
aAdd(aObjects,{100,100,.T.,.T.})

aInfo   := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
aPosObj := MsObjSize(aInfo,aObjects)

aCord   := aPosObj[1]

aCrdTot := aPosObj[2] 
aCrdTot[1] += 20

//Adiciona os botões na Enchoice Bar
aAdd(aButtons,{"PARAMETROS",{|| TelaParam()  },"Parametros" })
aAdd(aButtons,{"S4WB010N"  ,{|| TelaImprime()},"Imprimir"   })
aAdd(aButtons,{"PMSEXCEL"  ,{|| GeraExcel()  },"Gerar Excel"})

aCampos := {"E1_CLIENTE","E1_LOJA","E1_NOMCLI","E1_NUM","E1_PREFIXO","E1_EMISSAO","E1_VENCTO","E1_VALOR","E1_VALLIQ","A3_NOME"}

//Campos adicionais das tabelas temporarias
aCpTmp  := {{"EMPRESA","C",15,0},;
	    	{"FILDES" ,"C",15,0},;
	    	{"CNPJ"   ,"C",15,0}}

aCpTot  := {{"PERIODO","D",08,0},;
			{"TOTAL"  ,"N",20,2}}

aCpEmp := {	{"WKMARCA"  ,"C",02,0},;
			{"M0_CODIGO","C",02,0},;
	    	{"M0_CODFIL","C",02,0},;
			{"M0_FILIAL","C",15,0},;
			{"M0_NOME"  ,"C",15,0},;
			{"M0_CGC"   ,"C",14,0}}

//Campos de exibição das MSSelect.
aExibe  := {{"EMPRESA",,"Empresa","@!"},;
			{"FILDES" ,,"Filial" ,"@!"},;
			{"CNPJ"   ,,"CNPJ"   ,"@R 99.999.999/9999-99"}}

aExbTot := {{"PERIODO",,"Dia"   ,"@!"},;
			{"TOTAL"  ,,"Total" ,"@E 999,999,999.99"}}

//Tratamento dos campos da tela.
For nI := 1 To Len(aCampos)
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(aCampos[nI]))

		//Campos da MsSelect
		aAdd(aExibe,{SX3->X3_CAMPO,,AllTrim(SX3->X3_TITULO),SX3->X3_PICTURE})

		//Campos da Tabela Temporaria.
		aAdd(aCpTmp,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})		
	EndIf
Next

//Cria o arquivo temporário dos títulos.
cArqTmp := CriaTrab(aCpTmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPSE1",.F.,.F.)

//cIndSE1 := CriaTrab(Nil,.F.)
//IndRegua("TMPSE1",cIndSE1,"E1_NOMCLI",,,"Selecionando Registros...")

//Cria o arquivo temporário dos totais.
cArqTot := CriaTrab(aCpTot,.T.)
DbUseArea(.T.,"DBDCDX",cArqTot,"TMPTOT",.F.,.F.)

//Cria o arquivo temporário das empresas
cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPEMP",.T.,.F.)

//Carrega o browse com as empresas
SM0->(DbGoTop())
While SM0->(!EOF())

	TMPEMP->(DbAppend())

	TMPEMP->WKMARCA     := cMarca
	TMPEMP->M0_CODIGO := SM0->M0_CODIGO
	TMPEMP->M0_CODFIL := SM0->M0_CODFIL
	TMPEMP->M0_FILIAL := SM0->M0_FILIAL
	TMPEMP->M0_NOME   := SM0->M0_NOME	        
    TMPEMP->M0_CGC    := SM0->M0_CGC
	
	SM0->(DbSkip())	
EndDo

//Carrega e atualiza os dados da tela.
//Processa(AtuTela(),"Aguarde...","Carregando dados de empresas...",.F.)
//MsgRun(	"Favor Aguardar.....", "Carregando dados de empresas...",;
//	 	{|| AtuTela()})

//Chama a tela de paramentros
TelaParam()

//Exibição da tela
Define MsDialog oDlg From aSizeAut[7],aSizeAut[1] TO aSizeAut[6],aSizeAut[5] Title cTitulo Of oMainWnd Pixel
    
	//Browse com os títulos em aberto
	//TMPSE1->(DbSetOrder(1))
	TMPSE1->(DbGoTop())
	oBrw := MsSelect():New("TMPSE1",,,aExibe,,"",aCord,,,oDlg)
    
    //Browse com os totais por cliente. 
	oFont := TFont():New(,,-14,,.T.)
	oSCli := TSay():New(aCord[3]+7,aCord[2],{|| "Totais por dia de Vencimento:"},oDlg,,oFont,,,,.T.,CLR_RED)

	oSTot := TSay():New(aCord[3]+7,aCord[4]-160,{|| "Total Geral:"},oDlg,,oFont,,,,.T.,CLR_RED)
	oGetTot := TGet():New(aCord[3]+6,aCord[4]-090,{|u| If(PCount()>0,nTotal:=u,nTotal)},oDlg,060,008,'@E 999,999,999.99',,,,,,,.T.) 
    oGetTot:lReadOnly := .T.
    
    TMPTOT->(DbGoTop())
	oTot := MsSelect():New("TMPTOT",,,aExbTot,,"",aCrdTot,,,oDlg)

Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons) Centered


//Fecha as tabelas temporárias
TMPSE1->(DbCloseArea())
fErase(cArqTmp)
//fErase(cIndSE1)

TMPTOT->(DbCloseArea())
fErase(cArqTot)

TMPEMP->(DbCloseArea())
fErase(cArqTmp)

Return Nil

/*
Funcao      : TelaParam
Objetivos   : Exibe a tela de parametros.
Autor       : Eduardo C. Romanini
Data        : 02/02/2011 
*/
*-------------------------*
Static Function TelaParam()
*-------------------------*
Local lInverte := .F.

Local cArqTmp := ""

Local aCpTmp := {}
Local aExibe := {}

Local bOk := {|| MsgRun("Favor Aguardar.....","Carregando dados de empresas...",{|| AtuTela()}),;
 				 If(ValType(oBrw) == "O",oBrw:oBrowse:Refresh(),),;
 				 If(ValType(oTot) == "O",oTot:oBrowse:Refresh(),),;
 				 oDlg:End()}

Local oDlg
Local oGrp
Local oGrp2
Local oSel
Local oSay1
Local oGet1
Local oSay2
Local oGet2
Local oBtOk
Local oBtCan

//Campos de exibição das MSSelect.
aExibe  := {{"WKMARCA"  ,,""       ,""  },;
			{"M0_NOME"  ,,"Empresa","@!"},;
			{"M0_FILIAL",,"Filial" ,"@!"},;
			{"M0_CGC"   ,,"CNPJ"   ,"@R 99.999.999/9999-99"}}

oDlg := MSDialog():New( 091,232,606,841,"Parâmetros",,,.F.,,,,,,.T.,,,.T. )

oGrp := TGroup():New( 008,008,184,292,"Marque as empresas/filiais",oDlg,,,.T.,.F. )

TMPEMP->(DbGoTop())
oSel := MsSelect():New("TMPEMP","WKMARCA","",aExibe,@lInverte,@cMarca,{020,016,176,284},,, oGrp ) 
oSel:oBrowse:lHasMark := .T.
oSel:oBrowse:lCanAllMark:=.T.
oSel:oBrowse:bAllMark := {|| MarkAll("TMPEMP",cMarca,@oDlg)}

oGrp2 := TGroup():New( 188,008,224,292,"Vencimento:",oDlg,CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay1 := TSay():New( 204,016,{||"De:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008)
oGet1 := TGet():New( 202,041,{|u| If(PCount()>0,dDataDe:=u,dDataDe)},oGrp2,059,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oSay2 := TSay():New( 204,139,{||"Ate:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008)
oGet2 := TGet():New( 202,161,{|u| If(PCount()>0,dDataAte:=u,dDataAte)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oBtOk  := SButton():New( 228,232,1,bOk,oDlg,,"Confirmar", )
oBtCan := SButton():New( 228,264,2,{|| oDlg:End()},oDlg,,"Cancelar" , )

oDlg:Activate(,,,.T.)

Return Nil                                       

/*
Funcao      : AtuTela
Objetivos   : Atualiza as tabelas temporárias que formam a tela de consulta.
Autor       : Eduardo C. Romanini
Data        : 02/02/2011 
*/
*-----------------------*
Static Function AtuTela()
*-----------------------*
Local lExcSA1 := .F.
Local lExcSA3 := .F.

Local cSX2    := ""
Local cIndSX2 := ""
Local cTabela := ""
Local cFilTab := ""
Local cChave  := ""
Local cWhere  := ""
Local cPeriod := ""

Local nI := 0
Local nP := 0

Local aTotais  := {}

//Apaga todos os registros das tabelas temporarias. 
TMPSE1->(__DbZap())
TMPTOT->(__DbZap())

nTotal := 0

ProcRegua(TMPEMP->(RecCount()))

//Recupera os dados.
TMPEMP->(DbGoTop())
While TMPEMP->(!EOF())
    
    IncProc()	
    
    //Verifica se a empresa está selecionada.
    If Empty(TMPEMP->WKMARCA)
    	TMPEMP->(DbSkip())
    	Loop
    EndIf
   
	cTabela := "%SE1"+AllTrim(TMPEMP->M0_CODIGO)+"0%"
	cFilTab := AllTrim(TMPEMP->M0_CODFIL)    
	cSX2    := "\system\sx2"+AllTrim(TMPEMP->M0_CODIGO)+"0.dbf"

	//Abre o SX2 da empresa posicionada.
	DbUseArea(.T.,"DBDCDX",cSX2,"SX2TMP",.T.,.T.)		
    cIndSX2 := CriaTrab(Nil,.F.)
	IndRegua("SX2TMP",cIndSX2,"X2_CHAVE",,,"Selecionando Registros...")
    
	//Verifica se a tabela SA1 é exclusiva na empresa.
	SX2TMP->(DbSetOrder(1))
	If SX2TMP->(DbSeek("SA1"))
		If SX2TMP->X2_MODO == "C"
			lExcSA1 := .F.
		Else
			lExcSA1 := .T.
		EndIf
	EndIf

	//Verifica se a tabela SA3 é exclusiva na empresa.
	SX2TMP->(DbSetOrder(1))
	If SX2TMP->(DbSeek("SA3"))
		If SX2TMP->X2_MODO == "C"
			lExcSA3 := .F.
		Else
			lExcSA3 := .T.
		EndIf
	EndIf
    
	SX2TMP->(DbCloseArea())
	fErase(cIndSX2)
	    
	//Filtro da query
	cWhere := "%"
	
	If !Empty(dDataDe) .and. !Empty(dDataAte)
		cWhere += " AND E1_VENCTO >= '"+DtoS(dDataDe)+"' AND  E1_VENCTO <= '"+DtoS(dDataAte)+"'"
	ElseIf !Empty(dDataDe)
		cWhere += " AND E1_VENCTO >= '"+DtoS(dDataDe)+"'"
	ElseIf !Empty(dDataAte)
		cWhere += " AND E1_VENCTO <= '"+DtoS(dDataAte)+"'"
	EndIf
		
	cWhere += "%"

	//Query com os dados de cada empresa.
	BeginSql Alias 'QRY'
    	SELECT E1_NUM,E1_PREFIXO,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_EMISSAO,E1_VENCTO,E1_VALOR,E1_IRRF,E1_INSS,E1_PIS,E1_CSLL,E1_COFINS
    	FROM %exp:cTabela%
    	WHERE %NotDel%
    	  AND E1_FILIAL = %exp:cFilTab%
    	  AND E1_SALDO > 0
    	  AND E1_TIPO = 'NF'
    	  %exp:cWhere%
    	ORDER BY E1_VENCTO
	EndSql
        
	//Grava os dados na tabela temporaria de títulos.	
	QRY->(DbGoTop())
	While QRY->(!EOF())
		
		TMPSE1->(DbAppend())	

		TMPSE1->EMPRESA    := TMPEMP->M0_NOME
		TMPSE1->FILDES     := TMPEMP->M0_FILIAL	        
        TMPSE1->CNPJ       := TMPEMP->M0_CGC	        
        TMPSE1->E1_NUM     := QRY->E1_NUM
        TMPSE1->E1_PREFIXO := QRY->E1_PREFIXO
		TMPSE1->E1_CLIENTE := QRY->E1_CLIENTE
		TMPSE1->E1_LOJA    := QRY->E1_LOJA
		TMPSE1->E1_NOMCLI  := QRY->E1_NOMCLI
		TMPSE1->E1_EMISSAO := StoD(QRY->E1_EMISSAO)
		TMPSE1->E1_VENCTO  := StoD(QRY->E1_VENCTO)

		TMPSE1->E1_VALOR   := QRY->E1_VALOR		
		
		TMPSE1->E1_VALLIQ  := QRY->(E1_VALOR - E1_IRRF - E1_INSS - E1_PIS - E1_CSLL - E1_COFINS)
        
        //Totaliza o valor
		nTotal += TMPSE1->E1_VALLIQ
		
		cPeriod := QRY->E1_VENCTO
		
		nP := aScan(aTotais,{|a| AllTrim(a[1])==cPeriod})
			
		If nP == 0
			aAdd(aTotais,{cPeriod,TMPSE1->E1_VALLIQ})
		Else
			aTotais[nP][2] += TMPSE1->E1_VALLIQ
		EndIf

		//Recupera o gerente de contas 
		SA1->(DbSetOrder(1))

		If lExcSA1
			cChave := cFilTab+QRY->E1_CLIENTE+QRY->E1_LOJA
	    Else
	        cChave := Space(2)+QRY->E1_CLIENTE+QRY->E1_LOJA
	    EndIf
  
		If SA1->(DbSeek(cChave))
			If lExcSA3
				cChave := cFilTab+SA1->A1_VEND
		    Else
		        cChave := Space(2)+SA1->A1_VEND
	    	EndIf
		
			If !Empty(SA1->A1_VEND)
				SA3->(DbSetOrder(1))
				If SA3->(DbSeek(cChave))
		    		TMPSE1->A3_NOME := SA3->A3_NOME
				EndIf
			EndIf
		
		EndIf

		QRY->(DbSkip())				 	
	EndDo
        
	QRY->(DbCloseArea())

	TMPEMP->(DbSkip())
EndDo

//Atualiza a tabela com os totais.
aTotais := aSort (aTotais,,,{|x, y| x[1]<y[1]})
For nI:=1 To Len(aTotais)
	TMPTOT->(DbAppend())
    
	TMPTOT->PERIODO := StoD(aTotais[nI][1])
	TMPTOT->TOTAL   := aTotais[nI][2]
Next

//TMPSE1->(DbSetOrder(1))
TMPSE1->(DbGoTop())

TMPTOT->(DbGoTop())

Return Nil  

/*
Funcao      : MarkAll
Objetivos   : Inverter a marcação do MSSelect.
Autor       : Eduardo C. Romanini
Data        : 02/02/2011 
*/
*--------------------------------------------*
Static Function MarkAll(cAlias, cMarca, oDlg)
*--------------------------------------------*
Local nReg := RecNo()

(cAlias)->(dbGoTop())
dbEval({|| (cAlias)->(RecLock(cAlias,.F.)),(cAlias)->WKMARCA := If(Empty((cAlias)->WKMARCA), cMarca, "  "),(cAlias)->(MsUnlock())})
(cAlias)->(dbGoto(nReg))

oDlg:Refresh()

Return Nil        

/*
Funcao      : TelaImprime
Objetivos   : Impressão do relatório
Autor       : Eduardo C. Romanini
Data        : 02/02/2011 
*/
*---------------------------*
Static Function TelaImprime()
*---------------------------*
Private cString  := "TMPSE1"
Private cTitulo  := "Contas a receber em aberto por periodo"
Private cDesc1   := "Contas a receber em aberto por periodo"
Private cDesc2   := ""
Private cDesc3   := ""   
Private Cabec1   := "" 
Private Cabec2   := "" 
Private m_pag    := 1
Private nivel    := 1
Private nPagina  := 1
Private limite   := 132//220
Private tamanho  := "M"//"G"
Private nLastKey := 0
Private lin      := 0
Private aReturn  := { "Zebrado",1,"Administracao", 1, 2, 1,"",1 }
Private wnrel    := "GTRELE1P" 

//                     1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
cabec1   := "Empresa         Filial          CNPJ            Título       Cliente              Emissão     Vlr.Titulo         Vlr.Liq. Gerente"
cabec2   := ""

wnrel:=SetPrint(cString,wnrel,,cTitulo,cDesc1,cDesc2,cDesc3,.F.)

If LastKey()== 27 .or. nLastKey== 27 
	Return
Endif
         
SetDefault(aReturn,cString)

If LastKey()== 27 .Or. nLastKey==27
   Return
Endif

RptStatus({|| GeraDados()},cTitulo)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

/*
Funcao      : GeraDados
Objetivos   : Gera os dados para impressão.
Autor       : Eduardo C. Romanini
Data        : 02/02/2011 
*/
*-------------------------*
Static Function GeraDados()
*-------------------------*
Local lFirst := .T.

Local cVar := ""

Local nReg    :=  TMPSE1->(RecNo())
Local nTotPer := 0
Local nTotal  := 0

//TMPSE1->(DbSetOrder(1))
TMPSE1->(DbGoTop())

If TMPSE1->(BOF()).or. TMPSE1->(EOF())
	MsgAlert("Sem dados para consulta, revise os parâmetros.","Atenção")
    Return .F.
EndIf

lin := 80

While TMPSE1->(!EOF())
	
	If lin > 58
		lin := cabec(ctitulo,cabec1,cabec2,wnrel,tamanho,18)
		lin++
	Endif

 	cVar:= AllTrim(DtoS(TMPSE1->E1_VENCTO))

    nTotCli := 0
    
    While !TMPSE1->(EOF()) .and. cVar == AllTrim(DtoS(TMPSE1->E1_VENCTO))

		If lin > 58
			lin := cabec(ctitulo,cabec1,cabec2,wnrel,tamanho,18)
			lin++
		Endif
    
		If lFirst
			@lin,000 PSAY "DIA: " + AllTrim(DtoC(TMPSE1->E1_VENCTO))
			lFirst := .F.
			lin+=2	
		Endif		

   		@lin,000 PSAY TMPSE1->EMPRESA
		@lin,016 PSAY TMPSE1->FILDES
		@lin,032 PSAY TMPSE1->CNPJ
		@lin,048 PSAY TMPSE1->E1_NUM
		@lin,057 PSAY TMPSE1->E1_PREFIXO
		@lin,061 PSAY TMPSE1->E1_NOMCLI
		@lin,082 PSAY DtoC(TMPSE1->E1_EMISSAO)
		@lin,090 PSAY Transform(TMPSE1->E1_VALOR,"@E 999,999,999.99")
		@lin,108 PSAY Transform(TMPSE1->E1_VALLIQ,"@E 999,999,999.99")
		@lin,125 PSAY TMPSE1->A3_NOME
        
		nTotPer += TMPSE1->E1_VALLIQ
		nTotal  += TMPSE1->E1_VALLIQ

		lin++
		
		TMPSE1->(DbSkip())
	Enddo
	
	lFirst := .T.   
	
	lin++
	@lin,000 PSAY "TOTAL DO DIA " + AllTrim(DtoC(StoD(cVar))) + " :" 
	@lin,097 PSAY Transform(nTotPer,"@E 999,999,999.99")
	lin+=2

EndDo 

@lin,000 PSAY Replicate("-",220)
lin++
@lin,000 PSAY "TOTAL GERAL :" 
@lin,097 PSAY Transform(nTotal,"@E 999,999,999.99")

TMPSE1->(DbGoTo(nReg))

Return Nil

/*
Funcao      : GeraExcel
Objetivos   : Exporta os dados para o Excel
Autor       : Eduardo C. Romanini
Data        : 03/02/2011 
*/
*-------------------------*
Static Function GeraExcel()
*-------------------------*
Local nI := 0

Local aCabExcel   :={} 
Local aItensExcel :={}

Private lSubTotal := .F.

If MsgYesNo("Deseja imprimir os sub-totais?","Atenção")
	lSubTotal := .T. 
EndIf

//Os campos do cabeçalho do excel são os mesmos da tela.
aCabExcel := aClone(aCpTmp)

 //Inclui a coluna de deletado.
aAdd(aCabExcel,{"","L",1,0})

MsgRun(	"Favor Aguardar.....", "Selecionando os Registros",;
	 	{|| GProcItens(aCabExcel, @aItensExcel)})

//Altera o nome dos campos pelo seu título.
For nI:=1 To Len(aCabExcel)
	SX3->(DbSetOrder(2))
	If !Empty(aCabExcel[nI][1]) .and. SX3->(DbSeek(aCabExcel[nI][1]))	
		aCabExcel[nI][1]:= Upper(AllTrim(SX3->X3_TITULO))
	EndIf
Next

MsgRun(	"Favor Aguardar.....", "Exportando os Registros para o Excel",;
		{||DlgToExcel({{"GETDADOS",;
		"CONTAS A RECEBER EM ABERTO",;
		aCabExcel,aItensExcel}})}) 

Return Nil  

/*
Funcao      : GProcItens
Objetivos   : Carrega os dados que vão para o Excel.
Autor       : Eduardo C. Romanini
Data        : 03/02/2011 
*/
*----------------------------------------*
Static Function GProcItens(aHeader, aCols)
*----------------------------------------*
Local cPer := ""

Local nX      := 0
Local nP      := 0
Local nReg    := TMPSE1->(RecNo())
Local nTotPer := 0
Local nTotal  := 0

Local aItem := {}

If lSubTotal

	While TMPSE1->(!EOF())

		aItem := Array(Len(aHeader))

    	cPer := AllTrim(DtoS(TMPSE1->E1_VENCTO))
        
		nTotPer := 0

    	While !TMPSE1->(EOF()) .and. cPer == AllTrim(DtoS(TMPSE1->E1_VENCTO))
	
			For nX := 1 to Len(aHeader)-1
				 IF aHeader[nX][2] == "C"
				 	aItem[nX] := CHR(160)+TMPSE1->&(aHeader[nX][1])
				 ELSE
				 	aItem[nX] := TMPSE1->&(aHeader[nX][1])
				 ENDIF
			Next nX 
		    aItem[Len(aHeader)] := .F.        

			AADD(aCols,aItem)
			aItem := Array(Len(aHeader))
            
			nTotPer += TMPSE1->E1_VALLIQ
            nTotal  += TMPSE1->E1_VALLIQ

			TMPSE1->(dbSkip())
		EndDo    	
    	
    	aItem[1] := "TOTAL DIA VENCIMENTO:"
    	
    	nP := aScan(aHeader,{|e| AllTrim(e[1]) == "E1_VALLIQ"})
    	aItem[nP] := nTotPer

		AADD(aCols,aItem)
	EndDo
    
	aItem := Array(Len(aHeader))
   	aItem[1] := "TOTAL GERAL:"
    	
   	nP := aScan(aHeader,{|e| AllTrim(e[1]) == "E1_VALLIQ"})
   	aItem[nP] := nTotal

	AADD(aCols,aItem)

Else

	While TMPSE1->(!EOF())

		aItem := Array(Len(aHeader))

		For nX := 1 to Len(aHeader)-1
			 If aHeader[nX][2] == "C"
			 	aItem[nX] := CHR(160)+AllTrim(TMPSE1->&(aHeader[nX][1]))
			 Else
			 	aItem[nX] := TMPSE1->&(aHeader[nX][1])
			 EndIf
		Next nX 
	    aItem[Len(aHeader)] := .F.  

		AADD(aCols,aItem)
		aItem := {}
		
		TMPSE1->(dbSkip())
		
	EndDo

EndIf

TMPSE1->(DbGoTo(nReg))		

Return


