#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Tbiconn.ch" 
#DEFINE CRLF	Chr(13) + Chr(10)


/*
Funcao      : FOLR003
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Rotina de exportaçao de provisões - Horas
Autor       : TOTVS
Data        : 09/05/2011
Obs         : 
TDN         : 
Revisão     : Renato Rezende
Data/Hora   : 13/05/2013
Módulo      : Gestão de Pessoal
Cliente     : 
*/

*-----------------------*
User Function FOLR003
*-----------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     

Local aArea			:= GetArea()
Local nOpca     	:= 0
Local aSays     	:= {}
Local aButtons  	:= {}
Local cCadastro  	:= OemToAnsi("Exportação de Provisões - Gerencial")
Local cArquivo		:= "" 
Local cPerg			:= "FOLR003"


AjustaSX1(cPerg)
Pergunte(cPERG,.F. )


AADD(aSays,OemToAnsi("Rotina de exportações de dados para o excel. Controle de Horas - Gerencial."  ))
AADD(aButtons, { 5,.T.,{|| Pergunte(cPERG,.T. ) } } )
AADD(aButtons, { 1,.T.						,{|o| (nOpca := 1,o:oWnd:End())						   		}})
AADD(aButtons, { 2,.T.						,{|o| (nOpca := 0,o:oWnd:End())								}})
FormBatch( cCadastro, aSays, aButtons )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia a importacao                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1
	Processa({|lEnd| Export() },"Exportando informações......")
Endif

RestArea(aArea)

Return 


*-----------------------*
Static Function Export
*-----------------------*

Local cQuery 	:= ""
Local cAliasQry	:=GetNextAlias()                                    
Local aCabec	:= {"Filial","Matrícula","Centro de Custo","Nome","VLR. 172-DSR NOT","HORAS 190-DSR","VLR. 190-DSR","HORAS 235-ADIC","VLR. 235-ADIC","377-DIF VLR.","HORAS E11 - ADC ","VALOR E11 - ADC ","HORAS E12 - ADC ","VALOR E12 - ADC ","HORAS E13 - H EXTRA ","VALOR E13 - H EXTRA ","HORAS E14 - H EXTRA ","VALOR E14 - H EXTRA ","HORAS E15 - H EXTRA ","VALOR E15 - H EXTRA","H0RAS E01","VALOR E01","HORAS 499","VALOR 499","TOTAL HORAS ","TOTAL VALOR ","TOTAL ENCARGOS "} 	
Local cQuebra	:= ""
Local nTotFil1  := 0 
Local nTotGeral1:= 0 
Local nTotFil2  := 0 
Local nTotGeral2:= 0 
Local nTotFil3  := 0 
Local nTotGeral3:= 0 
Local nTotFil4  := 0 
Local nTotGeral4:= 0 
Local nTotFil5  := 0 
Local nTotGeral5:= 0 
Local nTotFil6  := 0 
Local nTotGeral6:= 0 
Local nTotFil7  := 0 
Local nTotGeral7:= 0 
Local nTotFil8  := 0 
Local nTotGeral8:= 0 
Local nTotFil9  := 0 
Local nTotGeral9:= 0 
Local nTotFil10  := 0 
Local nTotGeral10:= 0 
Local nTotFil11  := 0 
Local nTotGeral11:= 0 
Local nTotFil12  := 0 
Local nTotGeral12:= 0 
Local nTotFil13  := 0 
Local nTotGeral13:= 0 
Local nTotFil14  := 0 
Local nTotGeral14:= 0 
Local nTotFil15  := 0 
Local nTotGeral15:= 0 
Local nTotFil16  := 0 
Local nTotGeral16:= 0 
Local nTotFil17  := 0 
Local nTotGeral17:= 0 
Local nTotFil18  := 0 
Local nTotGeral18:= 0 
Local nTotFil19  := 0 
Local nTotGeral19:= 0 
Local nTotFil20  := 0 
Local nTotGeral20:= 0 
Local nTotFil21  := 0 
Local nTotGeral21:= 0 
Local nTotFil22  := 0 
Local nTotGeral22:= 0 
Local nTotFil23  := 0 
Local nTotGeral23:= 0 
Local aDetExcel	:= {}
Local nFator	:= 0.365336


cQuery := " SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_CC,SRA.RA_NOME," + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL ='"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "+CRLF
cQuery += " 				AND SRC.RC_PD= '172'),0) AS VL172," + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_HORAS) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL ='"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+CRLF
cQuery += " 				AND SRC.RC_PD= '190'),0) AS HR190,								" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL ='"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+CRLF
cQuery += " 				AND SRC.RC_PD= '190'),0) AS VL190,								" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_HORAS) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL ='"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+CRLF
cQuery += " 				AND SRC.RC_PD= '235'),0) AS HR235,								" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL ='"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+CRLF
cQuery += " 				AND SRC.RC_PD= '235'),0) AS VL235,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL ='"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= '377'),0) AS VL377 ,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_HORAS) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL ='"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E11'),0) AS HRE11,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL = '"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E11'),0) AS VLE11,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_HORAS) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL ='"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E12'),0) AS HRE12,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL = '"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E12'),0) AS VLE12,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_HORAS) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL ='"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E13'),0) AS HRE13,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL = '"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E13'),0) AS VLE13,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_HORAS) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL ='"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E14'),0) AS HRE14,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL = '"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E14'),0) AS VLE14,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_HORAS) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL = '"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E15'),0) AS HRE15,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL = '"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E15'),0) AS VLE15,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_HORAS) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL = '"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E01'),0) AS HRE01,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL = '"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= 'E01'),0) AS VLE01,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_HORAS) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL = '"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= '499'),0) AS HR499,				" + CRLF
cQuery += " 		COALESCE((SELECT SUM(SRC.RC_VALOR) FROM " + RetSqlName("SRC") + " SRC" + CRLF
cQuery += " 			WHERE SRC.RC_FILIAL = '"+xFilial("SRC")+"' " + CRLF
cQuery += " 				AND SRC.RC_MAT = SRA.RA_MAT" + CRLF
cQuery += " 				AND SRC.D_E_L_E_T_ =''" + CRLF
cQuery += " 				AND SRC.RC_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += " 				AND SRC.RC_PD= '499'),0) AS VL499				" + CRLF
cQuery += " 						" + CRLF
cQuery += " FROM " + RetSqlName("SRA") + " SRA" + CRLF
cQuery += " WHERE SRA.RA_FILIAL = '"+xFilial("SRA")+"'" + CRLF
cQuery += " 	AND SRA.RA_MAT BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"+CRLF
cQuery += " 	AND SRA.D_E_L_E_T_ =''  " +CRLF  
If MV_PAR05 == 2 

	cQuery += " 	AND SRA.RA_SITFOLH <> 'D'  " +CRLF  

Endif
cQuery += " ORDER BY RA_FILIAL,RA_MAT   "

cQuery := ChangeQuery( cQuery )
                               

dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

TcSetField(cAliasQry,"VL172","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"VL190","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"VL235","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"VL377","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"VLE11","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"VLE12","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"VLE13","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"VLE14","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"VLE15","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"VLE01","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"VL499","N",TamSx3("RC_VALOR")[1],TamSx3("RC_VALOR")[2])
TcSetField(cAliasQry,"HR190","N",TamSx3("RC_HORAS")[1],TamSx3("RC_HORAS")[2])
TcSetField(cAliasQry,"HR235","N",TamSx3("RC_HORAS")[1],TamSx3("RC_HORAS")[2])
TcSetField(cAliasQry,"HRE11","N",TamSx3("RC_HORAS")[1],TamSx3("RC_HORAS")[2])
TcSetField(cAliasQry,"HRE12","N",TamSx3("RC_HORAS")[1],TamSx3("RC_HORAS")[2])
TcSetField(cAliasQry,"HRE13","N",TamSx3("RC_HORAS")[1],TamSx3("RC_HORAS")[2])
TcSetField(cAliasQry,"HRE14","N",TamSx3("RC_HORAS")[1],TamSx3("RC_HORAS")[2])
TcSetField(cAliasQry,"HRE15","N",TamSx3("RC_HORAS")[1],TamSx3("RC_HORAS")[2])
TcSetField(cAliasQry,"HRE01","N",TamSx3("RC_HORAS")[1],TamSx3("RC_HORAS")[2])
TcSetField(cAliasQry,"HR499","N",TamSx3("RC_HORAS")[1],TamSx3("RC_HORAS")[2])

While !( cAliasQry )->(EOF())

	cQuebra := ( cAliasQry )->RA_FILIAL 
	
	While ! ( cAliasQry )->(EOF()) .And. cQuebra == ( cAliasQry )->RA_FILIAL 


		If ( cAliasQry )->VL172 != 0 .OR. ( cAliasQry )->VL190 != 0 .OR. ( cAliasQry )->VL235 != 0 .OR. ( cAliasQry )->VL377 != 0 ;
		   .OR. ( cAliasQry )->VLE11 != 0 .OR. ( cAliasQry )->VLE12 != 0	.OR. ( cAliasQry )->VLE13 != 0 .OR. ( cAliasQry )->VLE14 != 0 .OR. ( cAliasQry )->VLE15 != 0 .OR. ( cAliasQry )->VLE01 != 0 .OR. ( cAliasQry )->VL499 != 0
     
	        Aadd(aDetExcel, {( cAliasQry )->RA_FILIAL,;
	        				( cAliasQry )->RA_MAT,;	
							( cAliasQry )->RA_CC,;         				
							( cAliasQry )->RA_NOME,; 
							( cAliasQry )->VL172,;
							( cAliasQry )->HR190,;						
							( cAliasQry )->VL190,;
							( cAliasQry )->HR235,;
							( cAliasQry )->VL235,;						
							( cAliasQry )->VL377,;												
							( cAliasQry )->HRE11,;
							( cAliasQry )->VLE11,;						
							( cAliasQry )->HRE12,;
							( cAliasQry )->VLE12,;												
							( cAliasQry )->HRE13,;
							( cAliasQry )->VLE13,;																		
							( cAliasQry )->HRE14,;
							( cAliasQry )->VLE14,;																								
							( cAliasQry )->HRE15,;																														
							( cAliasQry )->VLE15,;																														
							( cAliasQry )->HRE01,;																														
							( cAliasQry )->VLE01,;																																					
							( cAliasQry )->HR499,;																														
							( cAliasQry )->VL499,;																																												
							( cAliasQry )->HR190+( cAliasQry )->HR235+( cAliasQry )->HRE11+( cAliasQry )->HRE12+( cAliasQry )->HRE13+( cAliasQry )->HRE14,;	  
							( cAliasQry )->VL172+( cAliasQry )->VL190+( cAliasQry )->VL235+( cAliasQry )->VL377+( cAliasQry )->VLE11+( cAliasQry )->VLE12+( cAliasQry )->VLE13+( cAliasQry )->VLE14+( cAliasQry )->VLE15,; 
							( ( cAliasQry )->VL172+( cAliasQry )->VL190+( cAliasQry )->VL235+( cAliasQry )->VL377+( cAliasQry )->VLE11+( cAliasQry )->VLE12+( cAliasQry )->VLE13+( cAliasQry )->VLE14+( cAliasQry )->VLE15) * nFator; 						
	        })
	
			nTotFil1+= ( cAliasQry )->VL172		
			nTotFil2+= ( cAliasQry )->HR190  
			nTotFil3+= ( cAliasQry )->VL190				
			nTotFil4+= ( cAliasQry )->HR235
			nTotFil5+= ( cAliasQry )->VL235
			nTotFil6+= ( cAliasQry )->VL377
			nTotFil7+= ( cAliasQry )->HRE11
			nTotFil8+= ( cAliasQry )->VLE11		
			nTotFil9+= ( cAliasQry )->HRE12  
			nTotFil10+= ( cAliasQry )->VLE12				
			nTotFil11+= ( cAliasQry )->HRE13
			nTotFil12+= ( cAliasQry )->VLE13
			nTotFil13+= ( cAliasQry )->HRE14
			nTotFil14+= ( cAliasQry )->VLE14		
			nTotFil15+= ( cAliasQry )->HRE15				
			nTotFil16+= ( cAliasQry )->VLE15				
			nTotFil17+= ( cAliasQry )->HRE01				
			nTotFil18+= ( cAliasQry )->VLE01							
			nTotFil19+= ( cAliasQry )->HR499				
			nTotFil20+= ( cAliasQry )->VL499										
			nTotFil21+= ( cAliasQry )->HR190+( cAliasQry )->HR235+( cAliasQry )->HRE11+( cAliasQry )->HRE12+( cAliasQry )->HRE13+( cAliasQry )->HRE14+( cAliasQry )->HRE15+( cAliasQry )->HRE01+( cAliasQry )->HR499
			nTotFil22+= ( cAliasQry )->VL172+( cAliasQry )->VL190+( cAliasQry )->VL235+( cAliasQry )->VL377+( cAliasQry )->VLE11+( cAliasQry )->VLE12+( cAliasQry )->VLE13+( cAliasQry )->VLE14+( cAliasQry )->VLE15+( cAliasQry )->VLE01+( cAliasQry )->VL499
			nTotFil23+= ( ( cAliasQry )->VL172+( cAliasQry )->VL190+( cAliasQry )->VL235+( cAliasQry )->VL377+( cAliasQry )->VLE11+( cAliasQry )->VLE12+( cAliasQry )->VLE13+( cAliasQry )->VLE14+( cAliasQry )->VLE15+( cAliasQry )->VLE01+( cAliasQry )->VL499) * nFator
	
			nTotGeral1+= ( cAliasQry )->VL172		
			nTotGeral2+= ( cAliasQry )->HR190  
			nTotGeral3+= ( cAliasQry )->VL190				
			nTotGeral4+= ( cAliasQry )->HR235
			nTotGeral5+= ( cAliasQry )->VL235
			nTotGeral6+= ( cAliasQry )->VL377
			nTotGeral7+= ( cAliasQry )->HRE11
			nTotGeral8+= ( cAliasQry )->VLE11		
			nTotGeral9+= ( cAliasQry )->HRE12  
			nTotGeral10+= ( cAliasQry )->VLE12				
			nTotGeral11+= ( cAliasQry )->HRE13
			nTotGeral12+= ( cAliasQry )->VLE13
			nTotGeral13+= ( cAliasQry )->HRE14
			nTotGeral14+= ( cAliasQry )->VLE14		
			nTotGeral15+= ( cAliasQry )->HRE15		
			nTotGeral16+= ( cAliasQry )->VLE15		
			nTotGeral17+= ( cAliasQry )->HRE01		
			nTotGeral18+= ( cAliasQry )->VLE01		
			nTotGeral19+= ( cAliasQry )->HR499		
			nTotGeral20+= ( cAliasQry )->VL499									
			nTotGeral21+= ( cAliasQry )->HR190+( cAliasQry )->HR235+( cAliasQry )->HRE11+( cAliasQry )->HRE12+( cAliasQry )->HRE13+( cAliasQry )->HRE14+( cAliasQry )->HRE15+( cAliasQry )->HRE01+( cAliasQry )->HR499
			nTotGeral22+= ( cAliasQry )->VL172+( cAliasQry )->VL190+( cAliasQry )->VL235+( cAliasQry )->VL377+( cAliasQry )->VLE11+( cAliasQry )->VLE12+( cAliasQry )->VLE13+( cAliasQry )->VLE14+( cAliasQry )->VLE15+( cAliasQry )->VLE01+( cAliasQry )->VL499
			nTotGeral23+= ( ( cAliasQry )->VL172+( cAliasQry )->VL190+( cAliasQry )->VL235+( cAliasQry )->VL377+( cAliasQry )->VLE11+( cAliasQry )->VLE12+( cAliasQry )->VLE13+( cAliasQry )->VLE14+( cAliasQry )->VLE15+( cAliasQry )->VLE01+( cAliasQry )->VL499) * nFator		

		Endif                     
		( cAliasQry )->(DbSkip())	
    Enddo       

        
    Aadd(aDetExcel, {"TOTAL FILIAL",;
        				"",;	
						"",;         				
						"",; 						
						nTotFil1,; 
						nTotFil2,;
						nTotFil3,;						
						nTotFil4,;
						nTotFil5,;
						nTotFil6,;						
						nTotFil7,; 
						nTotFil8,;
						nTotFil9,;						
						nTotFil10,;
						nTotFil11,;
						nTotFil12,;						
						nTotFil13,; 
						nTotFil14,;
						nTotFil15,;						
						nTotFil16,;
						nTotFil17,;
						nTotFil18,;
						nTotFil19,;
						nTotFil20,;
						nTotFil21,;
						nTotFil22,;																														
						nTotFil23;
        })

	nTotFil1 	:= 0
	nTotFil2	:= 0
	nTotFil3	:= 0
	nTotFil4	:= 0
	nTotFil5	:= 0
	nTotFil6   	:= 0             
	nTotFil7    := 0 
	nTotFil8 	:= 0
	nTotFil9	:= 0
	nTotFil10	:= 0
	nTotFil11	:= 0
	nTotFil12	:= 0
	nTotFil13  	:= 0             
	nTotFil14   := 0 
	nTotFil15	:= 0
	nTotFil16	:= 0
	nTotFil17	:= 0
	nTotFil18  	:= 0             
	nTotFil19  	:= 0             
	nTotFil20  	:= 0             
	nTotFil21  	:= 0             
	nTotFil22  	:= 0             
	nTotFil23  	:= 0             			




    
Enddo

        
Aadd(aDetExcel, {"TOTAL GERAL",;
        		"",;	
				"",;         				
				"",; 						
				nTotGeral1,; 
				nTotGeral2,;
				nTotGeral3,;						
				nTotGeral4,;
				nTotGeral5,;
				nTotGeral6,;						
				nTotGeral7,; 
				nTotGeral8,;
				nTotGeral9,;						
				nTotGeral10,;
				nTotGeral11,;
				nTotGeral12,;										
				nTotGeral13,; 
				nTotGeral14,;
				nTotGeral15,;						
				nTotGeral16,;
				nTotGeral17,;
				nTotGeral18,;
				nTotGeral19,;
				nTotGeral20,;
				nTotGeral21,;
				nTotGeral22,;																				
				nTotGeral23;														
 })

If Len(aDetExcel) > 0
	DlgToExcel({{"ARRAY","Relatório Gerencial",aCabec,aDetExcel}})
Endif 	


IIf( Select( cAliasQry ) > 0 , ( cAliasQry )->( dbCloseArea() ) , Nil )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1    ³Autor ³  TOTVS   		      ³Data³ 05/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta perguntas do SX1                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


*--------------------------------*
Static Function AjustaSX1(cPerg)
*--------------------------------*

Local aArea := GetArea()

U_PUTSX1(cPerg,"01","Data De    ?","","","mv_ch1","D",08                      ,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","",""  ,"")
U_PUTSX1(cPerg,"02","Data  Ate   ?","","","mv_ch2","D",08                      ,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","",""  ,"")
U_PUTSX1(cPerg,"03","Matricula De:","","","mv_ch3","C",TamSx3("RA_MAT")[1]   ,0,0,"G","","SRA","","","mv_par03"," "," "," ",""," "," "," "," "," "," "," "," "," ","","","")
U_PUTSX1(cPerg,"04","Matricula Ate:","","","mv_ch4","C",TamSx3("RA_MAT")[1]   ,0,0,"G","","SRA","","","mv_par04"," "," "," ",""," "," "," "," "," "," "," "," "," ","","","")
U_PUTSX1(cPerg,"05","Considera Demitidos?","","","mv_ch5","N",01,0,1,"C","","","","","mv_par05","Sim","Sim","Sim","","Não","Não","Não","","","","","","","","","")
RestArea(aArea)
Return  
