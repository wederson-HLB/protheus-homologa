#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
/*
Funcao      : GTGPE004
Retorno     : 
Objetivos   : Manutenção de cadastro de funcionario x Supervisor.
TDN			: 
Autor       : Jean Victor Rocha
Data/Hora   : 25/02/2013
Revisão		: 
Data/Hora   : 
Módulo      : Gestão de Pessoal
Cliente		:
*/
*----------------------*
User Function GTGPE004() 
*----------------------*

Private cMatEMP	:= SUBSTR(SRA->RA_P_MATSU,1,2)
Private cMatFIL	:= SUBSTR(SRA->RA_P_MATSU,3,2)
Private cMatSup	:= SUBSTR(SRA->RA_P_MATSU,5,6)
Private cNome	:= ""
If !EMPTY(cMatEMP) .and. !EMPTY(cMatFIL) .and. !EMPTY(cMatSup)
	cNome	:= GetNameSup()
EndIf

SetPrvt("oDlg1","oGrp1","oSay1","oSay2","oSay6","oSay7","oSay8","oSay9","oGrp2","oSay3","oSay4","oSay5")
SetPrvt("oSay11","oSay12","oSBtn1","oBtn1")

oDlg1      := MSDialog():New( 201,432,473,840,"Manutenção Funcionario x Supervisor - Grant Thornton Brasil.",,,.F.,,,,,,.T.,,,.T. )

oGrp1      := TGroup():New( 004,004,056,196,"Funcionario:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 016,008,{|| "Matricula:"	  		},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay2      := TSay():New( 024,008,{|| "Nome:"		  		},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay6      := TSay():New( 032,008,{|| "Dt. Nasc.:"	   		},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay7      := TSay():New( 016,044,{|| SRA->RA_MAT	   		},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay8      := TSay():New( 024,044,{|| SRA->RA_NOME	   		},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,088,008)
oSay9      := TSay():New( 032,044,{|| DTOC(SRA->RA_NASC)	},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

oGrp2      := TGroup():New( 060,004,112,196,"Supervisor:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay3      := TSay():New( 072,008,{|| "Matricula:"	   		},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay4      := TSay():New( 080,008,{|| "Nome:"				},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay5      := TSay():New( 088,008,{|| "Empresa/Filial:"		},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay10     := TSay():New( 072,044,{|| cMatSup		   		},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay11     := TSay():New( 080,044,{|| cNome					},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,088,008)
oSay12     := TSay():New( 088,044,{|| cMatEMP+"/"+cMatFIL	},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

oSBtn1     := SButton():New( 116,168,1, {|| oDlg1:End()} ,oDlg1,,"", )
oBtn1      := TButton():New( 116,004,"Alterar",oDlg1,{|| GETFUNCS()},032,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 116,040,"Excluir",oDlg1,{|| DELFUNCS()},032,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return .T.

/*
Funcao      : GetNameSup
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca o nome do Supervisor para exibição na tela.
Chamado     : 
Autor       : Jean Victor Rocha
Data/Hora   : 25/02/2013
*/
*--------------------------*
Static Function GetNameSup()
*--------------------------*
Local cRet := ""
Local cQry := ""

If Select("TMPGPE") > 0
	TMPGPE->(DbCloseArea())
EndIf

cQry:="	SELECT RA_NOME"
cQry+="	FROM SRA"+cMatEMP+"0"
cQry+="	WHERE D_E_L_E_T_ <> '*' AND RA_FILIAL = '"+cMatFIL+"' AND RA_MAT = '"+cMatSup+"'"

DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQry),"TMPGPE",.F.,.T.)

TMPGPE->(DBGOTOP())
If TMPGPE->(!EOF())
	cRet := ALLTRIM(TMPGPE->RA_NOME)
EndIf

Return cRet

/*
Funcao      : GETFUNCS
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Abre tela com a lista de funcionarios disponiveis para utilização
Chamado     : 
Autor       : Jean Victor Rocha
Data/Hora   : 25/02/2013
*/
*--------------------------*
Static Function GETFUNCS()  
*--------------------------*
Local cGetMat	:= SPACE(6)
Local nOpcFun := 0

Private aItens := {}
Private cEmpFil := ""

aOrd := SaveOrd("SM0")
SM0->(DbSetOrder(1))
SM0->(DbGoTop())
While SM0->(!EOF())
	If !(SM0->M0_CODIGO $ "YY")
		aAdd(aItens,SM0->M0_CODIGO+SM0->M0_CODFIL+" - "+SM0->M0_NOMECOM)
	EndIf
	SM0->(DbSkip())
EndDo
RestOrd(aOrd)

SetPrvt("oDlgFUN","oSay1","oSay2","oSay3","oCBox1","oGet1","oSBtn1")

oDlgFUN    := MSDialog():New( 215,525,340,845,"Busca de Supervisor - Grant Thornton Brasil.",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Informe os Dados do Supervisor:"},oDlgFUN,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,144,008)
oSay2      := TSay():New( 016,004,{||"Empresa:"},oDlgFUN,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3      := TSay():New( 036,004,{||"Matricula:"},oDlgFUN,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oCBox1     := TComboBox():New( 024,004,{|u|if(PCount()>0,cEmpFil:=u,cEmpFil)},aItens,148,010,oDlgFUN,,,,,,.T.,,,,,,,,,"cEmpFil")

oGet1      := TGet():New( 044,004,{|u| IF(PCount()>0,cGetMat:=u,cGetMat)},oDlgFUN,044,008,"@E 999999",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oBtn1      := TButton():New( 044,049,"?",oDlgFUN,{|| (cGetMat:=GETMAT(),oGet1:refresh(),oCBox1:refresh())},007,010,,,,.T.,,"",,,,.F. )

oSBtn1     := SButton():New( 044,124,1, {|| (nOpcFun := 1, oDlgFUN:END()) } ,oDlgFUN,,"", )

oDlgFUN:Activate(,,,.T.)                     

If nOpcFun == 1
	If EMPTY(cEmpFil) .Or. EMPTY(cGetMat)
		MsgInfo("Dados da empresa e/ou funcionarios invalidos!")
	Else
		RecLock("SRA", .F.)
		SRA->RA_P_MATSU := LEFT(cEmpFil,4)+ALLTRIM(cGetMat)
		SRA->(MsUnlock())
		M->RA_P_MATSU := SRA->RA_P_MATSU
		oEnchSra:Refresh()
	EndIf
EndIf

Return .T.

/*
Funcao      : GETFUNCS
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Abre tela com a lista de funcionarios disponiveis para utilização
Chamado     : 
Autor       : Jean Victor Rocha
Data/Hora   : 25/02/2013
*/
*--------------------------*
Static Function GETMAT()    
*--------------------------*
Local cRet := ""

Local aArea := GetArea() 
Local aAreaSRA := SRA->( GetArea() ) 
Local cSvFilAnt := cFilAnt //Salva a Filial Anterior 
Local cSvEmpAnt := cEmpAnt //Salva a Empresa Anterior 
Local cSvArqTab := cArqTab //Salva os arquivos de //trabalho 
Local cModo //Modo de acesso do arquivo aberto //"E" ou "C" 
Local cNewAls := GetNextAlias() //Obtem novo Alias 

IF EmpOpenFile("SRA","SRA",1,.T.,LEFT(cEmpFil,2),@cModo) 
	If CONPAD1(,,,"SRA",,,.F.) // Chama Consulta Padrao do Contrato de Condominio
		cRet := SRA->RA_MAT
		If SRA->RA_FILIAL <> SUBSTR(cEmpFil,3,2)
			nPos := aScan(aItens, {|x| LEFT(x,4) == LEFT(cEmpFil,2)+SRA->RA_FILIAL })
			cEmpFil := aItens[nPos]
		EndIf
	EndIf
	SRA->( dbCloseArea() ) 

	//Restaura os Dados de Entrada ( Ambiente ) 
	cFilAnt := cSvFilAnt 
	cEmpAnt := cSvEmpAnt 
	cArqTab := cSvArqTab 
	ChkFile( "SRA" ) //Reabre o SRA da empresa atual 
EndIF

//Restaura os ponteiros das Tabelas 
RestArea( aAreaSRA ) 
RestArea( aArea ) 

Return cRet

/*
Funcao      : DELFUNCS
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Limpa vinculo com Supervisores.
Chamado     : 
Autor       : Jean Victor Rocha
Data/Hora   : 25/02/2013
*/
*--------------------------*
Static Function DELFUNCS()    
*--------------------------*
RecLock("SRA", .F.)
SRA->RA_P_MATSU := ""
SRA->(MsUnlock())
M->RA_P_MATSU := SRA->RA_P_MATSU
oEnchSra:Refresh()
Return .T.