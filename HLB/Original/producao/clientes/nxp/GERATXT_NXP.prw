#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "rwmake.ch"
#Include "colors.ch"
#Include "pryor.ch"
#include "Fileio.ch"
                         

/*
Funcao      : GeraTXT_NXP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar arquivo do RH
Autor     	: 
Data     	: 
Obs         :
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Gestão Pessoal.
*/

*--------------------------
User Function GeraTXT_NXP()
*--------------------------
  
Local oMarkPrd        
Local aStruSRV := {}                                     
Local lInverte := .F.
local cMarca := GetMark()
Local aCpos := {}     
Local aStruSRV := {} 
Private nSISPREV   	          
Private dPeriodoDe:=dPeriodoAte:=CTOD("")                         
Public cVerba := ""          


AADD(aStruSRV, {"cINTEGRA","C",2})    
AADD(aStruSRV, {"RV_COD","C",3})
AADD(aStruSRV, {"RV_DESC","C",20})
cNome := CriaTrab(aStruSRV, .T.)                   
DbUseArea(.T.,,cNome,'wrkSRV',.F.,.F.)       

While !SRV->(Eof())
   RecLock("wrkSRV",.T.)		    
   wrkSRV->RV_COD   := SRV->RV_COD 
   wrkSRV->RV_DESC  := SRV->RV_DESC
   wrkSRV->(msunlock())
   SRV->(DbSkip())
End Do   

AADD(aCpos,{"cINTEGRA","",})
AADD(aCpos,{"RV_COD","","Codigo"})
AADD(aCpos,{"RV_DESC","","Descricao"})   

wrkSRV->(DbGoTop())

@ 200,001 To 480,480 Dialog oLeTxt Title "Geracao de Arquivos - Previdencia"
@ 015,005 Say "Periodo De: " COLOR CLR_HRED, CLR_WHITE
@ 030,005 Say "Periodo Ate: " COLOR CLR_HRED, CLR_WHITE
@ 045,005 Say "Verba: " COLOR CLR_HRED, CLR_WHITE
@ 014,40 Get dPeriodoDe Size 36,6
@ 029,40 Get dPeriodoAte Size 36,6 

oMarkPrd:= MsSelect():New("wrkSRV","cINTEGRA",,aCpos,@lInverte,@cMarca,{45,40,120,220})
@ 130,160 BmpButton Type 01 Action fGera_Arq()
@ 130,195 BmpButton Type 02 Action Close(oLeTxt)

Activate Dialog oLeTxt Centered

Return


*--------------------------
Static Function fGera_Arq()
*--------------------------
   
   ValidaVerba()  
   PERPHIL()
   SISPREV()
   SISPRV_MOV()  
   MOVPER()                              
   
   
Return
           

*----------------------------
Static Function ValidaVerba()
*----------------------------  

cVerba := ""         
wrkSRV->(DbGoTop())

While !wrkSRV->(Eof())  
   If (AllTrim(wrkSRV->cINTEGRA) <> "")
      cVerba := cVerba + wrkSRV->RV_COD + "/"
   End If   
   wrkSRV->(DbSkip())
End Do

Return


*--------------------------
Static Function PERPHIL()
*-------------------------- 
Local cLin  
Local nCont   
Local cEOL := CHR(13)+CHR(10)       
   
   nSISPREV:= fCreate("C:\PERPHIL_CAD.TXT")
   
   //Registro Tipo 0
   DbSelectArea("SM0")       
   cLin := Space(410)+cEOL
   cLin := Stuff(cLin,001,07, "0CADAST")  
   cLin := Stuff(cLin,008,05, "00001")      
   cLin := Stuff(cLin,013,08, AllTrim(StrZero(Day(dDataBase), 2) + StrZero(Month(dDataBase), 2) + StrZero(Year(dDataBase), 4)))
   
   fWrite(nSISPREV,cLin,Len(cLin))                                 	
   
   //Registro Tipo 1
   DbSelectArea("SRA") 
   DbSetOrder(1)
   SRA->(DbGoTop()) 
   
   nCont := 0
   While !SRA->(Eof())     
       cLin := Space(410)+cEOL
	   cLin := Stuff(cLin,001,01, "1")   
	   cLin := Stuff(cLin,002,02, "A")    
	   cLin := Stuff(cLin,003,09, AllTrim(SRA->RA_CHAPA))       
	   cLin := Stuff(cLin,010,02, "01")  
	   cLin := Stuff(cLin,012,40, Substr(SRA->RA_NOME, 1, 40)) 
	   cLin := Stuff(cLin,052,03, "NXP")
	   cLin := Stuff(cLin,055,02, "23" )
	   cLin := Stuff(cLin,058,02, "23")
	   cLin := Stuff(cLin,061,02, "0001")
	   cLin := Stuff(cLin,065,04, "0001")  
	   cLin := Stuff(cLin,069,40, Substr(SRA->RA_ENDEREC, 1, 40))
	   cLin := Stuff(cLin,109,05, "00000")
	   cLin := Stuff(cLin,114,20, Substr(SRA->RA_COMPLEM, 1, 20))
	   cLin := Stuff(cLin,139,20, Substr(SRA->RA_BAIRRO, 1, 20))
	   cLin := Stuff(cLin,154,20, Substr(SRA->RA_MUNICIP, 1, 20))
	   cLin := Stuff(cLin,174,02, Substr(SRA->RA_ESTADO, 1, 2))
	   cLin := Stuff(cLin,176,08, Substr(SRA->RA_CEP, 1, 8))  
	   cLin := Stuff(cLin,184,04, "    ")
	   cLin := Stuff(cLin,188,08, Substr(SRA->RA_TELEFON, 1, 8))
	   cLin := Stuff(cLin,196,08, AllTrim(StrZero(Year(SRA->RA_NASC), 4) + StrZero(Month(SRA->RA_NASC), 2) + StrZero(Day(SRA->RA_NASC), 2)))
	   cLin := Stuff(cLin,204,01, SRA->RA_SEXO)	   
	   cLin := Stuff(cLin,205,01, SRA->RA_ESTCIVI)	
	   cLin := Stuff(cLin,209,15, Substr(SRA->RA_RG, 1, 15))
	   cLin := Stuff(cLin,221,05, Substr(SRA->RA_RGORG, 1, 05))
	   cLin := Stuff(cLin,226,02, Substr(SRA->RA_RGUF, 1, 05)) 
	   cLin := Stuff(cLin,228,15, AllTrim(StrZero(Year(SRA->RA_DTRGEXP), 4) + StrZero(Month(SRA->RA_DTRGEXP), 2) + StrZero(Day(SRA->RA_DTRGEXP), 2)))
	   cLin := Stuff(cLin,236,11, Substr(SRA->RA_PIS, 1, 11)) 
	   cLin := Stuff(cLin,247,11, Substr(SRA->RA_CIC, 1, 11)) 
	   cLin := Stuff(cLin,258,15, AllTrim(StrZero(Year(SRA->RA_ADMISSA), 4) + StrZero(Month(SRA->RA_ADMISSA), 2) + StrZero(Day(SRA->RA_ADMISSA), 2)))
	   cLin := Stuff(cLin,266,03, Substr(SRA->RA_BCDEPSA, 1, 3)) 
	   cLin := Stuff(cLin,266,03, Substr(SRA->RA_BCDEPSA, 4, 4))  
	   cLin := Stuff(cLin,275,04, Substr(SRA->RA_CTDEPSA, 1, 10))  
	   cLin := Stuff(cLin,285,02, "  ")
	   cLin := Stuff(cLin,287,03, "          ")  
	   cLin := Stuff(cLin,289,04, "    ")
	   cLin := Stuff(cLin,297,01, "M")
	   cLin := Stuff(cLin,299,12, Strzero(SRA->RA_SALARIO, 12))     
	   cLin := Stuff(cLin,312,02, " ")
       cLin := Stuff(cLin,315,08, "        ")
       SRA->(DbSkip()) 
       nCont := nCont + 1   
       fWrite(nSISPREV,cLin,Len(cLin))  
   End Do	     
	   
   //Registro Tipo 9 
   cLin := Space(410)+cEOL
   cLin := Stuff(cLin,001,07, "9CADAST")
   cLin := Stuff(cLin,008,05, Strzero(nCont, 5))
   cLin := Stuff(cLin,013,12, Strzero(nCont, 12)) 
   cLin := Stuff(cLin,026,08, AllTrim(StrZero(Year(dDataBase), 4) + StrZero(Month(dDataBase), 2) + StrZero(Day(dDataBase), 2)))     
   
   fWrite(nSISPREV,cLin,Len(cLin))  
      
   fClose(nSISPREV)
       
Return               
                     

*--------------------------
Static Function SISPREV()
*-------------------------- 
Local cLin  
Local nCont   
Local cEOL := CHR(13)+CHR(10)       
   
   nSISPREV:= fCreate("C:\SISPREV.TXT")
   
   //Registro Tipo 0
   DbSelectArea("SM0")       
   cLin := Space(516)+cEOL
   cLin := Stuff(cLin,001,08, Substr(SM0->M0_CGC, 1, 8))  
   cLin := Stuff(cLin,009,04, "0CAD")   
   cLin := Stuff(cLin,013,06, Alltrim(Str(Year(dDataBase))+StrZero(Month(dDataBase), 2)))
   cLin := Stuff(cLin,019,08, AllTrim(StrZero(Year(dDataBase), 4) + StrZero(Month(dDataBase), 2) + StrZero(Day(dDataBase), 2)))
   
   fWrite(nSISPREV,cLin,Len(cLin)) 
   
   DbSelectArea("SRJ") 
   DbSetOrder(1)
   
   DbSelectArea("SX5") 
   DbSetOrder(1)
   
   //Registro Tipo 1
   DbSelectArea("SRA") 
   DbSetOrder(1)
   SRA->(DbGoTop()) 
   
   nCont := 0
   While !SRA->(Eof())     
       cLin := Space(60)+cEOL
	   cLin := Stuff(cLin,001,08, Substr(SM0->M0_CGC, 1, 8))   
	   cLin := Stuff(cLin,009,01, "1")    
	   cLin := Stuff(cLin,010,11, AllTrim(SRA->RA_CIC))       
	   cLin := Stuff(cLin,021,01, "A")
	   cLin := Stuff(cLin,022,10, SRA->RA_P_CODOR) //CODIGO ORGANIZACIONAL
	   cLin := Stuff(cLin,032,10, SRA->RA_P_MATRC)   
	   cLin := Stuff(cLin,042,30, Substr(SRA->RA_NOME, 1, 30)) 
	   cLin := Stuff(cLin,072,10, SPACE(10))   
	   cLin := Stuff(cLin,082,30, SRA->RA_ENDEREC)
   	   cLin := Stuff(cLin,112,10, SPACE(10))
	   cLin := Stuff(cLin,122,05, "00000")
	   cLin := Stuff(cLin,127,15, SRA->RA_COMPLEM)
	   cLin := Stuff(cLin,142,05, SPACE(5))
	   cLin := Stuff(cLin,147,15, SRA->RA_BAIRRO)
	   cLin := Stuff(cLin,162,05, SPACE(5))
	   cLin := Stuff(cLin,167,20, SRA->RA_MUNICIP)
	   cLin := Stuff(cLin,187,02, Substr(SRA->RA_ESTADO, 1, 2))
	   cLin := Stuff(cLin,189,08, Substr(SRA->RA_CEP, 1, 8))  
	   cLin := Stuff(cLin,197,04, SRA->RA_P_DDD)
	   cLin := Stuff(cLin,201,08, Substr(SRA->RA_TELEFON, 1, 8))
	   cLin := Stuff(cLin,209,08, AllTrim(StrZero(Year(SRA->RA_NASC), 4) + StrZero(Month(SRA->RA_NASC), 2) + StrZero(Day(SRA->RA_NASC), 2)))
	   cLin := Stuff(cLin,217,01, SRA->RA_SEXO)	   
	   cLin := Stuff(cLin,218,01, SRA->RA_ESTCIVI)	
	   cLin := Stuff(cLin,219,15, Substr(SRA->RA_RG, 1, 15))
	   cLin := Stuff(cLin,234,03, SRA->RA_RGORG)
	   cLin := Stuff(cLin,237,02, SPACE(2))
	   cLin := Stuff(cLin,239,02, Substr(SRA->RA_RGUF, 1, 05)) 
	   cLin := Stuff(cLin,241,15, AllTrim(StrZero(Year(SRA->RA_ADMISSA), 4) + StrZero(Month(SRA->RA_ADMISSA), 2) + StrZero(Day(SRA->RA_ADMISSA), 2)))
	   cLin := Stuff(cLin,249,02, Substr(SRA->RA_CODFUNC, 3, 2)) //agrupamento funcao  
	   If SRJ->(Dbseek(xFilial("SRJ")+SRA->RA_CODFUNC))
	      cLin := Stuff(cLin,251,20, SRJ->RJ_DESC) //descr cargo 
  	      cLin := Stuff(cLin,271,20, SPACE(20)) 
	   Else
	      cLin := Stuff(cLin,251,40,SPACE(40)) //descr cargo
	   EndIf   
       cLin := Stuff(cLin,291,01, Alltrim(Str(SRA->RA_P_SITFU))) //Código da Situação Funcional 
       cLin := Stuff(cLin,292,08, AllTrim(StrZero(Year(SRA->RA_P_DTSFU), 4) + StrZero(Month(SRA->RA_P_DTSFU), 2) + StrZero(Day(SRA->RA_P_DTSFU), 2))) //Data da Situação Funcional ==> (AAAAMMDD)
       cLin := Stuff(cLin,300,01, SRA->RA_P_INDAD) //Indicador de Afastamento por Doença ou Reclusão 
       cLin := Stuff(cLin,301,01, SRA->RA_P_INDRE) //Indicador de Afastamento Remunerado
       cLin := Stuff(cLin,302,01, SRA->RA_P_CSPSS) //Condição de Sócio da PSS
       cLin := Stuff(cLin,303,01, SRA->RA_P_PLPSS)                 
       cLin := Stuff(cLin,304,08, AllTrim(StrZero(Year(SRA->RA_P_DTADP), 4) + StrZero(Month(SRA->RA_P_DTADP), 2) + StrZero(Day(SRA->RA_P_DTADP), 2)))
       cLin := Stuff(cLin,312,03, Str(SRA->RA_P_BCOIN)) //Banco de Investimento no Plano C  (Opção)
       cLin := Stuff(cLin,315,01, SRA->RA_P_PERIN) //Perfil de Investimento
       cLin := Stuff(cLin,316,01, Str(SRA->RA_P_CONBA)) //Percentual de Contribuicao Basica no Plano C
       cLin := Stuff(cLin,317,02, Str(SRA->RA_P_PEREX)) //Percentual de Contribuicao Extraordinaria no Plano C
       cLin := Stuff(cLin,319,08, AllTrim(StrZero(Year(SRA->RA_P_DTVIG), 4) + StrZero(Month(SRA->RA_P_DTVIG), 2) + StrZero(Day(SRA->RA_P_DTVIG), 2)))
       cLin := Stuff(cLin,327,01, SRA->RA_P_INDIR)
       cLin := Stuff(cLin,328,08, AllTrim(StrZero(Year(SRA->RA_P_VIGIR), 4) + StrZero(Month(SRA->RA_P_VIGIR), 2) + StrZero(Day(SRA->RA_P_VIGIR), 2)))  
       cLin := Stuff(cLin,336,08, AllTrim(StrZero(Year(SRA->RA_DTRGEXP), 4) + StrZero(Month(SRA->RA_DTRGEXP), 2) + StrZero(Day(SRA->RA_DTRGEXP), 2)))
       If !Empty(SRA->RA_NACIONA)
          If SX5->(DbSeek(xFilial("SX5")+'34'+SRA->RA_NACIONA))
             cLin := Stuff(cLin,344,30, Substr(SX5->X5_DESCRI,1,30))    
          Else
             cLin := Stuff(cLin,344,30, 'BRASILEIRO                    ') 
          EndIf
       
       Else
          cLin := Stuff(cLin,344,30,SPACE(30))    
       EndIf
       cLin := Stuff(cLin,374,20, SUBSTR(SRA->RA_MUNNASC,1,20)) 
       cLin := Stuff(cLin,394,02, SRA->RA_NATURAL)
       cLin := Stuff(cLin,396,40, SRA->RA_PAI)
       cLin := Stuff(cLin,436,40, SRA->RA_MAE)     
       cLin := Stuff(cLin,476,40, SRA->RA_P_CONJU)
       cLin := Stuff(cLin,516,01, SRA->RA_P_INDPE)
       If !Empty(SRA->RA_EMAIL)
          cLin := Stuff(cLin,517,50, SRA->RA_EMAIL)       
       Else
          cLin := Stuff(cLin,517,50,SPACE(50))
       EndIf
       cLin := Stuff(cLin,567,40,SPACE(40))+cEOL
       SRA->(DbSkip()) 
       nCont := nCont + 1                         
       fWrite(nSISPREV,cLin,Len(cLin))  
   End Do	     
	   
   //Registro Tipo 9 
   cLin := Space(516)+cEOL
   cLin := Stuff(cLin,001,08, Substr(SM0->M0_CGC, 1, 8))
   cLin := Stuff(cLin,009,01, "9") 
   cLin := Stuff(cLin,010,05, Strzero(nCont, 5))
   cLin := Stuff(cLin,015,01, Strzero(nCont, 18))  
   
   fWrite(nSISPREV,cLin,Len(cLin))  
      
   fClose(nSISPREV)
       
Return               


*--------------------------
Static Function SISPRV_MOV()
*-------------------------- 
Local cLin, cControle  
Local nCont, nSoma
Local cEOL := CHR(13)+CHR(10)       
   
   nSISPRV_MOV:= fCreate("C:\SISPREVMOV.TXT")
   
   //Registro Tipo 0
   DbSelectArea("SM0")       
   cLin := Space(50)+cEOL
   cLin := Stuff(cLin,001,08, Substr(SM0->M0_CGC, 1, 8))  
   cLin := Stuff(cLin,009,04, "0MOV")   
   cLin := Stuff(cLin,013,06, Alltrim(Str(Year(dDataBase))+StrZero(Month(dDataBase), 2)))
   cLin := Stuff(cLin,019,08, AllTrim(StrZero(Year(dDataBase), 4) + StrZero(Month(dDataBase), 2) + StrZero(Day(dDataBase), 2)))
   
   fWrite(nSISPRV_MOV,cLin,Len(cLin)) 
   
   //Registro Tipo 1
   DbSelectArea("SRA") 
   DbSetOrder(1)
   SRA->(DbGoTop()) 
   
   nCont := 0    
   nSoma := 0   

   SRC->(DbSetOrder(1))
   While !SRA->(Eof())     
       cLin := Space(50)+cEOL
	   cLin := Stuff(cLin,001,08, Substr(SM0->M0_CGC, 1, 8))   
	   cLin := Stuff(cLin,009,01, "1") 	   
	                                                  
	   SRC->(DbSeek(xFilial("SRC")+SRA->RA_MAT)) 	  
	   
	   While SRC->RC_MAT == SRA->RA_MAT 
	       cControle := "N"
	       If (SRC->RC_DATA >= dPeriodoDe) .And. (SRC->RC_DATA <= dPeriodoAte) .And. (SRC->RC_PD $ cVerba)
	     	   cLin := Stuff(cLin,010,11, AllTrim(SRA->RA_CIC))       
			   cLin := Stuff(cLin,021,03, SRC->RC_PD) 
			   cLin := Stuff(cLin,024,16, StrTran(Strzero(SRC->RC_VALOR, 16,2), ".", "")) 
			   cLin := Stuff(cLin,039,13, StrTran(Strzero(SRC->RC_HORAS, 9,2), ".", "") + "0000")+cEOL	   
		       nCont := nCont + 1
		       cControle := "S"
		       nSoma := nSoma + SRC->RC_VALOR 
	       End If     
       	   SRC->(DbSkip())  
       	   If cControle == "S"	   
               fWrite(nSISPRV_MOV,cLin,Len(cLin))  
           End If   
       End Do
       SRA->(DbSkip())
       
   End Do	     
	   
   //Registro Tipo 9 
   cLin := Space(50)+cEOL
   cLin := Stuff(cLin,001,08, Substr(SM0->M0_CGC, 1, 8))
   cLin := Stuff(cLin,009,01, "9") 
   cLin := Stuff(cLin,010,05, Strzero(nCont, 5))
   cLin := Stuff(cLin,015,18, StrTran(Strzero(nSoma, 19, 2), ".", ""))     
   
   fWrite(nSISPRV_MOV,cLin,Len(cLin))  
      
   fClose(nSISPRV_MOV)
       
Return


*--------------------------
Static Function MOVPER()
*-------------------------- 
Local cLin, cControle  
Local nCont, nSoma
Local cEOL := CHR(13)+CHR(10)       
   
   nSISPRV_MOV:= fCreate("C:\SISP_MOVPER.TXT")
   
   //Registro Tipo 0
   DbSelectArea("SM0")       
   cLin := Space(47)+cEOL
   cLin := Stuff(cLin,001,07, "0ENVMOV")  
   cLin := Stuff(cLin,008,05, "00001")      
   cLin := Stuff(cLin,013,08, AllTrim(StrZero(Day(dDataBase), 2) + StrZero(Month(dDataBase), 2) + StrZero(Year(dDataBase), 4)))
   
   fWrite(nSISPRV_MOV,cLin,Len(cLin)) 
   
   //Registro Tipo 1
   DbSelectArea("SRA") 
   DbSetOrder(1)
   SRA->(DbGoTop()) 
   
   nCont := 0    
   nSoma := 0   

   SRC->(DbSetOrder(1))
   While !SRA->(Eof())     
      
      SRC->(DbSeek(xFilial("SRC")+SRA->RA_MAT))  	  
	   
	   While SRC->RC_MAT == SRA->RA_MAT                                           	
	       cControle := "N"
	       If (SRC->RC_DATA >= dPeriodoDe) .And. (SRC->RC_DATA <= dPeriodoAte) .And. (SRC->RC_PD $ cVerba)
	           cLin := Space(47)    
               cLin := Stuff(cLin,001,02, "10") 
	           cLin := Stuff(cLin,003,07, SRA->RA_P_MATRC)   	   	   	           
	     	   cLin := Stuff(cLin,009,06, AllTrim(StrZero(Year(SRC->RC_DATA), 4) + StrZero(Month(SRC->RC_DATA), 2)))
			   cLin := Stuff(cLin,015,03, SRC->RC_PD) 
			   cLin := Stuff(cLin,018,02, "FP")  
			   cLin := Stuff(cLin,020,13, StrTran(Strzero(SRC->RC_VALOR, 14,2), ".", "")) 
			   cLin := Stuff(cLin,033,15, StrTran(Strzero(SRC->RC_HORAS, 09,2), ".", "") + "0000")+cEOL 
		       nCont := nCont + 1
		       cControle := "S"
		       nSoma := nSoma + SRC->RC_VALOR 
	       End If     
       	   SRC->(DbSkip())
       	   If cControle == "S"	   
              fWrite(nSISPRV_MOV,cLin,Len(cLin))  
           End If  
       End Do
       SRA->(DbSkip())        
   End Do	     
	   
   //Registro Tipo 9 
   cLin := Space(47)+cEOL
   cLin := Stuff(cLin,001,07, "9ENVMOV")
   cLin := Stuff(cLin,008,05, Strzero(nCont, 5))
   cLin := Stuff(cLin,013,12, StrTran(Strzero(nSoma, 14, 2), ".", "")) 
   cLin := Stuff(cLin,026,08, AllTrim(StrZero(Day(dDataBase), 2) + StrZero(Month(dDataBase), 2) + StrZero(Year(dDataBase), 4)))    
   
   fWrite(nSISPRV_MOV,cLin,Len(cLin))  
      
   fClose(nSISPRV_MOV)

       
Return