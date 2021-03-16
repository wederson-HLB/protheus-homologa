#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AKORA20  ³ Autor ³ Andre Minelli         ³ Data ³18/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a leitura do arquivo para cadastro de clientes    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AKORA20                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ KPMG - ORANGE                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AKORA20()

Local aVetor 		:= {}
Local nTotalArq 	:= 0
Local cArqTxt		:= "E:\ORANGE\SA1ORA.csv"
Local cLine			:= ""
Local cLineOk		:= ""
Local aVetorTxt		:= {}
Local aVetorSA1		:= {}
Local cEMail		:= ""
Private lMsErroAuto := .F.//

nTotalArq := FT_FUse(cArqTXT)

FT_FGOTOP()

While !FT_FEof()

	cLine     := FT_FReadLn()
	cLineOk   := StrTran(cLine,";;",";NIL;",1) //SUBSTITUIR ";;" POR ";NIL;" EM TODO O TXT
	aVetorTXT := Separa(cLineOk,";",.T.)
	
	aAdd( aVetorSA1, aVetorTXT )
	
	FT_FSkip()
	
EndDo
FT_FUse()

For nX 	:= 2 to Len(aVetorSA1)

cEMail	:= STRTRAN(aVetorSA1[nX][24],"|",";") 

If Alltrim(cEMail) == "0"
	cEMail := ""
End If

aVetor 	:= 	{{"A1_FILIAL"    ,aVetorSA1[nX][1]     				,Nil},;
			{ "A1_COD"       ,aVetorSA1[nX][2]     				,Nil},;
		  	{ "A1_LOJA"      ,aVetorSA1[nX][3]     				,Nil},;
			{ "A1_NOME"      ,aVetorSA1[nX][4]  				,Nil},;
			{ "A1_PESSOA"    ,aVetorSA1[nX][5]			   		,Nil},;
			{ "A1_NREDUZ"    ,aVetorSA1[nX][6]					,Nil},;
			{ "A1_END"       ,aVetorSA1[nX][7]			   		,Nil},;
			{ "A1_TIPO"      ,aVetorSA1[nX][8]			   		,Nil},;
			{ "A1_EST"       ,aVetorSA1[nX][9]	    			,Nil},; 
		  	{ "A1_COD_MUN"   ,StrZero(Val(aVetorSA1[nX][11]),5) ,Nil},;
			{ "A1_MUN"       ,aVetorSA1[nX][12]  				,Nil},;
			{ "A1_BAIRRO"    ,aVetorSA1[nX][13]  		   		,Nil},;
			{ "A1_CEP"       ,aVetorSA1[nX][14]			   		,Nil},;
			{ "A1_ENDCOB"    ,aVetorSA1[nX][15]			   		,Nil},;
			{ "A1_PAIS"      ,aVetorSA1[nX][16]		   			,Nil},;
			{ "A1_CODPAIS"   ,aVetorSA1[nX][17]		   			,Nil},;
			{ "A1_CGC"       ,aVetorSA1[nX][18]	   	  			,Nil},;
			{ "A1_INSCR"     ,aVetorSA1[nX][19]	      			,Nil},; 
			{ "A1_BAIRROC"   ,aVetorSA1[nX][20]   	  		  	,Nil},;
			{ "A1_CEPC"      ,aVetorSA1[nX][21]	 	  			,Nil},;
			{ "A1_MUNC"      ,aVetorSA1[nX][22]	 				,Nil},;
			{ "A1_ESTC"      ,aVetorSA1[nX][23]	  				,Nil},;
			{ "A1_EMAIL"     ,cEMail         	   		 		,Nil},; 
			{ "A1_TPASS"     ,aVetorSA1[nX][25]	    			,Nil},; 
		  	{ "A1_TPUTI"     ,aVetorSA1[nX][26]    				,Nil},;
			{ "A1_GRPTEN"    ,aVetorSA1[nX][27]   		 		,Nil},;
			{ "A1_CODORA"    ,aVetorSA1[nX][28]   		 		,Nil}}
    
    SA1->(DbSetOrder(1))
    If SA1->(DbSeek(xFilial("SA1") + aVetorSA1[nX][2] + aVetorSA1[nX][3]))
    	MSExecAuto({|x,y| Mata030(x,y)},aVetor,4) //3- Inclusão, 4- Alteracao, 5- Exclusão
    Else
		MSExecAuto({|x,y| Mata030(x,y)},aVetor,3) //3- Inclusão, 4- Alteracao, 5- Exclusão
	End If
	
	If lMsErroAuto	
		MostraErro()
		lMsErroAuto	 := .F.
	End If
	
Next nX

Alert("Processo Finalizado")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AKORA30  ³ Autor ³ Andre Minelli         ³ Data ³18/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza somente codigo BEP do cadastro de clientes        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AKORA30                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ KPMG - ORANGE                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function AKORA30

Local aVetor 		:= {}
Local nTotalArq 	:= 0
Local cArqTxt		:= "E:\ORANGE\CODORA.csv"
Local cLine			:= ""
Local cLineOk		:= ""
Local aVetorTxt		:= {}
Local aVetorSA1		:= {}
Local cEMail		:= ""
Private lMsErroAuto := .F.//

nTotalArq := FT_FUse(cArqTXT)

FT_FGOTOP()

While !FT_FEof()

	cLine     := FT_FReadLn()
	cLineOk   := StrTran(cLine,";;",";NIL;",1) //SUBSTITUIR ";;" POR ";NIL;" EM TODO O TXT
	aVetorTXT := Separa(cLineOk,";",.T.)
	
	aAdd( aVetorSA1, aVetorTXT )
	
	FT_FSkip()
	
EndDo
FT_FUse()

For nX 	:= 2 to Len(aVetorSA1)

cEMail := Replace(aVetorSA1[nX][7],"|",";")

aVetor 	:= 	{{"A1_FILIAL"    ,aVetorSA1[nX][1]     				,Nil},;
			{ "A1_COD"       ,aVetorSA1[nX][2]     				,Nil},;
		  	{ "A1_LOJA"      ,aVetorSA1[nX][3]     				,Nil},;
		  	{ "A1_TPASS"     ,aVetorSA1[nX][4]    				,Nil},;
		  	{ "A1_TPUTI"     ,aVetorSA1[nX][5]    				,Nil},;
		  	{ "A1_GRPTEN"    ,aVetorSA1[nX][6]    				,Nil},;
		  	{ "A1_EMAIL"     ,cEMail		    				,Nil},;
			{ "A1_CODORA"    ,aVetorSA1[nX][8]   		 		,Nil}}
    
    SA1->(DbSetOrder(1))
    If SA1->(DbSeek(xFilial("SA1") + aVetorSA1[nX][2] + aVetorSA1[nX][3]))
    	MSExecAuto({|x,y| Mata030(x,y)},aVetor,4) //3- Inclusão, 4- Alteracao, 5- Exclusão
	End If
	
	If lMsErroAuto	
		MostraErro()
		lMsErroAuto	 := .F.
	End If
	
Next nX

Alert("Processo Finalizado")

Return