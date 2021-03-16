#INCLUDE "FIVEWIN.CH"
#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"  
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

//Definição de estrutura utilizada no fonte na tabela generica de beneficios.
/*
Z64_FILIAL 	Z64_TABELA 	Z64_CHAVE	Z64_DESCRI 		Z64_CONT1  		Z64_CONT2 		Z64_CONT3  		Z64_CONT4 		Z64_CONT5
*** F3 de fornecedores de beneficios.
			COD			VB			VB Servicos
			COD			VV			Visa Vale
*** Beneficios da Visa vale
			FORN.		'BENEFICIO'	CODIGO		DESCR.TIPO

*/

/*
Funcao      : GTGEN004
Parametros  : 
Retorno     : 
Objetivos   : Rotina principal para integração de Beneficios.
Autor       : Jean Victor Rocha
Data/Hora   : 27/09/2012
TDN         : 
*/
*----------------------*
User Function GTGEN004()
*----------------------*

//Chama tela principal.
ManuBenef()


Return .T. 

/*
Funcao      : ManuBenef
Parametros  : 
Retorno     : 
Objetivos   : Manutenção de vinculo de Funcionario com Beneficio/Fornecedor
Autor       : Jean Victor Rocha
Data/Hora   : 
TDN         : 
*/
*-------------------------*
Static Function ManuBenef()
*-------------------------*
LOCAL cFiltraSRA
LOCAL aIndexSRA	:= {}
Private bFiltraBrw := {|| Nil}
PRIVATE aRotina		:= MenuDef()
Private CCADASTRO	:= OemToAnsi("Manutenção de Funcionarios X Beneficios/Forn.")

If !ChkVazio("SRA")
	Alert("Não foi encontrado funcionarios para manutenção.")
	Return
Endif
	
//cFiltraRh := CHKRH("GPEA130","SRA","1") //Manutenção de Vale-Transporte Padrão
cFiltraRh := ""
bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
Eval(bFiltraBrw) 
	
dbSelectArea("SRA")
mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

Return .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-----------------------*
Static Function MenuDef()
*-----------------------*
Local aRotAdic := {}
Local aRotina :=  { { "Pesquisar" ,"AxPesqui"	, 0 , 1 },;
                    { "Manutenção","U_FUNCXBEN"	, 0 , 2 },;
                    { "Legenda"	  , "GpLegend"  , 0 , 6, NIL, .F.}}

Return aRotina    


/*
Funcao     : FUNCXBEN()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Manutenção de beneficios por funcionario.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-----------------------*
User Function FUNCXBEN()
*-----------------------*
Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
Private aCols := {}
Private aHeader := {}

Aadd(aHeader,{"Forn.Benef"	, "CFBENEF"	, "@!"	   		,03, 0, "", "", "C", "BENEFF"	, "" } )
Aadd(aHeader,{"Nome Forn."	, "NFBENEF"	, "@!"	   		,20, 0, "", "", "C", ""			, "" } )
Aadd(aHeader,{"Cod.Benef."	, "CBENEF"	, "@!"			,05, 0, "", "", "C", "BENEFB"	, "" } )
Aadd(aHeader,{"Desc.Benef"	, "DBENEF"	, "@!"			,35, 0, "", "", "C", ""			, "" } )
Aadd(aHeader,{"Qtde.Benef"	, "QBENEF"	, "@E 99"  		,02, 0, "", "", "N", ""			, "" } )
Aadd(aHeader,{"Valor B."	, "VBENEF"	, "@E 999.99"	,06, 0, "", "", "N", ""			, "" } )
Aadd(aHeader,{"RECNO"  		, "RECTAB"	, ""			,15, 0, "", "", "N", ""			, "" } )

aAlter := {"CFBENEF","CBENEF","QBENEF","VBENEF"}

BuscaDados()


SetPrvt("oDlg1","oGrp1","oGrp2","oGrp3","oBrw1","oSay1","oSay2","oSay3")

oDlg1	:= MSDialog():New( 213,264,509,1108,"Manutenção de Funcionario X Beneficios.",,,.F.,,,,,,.T.,,,.T. )

oGrp1	:= TGroup():New( 004,004,024,096,"Matricula:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1	:= TSay():New( 014,014,{|| SRA->RA_MAT}		   		,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)

oGrp2	:= TGroup():New( 004,100,024,316,"Nome:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay2	:= TSay():New( 014,110,{|| SRA->RA_NOME}			,oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)

oGrp3	:= TGroup():New( 004,320,024,412,"Admissão:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay3	:= TSay():New( 014,330,{|| DTOC(SRA->RA_ADMISSAO)}	,oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)

oBrw1	:= MsNewGetDados():New(028,004,124,412,nOpc,'U_GEN004LOK()','AllwaysTrue()','',aAlter,0,99,'U_GEN004VLD()','','AllwaysTrue()',oDlg1,aHeader,aCols )

bOk			:= {|| IF(GRVGEN004(),oDlg1:End(),) }
bCancel		:= {|| oDlg1:End()} 
aButtons	:= {}

oDlg1:bInit := {|| EnchoiceBar(oDlg1, bOk,bCancel,,aButtons)}
oDlg1:lCentered := .T.
oDlg1:Activate(,,,.T.)

Return

/*
Funcao      : GEN004LOK
Parametros  : 
Retorno     : 
Objetivos   : validar Linha, se todos os campos estão informados.
Autor       : Jean Victor Rocha
Data/Hora   : 
TDN         : 
*/
*-------------------------------*
User Function GEN004LOK()
*-------------------------------*
Local lRet := .T.
Local i

nPos := oBrw1:NAT

If !aCols[nPos][Len(aCols[nPos])] .and. (EMPTY(aCols[nPos][1]) .or. EMPTY(aCols[nPos][3]))
	Alert("Campo(s) obrigatorio(s) em branco!")	
	lRet := .F.
/*ElseIf (aCols[nPos][5] == 0 .or. aCols[nPos][6] == 0) .and. ;
		!MsgYesNo("Existem valores não informados, deseja continuar?")
	lRet := .F.*/
EndIf



Return lRet


/*
Funcao      : GEN004VLD
Parametros  : 
Retorno     : 
Objetivos   : validar campo do getdados
Autor       : Jean Victor Rocha
Data/Hora   : 
TDN         : 
*/
*-------------------------------*
User Function GEN004VLD()
*-------------------------------*
Local lRet := .T.
Local i

Do case
	Case __READVAR == "M->CFBENEF"
		Z64->(DbSetOrder(2))//Z64_FILIAL+Z64_TABELA+Z64_CHAVE+Z64_CONT1
		If Z64->(DbSeek("  "+"COD"+M->CFBENEF))
			aCols[oBrw1:NAT][aScan(aHeader,{|x| x[2] == "NFBENEF"})] := Z64->Z64_DESCRI
		Else
			M->CFBENEF := SPACE(aHeader[aScan(aHeader,{|x| x[2] == "CFBENEF"})][4])
			lRet := .F.
		EndIf

	Case __READVAR == "M->CBENEF"
		Z64->(DbSetOrder(1))//Z64_FILIAL+Z64_TABELA+Z64_CHAVE+Z64_DESCRI
		If Z64->(DbSeek("  "+aCols[oBrw1:NAT][aScan(aHeader,{|x| x[2] == "CFBENEF"})]+"BENEFICIO "+M->CBENEF))
			aCols[oBrw1:NAT][aScan(aHeader,{|x| x[2] == "DBENEF"})] := Z64->Z64_CONT1
		Else
			M->CBENEF := SPACE(aHeader[aScan(aHeader,{|x| x[2] == "CBENEF"})][4])
			aCols[oBrw1:NAT][aScan(aHeader,{|x| x[2] == "DBENEF"})] := SPACE(aHeader[aScan(aHeader,{|x| x[2] == "DBENEF"})][4])
			lRet := .F.
		EndIf
/*		If lRet
			nCont := 0
        	For i:=1 to len(aCols)
        		If	i <> oBrw1:NAT .and. ;
        			aCols[i][aScan(aHeader,{|x| x[2] == "CFBENEF"})] == aCols[oBrw1:NAT][aScan(aHeader,{|x| x[2] == "CFBENEF"})] .and.;
					ALLTRIM(aCols[i][aScan(aHeader,{|x| x[2] == "CBENEF"})])  == ALLTRIM(M->CBENEF) .and.;
					!aCols[i][LEN(aCols[i])]
        			nCont ++
        		EndIf
        	Next i
        	If nCont <> 0
                Alert("Item ja informado para funcionario!")
				lRet := .F.        	
        	EndIf
		EndIf
  */				
EndCase

Return lRet


/*
Funcao     : BuscaDados()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Manutenção de beneficios por funcionario.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*--------------------------*
Static Function BuscaDados()
*--------------------------*

Z71->(DbSetOrder(2))
If Z71->(DbSeek(xFilial("Z71")+SRA->RA_MAT))
	While Z71->(!EOF()) .and. Z71->Z71_FILIAL == xFilial("Z71") .and. Z71->Z71_MAT == SRA->RA_MAT
		aAdd(aCols,{Space(aHeader[1][4]),;//"Forn.Benef"
					Space(aHeader[1][4]),;//"Nome Forn."
					Space(aHeader[2][4]),;//"Cod.Benef."
					Space(aHeader[3][4]),;//"Desc.Benef"
					0,;//"Qtde.Benef"
					0,;//"Valor B."
					0,;//"RECNO"
					})		//DELET
	          
		aCols[LEN(aCols),Len(aHeader)+1] := .F.
		
		aCols[Len(aCols)][1] := Z71->Z71_FORN
		Z64->(DbSetOrder(2))//Z64_FILIAL+Z64_TABELA+Z64_CHAVE
		If Z64->(DbSeek("  "+"COD"+Z71->Z71_FORN))
			aCols[Len(aCols)][2] := Z64->Z64_DESCRI
		EndIf
		aCols[Len(aCols)][3] := Z71->Z71_COD
		aCols[Len(aCols)][4] := Z71->Z71_DESCR
		aCols[Len(aCols)][5] := Z71->Z71_QTDE
		aCols[Len(aCols)][6] := Z71->Z71_VALOR
		aCols[Len(aCols)][7] := Z71->(RECNO())
		
		Z71->(DbSkip())
	EndDo

Else
	aAdd(aCols,{Space(aHeader[1][4]),;//"Forn.Benef"
				Space(aHeader[2][4]),;//"Nome FOrn."
				Space(aHeader[3][4]),;//"Cod.Benef."
				Space(aHeader[4][4]),;//"Desc.Benef"
				0,;//"Qtde.Benef"
				0,;//"Valor B."
				0,;//"RECNO"
				})		//DELET
          
	aCols[LEN(aCols),Len(aHeader)+1] := .F.
EndIf
	
Return .T.

/*
Funcao      : GRVGEN004
Parametros  : 
Retorno     : 
Objetivos   : Gravação dos dados.
Autor       : Jean Victor Rocha
Data/Hora   : 21/01/2013
TDN         : 
*/
*--------------------------*
Static Function GRVGEN004()
*--------------------------*
Local i
Local lRec := .T.

aCols := oBrw1:aCols

For i:=1 to len(aCols)
	If !aCols[i][Len(aCols[i])] .and. (EMPTY(aCols[i][1]) .or. EMPTY(aCols[i][3]))
		Alert("Campo(s) obrigatorio(s) em branco!")	
		Return .F.
	EndIf
Next i	

Z71->(DbSetOrder(2))//Z71_FILIAL+Z71_MAT+Z71_FORN+Z71_COD

For i:=1 to Len(aCols)
	If aCols[i][Len(aCols[i])]
		If Z71->(DbSeek(xFilial("Z71")+SRA->RA_MAT+aCols[i][1]+aCols[i][3]))
			If aCols[i][Len(aCols[i])-1] <> 0
				Z71->(DbGoTo(aCols[i][Len(aCols[i])-1]))
				lRec := .F.
			Else
				lRec := .T.
			EndIf
			
			//Z71->(RecLock("Z71",.F.))
			Z71->(RecLock("Z71",lRec))
			Z71->(DbDelete())
		EndIf
	Else    
		//lRec := !Z71->(DbSeek(xFilial("Z71")+SRA->RA_MAT+aCols[i][1]+aCols[i][3]))
		If aCols[i][Len(aCols[i])-1] <> 0
			Z71->(DbGoTo(aCols[i][Len(aCols[i])-1]))
			lRec := .F.
		Else
			lRec := .T.
		EndIf

		Z71->(RecLock("Z71",lRec))
		Z71->Z71_FILIAL := xFilial("Z71")
		Z71->Z71_FORN	:= aCols[i][1]
		Z71->Z71_COD	:= aCols[i][3]
		Z71->Z71_DESCR	:= aCols[i][4]
		Z71->Z71_QTDE	:= aCols[i][5]
		Z71->Z71_VALOR	:= aCols[i][6]
		Z71->Z71_MAT	:= SRA->RA_MAT
	EndIf
	Z71->(MsUnlock())
Next i

Return .T.

/*
Funcao     : SXBGEN004()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Filtro para consulta padrão SXB. XB_ALIAS = 'BENEFB'
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*--------------------------*
User Function SXBGEN004()
*--------------------------*
Local lRet	:= .F.
Local cCond := "" 
Local cFil	:= "999"

If !EMPTY(oBrw1:aCols[oBrw1:NAT][aScan(oBrw1:AHEADER, {|x| ALLTRIM(x[2]) == "CFBENEF"})])
	cFil := oBrw1:aCols[oBrw1:NAT][aScan(oBrw1:AHEADER, {|x| ALLTRIM(x[2]) == "CFBENEF"})]
EndIf
                
cCond := &("{|| Z64->Z64_TABELA == '"+cFil+"' .and. Z64->Z64_CHAVE == 'BENEFICIO ' }")
lRet := Eval( cCond )


Return (if(  Valtype(lRet) =="U" ,.T. , lRet )) 