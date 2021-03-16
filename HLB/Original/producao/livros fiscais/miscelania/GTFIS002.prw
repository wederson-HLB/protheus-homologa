#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*
Funcao      : GTFIS002
Objetivos   : Cadastro de grupo tributario, SX5.
Revis�o     : Jean Victor Rocha
Data/Hora   : 08/05/2013
Revisao     :
Obs.        :
*/
*----------------------*
User Function GTFIS002()     
*----------------------*
Private aRotina		:= MenuDef() 
Private CCADASTRO	:= OemToAnsi("Manuten��o de Grupo Tributario.")
                          
Private cGet1 := Space(6)
Private cGet2 := Space(55)
Private cGet3 := Space(55)
Private cGet4 := Space(55)

Private lWhen1 := .T.
Private lWhen2 := .T.
Private lWhen3 := .T.
Private lWhen4 := .T.

Private lConfirm := .T.
                     
_cArea:=GetArea()

dbSelectArea("SX5")
dbGoTop()

cFiltro := "X5_TABELA = '21'"

mBrowse( 6,1,22,75,"SX5",,,,,,,,,,,,,,cFiltro)

dbSelectArea("SX5")

restarea(_cArea)   


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
Local aRotina :=  { { "Pesquisar" 	,"AxPesqui"		, 0 , 1 },;
                    { "Incluir" 	,"U_FIS002I"	, 0 , 2 },;
                    { "Alterar"		,"U_FIS002A"	, 0 , 3 },;
                    { "Visualizar"	,"U_FIS002V"	, 0 , 4 },;
                    { "Excluir"	  	,"U_FIS002E"  , 0 , 5, NIL, .F.}}

Return aRotina    

*---------------------* 
User Function FIS002I()
*---------------------*    

FIS002M()

If !lConfirm
	ResetODLG()
	Return .T.
EndIf

If Empty(cGet1) .or. Empty(cGet2)
	MsgInfo("Existe(m) campo(s) n�o informado(s)!")
	U_FIS002I()
ElseIf SX5->(DbSeek(xFilial("SX5")+"21"+cGet1))
	MsgInfo("Codigo informado ja utilizado!")
	U_FIS002I()
Else
	SX5->(RecLock("SX5",.T.))
	SX5->X5_TABELA	:= "21"
	SX5->X5_CHAVE	:= cGet1
	SX5->X5_DESCRI	:= cGet2
	SX5->X5_DESCSPA	:= cGet3
	SX5->X5_DESCENG	:= cGet4
	SX5->(MsUnlock())

	ResetODLG()
EndIf

Return .t.             

*---------------------*
User Function FIS002A()
*---------------------*
cGet1 := SX5->X5_CHAVE
cGet2 := SX5->X5_DESCRI
cGet3 := SX5->X5_DESCSPA
cGet4 := SX5->X5_DESCENG

lWhen1 := .F.

FIS002M()

If !lConfirm
	ResetODLG()
	Return .T.
EndIf

If Empty(cGet1) .or. Empty(cGet2)
	MsgInfo("Existe(m) campo(s) n�o informado(s)!")
	U_FIS002I()
ElseIf SX5->(DbSeek(xFilial("SX5")+"21"+cGet1))
	SX5->(RecLock("SX5",.F.))
	SX5->X5_CHAVE	:= cGet1
	SX5->X5_DESCRI	:= cGet2
	SX5->X5_DESCSPA	:= cGet3
	SX5->X5_DESCENG	:= cGet4
	SX5->(MsUnlock())

	ResetODLG() 
Else
	MsgInfo("N�o foi possivel altera��o!")
	ResetODLG()
EndIf

Return .t.             

*---------------------*
User Function FIS002V()
*---------------------*
cGet1 := SX5->X5_CHAVE
cGet2 := SX5->X5_DESCRI
cGet3 := SX5->X5_DESCSPA
cGet4 := SX5->X5_DESCENG

lWhen1 := lWhen2 := lWhen3 := lWhen4 := .F.

FIS002M()

ResetODLG()

Return .t.             

*---------------------*
User Function FIS002E()
*---------------------*
cGet1 := SX5->X5_CHAVE
cGet2 := SX5->X5_DESCRI
cGet3 := SX5->X5_DESCSPA
cGet4 := SX5->X5_DESCENG

lWhen1 := lWhen2 := lWhen3 := lWhen4 := .F.

FIS002M()

If !lConfirm
	ResetODLG()
	Return .T.
EndIf 
   
SF7->(DbSetOrder(1))
If SF7->(DbSeek(xFilial("SF7")+cGet1))
	MsgInfo("N�o foi possivel exclus�o, Grupo tributario sendo utilizado!") 
	ResetODLG()
	Return .T.
EndIf

If SX5->(DbSeek(xFilial("SX5")+"21"+cGet1))
	SX5->(RecLock("SX5",.F.))
	SX5->(DbDelete())
	SX5->(MsUnlock())

	ResetODLG() 
Else
	MsgInfo("N�o foi possivel exclus�o!") 
	ResetODLG()
EndIf

Return .t. 
          
*---------------------*
Static Function FIS002M()
*---------------------*
SetPrvt("oDlg1","oSay1","oSay2","oSay3","oSay4","oGet1","oGet2","oGet3","oGet4","oSBtn1","oSBtn2")

oDlg1      := MSDialog():New( 258,533,390,834,"Manuten��o Cadastro Grupo Tributario ",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 008,004,{||"Codigo"		},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay2      := TSay():New( 020,004,{||"Desc. Port."	},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay3      := TSay():New( 032,004,{||"Desc. Spanish"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay4      := TSay():New( 044,004,{||"Desc. English"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oGet1      := TGet():New( 004,044,{|u| IF(PCount()>0,cGet1:=u,cGet1)},oDlg1,060,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,!lWhen1,.F.,"","",,)
oGet2      := TGet():New( 016,044,{|u| IF(PCount()>0,cGet2:=u,cGet2)},oDlg1,060,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,!lWhen2,.F.,"","",,)
oGet3      := TGet():New( 028,044,{|u| IF(PCount()>0,cGet3:=u,cGet3)},oDlg1,060,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,!lWhen3,.F.,"","",,)
oGet4      := TGet():New( 040,044,{|u| IF(PCount()>0,cGet4:=u,cGet4)},oDlg1,060,008,"@!",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,!lWhen4,.F.,"","",,)
oSBtn1     := SButton():New( 004,112,1,{|| oDlg1:end() },oDlg1,,"", )
oSBtn2     := SButton():New( 016,112,2,{|| (lConfirm := .F.,oDlg1:end()) },oDlg1,,"", )

oDlg1:Activate(,,,.T.)
         
Return .T.   
              
*-------------------------*
Static Function ResetODLG() 
*-------------------------*
cGet1 := Space(6)
cGet2 := Space(55)
cGet3 := Space(55)
cGet4 := Space(55)
lWhen1 := .T.
lWhen2 := .T.
lWhen3 := .T.
lWhen4 := .T.
lConfirm := .T.

Return .T.