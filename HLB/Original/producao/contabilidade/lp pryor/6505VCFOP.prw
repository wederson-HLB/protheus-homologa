#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

User Function 6505VCFOP()        // incluido pelo assistente de conversao do AP5 IDE em 14/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALRESULT,")

lEasy     := SuperGetMV("MV_EASY") == "S"

_valResult:=0

_cCFOP1 :=  "1151/2151/1152/2152/1911/2911/3911/1912/2912/1917/2917/1949/2949/1910/2910"//3101/3102
             
_cCFOP2 :=  "1351/1352/1353/2351/2352/2353/1933/2933"//1253/1556/1303/1407"           

_cCFOP3 :=  "3101/3102"           

_cCFOP4 :=  "1351/1352/1353/2351/2352/2353"     

_cCFOP5 :=  "1913"   // EUROSILICONE

//If !lEasy             
//MSM - 13/01/2012 -comentado pois existe um novo cliente com o código 2V, e a perstorp teste(2V) não existe mais, chamado:002424
If SM0->M0_CODIGO $ 'UY' .AND. SD1->D1_TES $ '1E7'     //JSS - 17/10/2013 Solicitado via E-mail.
	_valResult:= 0

Else	   
	//WFA - 25/04/2019 - Inclusão da empresa ROGAMA (J2). Ticket: #10168.
	If SM0->M0_CODIGO $ 'A6|J2'
	   
	   If EMPTY(SD1->D1_CONHEC) .and.  SF4->F4_DUPLIC $ 'N'
	
	      IF ALLTRIM(SD1->D1_CF) $ (_cCFOP1+_cCFOP3+_cCFOP4)//.And. SF4->F4_LFICM $ "T" 
		     _valResult:=(SD1->D1_VALICM+SD1->D1_VALIPI+SD1->D1_VALIMP5+SD1->D1_VALIMP6)
	  
	      ELSE
	         _valResult:=0
	      EndIf	
	   ENDIF
	   
	Else
	
	   If EMPTY(SD1->D1_CONHEC)
	
	      IF ALLTRIM(SD1->D1_CF) $ (_cCFOP1).And. SF4->F4_LFICM $ "T" .or. ALLTRIM(SD1->D1_CF) $ (_cCFOP3)
		     _valResult:=(SD1->D1_VALICM+SD1->D1_VALIPI+SD1->D1_VALIMP5+SD1->D1_VALIMP6)
		
	      ELSEIF Alltrim(SD1->D1_CF) $ (_cCFOP2) .And. SF4->F4_LFICM $ "T" .AND. SF4->F4_CREDICM $ 'N'  .AND.  SF4->F4_DUPLIC $ 'N'
	         _valResult:=(SD1->D1_VALICM) 
	       
	      ELSEIF Alltrim(SD1->D1_CF) $ (_cCFOP4) .And. SF4->F4_LFICM $ "I" .AND. SF4->F4_CREDICM $ 'N'  .AND.  SF4->F4_DUPLIC $ 'N' .AND.  SF4->F4_PISCOF $ '3'
	         _valResult:=(SD1->D1_VALIMP5+SD1->D1_VALIMP6)	
	    
	      ELSEIF Alltrim(SD1->D1_CF) $ (_cCFOP5) 
	         _valResult:=(SD1->D1_VALICM)	    
	      
	      ELSE
	         _valResult:=0
	      EndIf	
	   
	   ENDIF
	   
	EndIf
	EndIf

Return(_valResult)
