#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"  
#include "Protheus.ch"
#include "Rwmake.ch"       

/*
Funcao      : GTGEN006
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Rotina de Geração de arquivo para integração com visa vale.
Autor       : Jean Victor Rocha.
Data/Hora   : 06/06/2013
*/                        
*----------------------*
User Function GTGEN006()
*----------------------*
Local cArea     := GetArea()
Local cArquivo  
Local oDlg
Local nOpcao	:= 0
Local oFont15	:= TFont():New("Arial",,15,,.T.,,,,.T.,.F.)         
Local aButtons	:= { }       

Private cFilialde    := Space(AvSx3("RA_FILIAL",3))
Private cFilialate   := Space(AvSx3("RA_FILIAL",3))
Private cMatde    := Space(AvSx3("RA_MAT",3))
Private cMatate   := Space(AvSx3("RA_MAT",3))  
Private dDtCred   := CtoD(Space(8))          
Private nDias	  := 22
Private cNomeArq  := Space(8)

Private cDir := "c:\"

Private oDir
Private bOk      	    := { || nOpcao:=1 , oDlg:End() }
Private bCancel  	    := { || nOpcao:=0 , oDlg:End() }

Private aExcFunc := {}

AADD(aButtons,{"MSGREPLY", {|| GEN006EXC()}, "Exceções","Exceções",{|| .T.}})
AADD(aButtons,{"SDUIMPORT", {|| GEN006FOL()}, "Int. Desc. Folha","Int. Desc. Folha",{|| .T.}})

DEFINE MSDIALOG oDlg TITLE "Grant Thornton Brasil. - Integração Visa Vale" FROM 00, 00 to 320, 380 PIXEL  

@ 014,005 Say "Filial de"		Size 40,10 FONT oFont15 COLOR RGB(0,0,155) of oDlg PIXEL
@ 014,090 Say "ate"				Size 40,10 FONT oFont15 COLOR RGB(0,0,155) of oDlg PIXEL
@ 030,005 Say "Matricula de"	Size 40,10 FONT oFont15 COLOR RGB(0,0,155) of oDlg PIXEL
@ 030,090 Say "ate"				Size 40,10 FONT oFont15 COLOR RGB(0,0,155) of oDlg PIXEL
@ 046,005 Say "Qtd. Dias"  	   	Size 40,10 FONT oFont15 COLOR RGB(0,0,155) of oDlg PIXEL      
@ 072,005 Say "Diretorio:"      Size 40,10 FONT oFont15 COLOR RGB(0,0,155) of oDlg PIXEL      
@ 014,055 MsGet cFilialde		Picture AvSx3("RA_FILIAL",6)	F3 "XM0"    	Size 30,6 of oDlg PIXEL
@ 014,105 MsGet cFilialate		Picture AvSx3("RA_FILIAL",6)   	F3 "XM0"	  	Size 30,6 of oDlg PIXEL
@ 030,055 MsGet cMatde			Picture AvSx3("RA_MAT",6)		F3 "SRA"    	Size 30,6 of oDlg PIXEL
@ 030,105 MsGet cMatate			Picture AvSx3("RA_MAT",6)   	F3 "SRA"	  	Size 30,6 of oDlg PIXEL       
@ 046,055 MsGet nDias			Picture "@E 99"      							Size 30,6 of oDlg PIXEL       
@ 072,055 MsGet cDir			Picture "@!" 		  							Size 60,6 of oDlg PIXEL       
@ 072,115 Button "?"	Size 7,10 Pixel of oDlg action (GetDir())

ACTIVATE MSDIALOG oDlg CENTERED On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

IF nOpcao == 1
  Processa({|lEnd| GEN006Proc(),"Calculando"})
Endif

RestArea(cArea)

Return .T.

/*
Funcao      : GEN006EXC
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : carrega Exceções de ferias/abonos/justificativas...
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-------------------------*
Static Function GEN006EXC()
*-------------------------*
Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
Local aButtons := {}
Local nOpcBut := 1

Private aCols := {}
Private aHeader := {}

SetPrvt("oDlgExc","oBrw1")
                                                                       
Aadd(aHeader,{"Filial" 		,"FILI","@!"	,02,00,"","","C","XM0",""})
Aadd(aHeader,{"Matricula"	,"MATR","@!"	,06,00,"","","C","SRA",""})
Aadd(aHeader,{"Nome"		,"NOME",""		,25,00,"","","C","","" })
Aadd(aHeader,{"Dias"		,"NDIA","@E 99"	,02,00,"","","N","","" })

aAlter := {"FILI","MATR","NDIA"}

If Len(aExcFunc) == 0
	aCols:={{SPACE(aHeader[1,4]),SPACE(aHeader[2,4]), SPACE(aHeader[3,4]), 0, .F. }}
Else
	aCols := aExcFunc
EndIf

oDlgExc    := MSDialog():New( 142,471,449,859,"Exceções por funcionarios.",,,.F.,,,,,,.T.,,,.T. )
oBrw1      := MsNewGetDados():New(004,004,124,184,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,999,'U_GEN006VLD()','','AllwaysTrue()',oDlgExc,aHeader,aCols )
                     
Private bOk      	    := { || (nOpcBut := 1, oDlgExc:End()) }
Private bCancel  	    := { || oDlgExc:End() }

oDlgExc:bInit := {|| EnchoiceBar(oDlgExc,bOk,bCancel,,aButtons)}
oDlgExc:lCentered := .T.
oDlgExc:Activate(,,,.T.)  

If nOpcBut == 1
	aExcFunc := {}
	For i:=1 to Len(oBrw1:aCols)
		If !oBrw1:aCols[i][LEN(oBrw1:aCols[i])]
			aAdd(aExcFunc, oBrw1:aCols[i])
		EndIf
	Next i
EndIf

Return .T.

/*
Funcao      : GEN006VLD
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Validação de campo
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*--------------------------*
User Function GEN006VLD()
*---------------------------*
lRet := .T.

Do case
	Case __READVAR == "M->MATR"
		SRA->(DbSetOrder(13))//RA_MAT+RA_FILIAL
		If SRA->(DbSeek(M->MATR))
			aCols[oBrw1:NAT][aScan(aHeader,{|x| x[2] == "NOME"})] := SRA->RA_NOME
		Else
			M->MATR := SPACE(aHeader[aScan(aHeader,{|x| x[2] == "MATR"})][4])
			aCols[oBrw1:NAT][aScan(aHeader,{|x| x[2] == "NOME"})] := ""
			lRet := .F.
		EndIf
EndCase


Return lRet

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

*--------------------------*
Static Function GEN006Proc()
*--------------------------*
Local lDados := .F.
Local cArquivos := ""           

Private i 		:= 0
Private aBenef 	:= GetBenef()                

For i:=1 to len(aBenef)
	lDados := .F.       
	cDir := AllTrim(cDir)

	cNomeArq := AchaNome() 
	nHandle := MSFCREATE(cDir+cNomeArq)

	If FERROR() # 0 .Or. nHandle < 0
		MsgAlert("Não foi possivel a criação de arquivo" + Chr(13) + ;
		         "       Processo será abortado        ","Grant Thornton Brasil")
		FClose(nHandle)
		Return(.f.)
	EndIf

	If EMPTY(cFilialAte)
		cFilialAte := "ZZZZZZ"
	EndIf	
	If EMPTY(cMatAte)
		cMatAte := "ZZZZZZ"
	EndIf	

	Set Century On                       
	Set SoftSeek On
	      
	lDados := .F.
	Fwrite(nHandle, ";NOME DO USUARIO;CPF;DATA DE NASCIMENTO;CODIGO DE SEXO;VALOR;TIPO DE LOCAL ENTREGA;LOCAL DE ENTREGA;MATRICULA;"+CHR(13)+CHR(10))

	//Busca os Funcionarios.
	cQry := " Select *
	cQry += " From "+RetSqlName("SRA")
	cQry += " Where D_E_L_E_T_ <> '*'
	cQry += " AND RA_DEMISSA = ''
	cQry += " AND RA_FILIAL >= '"+cFilialDe+"'
	cQry += " AND RA_FILIAL <= '"+cFilialAte+"'
	cQry += " AND RA_MAT >= '"+cMatDe+"'
	cQry += " AND RA_MAT <= '"+cMatAte+"'
	cQry += " Order By RA_FILIAL,RA_MAT
	
	If select("TMP")>0
		TMP->(DbCloseArea())
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMP",.T.,.T.)
	
	aStru:= SRA->(DbStruct())                
	For nI := 1 To Len(aStru)
		If aStru[nI][2] <> "C" .and.  FieldPos(aStru[nI][1]) > 0
			TcSetField("TMP",aStru[nI][1],aStru[nI][2],aStru[nI][3],aStru[nI][4])
		EndIf
	Next nI 
	
	TMP->(DbGoTop())
	While TMP->(!Eof())
     	If Select("TMPVV") > 0
			TMPVV->(DbClosearea())
		Endif     	                   
	    
		cQuery := " SELECT Z71_FORN, Z71_COD, Z71_QTDE, Z71_VALOR, Z71_MAT "	+ Chr(13)
      	cQuery += " FROM " + RetSqlName("Z71") + " Z71 "						+ Chr(13)	
      	cQuery += " WHERE D_E_L_E_T_ = '' "     								+ Chr(13)
      	cQuery += " AND Z71_FILIAL = '" + TMP->RA_FILIAL + "' "					+ Chr(13)
      	cQuery += " AND Z71_MAT = '" + TMP->RA_MAT + "' " 						+ Chr(13)
		cQuery += " AND Z71_FORN = 'VV'"										+ Chr(13)
		cQuery += " AND Z71_COD = '"+aBenef[i][1]+"'"   						+ Chr(13)//Refeição

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TMPVV",.F.,.T.)
		 
		aStru:= Z71->(DbStruct())                
		For nI := 1 To Len(aStru)
			If aStru[nI][2] <> "C" .and.  FieldPos(aStru[nI][1]) > 0
				TcSetField("TMPVV",aStru[nI][1],aStru[nI][2],aStru[nI][3],aStru[nI][4])
			EndIf
		Next nI 
		
		
		Do While TMPVV->(!EoF())     
			nQtdeDias := nDias
			If (nPos:=aScan(aExcFunc, {|x| x[1]==TMP->RA_FILIAL .and. x[2]==TMP->RA_MAT} )) <> 0
				nQtdeDias := aExcFunc[nPos][4]
			EndIf
               
			cValor := STRTRAN(TRANSFORM( ( TMPVV->Z71_Valor * nQtdeDias ), "99999999.99") ,".",",")
			
			cLinha :=	"%;"+;				  			//Primeira coluna "%" obrigatorio
						ALLTRIM(TMP->RA_NOME)	+";"+;
						TMP->RA_CIC				+";"+;
						DtoC(TMP->RA_NASC)		+";"+;
						TMP->RA_SEXO  			+";"+;
						cValor					+";"+;
						"FI"  					+";"+;
						RIGHT(SM0->M0_CGC,6)	+";"+;
						TMP->RA_FILIAL+TMP->RA_MAT	+";"+;
						"%"+CHR(13)+CHR(10)				//Ultima coluna "%" obrigatorio

			Fwrite(nHandle, cLinha)
			lDados := .T.           

			TMPVV->(DBSkip())
		Enddo
		TMP->(DBSkip())
	EndDo
	
	FClose(nHandle)
    
  	If lDados
		cArquivos += cDir+cNomeArq+CHR(13)+CHR(10)
	Else
   		FErase(cDir+cNomeArq)
  	EndIf
Next i
	 	   
If !EMPTY(cArquivos)   
   MsgAlert( "Arquivo(s) para integração Visa Vale gerado(s) com sucesso: "+CHR(13)+CHR(10)+cArquivos, "Atenção !")   
Else
	MsgAlert("Não existem dados para envio !!! " +Chr(13) +;
	         "Verifique os filtros selecionados", "Atenção !")
Endif



Set Century Off

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ConfAno     ³ 				         b   Data ³ 17/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Envio de arquivo para solicitação de Visa Vale             ³±±
±±³            Valida se o ano de referencia tem 4 digitos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
Alteração	: Jean Victor Rocha
Motivo		: Retirada da validação de ano entre 2012~2020.
Data		: 18/10/2012
*/
Static Function ConfAno()
Local lRet := .t.

If Len(Alltrim(cMesAno)) < 7
	MsgAlert( "É obrigatorio o preenchimento do mes com 2 digitos e ano com 4 digitos !","Atenção !")
    lRet := .f.  
Else
	if Val(Substr(cMesAno,1,2)) > 12 .or. Val(Substr(cMesAno,1,2)) < 1
 		MsgAlert( "   Mes informado incorreto !   " + Chr(13) +;
        	      "Favor informar um mes existente !", "Atenção !" )     
   		lRet := .f.
    Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³AchaNome    ³                           b   Data ³ 17/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Envio de arquivo para solicitação de Visa Vale             ³±±
±±³            Acha proximo nome para o arquivo de integração             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
Alteração	: Jean Victor Rocha
Motivo		: Adequação do nome criado com o padrão ja existente para Beneficios.
Data		: 18/10/2012
*/     
*-------------------------*
Static Function AchaNome()
*-------------------------*
Local n 		:= 0
Local cArq    := "VV_"+UPPER(LEFT(aBenef[i][2],3))+"_"+DTOS(Date())+"_"+ALLTRIM(cEmpAnt)+ALLTRIM(cFilAnt)

While File(cDir+cArq+".CSV")
	n++
	If AT("(",cArq) <> 0
		cArq := SUBSTR(cArq,1,AT("(",cArq))+ALLTRIM(STR(n))+")"
	Else
		cArq += "("+ALLTRIM(STR(n))+")"
	EndIf
EndDo
cArq += ".CSV"

Return(cArq)

/*
Funcao      : GEN006FOL
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 24/04/2013
*/
*---------------------------*
Static Function GEN006FOL()
*---------------------------*
Local cCadastro := "Importacao de Arquivo"

Private cArq	:= Space(200)
Private nPorc	:= 10

SetPrvt("oDlg1","oSay1","oSay2","oSay3","oSay4","oGet1","oBtn1","oSBtn1","oSBtn2","oGet2")

oDlg1      := MSDialog():New( 311,474,477,743,cCadastro,,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 032,004,{||"Arquivo:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
oSay2      := TSay():New( 004,004,{||"Geração de desconto em folha baseado no arquivo"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,124,008)
oSay3      := TSay():New( 012,004,{||"de pedido enviado ao fornecedor, Visa Vale."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,124,008)
oSay4      := TSay():New( 044,004,{||"Porc. Desc."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
oGet1      := TGet():New( 032,036,{|u| IF(PCount()>0,cArq:=u,cArq)},oDlg1,072,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet2      := TGet():New( 044,036,{|u| IF(PCount()>0,nPorc:=u,nPorc)},oDlg1,072,008,"@E 99",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oBtn1      := TButton():New( 032,108,"?",oDlg1,{|| GetArq()},008,012,,,,.T.,,"",,,,.F. )
oSBtn1     := SButton():New( 060,092,1,{|| (Processa({||ProcArq(cArq)}),oDlg1:end())},oDlg1,,"", )
oSBtn2     := SButton():New( 060,064,2,{|| oDlg1:end()},oDlg1,,"", )

oDlg1:Activate(,,,.T.)

Return( Nil )

*-------------------------------*
Static Function ProcArq(cArquivo)
*-------------------------------*
Local aLinha := {}
Local aInfos := {}
Local nPos := 0
Local nValor := 0
Local cVerba := "704"

If !File(cArq)
	Alert("Arquivo informado não encontrado!")
	Return .T.
EndIf

FT_FUse(cArquivo) // Abre o arquivo
FT_FGOTO(nPos)    // Posiciona no inicio do arquivo

n:=0
While !FT_FEof() .AND. !EMPTY(FT_FReadln())
	n++
	FT_FSkip() // Proxima linha
Enddo
PROCREGUA(n)
FT_FUse() // Fecha o arquivo

FT_FUse(cArquivo) // Abre o arquivo
FT_FGOTO(nPos)    // Posiciona no inicio do arquivo
While !FT_FEof() .AND. !EMPTY(FT_FReadln())
   	aLinha := StrTokArr( FT_FReadln(), ";")
   	If aLinha[1] == "%"
	    If (nPos:=Ascan(aInfos,{ |x| x[1] == aLinha[3]}) ) == 0
			aAdd(aInfos, {STRZERO(VAL(aLinha[9]),8)/*Filial+Matricula*/, VAL(aLinha[6])* nPorc / 100/*VALORES*/  })	
		EndIf 
	EndIf    
    INCPROC("Aguarde...")
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo

SRA->(DbSetOrder(1))//RA_FILIAL+RA_MAT
//SRA->(DbSetOrder(5))//RA_FILIAL+RA_CIC
For i:=1 to Len(aInfos)
	If aInfos[i][2] <> 0
		//If SRA->(DbSeek(xFilial("SRA")+ PadL(aInfos[i][1],RETSX3("RA_CIC","TAM"), "0") ))//RA_FILIAL+RA_CIC
		If SRA->(DbSeek(aInfos[i][1]))                                                 
			While SRA->(!EOF()) .and. SRA->RA_FILIAL+SRA->RA_MAT == aInfos[i][1]
			//While SRA->(!EOF()) .and. SRA->RA_CIC == PadL(aInfos[i][1],RETSX3("RA_CIC", "TAM"), "0")
				If EMPTY(SRA->RA_DEMISSA)
					lGrava := SRC->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVerba))
					SRC->(RecLock("SRC",!lGrava))
					SRC->RC_FILIAL	:= SRA->RA_FILIAL
					SRC->RC_MAT		:= SRA->RA_MAT
					SRC->RC_PD		:= cVerba
					SRC->RC_TIPO1	:= "V"
					SRC->RC_VALOR	:= aInfos[i][2]
					SRC->RC_DATA	:= Date()
					SRC->RC_CC		:= SRA->RA_CC
					SRC->RC_TIPO2	:= "I"
					SRC->(MsUnlock())
				EndIf
				SRA->(DbSkip())
			EndDo
		EndIf
	EndIf
Next i

MsgInfo("Arquivo Processado com sucesso!")

Return .T.

*------------------------------------*
Static Function RETSX3(cCampo, cFuncao)
*------------------------------------*
Local aOrd := SaveOrd({"SX3"})
Local xRet

SX3->(DBSETORDER(2))
If SX3->(DBSEEK(cCampo))   
	Do Case
		Case cFuncao == "TAM"
			xRet := SX3->X3_TAMANHO
		Case cFuncao == "DEC"		
			xRet := SX3->X3_DECIMAL
		Case cFuncao == "TIP"      
			xRet := SX3->X3_TIPO
		Case cFuncao == "PIC" 
			xRet := SX3->X3_PICTURE
		Case cFuncao == "TIT"
			xRet := SX3->X3_TITULO
	EndCase
EndIf
RestOrd(aOrd)
Return xRet    

/*
Funcao      : GetArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function GetArq()
*---------------------------*
Local cTitle:= "Selecione o diretório"
Local cFile := "Arquivos| *.csv|"
Local nDefaultMask := 0
Local cDefaultDir  := cArq
Local nOptions:= GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

cArq := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)+Space(200)

Return .T.

/*
Funcao      : GetBenef
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca os beneficios que estão habilitados para a empresa e carrega em um array.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function GetBenef()        
*---------------------------*
Local aRet := {}

Z64->(DbSetOrder(1))//Z64_Filial+Z64_tabela+Z64_chave+Z64_descri 
If Z64->(DbSeek(xFilial("Z64")+"VV "+"BENEFICIO "))
	While Z64->(!EOF()) .and. Z64->Z64_TABELA == "VV " .And. Z64->Z64_CHAVE == "BENEFICIO "
		If aScan(aRet, {|x| x[1] == Z64->Z64_DESCRI }) == 0
			aAdd(aRet,{Z64->Z64_DESCRI, Z64->Z64_CONT1})
		EndIf
		Z64->(DbSkip())
	EndDo     

EndIf

Return aRet