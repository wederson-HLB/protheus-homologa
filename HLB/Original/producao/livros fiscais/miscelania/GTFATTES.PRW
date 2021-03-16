#Include "rwmake.ch"   
#Include "topconn.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTFATTES  ºAutor  Tiago Luiz Mendonça  º Data ³  11/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca de numeração de TES                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HLB BRASIL                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍuÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*                                                          
Funcao      : GTFATTES
Objetivos   : Função para buscar o próximo número de TES 
Autor       : Tiago Luiz Mendonça
Obs.        :   
Data        : 11/11/2010
*/

*---------------------------*
User Function GTFATTES() 
	*---------------------------*    

	Local cTipoTes   
	Local oDlg,oMain,oCombo
	Local lOK:=.F.   
	Local aItens:={"1-Entrada","2-Saida"}  
	Local a:="1",b:="A",c:="1" 

	Private cDB := Alltrim(GetEnvServer())
	Private cItem

	If Select("WORK") > 0
		Work->(DbCloseArea())
	EndIf 

	DEFINE MSDIALOG oDlg TITLE "Proxima numeração de TES" From 1,7 To 10,35 OF oMain     

	@ 015,008 SAY "Selecione o tipo ? "  
	@ 015,060 COMBOBOX cItem ITEMS aItens SIZE 40,20 
	@ 030,025 BMPBUTTON TYPE 1 ACTION(lOk:=.T.,oDlg:End()) 
	@ 030,055 BMPBUTTON TYPE 2 ACTION(lOk:=.F.,oDlg:End()) 

	ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())     

	If !lOk
		Return .F.    
	EndIf         

	If Alltrim(cItem)=="2-Saida"
		a:="5" 
	EndIf

	MontaQry()    

	Work->(DbGoTop())

	IncProc()

	While Work->(!Eof())  

		If cItem == "1-Entrada"

			If c==":"  //Proximo caracter ASC.  
				c:="A" 
				Work->(DbSkip()) 
				Loop
			EndIf    

			If c=="Z" 
				b:=Alltrim(chr(asc(b)+1))
				c:="0" 
				Work->(DbSkip()) 
				Loop  
			EndIf   

			If b=="Z"
				a:=Alltrim(Str(Val(a)+1))
				b:="A"
				c:="0"
				Work->(DbSkip())  
				Loop
			EndIf   

			If Work->F4_CODIGO == a+b+c

				c:=Alltrim(chr(asc(c)+1))       

				Work->(DbSkip())  
				Loop

			Else         

				If Substr(RetSqlName("SF4"),4,2) $ ("YY")   

					If Check(a+b+c)  
						MsgInfo("O código "+a+b+c+" pode ser usado","HLB BRASIL") 
						lOk:=.F.
						Exit
					Else  

						c:=Alltrim(chr(asc(c)+1))       

						If c==":"  //Proximo caracter ASC.  
							c:="A"     
						EndIf    

						If c=="Z" 
							b:=Alltrim(chr(asc(b)+1))
							c:="0" 
						EndIf   

						If b=="Z"
							a:=Alltrim(Str(Val(a)+1))
							b:="A"
							c:="0"
						EndIf   

						Loop 

					EndIf

				Else  
					MsgStop("EstEempresa não estEvinculada a SF4(YY) padrão da empresa modelo, entrar em contato com TI.","HLB BRASIL") 
					lOk:=.F.
					Exit         
				EndIf      
			EndIf
		Else  

			If c==":"  //Proximo caracter ASC.  
				c:="A" 
				Work->(DbSkip()) 
				Loop
			EndIf    

			If c=="Z" 
				b:=Alltrim(chr(asc(b)+1))
				c:="0" 
				Work->(DbSkip()) 
				Loop  
			EndIf   

			If b=="Z"
				a:=Alltrim(Str(Val(a)+1))
				b:="A"
				c:="0"
				Work->(DbSkip())  
				Loop
			EndIf 


			If Work->F4_CODIGO == a+b+c

				c:=Alltrim(chr(asc(c)+1))       

				Work->(DbSkip()) 
				Loop

			Else 

				If Substr(RetSqlName("SF4"),4,2) $ ("YY")   

					If Check(a+b+c)  
						MsgInfo("O código "+a+b+c+" pode ser usado","HLB BRASIL") 
						lOk:=.F.
						Exit
					Else   

						c:=Alltrim(chr(asc(c)+1))       

						If c==":"  //Proximo caracter ASC.  
							c:="A"     
						EndIf    

						If c=="Z" 
							b:=Alltrim(chr(asc(b)+1))
							c:="0" 
						EndIf   

						If b=="Z"
							a:=Alltrim(Str(Val(a)+1))
							b:="A"
							c:="0"
						EndIf   

						Loop 

					EndIf
				Else  
					MsgStop("EstEempresa não estEvinculada a SF4(YY) padrão da empresa modelo, entrar em contato com TI.","HLB BRASIL") 
					lOk:=.F.
					Exit         
				EndIf  

			EndIf

		EndIf

	EndDo

	If lOk
		MsgInfo("O código "+a+b+c+" pode ser usado","HLB BRASIL")
	EndIf

	Return



	*----------------------------*
Static Function MontaQry()
	*----------------------------*

	aStruSF4:= SF4->(DbStruct())      

	cQuery:= "SELECT F4_CODIGO "
	cQuery+=" FROM "+RetSqlName("SF4")+" 

	If Alltrim(cItem) == "1-Entrada"
		cQuery+=" WHERE  F4_CODIGO > '1A0' AND F4_CODIGO < '5A1' AND D_E_L_E_T_ <> '*' "
	Else
		cQuery+=" WHERE  F4_CODIGO > '5A0' AND D_E_L_E_T_ <> '*' "
	EndIf

	cQuery+=" ORDER BY F4_CODIGO"    

	cQuery	:=	ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'WORK',.F.,.T.)

	For nI := 1 To Len(aStruSF4)
		If aStruSF4[nI][2] <> "C" .and.  FieldPos(aStruSF4[nI][1]) > 0
			TcSetField("WORK",aStruSF4[nI][1],aStruSF4[nI][2],aStruSF4[nI][3],aStruSF4[nI][4])
		EndIf
	Next nI


	Return

	*-------------------------*
Static Function Check(cTes)
	*-------------------------* 
	/*Local cTes
	Local lRet  
	Local cQuery1
	Local cQuery2

	If Select("SQL1") > 0
	SQL1->(dbCloseArea())
	EndIf 

	If Select("SQL2") > 0
	SQL2->(dbCloseArea())
	EndIf           

	If UPPER(cDB) $ "AMB01/ENV01/ENV02/LOCAL1/GT01/ENV07/ENV08"

	cQuery1 := " SELECT AMB02.F4_CODIGO AS COD FROM AMB02_P10.dbo.SF4YY0 as AMB02 where AMB02.F4_CODIGO = '"+cTes+"' and  AMB02.D_E_L_E_T_ <> '*'
	cQuery2 := " SELECT AMB03.F4_CODIGO AS COD FROM AMB03_P10.dbo.SF4YY0 as AMB03 where AMB03.F4_CODIGO = '"+cTes+"' and  AMB03.D_E_L_E_T_ <> '*'

	TCQuery cQuery1 ALIAS "SQL1" NEW 
	TCQuery cQuery2 ALIAS "SQL2" NEW     

	SQL1->(DbGoTop()) 
	SQL2->(DbGoTop())

	ElseIf UPPER(cDB)  $ "AMB02/ENV03/ENV04/LOCAL2/GT02/ENV09/ENV10"

	cQuery1 := " SELECT AMB01.F4_CODIGO AS COD FROM AMB01_P10.dbo.SF4YY0 as AMB01 where AMB01.F4_CODIGO = '"+cTes+"' and  AMB01.D_E_L_E_T_ <> '*'
	cQuery2 := " SELECT AMB03.F4_CODIGO AS COD FROM AMB03_P10.dbo.SF4YY0 as AMB03 where AMB03.F4_CODIGO = '"+cTes+"' and  AMB03.D_E_L_E_T_ <> '*'

	TCQuery cQuery1 ALIAS "SQL1" NEW 
	TCQuery cQuery2 ALIAS "SQL2" NEW     

	SQL1->(DbGoTop()) 
	SQL2->(DbGoTop())

	ElseIf UPPER(cDB) $ "AMB03/ENV05/ENV06/LOCAL3/GT03/ENV11/ENV12"  

	cQuery1 := " SELECT AMB01.F4_CODIGO AS COD FROM AMB01_P10.dbo.SF4YY0 as AMB01 where AMB01.F4_CODIGO = '"+cTes+"' and  AMB01.D_E_L_E_T_ <> '*'
	cQuery2 := " SELECT AMB02.F4_CODIGO AS COD FROM AMB02_P10.dbo.SF4YY0 as AMB02 where AMB02.F4_CODIGO = '"+cTes+"' and  AMB02.D_E_L_E_T_ <> '*'

	TCQuery cQuery1 ALIAS "SQL1" NEW 
	TCQuery cQuery2 ALIAS "SQL2" NEW     

	SQL1->(DbGoTop()) 
	SQL2->(DbGoTop())

	EndIf

	If Alltrim(SQL1->COD) == "" .And. Alltrim(SQL2->COD) == "" 
	lRet:=.T.
	Else
	lRet:=.F.
	EndIf
	*/

	//Nova versão para atender a P11.  
	Local lRet := .T.
	Local cBase := ""
	Local aBases := {}

	IF "P11_" $ Alltrim(GetEnvServer()) 
		aBases := {"P11_01","P11_02","P11_03","P11_04","P11_05","P11_06","P11_07","P11_08","P11_09","P11_10","P11_11","P11_12","P11_13","P11_14",;
		"P11_15","P11_16","P11_17","P11_18","P11_19","P11_20","P11_21","P11_22","P11_22","P11_23","P11_24","P11_25","P11_26","P11_27","P11_28"}
	ELSE
		aBases := {"P12_01","P12_02","P12_03","P12_04","P12_05","P12_06","P12_07","P12_08","P12_09","P12_10","P12_11","P12_12","P12_13","P12_14",;
		"P12_15","P12_16","P12_17","P12_18","P12_19","P12_20","P12_21","P12_22","P12_22","P12_23","P12_24","P12_25","P12_26","P12_27","P12_28"}		
	ENDIF

	For i:=1 to Len(aBases)
		If Select("SQL1") > 0
			SQL1->(dbCloseArea())          
		EndIf

		cQuery1 := "SELECT "+aBases[i]+".F4_CODIGO AS COD FROM "+aBases[i]+".dbo.SF4YY0 as "+aBases[i]+" where "+aBases[i]+".F4_CODIGO = '"+cTes+"' and  "+aBases[i]+".D_E_L_E_T_ <> '*'

		TCQuery cQuery1 ALIAS "SQL1" NEW 

		SQL1->(DbGoTop())

		If Alltrim(SQL1->COD) <> ""
			Return .F.
		EndIf
	Next i

Return lRet