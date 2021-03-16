#include "apwebex.ch"
#include "totvs.ch"
#include 'tbiconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGTWF001   บAutor  ณEduardo C. Romanini บ Data ณ  04/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็๕es genericas dos portal GT.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GT                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
Fun็ใo  : WFTamPx
Objetivo: Retorna o valor em pixels, a partir do tamanho de um campo
Autor   : Eduardo C. Romanini
Data    : 04/04/2012
*/
*-------------------------*
User Function WFTamPx(nTam)
*-------------------------*
Local cPx := ""

Local nPx := 0

If nTam <= 100
	nPx := nTam
Else
	nPx := 100
EndIf

cPx := Alltrim(Str(nPx))

Return cPx

/*
Fun็ใo    : WFForm()
Objetivo  : Monta a tela de formulario.
Autor     : Eduardo C. Romanini
Data      : 09/04/2012
Parametros: cTab  : Tabela com os campos para exibi็ใo
            cOpc  : Op็ใo da opera็ใo (Inclusใo, Altera็ใo, etc...)
            cChave: Chave de busca na tabela
            aExibe: Array com os campos da tabela que devem ser exibidos(opcional)
            aNeInc: Array com os campos que nใo devem ser editaveis na inclusใo (apenas quando aExibe nใo for informado)
            aNeAlt: Array com os campos que nใo devem ser editaveis na altera็ใo(apenas quando aExibe nใo for informado)
*/
*---------------------------------------------------------*
User Function WFForm(cTab,cOpc,cChave,aExibe,aNeInc,aNeAlt)
*---------------------------------------------------------*
Local lExibe  := .F.
Local lEnable := .T. 
Local lIniPad := .F.

Local cHtml   := ""
Local cInput  := ""
Local cAux    := ""
Local cCbox   := ""
Local cId     := ""
Local cLabel  := ""

Local nI      := 0
Local nX      := 0
Local nAt     := 0
Local nPosCol := 0
Local nQtdCol := 0

Local aCpos  := {}
Local aCbox  := {}
Local aNEdit := {}

Default cChave := ""
Default aExibe := {}
Default aNeInc := {}
Default aNeAlt := {}

//Prepara o ambiente se for necessแrio
If Select("SX3") == 0
	U_WFPrepEnv()
EndIf

/*
Formato do array aExibe
[1]-Nome do campo
[2]-Conteudo padrใo
[3]-Label da Tag
[4]-Habilitado?      
[5]-Editavel?
[6]-Classe?
*/

//Se o array aExibe foi informado entใo apenas os campos informados nele serใo exibidos.
If Len(aExibe) > 0
	lExibe := .T.
	
	For nI:=1 To Len(aExibe)
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek(aExibe[nI][1]))
			Aadd(aCpos,{Alltrim(SX3->X3_CAMPO),SX3->X3_TAMANHO,Alltrim(SX3->X3_TITULO),AllTrim(SX3->X3_CBOX),AllTrim(SX3->X3_RELACAO)})	
		EndIf
	Next		

//Exibe todos os campos usados da tabela informada
Else
	SX3->(DbSetOrder(1))
	If SX3->(DbSeek(cTab))
		While SX3->(!EOF()) .and. AllTrim(SX3->X3_ARQUIVO) == Alltrim(cTab)
			//Define os campos a serem exibidos
			If X3Usado(SX3->X3_CAMPO)
				Aadd(aCpos,{Alltrim(SX3->X3_CAMPO),SX3->X3_TAMANHO,u_WFTraduzir(Alltrim(SX3->X3_TITULO)),AllTrim(SX3->X3_CBOX),AllTrim(SX3->X3_WHEN),AllTrim(SX3->X3_VISUAL),AllTrim(SX3->X3_RELACAO),""/*Classe*/})
			EndIf

			SX3->(DbSkip())
		EndDo
	EndIf
EndIf

//Define o array com os campos que nใo podem ser editados.
If !lExibe
	If cOpc == "INC"
		aNEdit := aClone(aNeInc)
	ElseIf cOpc == "ALT"
		aNEdit := aClone(aNeAlt)	
	EndIf
EndIf

//Calcula a posi็ใo dos campos na tela, de acordo com o seu tamanho.
nTotal := Len(aCpos)
For nI:=1 To nTotal
    
	//Primeiro Campo
	If nI == 1
		
		nPosCol := 1 //1ช coluna
		
        If aCpos[nI][2] <= 60
			//Verifica o tamanho do proximo registro
			If nI+1 <= nTotal
				If aCpos[nI+1][2] <= 60
					nQtdCol := 2 //2 colunas
                Else
					nQtdCol := 1 //1 coluna
				EndIf				
			Else
				nQtdCol := 1
			EndIf

		Else
			nQtdCol := 1			
		EndIf

	//Demais Campos
	ElseIf nI < nTotal	
		
        If aCpos[nI][2] <= 60
        	If nPosCol == 1 .and. nQtdCol == 2
            	nPosCol := 2
            	nQtdCol := 2

			ElseIf nPosCol == 1 .and. nQtdCol == 1
 
            	nPosCol := 1

				//Verifica o tamanho do proximo registro
				If nI+1 <= nTotal
					If aCpos[nI+1][2] <= 60
						nQtdCol := 2
            	    Else
						nQtdCol := 1                
					EndIf				
				Else
					nQtdCol := 1
				EndIf

			ElseIf nPosCol == 2 .and. nQtdCol == 2
            	nPosCol := 1

				//Verifica o tamanho do proximo registro
				If nI+1 <= nTotal
					If aCpos[nI+1][2] <= 60
						nQtdCol := 2
            	    Else
						nQtdCol := 1                
					EndIf				
				Else
					nQtdCol := 1
				EndIf
			EndIf
        Else
 		   	nPosCol := 1
         	nQtdCol := 1
        EndIf

	EndIf

	//Retorna o Id da tag
	cId := aCpos[nI][1]

	//Retona o label do campo
	If lExibe
		If !Empty(aExibe[nI][3])
			cLabel := "<div id=tit_"+aCpos[nI][1]+">"+aExibe[nI][3]+"</div>"
		Else
			cLabel := "<div id=tit_"+aCpos[nI][1]+">"+aCpos[nI][3]+"</div>"
		EndIf
	Else
		cLabel := "<div id=tit_"+aCpos[nI][1]+">"+aCpos[nI][3]+"</div>"
	EndIf

	//Retorna se estแ habilitado
	If lExibe
		If aExibe[nI][4]
			lEnable := .T.
		Else
			lEnable := .F.		
		EndIf
	Else
		//Verifica o When do campo.
		If AllTrim(aCpos[nI][5]) == ".F."
			lEnable := .F.
	    Else
			lEnable := .T.
		EndIf
	EndIf
	
	//Retorna se estแ editavel.
	If lEnable
		If lExibe		
	    	If aExibe[nI][5]
	    		lEdit := .T.	
	    	Else
	    		lEdit := .F.	
	    	EndIf
		Else
			If aScan(aNEdit,aCpos[nI][1]) > 0
				lEdit := .F.
			Else
				//Verifica se o campo ้ editavel.
				If AllTrim(aCpos[nI][6]) == "V"
					lEdit := .F.
		    	Else
					lEdit := .T.
				EndIf
			EndIf
		EndIf
	EndIf		
	
	//Verifica se possui inicializador padrใo
	If cOpc == "INC"		
		If lExibe
			If !Empty(aCpos[nI][5])
				lIniPad := .T.
			Else
				lIniPad := .F.
			EndIf
		Else
			If !Empty(aCpos[nI][7])
				lIniPad := .T.
			Else
				lIniPad := .F.
			EndIf
		EndIf
	EndIf
	
	//Gera os campos de digita็ใo.

	//Tratamento para o tipo do campo
	If Empty(aCpos[nI][4]) //Nใo possui ComboBox
		cInput := "<input 
		cInput += " id='"+cId+"'"
		cInput += " name='"+aCpos[nI][1]+"'" 
		If (nPos:=aScan(aExibe,{|x| ALLTRIM(x[1]) == ALLTRIM(aCpos[nI][1]) }) ) <> 0
			If Len(aExibe[nPos]) > 5  .And. !EMPTY(aExibe[nPos])
				cInput += " class='inputtxt "+ALLTRIM(aExibe[nPos][6])+"'"
			Else  
				cInput += " class='inputtxt'"
			EndIf
		Else 
			cInput += " class='inputtxt'"
		EndIf
		
		cInput += " size='"+U_WFTamPx(aCpos[nI][2])+"'"
		cInput += " maxlength='"+Alltrim(Str(aCpos[nI][2]))+"'"

		If "SENHA" $ AllTrim(aCpos[nI][1])
			cInput += "type='password' "

		ElseIf "BLOQUE" $ AllTrim(aCpos[nI][1])
			cInput += "type='checkbox' "	
		Else
			cInput += "type='text' "			
		EndIf            

		If cOpc <> "INC"
			//Retorna o conteudo do campo
			cInput += "value="+U_WFVlCpo(cTab,aCpos[nI][1],cChave,aExibe,cOpc)
	
			If cOpc == "VIS"
				
				If "BLOQUE" $ AllTrim(aCpos[nI][1])			
					cInput += "disabled='disabled'"
				Else
					cInput += "readonly='readonly'"
				EndIf
			Else
				
				//Desabilita o campo.
				If !lEnable
					cInput += "disabled='disabled'"
                Else
					//Bloqueia a edi็ใo do campo.
					If !lEdit
						cInput += "readonly='readonly'"
					EndIf
				EndIf
				
			EndIf
		Else
			//Inicializador padrใo  
			If lIniPad
				cInput += "value="+U_WFIniPad(aCpos[nI][1])
			ElseIf lExibe .And. !EMPTY(aExibe[nI][2]) .And. GetSx3Cache(aCpos[nI][1],"X3_CONTEXT") <> "V"
				cInput += "value='"+aExibe[nI][2]+"'"
			EndIf
			
			//Desabilita o campo.
			If !lEnable
				cInput += "disabled='disabled'"
			Else
				//Bloqueia a edi็ใo do campo.
				If !lEdit
					cInput += "readonly='readonly'"
				EndIf
			EndIf
		EndIf
				
		cInput +="/>"
	
	Else //Possui ComboBox

		//Gera Array com as op็๕es do comboBox
		aCbox := {}
		cCbox := AllTrim(aCpos[nI][4])
		nAt := At(";",cCbox)
		While nAt > 0
			cAux  := Left(cCbox,nAt-1)
			
			// Separa o sinal de igual
			nIgual := At('=', cAux)
			aAdd(aCbox,{Left(cAux,nIgual-1),Substr(cAux,nIgual+1)}) 
			
			cCbox := Substr(cCbox,nAt+1)
			nAt := At(";",cCbox)
		EndDo
		cAux  := cCbox
		
		// Separa o sinal de igual
		nIgual := At('=', cAux)
		aAdd(aCbox,{Left(cAux,nIgual-1),Substr(cAux,nIgual+1)}) 			

		
    	//Monta o objeto select em html
     	cInput := "<select"
		cInput += " id='"+cId+"'"
		cInput += " name='"+aCpos[nI][1]+"'"
		If (nPos:=aScan(aExibe,{|x| ALLTRIM(x[1]) == ALLTRIM(aCpos[nI][1]) }) ) <> 0
			If Len(aExibe[nPos]) > 5  .And. !EMPTY(aExibe[nPos])
				cInput += " class='inputselect "+ALLTRIM(aExibe[nPos][6])+"'"
			Else  
				cInput += " class='inputselect'"
			EndIf
		Else 
			cInput += " class='inputselect'"
		EndIf

        If cOpc == "VIS" .or. !lEnable .or. !lEdit
			cInput += "disabled='disabled'"
        Endif
        
     	cInput += ">"
		
		For nX:=1 To Len(aCbox)
			cInput += "<option value='"+aCbox[nX][1]+"'"
			
			If cOpc == "INC"
            	If U_WFIniPad(aCpos[nI][1]) == "'"+aCBox[nX][1]+"'"
                	cInput += " selected='selected' "
				EndIf
			Else
				If U_WFVlCpo(cTab,aCpos[nI][1],cChave,aExibe,cOpc) == "'"+aCBox[nX][1]+"'"
					cInput += " selected='selected' "
				EndIf
			EndIf			
			
			cInput +=  ">" + u_WFTraduzir(aCbox[nX][2]) + "</option>"
		Next		

		cInput +="</select>"
	EndIf

	//Verifica se o campo serแ impresso na 1 coluna
	If nPosCol == 1
		cHtml+= "<tr>"

		//Imprime o nome do campo
		cHtml += "<td width='16%'>"
		cHtml += "<div align='right'>"
		cHtml += "<span class='label'>"
		cHtml += cLabel
		cHtml += "</span>
		cHtml += "</div>
		cHtml += "</td>

		//Verifica se serแ impresso apenas 1 coluna
		If nQtdCol == 1
            
			//Imprime o conteudo do campo 
			cHtml += "<td width='*%' colspan='3'>"

			cHtml += cInput

			//Exibe asterisco se o campo for obrigat๓rio	
			If X3Obrigat(aCpos[nI][1])
				cHtml += "<span id='obg_"+aCpos[nI][1]+"' style='color:Red;'>*</span>"
			EndIf

			cHtml += "</td>
			cHtml += "</tr>"

		//Serแ impresso 2 colunas
		Else
		
			cHtml += "<td width='34%'>"

			cHtml += cInput

			//Exibe asterisco se o campo for obrigat๓rio	
			If X3Obrigat(aCpos[nI][1])
				cHtml += "<span id='obg_"+aCpos[nI][1]+"' style='color:Red;'>*</span>"
			EndIf
			
			cHtml += "</td>

		EndIf	
	
	//Campo serแ impresso na 2 coluna					
	Else
	    
		//Imprime o nome do campo
		cHtml += "<td width='16%'>"
		cHtml += "<div align='right'>"
		cHtml += "<span class='label'>"
		cHtml += cLabel
		cHtml += "</span>
		cHtml += "</div>
		cHtml += "</td>

		//Imprime o conteudo do campo
		cHtml += "<td width='34%'>"

		cHtml += cInput

		//Exibe asterisco se o campo for obrigat๓rio	
		If X3Obrigat(aCpos[nI][1])
			cHtml += "<span id='obg_"+aCpos[nI][1]+"' style='color:Red;'>*</span>"
		EndIf

		cHtml += "</td>

		cHtml += "</tr>"		
	EndIf
Next

Return cHtml

/*
Fun็ใo  : WFVlCpo()
Objetivo: Retorna o conteudo do campo
Autor   : Eduardo C. Romanini
Data    : 05/04/2012
*/
*-------------------------------------*
User Function WFVlCpo(cTab,cCpo,cChave,aCampos,cOpc)
*-------------------------------------*
Local cRet  := "" 
Local cPass := ""

If Select("SX2") == 0
	U_WFPrepEnv()
EndIf

If Empty(cTab) .or. ValType(cTab) == "U"
	Return cRet
EndIf

If Empty(cChave) .or. ValType(cChave) == "U"
	Return cRet
EndIf

If Empty(cCpo) .or. ValType(cCpo) == "U"
	Return cRet
EndIf

If "BLOQUE" $ AllTrim(cCpo)

	If (cTab)->&(cTab+"_BLOQUE") == "S"
		cRet := "'S' checked"
	Else
		cRet := "'S'"
	EndIf
Else
	(cTab)->(DbSetOrder(1))
	If (cTab)->(DbSeek(xFilial(cTab)+Alltrim(cChave)))
		SX3->(DbSetOrder(2))
		If SX3->(DbSeek(AllTrim(cCpo)))
	    	If SX3->X3_CONTEXT = "V" .and. cOpc <> "INC"
	    		If (nPos:=aScan(aCampos,{|x| ALLTRIM(x[1]) == ALLTRIM(cCpo) }) ) <> 0 .and. !EMPTY(aCampos[nPos][2])
					If Left(aCampos[nPos][2],2) == "U_"//Verifica se ้ fun็ใo
						cFuncao := ""
						cAux := aCampos[nPos][2]
						cFuncao += SUBSTR(cAux,1,AT("(",cAux))
						cAux := SUBSTR(cAux,AT("(",cAux)+1,Len(cAux))
						cAux := Left(cAux,Len(cAux)-1)
					   	nMax:=0
					   	While Len(cAux) > 0
					   		cFuncao += '"'
					   		If AT(",",cAux) == 0
						   		cFuncao += &(cAux)
						   		cAux :=  ""
						   	Else 
						   		cFuncao += &(SUBSTR(cAux,1,AT(",",cAux)-1))   
						   		cAux :=  SUBSTR(cAux,AT(",",cAux)+1,Len(cAux))
						   	EndIf
					   		cFuncao += '",'
					   	EndDo      
					   	cFuncao := IF(AT(",",cFuncao) <> 0,LEFT(cFuncao,Len(cFuncao)-1) ,cFuncao)
						cFuncao += ")"
						aArea := GetArea()
						cRet := "'"+&(cFuncao)+"'"
						RestArea(aArea)
					Else                   
						cRet := "'"+ALLTRIM(aCampos[nPos][2])+"'"
					EndIf						
				Else
					cRet := "''"
				EndIf  
				
			Else		    	
		    	//Descripita็ใo de senha
				If "SENHA" $ AllTrim(cCpo)
					cPass := AllTrim((cTab)->&(AllTrim(cCpo)))
					cPass := Substr(cPass,2,Len(cPass)-2) //Retira os delimitadores				
					cRet := "'"+Encript(cPass,0)+"'"
	
		    	ElseIf SX3->X3_TIPO == "C"
					cRet := "'"+Alltrim((cTab)->&(AllTrim(cCpo)))+"'"    	
	
		    	ElseIf SX3->X3_TIPO == "N"
					cRet := "'"+Alltrim(Str((cTab)->&(AllTrim(cCpo))))+"'"    	
	
		    	ElseIf SX3->X3_TIPO == "D"
					cRet := "'"+Alltrim(DtoC((cTab)->&(AllTrim(cCpo))))+"'"    	
	
				Else
					cRet := "'"+Alltrim((cTab)->&(AllTrim(cCpo)))+"'"    	
				EndIf
			EndIf
		EndIf		
	EndIf
EndIf

Return cRet   

/*
Fun็ใo  : WFRetBanco
Objetivo: Retorna o banco de dados da empresa logada.
Autor   : Eduardo C. Romanini
Data    : 09/05/2012
*/
*----------------------------------*
User Function WFRetBanco(cEmp,cLoja)
*----------------------------------*
Local cBanco := ""
Local cAmb   := ""
Local cIp    := ""

Local nPos := 0
Local aRet := {}

Local nCon := 0
          
If cEmp <> "GTHD"
	If Select("SX2") == 0
		U_WFPrepEnv()
	EndIf
	
	ZW1->(DbSetOrder(1))
	If ZW1->(DbSeek(xFilial("ZW1")+cEmp+cLoja))		
		//Retorna o ambiente 
		cAmb := AllTrim(ZW1->ZW1_AMB)
	EndIf

	If !EMPTY(cAmb)
		//JVR - 09/08/2016 - Alterado o tratamento de TClink para fixo, para otimizar a performance
		//JVR - 26/08/2015 - Novo tratamento baseado no GTHD para busca do Banco das empresas.	
		//aArea := GetArea()
		//aCon  := U_WFRetBanco("GTHD")
		//cBanco:= aCon[1]
		//cIp   := aCon[2]
		//nCon := TCLink(cBanco,cIp,aCon[6])
		
		If Select("QRY") <> 0
			QRY->(DbCloseArea())
		EndIf
		cQuery := " Select *
		cQuery += " from GTHD.dbo.Z04010 Z04
		cQuery += " 	Left Outer join (Select * From GTHD.dbo.Z10010 Where D_E_L_E_T_ <> '*') AS Z10 on Z04.Z04_AMB = Z10.Z10_AMB
		cQuery += " 																  				AND Z04.Z04_RELEAS = Z10.Z10_RELEAS
		cQuery += " Where Z04.D_E_L_E_T_ <> '*'
		cQuery += " 	AND Z04.Z04_CODIGO = '"+ALLTRIM(cEmp)+"'
		cQuery += " 	AND Z04.Z04_CODFIL = '"+ALLTRIM(cLoja)+"'

		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

		QRY->(DbGoTop())
		If QRY->(!BOF() .and. !EOF())	
			aAdd(aRet,ALLTRIM(QRY->Z10_BANCO))//Banco
			aAdd(aRet,ALLTRIM(QRY->Z10_IPBD))//Ip
			IF QRY->Z10_AMB == "GTCORP"
				aAdd(aRet,ALLTRIM(QRY->Z10_AMB)+"11")//Ambiente
			Else                       
				aAdd(aRet,ALLTRIM(QRY->Z10_AMB))//Ambiente
			EndIf
			aAdd(aRet,ALLTRIM(QRY->Z10_SERVID))//Servidor
			aAdd(aRet,ALLTRIM(QRY->Z10_PORTA))//Porta
			aAdd(aRet,VAL(ALLTRIM(QRY->Z10_TOPORT)))//Porta Top
		EndIf 
		QRY->(DbCloseArea())

		//TCunLink(nCon)    
		//RestArea(aArea)
	EndIf
	
Else
	aAdd(aRet,"MSSQL7/GTHD")//Banco
	aAdd(aRet,"10.0.30.5")//Ip
	aAdd(aRet,"")//Ambiente
	aAdd(aRet,"")//Servidor
	aAdd(aRet,"")//Porta
	aAdd(aRet,7894)//Top Porta
EndIf
	
Return aRet

/*
Fun็ใo  : WFIniPad
Objetivo: Retorna o inicializador padrใo do campo
Autor   : Eduardo C. Romanini
Data    : 09/05/2012
*/
*--------------------------*
User Function WFIniPad(cCpo)
*--------------------------*
Local cRet := ""

SX3->(DbSetOrder(2))
If SX3->(DbSeek(AllTrim(cCpo)))
	If !Empty(SX3->X3_RELACAO)
		cRet := "'" + &(SX3->X3_RELACAO) + "'"
	EndIf
EndIf

Return cRet

/*
Fun็ใo  : WFMenu
Objetivo: Retorna os menus disponiveis para o usuario
Autor   : Eduardo C. Romanini
Data    : 30/05/2012
*/
*--------------------------*
User Function WFMenu(cLogin)
*--------------------------*
Local aRet := {}

If Select("SX2") == 0
	U_WFPrepEnv()
EndIf

//Posiciona no usuแrio
ZW0->(DbSetOrder(1))
If ZW0->(DbSeek(xFilial("ZW0")+AllTrim(cLogin)))
	If !Empty(ZW0->ZW0_CODGRP)	

		//Verifica as rotinas diponiveis para o usuario    	
    	ZW7->(DbSetOrder(1))
    	If ZW7->(DbSeek(xFilial("ZW7")+ZW0->ZW0_CODGRP))
        	While ZW7->(!EOF()) .and. ZW7->(ZW7_FILIAL+ZW7_CODGRP) == xFilial("ZW7")+ZW0->ZW0_CODGRP
				
				//Posiciona na rotina
				ZW4->(DbSetOrder(1))
				If ZW4->(DbSeek(xFilial("ZW4")+ZW7->ZW7_CODROT))
                		
					If !Empty(ZW4->ZW4_CODSUB)

						//Posiciona no SubMenu					
						ZW5->(DbSetOrder(1))
						If ZW5->(DbSeek(xFilial("ZW5")+ZW4->ZW4_CODSUB))
							                        
                            If !Empty(ZW5->ZW5_CODMEN)

								//Posiciona no Menu
								ZW3->(DbSetOrder(1))
								If ZW3->(DbSeek(xFilial("ZW3")+ZW5->ZW5_CODMEN))
                                	
									If aScan(aRet,{|a| a[1] == ZW3->ZW3_CODIGO}) == 0
	                                	ZW3->(aAdd(aRet,{AllTrim(ZW3_CODIGO),AllTrim(ZW3_TITULO),AllTrim(ZW3_IMAGEM)}))
	        						EndIf
								
                                EndIf
								
							EndIf

						EndIf
					
					EndIf	

                EndIf
								
            	ZW7->(DbSkip())
		    EndDo
        EndIf
	EndIf
EndIf

Return aRet

/*
Fun็ใo  : WFPrepEnv
Objetivo: Prepara o ambiente do portal
Autor   : Eduardo C. Romanini
Data    : 23/08/2012
*/
*-----------------------*
User Function WFPrepEnv()
*-----------------------*

If Upper(AllTrim(GetEnvServer())) == "PORTAL"
	PREPARE ENVIRONMENT EMPRESA "02" FILIAL "01" MODULO 'FAT'
ElseIf Upper(AllTrim(GetEnvServer())) == "TESTE"
	PREPARE ENVIRONMENT EMPRESA "03" FILIAL "01" MODULO 'FAT'
EndIf

Return Nil