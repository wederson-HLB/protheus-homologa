#Include "Protheus.ch"

/*
Funcao      : GTCORP84
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Função para escolher qual boleto deseja-se gerar Itau/Santander
Autor       : Matheus Massarotto
Data/Hora   : 12/02/2014    10:14
Revisão		: Guilherme Fernandes Pilan - GFP                   
Data/Hora   : 01/03/2017 :: 08:09
Módulo      : Genérico
*/

*------------------------------*
User Function GTCORP84(lAutom)
*------------------------------*
Local aPergs	:={}
Local cPerg     :="P_GTCORP84"
Private cTpND 	:= ""
Default lAutom := .F.

//If !cEmpAnt $ "Z4/4K/ZG/ZB"
//	Alert("Rotina não disponível para empresa!")
//	Return .F.
//EndIf

//MSM - 19/02/2016 - Tratamento para não permitir gerar boletos quando a data do sistema for diferente da data atual. Chamado: 031885
if ddatabase <> Date() 
	Alert( "A data do sistema é diferente da data atual!")
	Return .F.
endif

If !lAutom .AND. FwIsAdmin() .AND. MsgNoYes("Deseja exibir o cadastro de Contas para Boletos?" +Chr(13)+Chr(13)+;
   										  	"Sim: Exibe o cadastro de Contas para Boletos." +Chr(13)+Chr(10)+;
   										  	"Não: Exibe a rotina de geração de Boletos.","Grant Thornton")
   U_GTFIN030()
   Return .T.
EndIf

Aadd(aPergs,{"Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
//Alterado - MSM - 27/07/2012
Aadd(aPergs,{"Envia Email","","","mv_ch4","N",1,0,0,"C","","MV_PAR04","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Tipo Boleto","","","mv_ch5","N",1,0,0,"C","","MV_PAR05","Itau GT","","","","","Itau KPMG","","","","","Santander","","","","","Sofisa","","","","","","","","","","","","",""})
Aadd(aPergs,{"Pré-Visualizar Boleto","","","mv_ch6","N",1,0,0,"C","","MV_PAR06","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1(cPerg,aPergs)  

If !lAutom
	If !Pergunte (cPerg,.T.)
		Return .F.
	EndIF
ELSE // GFP - Geração automatica de Boleto atraves do GTFAT016.
	MV_PAR01 := SE1->E1_PREFIXO
	MV_PAR02 := SE1->E1_NUM
	MV_PAR03 := SE1->E1_NUM
	MV_PAR04 := 1
	MV_PAR05 := Val(Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_P_TPBOL"))
	MV_PAR06 := 2
ENDIF

If cEmpAnt $ 'Z4/ZG/ZB' //AOA - 16/08/2016 - Incluido código da empresa ZG para gerar boleto Santander
	cTpND 	:= SuperGetMv("MV_P_00013",.F.,MV_PAR01)
EndIf
If !Empty(cTpND) .AND. MV_PAR01 $ cTpND
	MsgInfo ("Este prefixo deve ser utilizado na rotina Fatura ND Itau." + Chr (13) + Chr (13) + "Por favor, informe outro prefixo.","Grant Thornton")
	Return .F.
/*ElseIf cEmpAnt == '4K' //RRP - 28/05/2014 - Inclusão da Outsourcing RJ.
	If MV_PAR05 == 1 .OR. MV_PAR05 == 2
		U_GTFIN024(.T., MV_PAR06 == 1, lAutom)//AOA - 06/02/2017 - Inclusão de rotina boleto Itau
	ElseIf MV_PAR05 == 3 
		U_4KFIN001(.T., MV_PAR06 == 1, lAutom)
	EndIf*/
Else
	If MV_PAR05 == 1 .OR. MV_PAR05 == 2 
		U_GTFIN024(.T., MV_PAR06 == 1, lAutom)//GFP - 31/01/2017 - Novo Boleto Itau
	ElseIf MV_PAR05 == 3 
		U_Z4FIN001(.T., MV_PAR06 == 1, lAutom)
	ElseIf MV_PAR05 == 4
		U_GTFIN027(.T., MV_PAR06 == 1, lAutom)//AOA - 23/12/2016 - Inclusão do fonte para boleto sofisa/santander
	EndIf
EndIf

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                    	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local cKey		:= ""
Local nJ		:= 0
Local nCondicao

cPerg := Padr(cPerg,10)

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next
Return