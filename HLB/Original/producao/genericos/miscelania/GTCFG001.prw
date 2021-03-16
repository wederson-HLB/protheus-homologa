#Include "Protheus.ch"
#Include "rwmake.ch"
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

aCampos:=  {{"ID"		,"C", 6	,0},;//ID
			{"NOME" 	,"C", 15,0},;//Nome
			{"NOMEC" 	,"C", 30,0},;//Nome
			{"RAMAL" 	,"C", 4	,0},;//Ramal
			{"USER_BL"	,"C", 1	,0},;//Usu�rio bloqueado
			{"DATAINC"	,"D", 8 ,0},;// Data de inclus�o no sistema
			{"DATAALT"	,"D", 8 ,0},;//Data da �ltima altera��o
			{"MAIL" 	,"C", 130,0},;//E-Mail
			{"DEPART"	,"C", 30,0},;//Departamento
			{"IDSUP" 	,"C", 6	,0},;//ID do superior
			{"ACSIM" 	,"C", 4	,0},;//N�mero de acessos simult�neos
			{"CARGO" 	,"C", 30,0},;//Cargo
			{"PCFGGRP" 	,"C", 3 ,0},; //Priorizar configura��o do grupo
			{"MENUATF"	,"C", 30,0},;//MENU Ativo Fixo
			{"MENUCOM"	,"C", 30,0},;//MENU compras
			{"MENUCON"	,"C", 30,0},;//MENU Contabilidade Gerencial
			{"MENUEIC"	,"C", 30,0},;//MENU EIC
			{"MENUEST"	,"C", 30,0},;//MENU Estoque e Custo
			{"MENUFAT"	,"C", 30,0},;//MENU Faturamento
			{"MENUFIN"	,"C", 30,0},;//MENU Financeiro
			{"MENUGCT"	,"C", 30,0},;//MENU Gest�o de Contratos
			{"MENUGPE"	,"C", 30,0},;//MENU Gest�o de Pessoal
			{"MENUFIS"	,"C", 30,0},;//MENULivros Fiscais
			{"GRUPOS" 	,"C", 300,0};//Grupos
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
 
aCamposG:=  {{"ID"		,"C", 6	,0},;//ID
			{"NOME" 	,"C", 15,0},;//Nome
			{"DTVALID" 	,"D", 08,0},;//Nome
			{"MENUATF"	,"C", 30,0},;//MENU Ativo Fixo
			{"MENUCOM"	,"C", 30,0},;//MENU compras
			{"MENUCON"	,"C", 30,0},;//MENU Contabilidade Gerencial
			{"MENUEIC"	,"C", 30,0},;//MENU EIC
			{"MENUEST"	,"C", 30,0},;//MENU Estoque e Custo
			{"MENUFAT"	,"C", 30,0},;//MENU Faturamento
			{"MENUFIN"	,"C", 30,0},;//MENU Financeiro
			{"MENUGCT"	,"C", 30,0},;//MENU Gest�o de Contratos
			{"MENUGPE"	,"C", 30,0},;//MENU Gest�o de Pessoal
			{"MENUFIS"	,"C", 30,0}; //MENU Livros Fiscais
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

If cVersao == '11'
	Carrega11(aUsuario, aGrupos)
Else
	Carrega10(aUsuario, aGrupos)
EndIf

Excel(cNome , cAlias , cIndex)
Excel(cNomeG, cAliasG, cIndexG)

Return .t.

*----------------------------------------*
Static Function Carrega11(aUsuario, aGrupos)
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

*----------------------------------------*
Static Function Carrega10(aUsuario, aGrupos)
*----------------------------------------*
Local i, j

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
	(cAliasG)->(DbAppend())
	(cAliasG)->ID		:= aGrupos[i][1][1]
	(cAliasG)->NOME		:= aGrupos[i][1][2]
	(cAliasG)->DTVALID	:= aGrupos[i][1][4]
	If ValType(aGrupos[i][2]) == "A"
		For j := 1 to Len(aGrupos[i][2])
			Do Case
				Case Left(aGrupos[i][2][j],2) == "01"
					(cAliasG)->MENUATF	:= SUBSTR(aGrupos[i][2][j],4,Len(aGrupos[i][2][j]))//01
				Case Left(aGrupos[i][2][j],2) == "02"
					(cAliasG)->MENUCOM	:= SUBSTR(aGrupos[i][2][j],4,Len(aGrupos[i][2][j]))//02
				Case Left(aGrupos[i][2][j],2) == "03"
					(cAliasG)->MENUCON	:= SUBSTR(aGrupos[i][2][j],4,Len(aGrupos[i][2][j]))//03
				Case Left(aGrupos[i][2][j],2) == "17"
					(cAliasG)->MENUEIC	:= SUBSTR(aGrupos[i][2][j],4,Len(aGrupos[i][2][j]))//17
				Case Left(aGrupos[i][2][j],2) == "04"
					(cAliasG)->MENUEST	:= SUBSTR(aGrupos[i][2][j],4,Len(aGrupos[i][2][j]))//04
				Case Left(aGrupos[i][2][j],2) == "05"
					(cAliasG)->MENUFAT	:= SUBSTR(aGrupos[i][2][j],4,Len(aGrupos[i][2][j]))//05
				Case Left(aGrupos[i][2][j],2) == "06"
					(cAliasG)->MENUFIN	:= SUBSTR(aGrupos[i][2][j],4,Len(aGrupos[i][2][j]))//06
				Case Left(aGrupos[i][2][j],2) == "69"
					(cAliasG)->MENUGCT	:= SUBSTR(aGrupos[i][2][j],4,Len(aGrupos[i][2][j]))//69
				Case Left(aGrupos[i][2][j],2) == "07"
					(cAliasG)->MENUGPE	:= SUBSTR(aGrupos[i][2][j],4,Len(aGrupos[i][2][j]))//07
				Case Left(aGrupos[i][2][j],2) == "09"
					(cAliasG)->MENUFIS	:= SUBSTR(aGrupos[i][2][j],4,Len(aGrupos[i][2][j]))//09
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
	Alert("Excel n�o instalado") 
EndIf

Erase &cNome+".DBF"

Return .T.

/*
http://tdn.totvs.com/kbm#14499

AllUsers
Retorna um vetor principal onde cada elemento refere-se a um usu�rio do sistema, estes elementos 
s�o compostos de um vetor multidimensional subdividindo as informa��es dos usu�rios. Sua estrutura 
� composta de:
ELEMENTO  Descri��o Tipo Qtd.
1
1 ID C 6
2 Nome C 15
3 Senha C 6
4 Nome Completo C 30
5 Vetor com n� �ltimas senhas A --
6 Data de validade D 8
7 Quantas vezes para expirar N 4
8 Autorizado a alterar a senha L 1
9 Alterar a senha no pr�ximo logon L 1
10 Vetor com os grupos A --
11 ID do superior C 6
12 Departamento C 30
13 Cargo C 30
14 E-Mail C 130
15 N�mero de acessos simult�neos N 4
16 Data da �ltima altera��o D 8
17 Usu�rio bloqueado L 1
18 N�mero de d�gitos para o ano N 1
19 Listner de liga��es L 1
20 Ramal C 4
2
1 Vetor com hor�rios de acesso A --
2 Idioma N 1
3 Diret�rio C 100
4 Impressora C --
5 Acessos C 512
6 Vetor com empresas A --
7 Ponto de entrada C 10
8 Tipo de impress�o N 1
9 Formato N 1
10 Ambiente N 1
11 Prioridade p/ config. do grupo L 1
12 Op��o de impress�o C 50
13 Acesso a outros dir de impress�o L 1
3
1 M�dulo+n�vel+menu C

aUsers
�ndice      Tipo Conteudo
[n][1][1]  C     N�mero de identifica��o seq�encial com o tamanho de 6 caracteres
[n][1][2]  C     Nome do usu�rio
[n][1][3]  C     Senha (criptografada)
[n][1][4]  C     Nome completo do usu�rio
[n][1][5]  A     Vetor contendo as �ltimas n senhas do usu�rio
[n][1][6]  D     Data de validade
[n][1][7]  N     N�mero de dias para expirar
[n][1][8]  L      Autoriza��o para alterar a senha
[n][1][9]  L      Alterar a senha no pr�ximo logon
[n][1][10] A     Vetor com os grupos
[n][1][11] C     N�mero de identifica��o do superior
[n][1][12] C     Departamento
[n][1][13] C     Cargo
[n][1][14] C     E-mail
[n][1][15] N     N�mero de acessos simult�neos
[n][1][16] D     Data da �ltima altera��o
[n][1][17] L      Usu�rio bloqueado
[n][1][18] N     N�mero de d�gitos para o ano
[n][1][19] L      Listner de liga��es
[n][1][20] C     Ramal
[n][1][21] C     Log de opera��es
[n][1][22] C     Empresa, filial e matricula
[n][1][23] A     Informa��es do sistema 
    [n][1][23][1]  L  Permite alterar database do sistema
    [n][1][23][1]  N  Dias a retroceder
    [n][1][23][1]  N  Dias a avan�ar
[n][1][24] D     Data de inclus�o no sistema
[n][1][25] C     N�o usado
[n][1][26] U     N�o usado    
[n][2][1]  A    Vetor contendo os hor�rios dos acessos. Cada elemento do vetor corresponde a um dia da semana com a hora inicial e final.
[n][2][2]  N    Uso interno
[n][2][3]  C    Caminho para impress�o em disco
[n][2][4]  C    Driver para impress�o direto na porta. Ex: EPSON.DRV
[n][2][5]  C    Acessos
[n][2][6]  A    Vetor contendo as empresas, cada elemento cont�m a empresa e a filial. Ex:"9901", se existir "@@@@" significa acesso a todas as empresas
[n][2][7]  C    Elemento alimentado pelo ponto de entrada USERACS
[n][2][8]  N    Tipo de impress�o: 1 - em disco, 2 - via Windows e 3 direto na porta
[n][2][9]  N    Formato da p�gina: 1 � retrato, 2 - paisagem
[n][2][10] N    Tipo de Ambiente: 1 � servidor, 2 - cliente
[n][2][11] L     Priorizar configura��o do grupo
[n][2][12] C    Op��o de impress�o
[n][2][13] L    Acessar outros diret�rios de impress�o
[n][3]     A    Vetor contendo o m�dulo, o n�vel e o menu do usu�rio. 
      Ex: [n][3][1] = "019\sigaadv\sigaatf.xnu"
          [n][3][2] = "029\sigaadv\sigacom.xnu"
Se o par�metro lSerie for igual a .T., a dimens�o 4 do array tamb�m ser� mostrada.
[n][4]     A    Vetor contendo as informa��es do SenhaP
[n][4][1]  L    Utiliza SenhaP
[n][4][2]  C    N�mero de s�rie do SenhaP
[n][4][3]  C    N�o usado
[n][4][4]  C    N�o usado
[n][5]     A    N�o usado
[n][6]     A    N�o usado
[n][7]     A    N�o usado
*/