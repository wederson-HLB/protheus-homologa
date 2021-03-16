#Include "rwmake.ch"   
#Include "topconn.ch"  

/*
Funcao      : R7BFAT03
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Informa as últimas amostras enviadas para o cliente, rotina está sendo executada a partir do campo C6_QTDVEN (SX3). 
Autor     	: 
Data     	:                        '
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Faturamento. 
Cliente     : Shiseido
*/

*------------------------*
 User Function R7BFAT03()
*------------------------*

//MSM - 22/05/2017 - Se não for job, para não dar erro no portal da Logos
if !IsBlind()

	DbSelectArea("SX6")  
	
	If! DbSeek("  MV_PMESES")
		    RecLock("SX6",.T.)
		    Replace X6_VAR		 With "MV_PMESES"
		    Replace X6_TIPO	    With "N"
		    Replace X6_DESCRIC   With "Especifico Shiseido" 
		    Replace X6_CONTEUD   With "3"
		    Replace X6_PROPRI	 With "U"
		    MsUnLock()
	EndIf
	_nMeses :=SX6->X6_CONTEUD	    
	If! DbSeek("  MV_PTES")
		    RecLock("SX6",.T.)
		    Replace X6_VAR		 With "MV_PTES"
		    Replace X6_TIPO	    With "C"
		    Replace X6_DESCRIC   With "Especifico Shiseido" 
		    Replace X6_CONTEUD   With "77T"
		    Replace X6_PROPRI	 With "U"
		    MsUnLock()
	EndIf
	_cTes :=SX6->X6_CONTEUD	    
	
	fOkProc()
	
	DbSelectArea("SQL")
	DbGoTop()
	If RecCount() > 0
		Campos:={}
		aadd(Campos , {"D2_SERIE"   ,"Serie","@!","03","0"})
		aadd(Campos , {"D2_DOC"     ,"Documento","@!","06","0"})
		aadd(Campos , {"D2_QUANT"   ,"Quantidade","@E 999,999.99","08","2"})
		aadd(Campos , {"D2_EMISSAO" ,"Emissao","@!","08","0"})
	    
		@ 000,000 To 320,450 Dialog oCli Title "Amostras enviadas nos ultimos "+AllTrim(Str(GetMv("MV_PMESES")))+" mes(es)."
		@ 002,002 To 140,225 Browse "SQL" Fields Campos 
		@ 145,170 Button "_Fechar"  Size 55,15 Action Close(oCli)
		
		Activate Dialog oCli Centered
	EndIf

endif

Return(.T.)

*--------------------------*
 Static Function fOkProc()
*--------------------------*

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

cQuery := "SELECT D2_SERIE,D2_DOC,D2_QUANT,D2_EMISSAO " 
cQuery += "FROM "+RetSqlName("SD2")+" WHERE "+Chr(10)
cQuery += "D2_FILIAL = '"+xFilial("SD2")+"'"+Chr(10)
cQuery += "AND D2_CLIENTE = '"+M->C5_CLIENTE+"'"+Chr(10)
cQuery += "AND D2_LOJA = '"+M->C5_LOJACLI+"'"+Chr(10)
cQuery += "AND D2_COD = '"+aCols[n][2]+"'"+Chr(10)
cQuery += "AND DateDiff(Month, Convert(SmallDateTime,D2_EMISSAO),Convert(SmallDateTime,'"+Dtos(dDataBase)+"'))<= "+_nMeses
cQuery += "AND D2_TES ='"+AllTrim(_cTes)+"'"+Chr(10)
cQuery += "AND D_E_L_E_T_ <> '*'"+Chr(10)
cQuery += "ORDER BY D2_SERIE,D2_DOC"

//cQuery += "AND D2_EMISSAO Between '"+AllTrim(Str(Year(dDataBase)))+StrZero(Month(dDataBase)-Val(_nMeses),2)+AllTrim(Str(Day(dDataBase)))+"' AND '"+Dtos(dDataBase)+"'"+Chr(10)   

TcQuery cQuery ALIAS "SQL" NEW        

TCSetField("SQL","D2_EMISSAO","D",08,0)

cTmp := CriaTrab(NIL,.F.)
Copy To &cTmp
DbCloseArea()
DbUseArea(.T.,,cTmp,"SQL",.T.)

Return