#Include "Protheus.ch"
#Include "Rwmake.ch" 
#Include "TOPCONN.ch"
/*
//Função para criar um txt do CT2(Lançamentos Contábeis), a partir de certo periodo.
//Com opção de selecionar o Diretório a ser salvo o arquivo.
*/
User Function P_CT2TXT()    

SET DATE FORMAT "dd/mm/yyyy" 

Private oDlg
Private cNome:=space(15)
Private dDataIni:=date()
Private dDataFin:=date()
PRIVATE oFont6  := NIL

DEFINE FONT oFont6 NAME "ARIAL" BOLD


DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE "Gerar arquivo" OF oDlg PIXEL
@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL

@ 015,017 SAY "Nome do arquivo: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 013,075 MsGet oEdit Var cNome Size 060,009 COLOR CLR_BLACK PIXEL OF oDlg
@ 040,017 SAY "De Data: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 050,017 MsGet oEdit1 Var dDataIni Size 045,009 COLOR CLR_BLACK PIXEL OF oDlg
@ 040,075 SAY "Ate Data: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 050,075 MsGet oEdit2 Var dDataFin Size 045,009 COLOR CLR_BLACK PIXEL OF oDlg

//@  6,167 BUTTON "&Cheques" SIZE 036,012 ACTION ()   OF oDlg PIXEL
@ 28,167 BUTTON "&Gerar"   SIZE 036,012 ACTION (GERATXT())   OF oDlg PIXEL
@ 49,167 BUTTON "&Sair" SIZE 036,012 ACTION (oDlg:End())   OF oDlg PIXEL    
//@ 70,167 BUTTON "&Mov.Banc"    SIZE 036,012 ACTION ()     OF oDlg PIXEL

	oEdit1:bValid     := {|| IIF(EMPTY(dDataIni),DtVazio(dDataIni),.T.) }
	oEdit2:bValid     := {|| IIF(EMPTY(dDataFin),DtVazio(dDataFin),DtMenMai(dDataIni,dDataFin)) }

ACTIVATE MSDIALOG oDlg CENTERED


Return                                                   

//Função para validar se campo data até é > = a data inicial
Static Function DtMenMai(dDtI,dDtF)
Local lRet:=.T.

If dDtF < dDtI
	Alert("Campo 'Ate Data' deve ser maior ou igual ao campo 'De Data'!!")
	lRet:=.F.
EndIf

Return(lRet)

//Validação do campo Data, para não deixar vir em branco.

Static Function DtVazio(dDt)
Local lRet:=.T.

If Empty(dDt)
	Alert("Campo Data não preenchido!")
	lRet:=.F.
EndIf

Return(lRet)   

//****************************************************************************************************************
//--                         **********Função para gerar arquivo .txt***********                                --
//****************************************************************************************************************

Static Function GERATXT()

//+-----------------------------------------------------------------------------
//| Cria o arquivo texto
//+-----------------------------------------------------------------------------

//Retorna o diretório selecionado.
Private cDireto :=Alltrim(direto())

//Verifica se diretório retornou vazio
If Empty(cDireto)
	Alert("Cancelado!")
	Return	
EndIf

Private cArqTxt := alltrim(cDireto+alltrim(cNome)+".TXT")				//cArqtxt recebe o diretorio á partir da função "direto()" + o nome do arquivo

nHdl := fOpen(cArqTxt)

If nHdl > 0
     If !MsgBox("Arquivo "+AllTrim(cNome)+" ja existe no diretorio informado. Deseja substituir ?","Aviso","YESNO")
          fClose(nHdl)
          Return     
     EndIf
EndIf
     
fClose(nHdl)
nHdl := FCreate(cArqTxt)


//Private nHdl := fCreate(cArqTxt)
If nHdl == -1
	MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
Return
Endif
// Inicializa a régua de processamento
Processa({|| RunCont() },"Processando...")

Return Nil
/*/
+-----------------------------------------------------------------------------
| Função | RUNCONT |
+-----------------------------------------------------------------------------
| Descrição | Função auxiliar chamada pela PROCESSA. A função PROCESSA |
| | monta a janela com a régua de processamento. |
+-----------------------------------------------------------------------------
/*/
Static Function RunCont
 
Private CQUERY:=""

Private cDataIni:=DTOS(dDataIni)
Private cDataFin:=DTOS(dDataFin)

//----------------------------
//| QUERY                    |               
//----------------------------
//--LANCAMENTOS DEBITO E CREDITO EXCLUINDO OS DE PARTIDA DOBRADA
CQUERY:= " SELECT R_E_C_N_O_ ,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_MOEDLC,CT2_DC,CT2_DEBITO,CT2_CREDIT,CT2_VALOR,CT2_HIST,CT2_CCD,CT2_CCC,CT2_ITEMD,CT2_ITEMC,CT2_CLVLDB,CT2_CLVLCR,CT2_FILORI FROM "+RETSQLNAME("CT2")+CRLF
CQUERY+= " WHERE D_E_L_E_T_='' "+CRLF
CQUERY+= " AND CT2_DC IN ('1','2')"+CRLF
CQUERY+= " AND CT2_MOEDLC = '01'"+CRLF
CQUERY+= " AND CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFin)+"'"+CRLF
CQUERY+= " UNION ALL"+CRLF
CQUERY+= " SELECT R_E_C_N_O_ ,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_MOEDLC,'1' AS CT2_DC,CT2_DEBITO,'' AS CT2_CREDIT,CT2_VALOR,CT2_HIST,CT2_CCD,'' AS CT2_CCC,CT2_ITEMD,'' AS CT2_ITEMC,CT2_CLVLDB,'' AS CT2_CLVLCR,CT2_FILORI FROM "+RETSQLNAME("CT2")+CRLF
CQUERY+= " WHERE D_E_L_E_T_='' "+CRLF
CQUERY+= " AND CT2_DC IN ('3')"+CRLF
CQUERY+= " AND CT2_MOEDLC = '01'"+CRLF
CQUERY+= " AND CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFin)+"'"+CRLF
CQUERY+= " UNION ALL"+CRLF
CQUERY+= " SELECT R_E_C_N_O_ ,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_MOEDLC,'2' AS CT2_DC,'' AS CT2_DEBITO,CT2_CREDIT,CT2_VALOR,CT2_HIST,'' AS CT2_CCD,CT2_CCC,'' AS CT2_ITEMD,CT2_ITEMC,'' AS CT2_CLVLDB,CT2_CLVLCR,CT2_FILORI FROM "+RETSQLNAME("CT2")+CRLF
CQUERY+= " WHERE D_E_L_E_T_='' "+CRLF
CQUERY+= " AND CT2_DC IN ('3')"+CRLF
CQUERY+= " AND CT2_MOEDLC = '01'"+CRLF
CQUERY+= " AND CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFin)+"'"+CRLF
CQUERY+= " ORDER BY R_E_C_N_O_"

//----------------------------
//| FIM QUERY                    |               
//----------------------------

//memowrite("C:\Grant Thorntom\QUERYGERATXT.txt",cQuery)

//CQUERY:=CHANGEQUERY(CQUERY)                                  

If tcSQLexec(CQUERY) < 0   //para verificar se a query funciona
	Alert("Ocorreu um erro na busca das informações!!")
	fClose(nHdl)
	FERASE(cArqTxt)
	return
Endif

if select("QUERY")>0
	QUERY->(DbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,CQUERY), "QUERY", .F., .T.)

COUNT TO nRecCount

If nRecCount == 0
	Msginfo("Não existem informações neste periodo!!")
	QUERY->(dbclosearea())
	fClose(nHdl)
	FERASE(cArqTxt)
	Return()
EndIf

Private cLin
//dbsetorder(1)
QUERY->(dbGoTop())
ProcRegua(0) //ProcRegua(RecCount()) // Numero de registros a processar

While QUERY->(!EOF())

//Incrementa a régua
IncProc()         

	cLin := PADL(AllTrim(SM0->M0_CODIGO),2)
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_DATA,1,8)),8)
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_LOTE,1,6)),6)
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_SBLOTE,1,3)),3)
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_DOC,1,6)),6)
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_LINHA,1,3)),3)
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_MOEDLC,1,2)),2)
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_DC,1,1)),1)
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_DEBITO,1,20)),20)
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_CREDIT,1,20)),20)
	cLin += PADL(alltrim(TRANSFORM( QUERY->CT2_VALOR , "@E 99999999999999.99" )),17)
	cLin += PADR(ALLTRIM(SUBSTR(QUERY->CT2_HIST,1,40)),40)		
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_CCD,1,9)),9)
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_CCC,1,9)),9)
	//cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_ITEMD,1,9)),9)
	//cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_ITEMC,1,9)),9)
	//cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_CLVLDB,1,9)),9)
	//cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_CLVLCR,1,9)),9)
	//Alterado temporariamente para não trazer o item e classe de valor até a aprovação do layout.
	cLin += PADL("",9)
	cLin += PADL("",9)
	cLin += PADL("",9)
	cLin += PADL("",9)
   
	cLin += PADL(ALLTRIM(SUBSTR(QUERY->CT2_FILORI,1,2)),2)	
	cLin += ""+CRLF
	
//fim
//+-------------------------------------------------------------------+
//| Gravação no arquivo texto. Testa por erros durante a gravação da |
//| linha montada. |
//+-------------------------------------------------------------------+
If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
If !MsgAlert("Ocorreu um erro na gravação do arquivo."+;
"Continua?","Atenção!")
Exit
Endif
Endif
QUERY->(dbSkip())
EndDo
// O arquivo texto deve ser fechado, bem como o dialogo criado na função anterior
QUERY->(dbclosearea())
fClose(nHdl)
msginfo("Arquivo gerado com sucesso!")
Return Nil   

/*
//---------------------//
//Diretorio a ser salvo//
//---------------------//
*/
Static function direto()
Private cDir

cDir:=Alltrim(cGetFile(,'Escolha o diretorio',,,.T.,16+128+GETF_NETWORKDRIVE,.F.))    //cDir recebe o endereço(caminho) selecionado

return(cDir)