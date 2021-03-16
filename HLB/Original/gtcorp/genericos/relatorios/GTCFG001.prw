#Include "Totvs.ch"
#Include "rwmake.ch"
/*
http://tdn.totvs.com/kbm#14499
http://tdn.totvs.com/pages/viewpage.action?pageId=6814847
*/

/*
Funcao      : GTCFG001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio de Usuarios e Grupos do ambiente logado.
Autor       : Jean Victor Rocha.
Data/Hora   : 20/01/2012
*/
*--------------------*
User Function GTCFG001()
*--------------------*
Private cAlias    := "Work"
Private cIndex    := ""
Private cNome     := ""         
Private aUsuario  := ""


Private aGrupos   := ""

aCampos:=  {{"ID"		,"C", 6	,0},; //ID
			{"NOME" 	,"C", 15,0},; //Nome
			{"NOMEC" 	,"C", 30,0},; //Nome
			{"RAMAL" 	,"C", 4	,0},; //Ramal
			{"USER_BL"	,"C", 1	,0},; //Usuário bloqueado
			{"DATAINC"	,"D", 8 ,0},;// Data de inclusão no sistema
			{"DATAALT"	,"D", 8 ,0},;//Data da última alteração
			{"MAIL" 	,"C", 130,0},; //E-Mail
			{"DEPART"	,"C", 30,0},; //Departamento
			{"IDSUP" 	,"C", 6	,0},; //ID do superior
			{"ACSIM" 	,"C", 4	,0},; //Número de acessos simultâneos
			{"CARGO" 	,"C", 30,0},; //Cargo
			{"PCFGGRP" 	,"C", 3 ,0},; //Priorizar configuração do grupo
			{"MENUATF"	,"C", 30,0},; //MENU Ativo Fixo
			{"MENUCOM"	,"C", 30,0},; //MENU compras
			{"MENUCON"	,"C", 30,0},; //MENU Contabilidade Gerencial
			{"MENUEIC"	,"C", 30,0},; //MENU EIC
			{"MENUEST"	,"C", 30,0},; //MENU Estoque e Custo
			{"MENUFAT"	,"C", 30,0},; //MENU Faturamento
			{"MENUFIN"	,"C", 30,0},; //MENU Financeiro
			{"MENUGCT"	,"C", 30,0},; //MENU Gestão de Contratos
			{"MENUGPE"	,"C", 30,0},; //MENU Gestão de Pessoal
			{"MENUFIS"	,"C", 30,0},; //MENULivros Fiscais
			{"GRUPOS" 	,"C", 300,0}; //Grupos
}
            
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
               
cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAlias,.F.,.F.)

DbSelectArea(cAlias)
cIndex:=CriaTrab(Nil,.F.)
IndRegua(cAlias,cIndex,"ID+NOME",,,"Selecionando Registro...")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

//--------------------------------------------------------------------------

Private cAliasG    := "WorkG"
Private cIndexG    := ""
Private cNomeG     := ""   
 
aCamposG:=  {{"ID"		,"C", 6	,0},; //ID
			{"NOME" 	,"C", 15,0},; //Nome
			{"DTVALID" 	,"D", 08,0},; //Nome
			{"MENUATF"	,"C", 30,0},; //MENU Ativo Fixo
			{"MENUCOM"	,"C", 30,0},; //MENU compras
			{"MENUCON"	,"C", 30,0},; //MENU Contabilidade Gerencial
			{"MENUEIC"	,"C", 30,0},; //MENU EIC
			{"MENUEST"	,"C", 30,0},; //MENU Estoque e Custo
			{"MENUFAT"	,"C", 30,0},; //MENU Faturamento
			{"MENUFIN"	,"C", 30,0},; //MENU Financeiro
			{"MENUGCT"	,"C", 30,0},; //MENU Gestão de Contratos
			{"MENUGPE"	,"C", 30,0},; //MENU Gestão de Pessoal
			{"MENUFIS"	,"C", 30,0};  //MENU Livros Fiscais
}
            
If Select(cAliasG) > 0
	(cAliasG)->(DbCloseArea())
EndIf
               
cNomeG := CriaTrab(aCamposG,.t.)
dbUseArea(.T.,,cNomeG,cAliasG,.F.,.F.)

DbSelectArea(cAliasG)
cIndexG:=CriaTrab(Nil,.F.)
IndRegua(cAliasG,cIndexG,"ID+NOME",,,"Selecionando Registro...")
DbSetIndex(cIndexG+OrdBagExt())
DbSetOrder(1) 

aUsuario  := ALLUSERS(.F.)

aGrupos   := ALLGROUPS()
Carrega(aUsuario, aGrupos)

Excel(cNome , cAlias , cIndex)

Excel(cNomeG, cAliasG, cIndexG)

Return .t.

*----------------------------------------*
Static Function Carrega(aUsuario, aGrupos)
*----------------------------------------*
Local i, j
Local aMenusGrp := {}

For i:= 1 to Len(aUsuario)
	(cAlias)->(DbAppend())
	(cAlias)->ID		:= aUsuario[i][1][1]
	(cAlias)->NOME		:= aUsuario[i][1][2]
	(cAlias)->NOMEC		:= aUsuario[i][1][4]
	(cAlias)->RAMAL		:= aUsuario[i][1][20]
	(cAlias)->USER_BL	:= If(aUsuario[i][1][17],"S","N")
	(cAlias)->DATAINC   := IF(!EMPTY(aUsuario[i][1][24]),aUsuario[i][1][24],CTOD(""))
	(cAlias)->DATAALT	:= IF(!EMPTY(aUsuario[i][1][16]),aUsuario[i][1][16],CTOD(""))
	(cAlias)->MAIL		:= aUsuario[i][1][14]
	(cAlias)->DEPART	:= aUsuario[i][1][12]
	(cAlias)->CARGO		:= aUsuario[i][1][13]
	(cAlias)->PCFGGRP	:= IF(aUsuario[i][2][11],"SIM","NAO")
	(cAlias)->IDSUP		:= aUsuario[i][1][11]
	(cAlias)->ACSIM		:= STRZERO(aUsuario[i][1][15], 4)
	
	If ValType(aUsuario[i][3]) == "A"
		For j := 1 to Len(aUsuario[i][3])
			Do Case
				Case Left(aUsuario[i][3][j],2) == "01"
					(cAlias)->MENUATF	:= SUBSTR(aUsuario[i][3][j],4,Len(aUsuario[i][3][j]))//01
				Case Left(aUsuario[i][3][j],2) == "02"
					(cAlias)->MENUCOM	:= SUBSTR(aUsuario[i][3][j],4,Len(aUsuario[i][3][j]))//02
				Case Left(aUsuario[i][3][j],2) == "03"
					(cAlias)->MENUCON	:= SUBSTR(aUsuario[i][3][j],4,Len(aUsuario[i][3][j]))//03
				Case Left(aUsuario[i][3][j],2) == "17"
					(cAlias)->MENUEIC	:= SUBSTR(aUsuario[i][3][j],4,Len(aUsuario[i][3][j]))//17
				Case Left(aUsuario[i][3][j],2) == "04"
					(cAlias)->MENUEST	:= SUBSTR(aUsuario[i][3][j],4,Len(aUsuario[i][3][j]))//04
				Case Left(aUsuario[i][3][j],2) == "05"
					(cAlias)->MENUFAT 		:= SUBSTR(aUsuario[i][3][j],4,Len(aUsuario[i][3][j]))//05
				Case Left(aUsuario[i][3][j],2) == "06"
					(cAlias)->MENUFIN	:= SUBSTR(aUsuario[i][3][j],4,Len(aUsuario[i][3][j]))//06
				Case Left(aUsuario[i][3][j],2) == "69"
					(cAlias)->MENUGCT	:= SUBSTR(aUsuario[i][3][j],4,Len(aUsuario[i][3][j]))//69
				Case Left(aUsuario[i][3][j],2) == "07"
					(cAlias)->MENUGPE	:= SUBSTR(aUsuario[i][3][j],4,Len(aUsuario[i][3][j]))//07
				Case Left(aUsuario[i][3][j],2) == "09"
					(cAlias)->MENUFIS	:= SUBSTR(aUsuario[i][3][j],4,Len(aUsuario[i][3][j]))//09
			EndCase
	    Next j
	EndIf
	If ValType(aUsuario[i][1][10]) == "A"
		(cAlias)->GRUPOS := ""
		For j:=1 to Len(aUsuario[i][1][10])
			(cAlias)->GRUPOS	:= AllTrim((cAlias)->GRUPOS) + aUsuario[i][1][10][j] +"\"
        Next j
	EndIf
	(cAlias)->(MsUnlock())
Next i

For i:= 1 to Len(aGrupos)  
	aParamGrp := FWGrpParam(aGrupos[i][1][1])//Retorna parametros do grupo.
	aMenusGrp := FWGrpMenu(aGrupos[i][1][1])//Retorna os menus do grupo identificado pelo ID do grupo.

	(cAliasG)->(DbAppend())
	(cAliasG)->ID		:= aGrupos[i][1][1]
	(cAliasG)->NOME		:= aGrupos[i][1][2]
	(cAliasG)->DTVALID	:= aParamGrp[1][4]
	If ValType(aMenusGrp) == "A"
		For j := 1 to Len(aMenusGrp)
			Do Case
				Case Left(aMenusGrp[j],2) == "01"
					(cAliasG)->MENUATF	:= SUBSTR(aMenusGrp[j],4,Len(aMenusGrp[j]))//01
				Case Left(aMenusGrp[j],2) == "02"
					(cAliasG)->MENUCOM	:= SUBSTR(aMenusGrp[j],4,Len(aMenusGrp[j]))//02
				Case Left(aMenusGrp[j],2) == "03"
					(cAliasG)->MENUCON	:= SUBSTR(aMenusGrp[j],4,Len(aMenusGrp[j]))//03
				Case Left(aMenusGrp[j],2) == "17"
					(cAliasG)->MENUEIC	:= SUBSTR(aMenusGrp[j],4,Len(aMenusGrp[j]))//17
				Case Left(aMenusGrp[j],2) == "04"
					(cAliasG)->MENUEST	:= SUBSTR(aMenusGrp[j],4,Len(aMenusGrp[j]))//04
				Case Left(aMenusGrp[j],2) == "05"
					(cAliasG)->MENUFAT	:= SUBSTR(aMenusGrp[j],4,Len(aMenusGrp[j]))//05
				Case Left(aMenusGrp[j],2) == "06"
					(cAliasG)->MENUFIN	:= SUBSTR(aMenusGrp[j],4,Len(aMenusGrp[j]))//06
				Case Left(aMenusGrp[j],2) == "69"
					(cAliasG)->MENUGCT	:= SUBSTR(aMenusGrp[j],4,Len(aMenusGrp[j]))//69
				Case Left(aMenusGrp[j],2) == "07"
					(cAliasG)->MENUGPE	:= SUBSTR(aMenusGrp[j],4,Len(aMenusGrp[j]))//07
				Case Left(aMenusGrp[j],2) == "09"
					(cAliasG)->MENUFIS	:= SUBSTR(aMenusGrp[j],4,Len(aMenusGrp[j]))//09
			EndCase
	    Next j
	EndIf
	(cAliasG)->(MsUnlock())
Next i

Return .T.
    
*------------------------------------------*
Static Function Excel(cNome, cAlias, cIndex)
*------------------------------------------*
DbSelectArea(cAlias)                   
DbCloseArea()

cArqOrig  := "\SYSTEM\"+cNome+".DBF"
cPath     := AllTrim(GetTempPath())                                                   
CpyS2T(cArqOrig, cPath, .T.)
If ApOleClient("MsExcel")
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath+cNome+".DBF" )  
	oExcelApp:SetVisible(.T.)   
Else 
	Alert("Excel não instalado") 
EndIf

Erase &cNome+".DBF"

Return .T.