#Include "Protheus.ch"
#Include "Rwmake.ch" 
#Include "TOPCONN.ch"

User Function DPZZKTXT

SET DATE FORMAT "dd/mm/yyyy" 

Private oDlg
Private cNome:=space(15)
Private dDataIni:=date()
Private dDataFin:=date()
PRIVATE oFont6  := NIL
Private cDirec:=space(50)
Private cLote:=space(6)
Private cMoeda:=space(2)
Private cCodEmp:=space(9)

DEFINE FONT oFont6 NAME "ARIAL" BOLD

                          //264,182  //541,613
DEFINE MSDIALOG oDlg FROM 264,182 TO 541,580 TITLE "Gerar arquivo" OF oDlg PIXEL
@ 004,010 TO 122,187 LABEL "" OF oDlg PIXEL
			//082,157
@ 015,017 SAY "Diretorio: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 013,075 MsGet oEdit3 Var cDirec Size 060,009 COLOR CLR_BLACK PIXEL OF oDlg

@ 030,017 SAY "Nome do arquivo: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 028,075 MsGet oEdit Var cNome Size 060,009 COLOR CLR_BLACK PIXEL OF oDlg

@ 050,017 SAY "De Data: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 060,017 MsGet oEdit1 Var dDataIni Size 045,009 COLOR CLR_BLACK PIXEL OF oDlg

@ 050,075 SAY "Ate Data: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 060,075 MsGet oEdit2 Var dDataFin Size 045,009 COLOR CLR_BLACK PIXEL OF oDlg

@ 075,017 SAY "Lote: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 085,017 MsGet oEdit4 Var cLote Size 045,009 COLOR CLR_BLACK PIXEL OF oDlg PICTURE "999999"                                                                                 

@ 075,075 SAY "Moeda: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 085,075 MsGet oEdit5 Var cMoeda Size 045,009 COLOR CLR_BLACK PIXEL OF oDlg PICTURE "99"  

@ 075,133 SAY "Cod Empresa: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 085,133 MsGet oEdit6 Var cCodEmp Size 045,009 COLOR CLR_BLACK PIXEL OF oDlg

//@  6,167 BUTTON "&Cheques" SIZE 036,012 ACTION ()   OF oDlg PIXEL
@ 13,140 BUTTON oBtn PROMPT "Se&lecionar" SIZE 036,012 ACTION (direto())   OF oDlg PIXEL
@ 125,127 BUTTON oBtn1 PROMPT "&Sair" SIZE 036,012 ACTION (oDlg:End())   OF oDlg PIXEL    
@ 125,047 BUTTON oBtn2 PROMPT "&Gerar" SIZE 036,012 ACTION (gerar(cDirec,cNome))   OF oDlg PIXEL    
//@ 70,167 BUTTON "&Mov.Banc"    SIZE 036,012 ACTION ()     OF oDlg PIXEL

	oEdit1:bValid     := {|| IIF(EMPTY(dDataIni),DtVazio(dDataIni),.T.) }
	oEdit2:bValid     := {|| IIF(EMPTY(dDataFin),DtVazio(dDataFin),DtMenMai(dDataIni,dDataFin)) }
	
	oEdit4:bValid := {|| LibBtGer()}
	oEdit5:bValid := {|| LibBtGer()}
	oEdit6:bValid := {|| LibBtGer()}	

oEdit:Disable()

oEdit1:Disable()
oEdit2:Disable()
oEdit3:Disable()
oEdit4:Disable()
oEdit5:Disable()
oEdit6:Disable()                


oBtn2:Disable()


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
//--------------
Static Function LibBtGer()
	
If !Empty(cLote) .AND. !Empty(cMoeda) .AND. !Empty(cCodEmp) .AND. !Empty(dDataIni) .AND. !Empty(dDataFin)
	oBtn2:Enable()
Else
	oBtn2:Disable()
EndIf 

Return(.T.)
/*
//---------------------//
//Diretorio a ser salvo//
//---------------------//
*/
Static function direto()
Local cDir

cDir:=Alltrim(cGetFile(,'Escolha o diretorio',,,.T.,16+128))    //cDir recebe o endereço(caminho) selecionado

//Verifica se diretório retornou vazio
If Empty(cDir)
	Alert("Cancelado!")
	Return	
Else
	cDirec:=cDir
	oEdit:Enable()
	oEdit1:Enable()
	oEdit2:Enable()
	oEdit4:Enable()
	oEdit5:Enable()
	oEdit6:Enable()    
EndIf

return()

Static Function gerar(cDir,cNome)

Private cArqTxt := alltrim(cDir)+alltrim(cNome)+".TXT"		

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
 
Local cQuery:=""

cQuery+=" SELECT "+CRLF 
cQuery+=" convert(varchar(10),R_E_C_N_O_) as ordem,"+CRLF

cQuery+=" 'D' as tipo,"+CRLF

cQuery+=" CT2_DATA "+CRLF

cQuery+=" + ',' + '"+'"0"'+"' "+CRLF

cQuery+=" + ',' + '"+'"1"'+"' "+CRLF

cQuery+=" + ',' + LEFT(CT2_DATA,4) "+CRLF

cQuery+=" + ',' + RIGHT(LEFT(CT2_DATA,6),2) "+CRLF

cQuery+=" + ',' + RIGHT(CT2_DATA,2) "+CRLF

cQuery+=" + ',' + '1' "+CRLF

cQuery+=" + ',' + '"+'"INTERFACE"'+"' "+CRLF

cQuery+=" + ',' + RTRIM(CT2_DEBITO) "+CRLF

cQuery+=" + ',' + '"+'"D"'+"' "+CRLF

cQuery+=" + ',' + convert(varchar(11),(convert(decimal(15,2),CT2_VALOR)))"+CRLF

cQuery+=" + ',' + '789' "+CRLF

cQuery+=" + ',' + '' "+CRLF

cQuery+=" + ',' + '' "+CRLF

cQuery+=" + ',' + '' "+CRLF

cQuery+=" + ',' + '' "+CRLF

cQuery+=" + ',' + '"+'"'+"' + CT2_HIST + '"+"'"+CRLF

cQuery+=" + ',' + 'FOL' "+CRLF

cQuery+=" + ',' + '"+cCodEmp+"' AS A"+CRLF

cQuery+=" FROM "+CRLF
cQuery+="  ("+CRLF
cQuery+=" Select CT2.R_E_C_N_O_,CT2_DATA,"+CRLF
cQuery+=" (case "+CRLF
cQuery+=" --CONSIDERA CTE_DEBITO,ZZK_HIST,ZZK_CC=''"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='') <> '' "+CRLF
cQuery+=" 	then "+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC,ZZ_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_CC) = UPPER(CT2_CCD) AND ZZK_HIST = '') <> ''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_CC) = UPPER(CT2_CCD) AND ZZK_HIST = '')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_HIST,ZZK_CC	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCD)) <>''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCD))"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC='',ZZK_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND ZZK_CC='' AND ZZK_HIST = '') <> '' "+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND ZZK_CC='' AND ZZK_HIST = '')"+CRLF
cQuery+=" Else"+CRLF
cQuery+=" ''"+CRLF
cQuery+="  end ) AS CT2_DEBITO,"+CRLF

cQuery+=" (case "+CRLF
cQuery+=" --CONSIDERA CTE_DEBITO,ZZK_HIST,ZZK_CC=''"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='') <> '' "+CRLF
cQuery+=" 	then "+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC,ZZ_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_CC) = UPPER(CT2_CCC) AND ZZK_HIST = '') <> ''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_CC) = UPPER(CT2_CCC) AND ZZK_HIST = '')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_HIST,ZZK_CC	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCC)) <>''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCC))"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC='',ZZK_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND ZZK_CC='' AND ZZK_HIST = '') <> '' "+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND ZZK_CC='' AND ZZK_HIST = '')"+CRLF
cQuery+=" Else"+CRLF
cQuery+=" ''"+CRLF
cQuery+="  end ) AS CT2_CREDIT,"+CRLF
 
cQuery+=" CT2_HIST,CT2_VALOR,CT2_CCC,CT2_CCD FROM "+RETSQLNAME("CT2")+" CT2"+CRLF
cQuery+=" where CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFin)+"'  "+CRLF

cQuery+=" and CT2_LOTE = '"+cLote+"'"+CRLF

cQuery+=" and CT2_MOEDLC = '"+cMoeda+"' AND CT2.D_E_L_E_T_=''"+CRLF

cQuery+=" ) AS CT2N"+CRLF

cQuery+=" WHERE CT2N.CT2_DEBITO <> ''"+CRLF

cQuery+=" UNION ALL"+CRLF

cQuery+=" SELECT "+CRLF
cQuery+=" convert(varchar(10),R_E_C_N_O_) as ordem,"+CRLF

cQuery+=" 'D' as tipo,"+CRLF

cQuery+=" CT2_DATA "+CRLF

cQuery+=" + ',' + '"+'"1"'+"' "+CRLF

cQuery+=" + ',' + RTRIM(CT2_CCD) "+CRLF

cQuery+=" + ',' + RTRIM(CT2_CCD)"+CRLF

cQuery+=" + ',' + convert(varchar(11),(convert(decimal(15,2),CT2_VALOR))) AS A -- Valor"+CRLF

cQuery+=" FROM "+CRLF
cQuery+="  ("+CRLF
cQuery+=" Select CT2.R_E_C_N_O_,CT2_DATA,"+CRLF
cQuery+=" (case "+CRLF
cQuery+=" --CONSIDERA CTE_DEBITO,ZZK_HIST,ZZK_CC=''"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='') <> '' "+CRLF
cQuery+=" 	then "+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC,ZZ_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_CC) = UPPER(CT2_CCD) AND ZZK_HIST = '') <> ''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_CC) = UPPER(CT2_CCD) AND ZZK_HIST = '')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_HIST,ZZK_CC	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCD)) <>''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCD))"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC='',ZZK_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND ZZK_CC='' AND ZZK_HIST = '') <> '' "+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND ZZK_CC='' AND ZZK_HIST = '')"+CRLF
cQuery+=" Else"+CRLF
cQuery+=" ''"+CRLF
cQuery+="  end ) AS CT2_DEBITO,"+CRLF

cQuery+=" (case "+CRLF
cQuery+=" --CONSIDERA CTE_DEBITO,ZZK_HIST,ZZK_CC=''"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='') <> '' "+CRLF
cQuery+=" 	then "+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC,ZZ_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_CC) = UPPER(CT2_CCC) AND ZZK_HIST = '') <> ''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_CC) = UPPER(CT2_CCC) AND ZZK_HIST = '')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_HIST,ZZK_CC	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCC)) <>''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCC))"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC='',ZZK_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND ZZK_CC='' AND ZZK_HIST = '') <> '' "+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND ZZK_CC='' AND ZZK_HIST = '')"+CRLF
cQuery+=" Else"+CRLF
cQuery+=" ''"+CRLF
cQuery+="  end ) AS CT2_CREDIT,"+CRLF
 
cQuery+=" CT2_HIST,CT2_VALOR,CT2_CCC,CT2_CCD FROM "+RETSQLNAME("CT2")+" CT2"+CRLF
cQuery+=" where CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFin)+"'  "+CRLF

cQuery+=" and CT2_LOTE = '"+cLote+"'"+CRLF

cQuery+=" and CT2_MOEDLC = '"+cMoeda+"' AND CT2.D_E_L_E_T_=''"+CRLF

cQuery+=" ) AS CT2N"+CRLF

cQuery+=" WHERE CT2N.CT2_DEBITO <> '' AND CT2_CCD <> ''"+CRLF

cQuery+=" UNION "+CRLF

cQuery+=" SELECT "+CRLF

cQuery+=" convert(varchar(10),R_E_C_N_O_) as ordem,"+CRLF

cQuery+=" 'C' as tipo,"+CRLF

cQuery+=" CT2_DATA "+CRLF

cQuery+=" + ',' + '"+'"0"'+"' "+CRLF

cQuery+=" + ',' + '"+'"1"'+"' "+CRLF

cQuery+=" + ',' + LEFT(CT2_DATA,4) "+CRLF

cQuery+=" + ',' + RIGHT(LEFT(CT2_DATA,6),2) "+CRLF

cQuery+=" + ',' + RIGHT(CT2_DATA,2) "+CRLF

cQuery+=" + ',' + '1' "+CRLF

cQuery+=" + ',' + '"+'"INTERFACE"'+"'" +CRLF

cQuery+=" + ',' + RTRIM(CT2_CREDIT) "+CRLF

cQuery+=" + ',' + '"+'"C"'+"' "+CRLF

cQuery+=" + ',' + convert(varchar(11),(convert(decimal(15,2),CT2_VALOR)))"+CRLF

cQuery+=" + ',' + '789' "+CRLF

cQuery+=" + ',' + '' "+CRLF

cQuery+=" + ',' + '' "+CRLF

cQuery+=" + ',' + '' "+CRLF

cQuery+=" + ',' + '' "+CRLF

cQuery+=" + ',' + '"+'"'+"' + CT2_HIST + '"+"'"+CRLF

cQuery+=" + ',' + 'FOL' "+CRLF

cQuery+=" + ',' + '"+cCodEmp+"' AS A"+CRLF

cQuery+=" FROM "+CRLF
cQuery+="  ("+CRLF
cQuery+=" Select CT2.R_E_C_N_O_,CT2_DATA,"+CRLF
cQuery+=" (case "+CRLF
cQuery+=" --CONSIDERA CTE_DEBITO,ZZK_HIST,ZZK_CC=''"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='') <> '' "+CRLF
cQuery+=" 	then "+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC,ZZ_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_CC) = UPPER(CT2_CCD) AND ZZK_HIST = '') <> ''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_CC) = UPPER(CT2_CCD) AND ZZK_HIST = '')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_HIST,ZZK_CC	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCD)) <>''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCD))"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC='',ZZK_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND ZZK_CC='' AND ZZK_HIST = '') <> '' "+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND ZZK_CC='' AND ZZK_HIST = '')"+CRLF
cQuery+=" Else"+CRLF
cQuery+=" ''"+CRLF
cQuery+="  end ) AS CT2_DEBITO,"+CRLF

cQuery+=" (case "+CRLF
cQuery+=" --CONSIDERA CTE_DEBITO,ZZK_HIST,ZZK_CC=''"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='') <> '' "+CRLF
cQuery+=" 	then "+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC,ZZ_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_CC) = UPPER(CT2_CCC) AND ZZK_HIST = '') <> ''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_CC) = UPPER(CT2_CCC) AND ZZK_HIST = '')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_HIST,ZZK_CC	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCC)) <>''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCC))"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC='',ZZK_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND ZZK_CC='' AND ZZK_HIST = '') <> '' "+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND ZZK_CC='' AND ZZK_HIST = '')"+CRLF
cQuery+=" Else"+CRLF
cQuery+=" ''"+CRLF
cQuery+="  end ) AS CT2_CREDIT,"+CRLF
 
cQuery+=" CT2_HIST,CT2_VALOR,CT2_CCC,CT2_CCD FROM "+RETSQLNAME("CT2")+" CT2"+CRLF
cQuery+=" where CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFin)+"'  "+CRLF

cQuery+=" and CT2_LOTE = '"+cLote+"'"+CRLF

cQuery+=" and CT2_MOEDLC = '"+cMoeda+"' AND CT2.D_E_L_E_T_=''"+CRLF

cQuery+=" ) AS CT2N"+CRLF

cQuery+=" WHERE CT2N.CT2_CREDIT <> ''"+CRLF
 
cQuery+=" UNION ALL"+CRLF

cQuery+=" SELECT "+CRLF

cQuery+=" convert(varchar(10),R_E_C_N_O_) as ordem,"+CRLF

cQuery+=" 'C' as tipo,"+CRLF

cQuery+=" CT2_DATA "+CRLF

cQuery+=" + ',' + '"+'"1"'+"' "+CRLF

cQuery+=" + ',' + RTRIM(CT2_CCC)"+CRLF

cQuery+=" + ',' + RTRIM(CT2_CCC)"+CRLF

cQuery+=" + ',' + convert(varchar(11),(convert(decimal(15,2),CT2_VALOR))) AS A "+CRLF

cQuery+=" FROM "+CRLF
cQuery+="  ("+CRLF
cQuery+=" Select CT2.R_E_C_N_O_,CT2_DATA,"+CRLF
cQuery+=" (case "+CRLF
cQuery+=" --CONSIDERA CTE_DEBITO,ZZK_HIST,ZZK_CC=''"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='') <> '' "+CRLF
cQuery+=" 	then "+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC,ZZ_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_CC) = UPPER(CT2_CCD) AND ZZK_HIST = '') <> ''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_CC) = UPPER(CT2_CCD) AND ZZK_HIST = '')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_HIST,ZZK_CC	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCD)) <>''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCD))"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC='',ZZK_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND ZZK_CC='' AND ZZK_HIST = '') <> '' "+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_DEBITO) AND UPPER(ZZK_NATURE)='D' AND ZZK_CC='' AND ZZK_HIST = '')"+CRLF
cQuery+=" Else"+CRLF
cQuery+=" ''"+CRLF
cQuery+="  end ) AS CT2_DEBITO,"+CRLF

cQuery+=" (case "+CRLF
cQuery+=" --CONSIDERA CTE_DEBITO,ZZK_HIST,ZZK_CC=''"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='') <> '' "+CRLF
cQuery+=" 	then "+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND ZZK_CC='')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC,ZZ_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_CC) = UPPER(CT2_CCC) AND ZZK_HIST = '') <> ''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_CC) = UPPER(CT2_CCC) AND ZZK_HIST = '')"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_HIST,ZZK_CC	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCC)) <>''"+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND  UPPER(ZZK_HIST) LIKE UPPER(CT2_HIST+'%') AND  UPPER(ZZK_CC) = UPPER(CT2_CCC))"+CRLF
cQuery+=" --CONSIDERA CT2_DEBITO,ZZK_CC='',ZZK_HIST=''	"+CRLF
cQuery+=" when (SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND ZZK_CC='' AND ZZK_HIST = '') <> '' "+CRLF
cQuery+=" 	then"+CRLF
cQuery+=" 	(SELECT ZZK_CONTDE FROM "+RETSQLNAME("ZZK")+CRLF
cQuery+=" 	WHERE UPPER(ZZK_CONTCT)=UPPER(CT2_CREDIT) AND UPPER(ZZK_NATURE)='C' AND ZZK_CC='' AND ZZK_HIST = '')"+CRLF
cQuery+=" Else"+CRLF
cQuery+=" ''"+CRLF
cQuery+="  end ) AS CT2_CREDIT,"+CRLF

cQuery+=" CT2_HIST,CT2_VALOR,CT2_CCC,CT2_CCD FROM "+RETSQLNAME("CT2")+" CT2"+CRLF
cQuery+=" where CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFin)+"'  "+CRLF

cQuery+=" and CT2_LOTE = '"+cLote+"'"+CRLF

cQuery+=" and CT2_MOEDLC = '"+cMoeda+"' AND CT2.D_E_L_E_T_=''"+CRLF

cQuery+=" ) AS CT2N       "+CRLF

cQuery+=" WHERE CT2N.CT2_CREDIT <> '' AND CT2_CCC <> ''"+CRLF
 
cQuery+=" ORDER BY ordem,tipo,A"
                             

If tcSQLexec(cQuery) < 0   //para verificar se a query funciona
	Alert("Ocorreu um erro na busca das informações!!")
	fClose(nHdl)
	FERASE(cArqTxt)
	return
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "CT2NEW", .F., .T.)

COUNT TO nRecCount

If nRecCount == 0
	Msginfo("Não existem informações neste periodo!!")
	CT2NEW->(dbclosearea())
	fClose(nHdl)
	FERASE(cArqTxt)
	Return()
EndIf

Private cLin
//dbsetorder(1)
CT2NEW->(dbGoTop())
ProcRegua(0) //ProcRegua(RecCount()) // Numero de registros a processar

While CT2NEW->(!EOF())

//Incrementa a régua
IncProc()         

	cLin := ALLTRIM(CT2NEW->A)
	cLin += CRLF
	
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
CT2NEW->(dbSkip())
EndDo
// O arquivo texto deve ser fechado, bem como o dialogo criado na função anterior
CT2NEW->(dbclosearea())
fClose(nHdl)

msginfo("Arquivo gerado com sucesso!")
Return Nil   
