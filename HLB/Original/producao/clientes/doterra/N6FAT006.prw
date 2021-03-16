#Include "Protheus.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³N6FAT006  º Autor ³Marcus Amorim       º Data ³  03/08/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Endereços de entrega                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFAT                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//-----------------------------------------------------------------------------------------  
*----------------------*
User Function N6FAT006()
*----------------------*
Local aACampos  	:= {"NomeDest","Endere","Bairro","Cep","CodMun","Complemento"} //Variável contendo o campo editável no Grid
Local aBotoes		:= {}         //Variável onde serEincluido o botão para a legenda
Private oLista                    //Declarando o objeto do browser
Private oDlg
Private aCabecalho  := {}         //Variavel que montarEo aHeader do grid
Private aColsEx 	:= {}         //Variável que receberEos dados
Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
Private oAzul  		:= LoadBitmap( GetResources(), "BR_AZUL")
Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
Private oAmarelo	:= LoadBitmap( GetResources(), "BR_AMARELO")

DEFINE MSDIALOG oDlg TITLE "HLB BRASIL - doTerra - Endereços de Entrega" FROM 000, 000  TO 300, 700  PIXEL
	//chamar a função que cria a estrutura do aHeader
	CriaCabec()
	
	//Monta o browser
	oLista := MsNewGetDados():New(073,098,435,795,GD_INSERT+GD_UPDATE,"AllwaysTrue","AllwaysTrue","AllwaysTrue",aACampos,1,999,"AllwaysTrue","","AllwaysTrue",oDlg,aCabecalho,aColsEx)
	
	//Carregar os itens que irão compor o conteudo do grid
	Carregar()
	
	//Alinho o grid para ocupar todo o meu formulário
	oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//Ao abrir a janela o cursor estEposicionado no objeto
	oLista:oBrowse:SetFocus()
 
	//Para tratamento de edição de linha de acordo com o Status
	oLista:SetEditLine(.F.)
	oLista:LCANEDITLINE:=.F.
	oLista:OBROWSE:BLDBLCLICK := {|| IIF(oLista:ACOLS[oLista:OBROWSE:NAT][1] == oVerde,oLista:Editcell(),NIL)}
	oLista:BFIELDOK := {|| IIF(oLista:ACOLS[oLista:OBROWSE:NAT][1] == oVerde,.T., (MsgInfo("Edição não permitida para o Status atual."),.F.))}

	//Variavel para a chamado do F3 de codigos de municipios
	AjustaSXB()
	IF TYPE("M->A1_EST") <> "C"
   		M->A1_EST := SA1->A1_EST
	Endif

	//Crio o menu que irEaparece no botão Ações relacionadas
	aadd(aBotoes,{"NG_ICO_LEGENDA", {||Legenda()},"Legenda","Legenda"})
	
	EnchoiceBar(oDlg, {|| U_GRVDADO(oLista:aCols),oDlg:End() }, {|| oDlg:End() },,aBotoes)
ACTIVATE MSDIALOG oDlg CENTERED

Return

//-----------------------------------------------------------------------------------------  
*-------------------------*
Static Function CriaCabec()
*-------------------------*
    Aadd(aCabecalho, {"",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "oVerde",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//
    Aadd(aCabecalho, {"Cod.Cliente",;	//X3Titulo()
                  "CodigoCli",; //X3_CAMPO
                  "",;		    //X3_PICTURE
                  6,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "SA1",; 		//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "SA1->A1_COD",; //X3_RELACAO
                  "",;          //X3_WHEN
                  ""})			//
    Aadd(aCabecalho, {"Loja",;      //X3Titulo()
                  "Loja",;      //X3_CAMPO
                  "",;	    	//X3_PICTURE
                  2,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "SA1->A1_LOJA",;//X3_RELACAO
                  ""})          //X3_WHEN
    Aadd(aCabecalho, {"Cod. End.",; //X3Titulo()
                  "CodEnd",;    //X3_CAMPO
                  "",;		    //X3_PICTURE
                  6,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "U_CODEND()",;  //X3_RELACAO
                  ""})          //X3_WHEN
    Aadd(aCabecalho, {"Nome Dest.",;	//X3Titulo()
                  "NomeDest",;  //X3_CAMPO
                  "@!",;		//X3_PICTURE
                  40,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;		    //X3_F3
                  "R",;		 	//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})	        //X3_WHEN
    Aadd(aCabecalho, {"Endereço",;	//X3Titulo()
                  "Endere",; 	//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  80,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
    Aadd(aCabecalho, {"Bairro",;	//X3Titulo()
                  "Bairro",;  	//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  40,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
    Aadd(aCabecalho, {"Cep",;	//X3Titulo()
                  "Cep",;  	//X3_CAMPO
                  "@R 99999-999",;		//X3_PICTURE
                  08,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
    Aadd(aCabecalho, {"Cod.Mun.",;	//X3Titulo()
                  "CodMun",;  	//X3_CAMPO
                  "",;	    	//X3_PICTURE
                  05,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "ZX4CC2",;	//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN     
    Aadd(aCabecalho, {"Municipio",;	//X3Titulo()
                  "Municipio",;  	//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  60,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
    Aadd(aCabecalho, {"Complemento",;	//X3Titulo()
                  "Complemento",;  	//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  50,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
Return

//-----------------------------------------------------------------------------------------  
*------------------------*
Static Function Carregar()
*------------------------*
Local cQuery    := ""
   
cQuery := "SELECT COUNT(SC5.C5_CLIENTE) AS SC5,ZX4.ZX4_CODCLI,ZX4.ZX4_LOJA,ZX4.ZX4_CODEND,ZX4.ZX4_NOME,ZX4.ZX4_END,ZX4.ZX4_BAIRRO,ZX4.ZX4_CEP,ZX4.ZX4_CODMUN,ZX4.ZX4_MUN,ZX4.ZX4_COMPLE
cQuery += " FROM "+RETSQLNAME("ZX4")+" ZX4
cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SC5")+" SC5 on SC5.D_E_L_E_T_<>'*' AND SC5.C5_NOTA<>'' AND SC5.C5_CLIENTE=ZX4.ZX4_CODCLI AND SC5.C5_LOJACLI=ZX4.ZX4_LOJA AND SC5.C5_P_ENDEN=ZX4.ZX4_CODEND
cQuery += " WHERE ZX4_CODCLI = '"+SA1->A1_COD+"'
cQuery += " 	AND ZX4_LOJA = '"+SA1->A1_LOJA+"'
cQuery += " GROUP BY ZX4.ZX4_CODCLI,ZX4.ZX4_LOJA,ZX4.ZX4_CODEND,ZX4.ZX4_NOME,ZX4.ZX4_END,ZX4.ZX4_BAIRRO,ZX4.ZX4_CEP,ZX4.ZX4_CODMUN,ZX4.ZX4_MUN,ZX4.ZX4_COMPLE

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf
TCQUERY cQuery NEW ALIAS "TMP"

While !TMP->(EOF())		
	aAdd(aColsEx,{IIF(TMP->SC5==0,oVerde,oVermelho),TMP->ZX4_CODCLI,TMP->ZX4_LOJA,TMP->ZX4_CODEND,TMP->ZX4_NOME,TMP->ZX4_END,TMP->ZX4_BAIRRO,TMP->ZX4_CEP,TMP->ZX4_CODMUN,ZX4->ZX4_MUN,TMP->ZX4_COMPLE,.F.})
	TMP->(dbSkip())
EndDo	

//Setar array do aCols do Objeto.
oLista:SetArray(aColsEx,.T.)

//Atualizo as informações no grid
oLista:Refresh()

TMP->(dbCloseArea())
Return

//-----------------------------------------------------------------------------------------  
*-----------------------*
Static function Legenda()
*-----------------------*
Local aLegenda := {}
AADD(aLegenda,{"BR_VERDE"    	,"   Endereço pode ser alterado (Sem faturamento)" })
AADD(aLegenda,{"BR_VERMELHO" 	,"   Endereço não pode ser alterado (Possui faturamento)" })

BrwLegenda("Legenda", "Legenda", aLegenda)
Return Nil  

//-----------------------------------------------------------------------------------------  
*--------------------*
User Function CODEND()
*--------------------*
Local cQuery  := ""
Local cCodEnd := ""

cQuery  := " SELECT ISNULL(MAX(ZX4_CODEND),0) CODIGO FROM "+RetSqlName("ZX4")+" WHERE ZX4_FILIAL = '"+xFilial("ZX4")+"' "

If Select("CODEND") > 0
	CODEND->(dbCloseArea())
EndIf

TCQUERY cQuery NEW ALIAS "CODEND"

cCodEnd := SOMA1(CODEND->CODIGO)

CODEND->(dbCloseArea())

Return(cCodEnd)

//-----------------------------------------------------------------------------------------  
*--------------------------*
User Function GRVDADO(aCols)
*--------------------------*
Local nX     := 0
Local aDados := {}
Local lLock := .T.

dbSelectArea("ZX4")
ZX4->(dbSetOrder(1))

aDados := aClone(aCols)
For nX := 1 To Len(aDados)
	lLock := !ZX4->(dbSeek(xFilial("ZX4")+aDados[nX,2]+aDados[nX,3]+aDados[nX,4])) //ZX4_FILIAL+ZX4_CODCLI+ZX4_LOJA+ZX4_CODEND
	ZX4->(RecLock("ZX4", lLock))
	ZX4->ZX4_CODCLI := aDados[nX,2]
	ZX4->ZX4_LOJA 	:= aDados[nX,3]
	ZX4->ZX4_CODEND := aDados[nX,4]
	ZX4->ZX4_NOME	:= aDados[nX,5]
	ZX4->ZX4_END	:= aDados[nX,6]
	ZX4->ZX4_BAIRRO	:= aDados[nX,7]
	ZX4->ZX4_CEP	:= aDados[nX,8]
	ZX4->ZX4_CODMUN	:= aDados[nX,9]	
	ZX4->ZX4_MUN	:= aDados[nX,10]
	ZX4->ZX4_COMPLE	:= aDados[nX,11]
	ZX4->(MsUnLock())
Next

Return

*-------------------------*
Static Function AjustaSXB()
*-------------------------*
Local lReclock := .t.
Local aSXB := {}

aAdd(aSXB,{"ZX4CC2","1","01","DB","Municúio Entidade"		,"Municipio Entidad"	,"Entity City"		,"CC2"})
aAdd(aSXB,{"ZX4CC2","2","01","01","Estado + Codigo IBGE"	,"Es/Pr/Reg + Codigo I"	,"State + IBGE Code",""})
aAdd(aSXB,{"ZX4CC2","2","02","02","Municúio"				,"Municipio"			,"City"				,""})
aAdd(aSXB,{"ZX4CC2","4","01","01","Estado"					,"Est/Prov/Reg"			,"State"			,"CC2_EST"})
aAdd(aSXB,{"ZX4CC2","4","01","02","Codigo IBGE"				,"Codigo IBGE"			,"IBGE Code"		,"CC2_CODMUN"})
aAdd(aSXB,{"ZX4CC2","4","01","03","Municúio"				,"Municipio"			,"City"				,"CC2_MUN"})
aAdd(aSXB,{"ZX4CC2","4","02","01","Estado"					,"Estado"				,"State"			,"CC2_EST"})
aAdd(aSXB,{"ZX4CC2","4","02","02","Codigo IBGE"				,"Codigo IBGE"			,"IBGE Code"		,"CC2_CODMUN"})
aAdd(aSXB,{"ZX4CC2","4","02","03","Municúio"				,"Municipio"			,"City"				,"CC2_MUN"})
aAdd(aSXB,{"ZX4CC2","5","01",""	 ,""						,""						,""					,"CC2->CC2_CODMUN"})
aAdd(aSXB,{"ZX4CC2","5","02",""	 ,""						,""						,""					,"CC2->CC2_MUN"})
aAdd(aSXB,{"ZX4CC2","6","01",""	 ,""						,""						,""					,"CC2->CC2_EST==M->A1_EST"})

For i:=1 to Len(aSXB)
	lReclock := !SXB->(DbSeek(aSXB[i][1]+aSXB[i][2]+aSXB[i][3]+aSXB[i][4]))
	SXB->(RecLock("SXB",lReclock))
	SXB->XB_ALIAS	:= aSXB[i][1]
	SXB->XB_TIPO	:= aSXB[i][2]
	SXB->XB_SEQ		:= aSXB[i][3]
	SXB->XB_COLUNA	:= aSXB[i][4]
	SXB->XB_DESCRI	:= aSXB[i][5]
	SXB->XB_DESCSPA	:= aSXB[i][6]
	SXB->XB_DESCENG	:= aSXB[i][7]
	SXB->XB_CONTEM	:= aSXB[i][8]
	SXB->(MsUnLock())
Next i

Return .T.