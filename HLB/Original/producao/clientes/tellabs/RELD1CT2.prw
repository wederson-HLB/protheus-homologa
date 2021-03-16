#include "Protheus.ch"
#include "topconn.ch"

/*
Funcao      : RELD1CT2
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Fonte para gerar relatório dos Lançamentos Contábeis (CT2), no formato Conta | Valor | Historico | C Custo | Item Contábil
Autor       : Matheus Massarotto
Revisão 1   : Matheus - 17/02/2012 : Incluido item contábil no relatório
Data/Hora   : 31/10/11
Módulo      : Contabilidade gerencial
*/

User Function RELD1CT2
Local cPerg:="P_RELD1CT2"
/*
U_PUTSX1( cPerg, "01", "Conta Contábil de:", "Conta Contábil de:", "Conta Contábil de:", "", "C",20,00,00,"G","" , "CT1","","","MV_PAR01")
U_PUTSX1( cPerg, "02", "Conta Contábil ate:", "Conta Contábil ate:", "Conta Contábil ate:", "", "C",20,00,00,"G","" , "CT1","","","MV_PAR02")
U_PUTSX1( cPerg, "03", "Data De:", "Data De:", "Data De:", "", "D",08,00,00,"G","" , "","","","MV_PAR03")
U_PUTSX1( cPerg, "04", "Data Ate:", "Data Ate:", "Data Ate:", "", "D",08,00,00,"G","" , "","","","MV_PAR04")
*/
U_PUTSX1( cPerg, "01", "Data De:", "Data De:", "Data De:", "", "D",08,00,00,"G","" , "","","","MV_PAR01")
U_PUTSX1( cPerg, "02", "Data Ate:", "Data Ate:", "Data Ate:", "", "D",08,00,00,"G","" , "","","","MV_PAR02")

if !Pergunte(cPerg,.T.)
	Return
endif
	
	RptStatus({||Imprime()},"Processando")

Return

Static Function Imprime
Local aDadTemp:={}
Local cQry:=""

AADD(aDadTemp,{"CTA_CONTAB","C",20,0})
AADD(aDadTemp,{"VALOR","N",17,2})
AADD(aDadTemp,{"HISTORICO","C",40,0})
AADD(aDadTemp,{"C_CUSTO","C",9,0})
AADD(aDadTemp,{"COD_FUNC","C",9,0})
//AADD(aDadTemp,{"VERBA","C",6,0}) //para considerar a verba
//AADD(aDadTemp,{"C_CUSTO_C","C",9,0})

if select("D1CT2")>0
	D1CT2->(DbCloseArea())
endif

cNome := CriaTrab(aDadTemp,.t.)
dbUseArea(.T.,,cNome,"D1CT2",.F.,.F.)
 
cIndex:=CriaTrab(Nil,.F.)
IndRegua("D1CT2",cIndex,"CTA_CONTAB",,,"Selecionando Registro...")

DbSelectArea("D1CT2")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

//CT1_P_CONT
/*
cQry+=" SELECT R_E_C_N_O_,"+CRLF
cQry+=" CASE WHEN CT2_DEBITO<>'' THEN CT2_DEBITO ELSE CT2_CREDIT END  AS CONTA"+CRLF
cQry+=" ,CASE WHEN CT2_DEBITO<>'' THEN CT2_VALOR ELSE -CT2_VALOR END AS VALOR"+CRLF
cQry+=" ,CT2_HIST"+CRLF
cQry+=" ,CASE WHEN CT2_CCC <> '' THEN CT2_CCC ELSE CT2_CCD END AS CT2_CC"+CRLF
cQry+=" FROM "+RETSQLNAME("CT2")+CRLF
cQry+=" WHERE D_E_L_E_T_='' AND CT2_MOEDLC='01' AND CT2_DC IN ('1','2')"+CRLF
cQry+=" AND CT2_DEBITO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+CRLF
cQry+=" AND CT2_CREDIT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+CRLF
cQry+=" AND CT2_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"+CRLF

cQry+=" UNION ALL"+CRLF

cQry+=" SELECT R_E_C_N_O_,CT2_DEBITO,CT2_VALOR,CT2_HIST,CT2_CCD AS CT2_CC FROM "+RETSQLNAME("CT2")+CRLF
cQry+=" WHERE D_E_L_E_T_='' AND CT2_MOEDLC='01' AND CT2_DC='3'"+CRLF
cQry+=" AND CT2_DEBITO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+CRLF
cQry+="  AND CT2_CREDIT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+CRLF
cQry+=" AND CT2_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"+CRLF
cQry+=" UNION ALL"+CRLF
cQry+=" SELECT R_E_C_N_O_,CT2_CREDIT,-CT2_VALOR,CT2_HIST,CT2_CCC AS CT2_CC FROM "+RETSQLNAME("CT2")+CRLF
cQry+=" WHERE D_E_L_E_T_='' AND CT2_MOEDLC='01' AND CT2_DC='3'"+CRLF
cQry+=" AND CT2_DEBITO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+CRLF
cQry+=" AND CT2_CREDIT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+CRLF
cQry+=" AND CT2_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"+CRLF
cQry+=" ORDER BY R_E_C_N_O_"
*/
//não coloquei a filial pois o ct2 está exclusivo e o ct1 compartilhado
cQry+=" SELECT CT2.R_E_C_N_O_,"+CRLF
cQry+=" CASE WHEN CT2_DEBITO<>'' THEN (CASE WHEN CT1_P_CONT<>'' THEN CT1_P_CONT ELSE CT2_DEBITO END) ELSE (CASE WHEN CT1_P_CONT<>'' THEN CT1_P_CONT ELSE CT2_CREDIT END) END  AS CONTA"+CRLF
cQry+=" ,CASE WHEN CT2_DEBITO<>'' THEN CT2_VALOR ELSE -CT2_VALOR END AS VALOR"+CRLF
cQry+=" ,CT2_HIST"+CRLF
cQry+=" ,CASE WHEN CT2_CCC <> '' THEN CT2_CCC ELSE CT2_CCD END AS CT2_CC"+CRLF
cQry+=" ,CASE WHEN CT2_ITEMD <> '' THEN CT2_ITEMD ELSE CT2_ITEMC END AS CT2_ITEM"+CRLF
//cQry+=" ,SUBSTRING(CT2_ORIGEM,1,3) AS VERBA"+CRLF //para considerar a verba
cQry+=" FROM "+RETSQLNAME("CT2")+" CT2"+CRLF 
cQry+=" JOIN "+RETSQLNAME("CT1")+" CT1 ON CT1_CONTA =  CASE WHEN CT2_DEBITO<>'' THEN CT2_DEBITO ELSE CT2_CREDIT END"+CRLF
cQry+=" WHERE CT2.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' AND CT2_MOEDLC='01' AND CT2_DC IN ('1','2')"+CRLF
cQry+=" AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF

cQry+=" UNION ALL"+CRLF

cQry+=" SELECT CT2.R_E_C_N_O_,CASE WHEN CT1_P_CONT<>'' THEN CT1_P_CONT ELSE CT2_DEBITO END,CT2_VALOR,CT2_HIST,CT2_CCD AS CT2_CC, CT2_ITEMD AS CT2_ITEM "+CRLF //,SUBSTRING(CT2_ORIGEM,1,3) AS VERBA
cQry+=" FROM "+RETSQLNAME("CT2")+" CT2"+CRLF
cQry+=" JOIN "+RETSQLNAME("CT1")+" CT1 ON CT1_CONTA =  CASE WHEN CT2_DEBITO<>'' THEN CT2_DEBITO ELSE CT2_CREDIT END"+CRLF
cQry+=" WHERE CT2.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' AND CT2_MOEDLC='01' AND CT2_DC='3'"+CRLF
cQry+=" AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQry+=" UNION ALL"+CRLF
cQry+=" SELECT CT2.R_E_C_N_O_,CASE WHEN CT1_P_CONT<>'' THEN CT1_P_CONT ELSE CT2_CREDIT END,-CT2_VALOR,CT2_HIST,CT2_CCC AS CT2_CC, CT2_ITEMC AS CT2_ITEM"+CRLF //,SUBSTRING(CT2_ORIGEM,1,3) AS VERBA 
cQry+=" FROM "+RETSQLNAME("CT2")+" CT2"+CRLF
cQry+=" JOIN "+RETSQLNAME("CT1")+" CT1 ON CT1_CONTA =  CASE WHEN CT2_DEBITO<>'' THEN CT2_DEBITO ELSE CT2_CREDIT END "+CRLF
cQry+=" WHERE CT2.D_E_L_E_T_='' AND CT1.D_E_L_E_T_='' AND CT2_MOEDLC='01' AND CT2_DC='3'"+CRLF
cQry+=" AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQry+=" ORDER BY R_E_C_N_O_"+CRLF

if select("TRBD1CT2")>0
	TRBD1CT2->(DbCloseArea())
endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBD1CT2",.T.,.T.)   

COUNT to nRecCount

if nRecCount>0

TRBD1CT2->(DbGoTop())	

	While TRBD1CT2->(!eof())
		RecLock("D1CT2",.T.)
			D1CT2->CTA_CONTAB:=TRBD1CT2->CONTA
			D1CT2->VALOR:=TRBD1CT2->VALOR
			D1CT2->HISTORICO:=TRBD1CT2->CT2_HIST
			D1CT2->C_CUSTO:=TRBD1CT2->CT2_CC
			D1CT2->COD_FUNC:=TRBD1CT2->CT2_ITEM
//			D1CT2->VERBA:=TRBD1CT2->VERBA //para considerar a verba
			//D1CT2->C_CUSTO_D:=TRBD1CT2->CT2_CCC
			//D1CT2->C_CUSTO_C:=TRBD1CT2->CT2_CCD
		D1CT2->(MsUnlock())
		TRBD1CT2->(DbSkip())	
	enddo
	
else
	alert("Não há registros com os parâmetros informados!")
	return
endif

D1CT2->(DbCloseArea())

If !ApOleClient("MsExcel")
     MsgStop("Microsoft Excel nao instalado.")
     Return
EndIf 
	
	cArqOrig := "\"+CURDIR()+cNome+".DBF"
   	cPath     := AllTrim(GetTempPath())                                                   

	CpyS2T( cArqOrig , cPath, .T. )
       
    oExcelApp:=MsExcel():New()
    oExcelApp:WorkBooks:Open(cPath+cNome+".DBF")  
    oExcelApp:SetVisible(.T.)   
    
//	Alert("Arquivo gerado com sucesso!")  

sleep(05)	


Erase &cNome+".DBF"            


Return
