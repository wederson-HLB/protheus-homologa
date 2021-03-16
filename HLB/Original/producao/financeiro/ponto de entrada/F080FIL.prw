#Include "Protheus.ch"

/*
Funcao      : F080FIL
Parametros  : Nil
Retorno     : Nil
Objetivos   : Ponto de entrada para filtrar a tela de seleção de tú‘ulos para baixa por lote.
TDN			: O ponto de entrada F080FIL sera executado antes da montagem da IndRegua na baixa por lote do contas a pagar. Utilizado para completar o filtro da IndRegua.
Autor       : Matheus Massarotto
Data/Hora   : 04/02/2015    09:15
Revisão		:                    
Data/Hora   : 
Módulo      : Financeiro
*/

*----------------------*
User function F080FIL
*----------------------*
Local cRet:=""

if cEmpAnt $ "LW/LX/LY"
	
	DbSelectArea("SE2")
	if SE2->(FieldPos("E2_P_FATUR")>0)
		TelaFiltro(@cRet)
	endif
	
endif

Return(cRet)

/*
Funcao      : TelaFiltro()
Parametros  : 
Retorno     : 
Objetivos   : Função com a tela para informar parametros de/ate
Autor       : Matheus Massarotto
Data/Hora   : 03/02/2015	17:10
*/

*------------------------------*
Static Function TelaFiltro(cRet)
*------------------------------*
Local oDlg1,oGrp1,oSay1,oSay2,oGet1,oGet2,oBtn1,oBtn2
Private cFatDe	:= space(20)
Private cFatAte	:= space(20)

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1      := MSDialog():New( 216,452,390,716,"HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 004,008,060,120,"Filtro Adicional",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 016,012,{||"Fatura De:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay2      := TSay():New( 032,012,{||"Fatura AtE"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet1      := TGet():New( 013,044,{|u| if(PCount()>0,cFatDe:=u,cFatDe)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet2      := TGet():New( 029,044,{|u| if(PCount()>0,cFatAte:=u,cFatAte)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oBtn1      := TButton():New( 064,016,"Utilizar",oDlg1,{ || cRet:=MontaFil(),oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 064,076,"Não Utilizar",oDlg1,{ || oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return

/*
Funcao      : MontaFil()
Parametros  : 
Retorno     : 
Objetivos   : Função para montagem do filtro
Autor       : Matheus Massarotto
Data/Hora   : 03/02/2015	17:10
*/

*------------------------*
Static function MontaFil()
*------------------------*
Local cFiltro:=""

cFiltro+="SE2->E2_P_FATUR >= '"+alltrim(cFatDe)+"' .AND. SE2->E2_P_FATUR <= '"+alltrim(cFatAte)+"'"

Return(cFiltro)