#Include "rwmake.ch"
#Include "topconn.ch" 

/*
Funcao      : TYY001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Rotina de manutenção de Flag campo F1_P_EASY  relacionado ao software EasyWay   
Autor     	: 
Data     	:  
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Livros Fiscais.
*/

*------------------------*
 User Function TYY001()
*------------------------*

If MsgYesNo("Está rotina realiza manutencao na Flag"+Chr(10)+Chr(13)+"utilizada pela rotina de importacao.","Específico EasyWay ")
   Processa({||fOkProc()},"Especifico EasyWay")
Endif

Return

//---------------------------------                                         

Static Function fOkProc()
_cFilial :=cFilAnt
_cEmpresa:=cEmpAnt
_nCont   :=_nCont2:=0  

DbSelectArea("SM0")
_nRecno:=Recno()
DbGotop()
ProcRegua(RecCount())
Do While.Not.Eof()
   _cQuery :="UPDATE SF1"+M0_CODIGO+"0 SET F1_P_EASY = '20050702'"+Chr(10) 
   _cQuery +="WHERE D_E_L_E_T_ <> '*' AND F1_DTDIGIT <= '20050702'"

   If TcSqlExec(_cQuery)<0
      _nCont2 ++
   Else        
      _nCont ++
   Endif   
   IncProc(M0_NOMECOM)
   DbSkip()
EndDo

MsgInfo("Empresas Processadas :"+StrZero(+_nCont,3)+Chr(10)+Chr(13)+"Nao Processadas :"+StrZero(_nCont2,3),"Especifico EasyWay")

cFilAnt:=_cFilial
cEmpAnt:=_cEmpresa
DbSelectArea("SM0")
DbGoto(_nRecno)
Return