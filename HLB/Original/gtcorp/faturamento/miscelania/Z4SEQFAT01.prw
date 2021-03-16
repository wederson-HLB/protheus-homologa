#Include "rwmake.ch"   
#Include "topconn.ch"

/*
Funcao      : Z4SEQFAT01
Parametros  : 
Retorno     : 
Objetivos   : Busca RECNO para gravacao de campo sequencial de acordo com o parametro MV_SEQZ4
Autor       : Renato Mendonça 
TDN         : 
Revisão     : Matheus Massarotto
Data/Hora   : 24/07/2012 - 16:14
Módulo      : Faturamento.
*/


*-------------------------*
User Function Z4SEQFAT01()
*-------------------------*

fOkProc()

DbSelectArea("SQL")
DbGoTop()
If Select("SQL") > 0
	Numero := SQL->MAXIMO
EndIf                    

	Numero := Numero+1
              
Return(Numero)

//----------------

Static Function fOkProc()

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT MAX(A1_P_SEQUE) AS MAXIMO "+Chr(10)
cQuery += "FROM "+RetSqlName("SA1")+" WHERE "+Chr(10)
cQuery += "A1_FILIAL = '"+xFilial("SA1")+"'"+Chr(10)
cQuery += "AND D_E_L_E_T_ <> '*' "

TcQuery cQuery ALIAS "SQL" NEW        
//DbUseArea(.T.,,cTmp,"SQL",.T.)

Return