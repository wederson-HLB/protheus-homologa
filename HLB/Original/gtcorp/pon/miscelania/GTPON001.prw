#INCLUDE "FIVEWIN.CH"
#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"  
#include "Fileio.ch"
/*
Funcao      : GTPON001
Parametros  : 
Retorno     : 
Objetivos   : Integração de lançamentos de banco de horas.
Autor       : Jean Victor Rocha
Data/Hora   : 11/01/2013
TDN         : 
*/          
*----------------------*
User Function GTPON001()
*----------------------*
Private cGet1 	:= ""  //Arquivo
Private aDados 	:= {}
Private aAlter	:= {}
Private lOk 	:= .F.
Private aRel	:= {}

//Tela de parametros 
If !TelaParam()
	Return .T.
EndIf
                    
//Carregar dados.  
If !LoadFile()
	Return .T.
EndIf

//Tela com os dados carregados.
TelaManut()

//Gera relatorio dos itens gravados.
RelInt()

Return( Nil )


/*
Funcao      : TelaParam
Parametros  : 
Retorno     : 
Objetivos   : Tela de parametros para integração.
Autor       : Jean Victor Rocha
Data/Hora   : 11/01/2013
TDN         : 
*/
*----------------------------*
Static Function TelaParam()
*----------------------------*
Local lRet  := .F.

cGet1 := "c:\Banco.csv"+Space(150)

SetPrvt("oDlg1","oSay1","oSay2","oGet1","oSBtn1")

oDlg1      := MSDialog():New( 183,522,291,850,"Grant Thornton Brasil.",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Integração de lançamentos de Banco de Horas."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,116,008)
oSay2      := TSay():New( 020,004,{||"Informe o arquivo:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
oGet1	   := TGet():New( 032,004,{|u| IF(PCount()>0,cGet1:=u,cGet1)},oDlg1,096,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oSBtn1     := SButton():New( 032,128,1,{|| (lret := .T. , oDlg1:END())},oDlg1,,"", )

oDlg1:Activate(,,,.T.)

Return lRet
 
/*
Funcao      : LoadFile
Parametros  : 
Retorno     : 
Objetivos   : Carrega arquivo em array
Autor       : Jean Victor Rocha
Data/Hora   : 11/01/2013
TDN         : 
*/
*----------------------------*
Static Function LoadFile()
*----------------------------*
Local nPos := 0

cGet1 := ALLTRIM(cGet1)

If !File(cGet1)
	MsgInfo("Arquivo não encontrado!")
	Return .F.
EndIf

FT_FUse(ALLTRIM(cGet1))	// Abre o arquivo
FT_FGOTOP()			 	// Posiciona no inicio do arquivo

FT_FSkip(1)//Pula o cabeçalho.

While !FT_FEof()

   	cLinha := FT_FReadln()        // Le a linha
 	aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 

	aAdd(aDados, aLinha)
	FT_FSkip() // Proxima linha
Enddo
FT_FUse() // Fecha o arquivo                     

Return .T.


/*
Funcao      : TelaManut
Parametros  : 
Retorno     : 
Objetivos   : Tela de manutenção dos dados a serem integrados.
Autor       : Jean Victor Rocha
Data/Hora   : 11/01/2013
TDN         : 
*/
*----------------------------*
Static Function TelaManut()
*----------------------------*
Local nOpc := GD_DELETE+GD_UPDATE+GD_INSERT
Local bOK     := {|| IF(ValidOk(),(GrvDados(),oDlgManu:End()),) }
Local bCancel := {|| lRet := .F.,oDlgManu:End()}
Local aButtons := {}

Private aCols := {}
Private aHeader := {}
Private noBrw1  := 0

MontaHeader()
MontaCols()


SetPrvt("oDlgManu","oBrw1")

DEFINE MSDIALOG oDlgManu TITLE "Manutenção de integração de banco de horas - Grant Thornton Brasil." FROM 100,150 TO 560,1350 PIXEL

oBrw1      := MsNewGetDados():New(004,004,210,600,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,9999,'U_ValCpo()','','AllwaysTrue()',oDlgManu,aHeader,aCols )

ACTIVATE MSDIALOG oDlgManu ON INIT (EnchoiceBar(oDlgManu,bOk,bCancel,,aButtons)) CENTERED



Return

/*
Funcao      : ValidOk
Parametros  : 
Retorno     : 
Objetivos   : validar o click em ok.
Autor       : Jean Victor Rocha
Data/Hora   : 14/01/2013
TDN         : 
*/
*-----------------------*
Static Function ValidOk()
*-----------------------*
Local lRet := .F.

If !lok
	lRet := MsgYesNo("Existe(m) item(ns) com erro(s) que não será(ão) gravados, deseja continuar assim mesmo?")
Else
	lRet := .T.
EndIf

Return lRet

/*
Funcao      : MontaHeader
Parametros  : 
Retorno     : 
Objetivos   : Carrega o array aHeader com informações do cabeçalho.
Autor       : Jean Victor Rocha
Data/Hora   : 14/01/2013
TDN         : 
*/
*---------------------------*
Static Function MontaHeader()
*---------------------------*

Aadd(aHeader,{"Filial"		, "FILIAL"	, "@!",02, 0, "", "", "C", "", "" } )
Aadd(aHeader,{"Matricula"	, "MAT"		, "@!",06, 0, "", "", "C", "SRA", "" } )
Aadd(aHeader,{"Nome"		, "NOME"	, "@!",25, 0, "", "", "C", "", "" } )
Aadd(aHeader,{"Tipo Lanc."	, "TPLANC"	, "@!",03, 0, "", "", "C", "", "" } )
Aadd(aHeader,{"Desc.Lanc."	, "DSCLANC"	, "@!",20, 0, "", "", "C", "", "" } )
Aadd(aHeader,{"Data Lanc."	, "DTLANC"	, ""  ,08, 0, "", "", "D", "", "" } )
Aadd(aHeader,{"Horas"		, "HORAS"	, "@E 999.99", 5, 2, "", "", "N", "", "" } )
Aadd(aHeader,{"Centro Custo", "CC"		, "@!",04, 0, "", "", "C", "", "" } )
Aadd(aHeader,{"Status"		, "STATUS"	, "@!",60, 0, "", "", "C", "", "" } )

aAlter := {"FILIAL","MAT","TPLANC","HORAS","CC","DTLANC"}

Return

/*
Funcao      : MontaCols
Parametros  : 
Retorno     : 
Objetivos   : Carrega o acols com informações do arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 14/01/2013
TDN         : 
*/
*-------------------------*
Static Function MontaCols()
*-------------------------*
For i := 1 To Len(aDados)
	aAdd(aCols,{aDados[i][1],;//Filial
				aDados[i][2],;//MAtricula
				BuscaSRA(aDados[i][1],aDados[i][2],"NOME"),;//Nome
				aDados[i][3],;//Tipo de Lancamento
				BuscaSP9(aDados[i][3]),;//Descrição do lancamento
		   		ctoD(aDados[i][4]),;//Data Lançamento
				VAL(aDados[i][5]),;//Horas
				BuscaSRA(aDados[i][1],aDados[i][2],"CC"),;//Centro de custo
				"",;//Status para integração
				})		//DELET
	aCols[len(aCols)][len(aCols[len(aCols)])] := .F.
Next  

ValidDados(.T.)


Return

/*
Funcao      : BuscaSRA
Parametros  : 
Retorno     : 
Objetivos   : Buscar dados na SRA baseado em filial+Mat.
Autor       : Jean Victor Rocha
Data/Hora   : 14/01/2013
TDN         : 
*/
*-------------------------*
Static Function BuscaSRA(cFilialSRA,cMAtSRA,cTipo)
*-------------------------*                             
Local cRet := ""

SRA->(DbSetOrder(1))
If SRA->(DbSeek(cFilialSRA+cMAtSRA))
	If cTipo == "NOME"
		cRet := SRA->RA_NOME
	ElseIf cTipo == "CC"
		cRet := SRA->RA_CC
	EndIf
EndIf

Return cRet
           
/*
Funcao      : BuscaSP9
Parametros  : 
Retorno     : 
Objetivos   : Buscar dados na SP9, eventos.
Autor       : Jean Victor Rocha
Data/Hora   : 14/01/2013
TDN         : 
*/
*-------------------------*
Static Function BuscaSP9(cEvento)
*-------------------------*                             
Local cRet := ""

SP9->(DbSetOrder(1))
If SP9->(DbSeek(xFilial("SP9")+cEvento))
	cRet := SP9->P9_DESC
EndIf

Return cRet
           
/*
Funcao      : BuscaBanco
Parametros  : 
Retorno     : 
Objetivos   : Buscar na tabela de lançamentos de banco de horas se ja nao existe um registro igual.
Autor       : Jean Victor Rocha
Data/Hora   : 14/01/2013
TDN         : 
*/
*-------------------------*
Static Function BuscaBanco(cChave)
*-------------------------*                             
Local cRet := ""

SPI->(DbSetOrder(1))
lRet := SPI->(DbSeek(cChave))

Return lRet

/*
Funcao      : ValidDados
Parametros  : 
Retorno     : 
Objetivos   : Validar os dados carregados/informados.
Autor       : Jean Victor Rocha
Data/Hora   : 14/01/2013
TDN         : 
*/
*-------------------------------*
Static Function ValidDados(lTudo)
*-------------------------------*
Local cMsg := ""

lOk := .T.

For i:=1 to Len(aCols)
	If !lTudo
    	i:= oBrw1:NAT
	EndIf
	cMsg := ""
	If EMPTY(aCols[i][3])
	   	cMsg += "Funcionario nao encontrado;"
	EndIf
	If EMPTY(aCols[i][4])
	   	cMsg += "Evento em branco;"
	EndIf
	If aCols[i][7] <= 0
	   	cMsg += "Valor de horas invalida;"
	EndIf
	If VAL(RIGHT(TRANSFORM(aCols[i][7], "999.99"),2)) >=60
	   	cMsg += "Maximo de minutos invalido, maximo 59.;"
	EndIf
	If EMPTY(aCols[i][8])
	   	cMsg += "Centro de custo em branco;"
	EndIf
	If EMPTY(aCols[i][6])
	   	cMsg += "Data em branco;"
	ElseIf	aCols[i][6] <= STOD("20120101")
		cMsg += "Data invalida;"
	EndIf

    aCols[i][LEN(aCols[i])] := BuscaBanco(aCols[i][1]+aCols[i][2]+aCols[i][4]+DTOS(aCols[i][6]))
	
	aCols[i][9] := cMsg

	If !lTudo
		i:= Len(aCols ) +1
	EndIf
Next i

For i:=1 to Len(acols)
	If !EMPTY(cMsg) .and. !aCols[i][LEN(aCols[i])]
		lOk := .F.
	EndIf
Next i

Return cMsg

/*
Funcao      : ValCpo
Parametros  : 
Retorno     : 
Objetivos   : validar campo do getdados
Autor       : Jean Victor Rocha
Data/Hora   : 14/01/2013
TDN         : 
*/
*-------------------------------*
User Function ValCpo()
*-------------------------------*
Local i

Do case
	Case __READVAR == "M->FILIAL"
		aCols[oBrw1:NAT][1] := M->FILIAL
	Case __READVAR == "M->MAT"
		aCols[oBrw1:NAT][2] := M->MAT
	Case __READVAR == "M->HORAS"
		aCols[oBrw1:NAT][7] := M->HORAS
	Case __READVAR == "M->TPLANC"
		aCols[oBrw1:NAT][4] := M->TPLANC
	Case __READVAR == "M->CC"
		aCols[oBrw1:NAT][8] := M->CC
	Case __READVAR == "M->DTLANC"
		aCols[oBrw1:NAT][6] := M->DTLANC		
EndCase

aCols[oBrw1:NAT][3] := BuscaSRA(aCols[oBrw1:NAT][1],aCols[oBrw1:NAT][2],"NOME")
aCols[oBrw1:NAT][5] := BuscaSP9(aCols[oBrw1:NAT][4])

ValidDados(.F.)

Return .T.

/*
Funcao      : GrvDados
Parametros  : 
Retorno     : 
Objetivos   : Gravar dados informados.
Autor       : Jean Victor Rocha
Data/Hora   : 14/01/2013
TDN         : 
*/
*-------------------------------*
Static Function GrvDados()
*-------------------------------*
Local i
Local nPerc := 0 
Local nVarVal := 0
Local cTipo := "" 
Local cVar := ""

aCols := oBrw1:acols

SPI->(DbSetOrder(1))

For i:=1 to LEN(aCols)
	If 	!aCols[i][LEN(aCols[i])] .and. EMPTY(aCols[i][9])//Executa apenas os que nao estao deletados e que nao possuem erros
		If SPI->(DbSeek(aCols[i][1]+aCols[i][2]+aCols[i][4]+DTOS(aCols[i][6])))
			While SPI->(PI_FILIAL+PI_MAT+PI_PD+Dtos(PI_DATA)) == aCols[i][1]+aCols[i][2]+aCols[i][4]+DTOS(aCols[i][6])
				If EMPTY(SPI->PI_DTBAIX)
					SPI->(RecLock("SPI",.F.))
					SPI->(DbDelete())
					SPI->(MsUnlock())
				EndIf
				SPI->(DbSkip())
			EndDo
		EndIf

		nPerc	:= PosSP9( aCols[i][4], xFilial("SPI"), "P9_BHPERC"	,1 ,.F. )
		cTipo	:= PosSP9( aCols[i][4], xFilial("SPI"), "P9_TIPOCOD"	,1 ,.F. )
		cVar	 := aCols[i][7]
		
		nVarVal := fConvHr(Round(fConvHr(cVar,"D")*(nPerc/100),2),"H")
        
		SPI->(RecLock("SPI",.T.))
		SPI->PI_FILIAL 	:= aCols[i][1]
		SPI->PI_MAT		:= aCols[i][2]
		SPI->PI_DATA	:= aCols[i][6]
		SPI->PI_PD		:= aCols[i][4]
		SPI->PI_CC 		:= aCols[i][8]
		SPI->PI_QUANT 	:= aCols[i][7]
		SPI->PI_QUANTV	:= nVarVal
		SPI->PI_FLAG	:= "I"
		SPI->(MsUnLock())
		  
		aAdd(aRel, aCols[i])
	EndIf
Next i

Return .T.

/*
Funcao      : GrvDados
Parametros  : 
Retorno     : 
Objetivos   : Gerar Relatorio dos Itens Gravados.
Autor       : Jean Victor Rocha
Data/Hora   : 17/01/2013
TDN         : 
*/
*----------------------*
Static Function RelInt()
*----------------------*
Private cArqMV := "Int_BH_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","")

//Gera o arquivo XLS.
GeraXls()


Return .T.

*-------------------------*
Static Function GeraXLS()
*-------------------------*
Local nHdl
Local cHtml := ""
Private cDest :=  GetTempPath()
 
cArq := ALLTRIM(cArqMV)+".xls"
	
IF FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF

nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
nBytesSalvo := FWRITE(nHdl, cHtml ) // Gravação do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado	

cHtml := Montaxls()

If nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	cExt := '.xls'
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
endif
          
//FErase(cDest+cArq)

Return .T. 

*------------------------------*
Static Function GrvXLS(cMsg)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

*-------------------------*
Static Function Montaxls()
*-------------------------*
Local cMsg := ""
Local i,j  
Local cCont := ""

cMsg += "<html>"
cMsg += "	<body>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='0' bordercolor='#ffffff' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
cMsg += "		<td>Data Execução:</td><td></td><td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"+Dtoc(DATE())+"</td>"
cMsg += "		<tr><td></td><td></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b>    Relatorio de Integração</b></font></td>"
cMsg += "			<td  width='100' height='41' bgcolor='#ffffff' border='0' bordercolor='#ffffff' align = 'Left'><font face='times' color='black' size='4'><b>    Banco de Horas.</b></font></td>"
cMsg += "		</tr>"
cMsg += "		<tr></tr>"
cMsg += "		 <tr>"
cMsg += "	</table>"
cMsg += "	<table height='361' width='844' bgColor='#ffffff' border='2' bordercolor='#000000' style='border-collapse: collapse' cellpadding='0' cellspacing='0'>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Filial</b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Matricula</b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Nome</b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Tipo.Lanc.</b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Desc.Lanc.</b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Data Lanc.</b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Horas</b></font>"
	cMsg += "		</td>"
	cMsg += "		<td width='400' height='41' bgcolor='#ffffff' border='2' bordercolor='#000000' align = 'Left'>"
	cMsg += "		<font face='times' color='black' size='3'> <b> Centro Custo</b></font>"
	cMsg += "		</td>"
cMsg += "	</tr>"
cMsg := GrvXLS(cMsg)

ProcRegua(LEN(aRel))//apenas carrega variavel com o numero de registros.

nIncTempo := 0

For i:=1 to Len(aRel)
	cMsg += "		 <tr>"
	For j:=1 to Len(aRel[i]) -1//tira a posição do array de D_E_L_E_T_
		aRel[i][j]
		If j == 1 
			cCont := '=TEXTO('+ALLTRIM(STR(VAL(aRel[i][j])))+';"00")'
		ElseIf j == 2
			cCont := '=TEXTO('+ALLTRIM(STR(VAL(aRel[i][j])))+';"000000")'
		ElseIf j == 4
			cCont := '=TEXTO('+ALLTRIM(STR(VAL(aRel[i][j])))+';"000")'
		ElseIf j == 6
			cCont := DtoC(aRel[i][j])
		ElseIf j == 7
			cCont := TRANSFORM(aRel[i][j], "@R 999.99")
		Else
			cCont := aRel[i][j]
		EndIf
		cMsg += "			 <td width='400' height='41' bgcolor='#ffffff' border='1' bordercolor='#000000' align = 'Left'>"
		cMsg += "				<font face='times' color='black' size='3'>"+cCont
		cMsg += "			</td>"
	Next j
	cMsg += "		 </tr>"

	If nIncTempo >= 30//Aumentar o desempenha executando a cada X vezes...(nao aumentar o valor..pois causa lag na gracação)
		cMsg := GrvXLS(cMsg)
		nIncTempo := 0
	EndIf

	IncProc("Reg:"+ALLTRIM(STR(i))+"/"+ALLTRIM(STR(LEN(aRel)))+" - Gerando arquivo Excel...")	
	nIncTempo++
Next i

cMsg += "	</table>"
cMsg += "	<BR?>"
cMsg += "</html> "
cMsg := GrvXLS(cMsg)

Return cMsg