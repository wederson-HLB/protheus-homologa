#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ R7FAT003 บ Autor ณ Ewerton Vicentin บ Data ณ  22/12/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controle de numera็ใo dos pedidos de venda da Shiseido.	  บฑฑ
ฑฑบ          ณ Retorna o ๚ltimo n๚mero para o portal.					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MPx                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function R7FAT003()
                  
Local cNum   := ""
Local cQuery := ""
            
cQuery := "SELECT (Case when right(convert(varchar, replicate('0', 6) + convert(varchar(6),MAX(C5_NUM)+1 )), 6) = '091234' THEN '091235' "
cQuery += "Else right(convert(varchar, replicate('0', 6) + convert(varchar(6),MAX(C5_NUM)+1 )), 6) End) AS C5_NUM "
cQuery += "FROM " + RetSQLName("SC5") 
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND C5_FILIAL = '01' "
cQuery += "AND Substring(C5_NUM,1,1) NOT IN ('A','B','C','X','T','Z','S','#','*','D','.') "
cQuery += "AND C5_NUM NOT IN ('091234') "
cQuery += "AND R_E_C_N_O_ > 90000"
            
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "SC5QRY", .F., .F.)

If !SC5QRY->(EOF())
	cNum := SC5QRY->C5_NUM
EndIf
SC5QRY->(dbCloseArea())

Return(cNum)