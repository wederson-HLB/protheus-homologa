#include "rwmake.ch"            
#include "colors.ch"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � MT100AGR � Autor � HAMILTON               � Data �          ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao � Ponto de Entrada Apos Geracao de Notas Fiscais Entrada      ���
���          � fora da Transacao (para conter tela, segundo Quark)         ���
���			   Editado em 05/2004 - Francisco   							��   
���            Editado em 06/2007 - Jos� Augusto Pereira Alves             ���
��������������������������������������������������������������������������Ĵ��
���Uso       �                                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������/*/ 

/*
Funcao      : MT100AGR
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. apos Geracao de Notas Fiscais Entrada
Autor       : HAMILTON 
Data/Hora   :   	
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 13/07/2012
Obs         : 
M�dulo      : Compras.
Cliente     : Todos
*/
                   
*------------------------*
 User Function MT100AGR()      
*------------------------*


Local   oMemo 
Private cMemo:= ""      
Private oDlg    

nLiqui  :=nBruto:=nQuant:=0
cEspeci:=cMarca:=cPlaca:=space(15)
cMENEND :=space(129)
pTransp :=space(6)   
       
/*//Espec�fico Sumitomo - Jos� Augusto Pereira Alves - 21/06/07    

If cEmpAnt $ "FF"

   If INCLUI .OR. ALTERA
        
      @ 0,0 TO 445,460 DIALOG oDlg TITLE "Informacoes Complementares NFE Sumitomo"
		@ 05,10 TO 180,220    
		
		@ 20,015 		SAY "Quantidade"
		@ 35,015   		SAY "Especie"
		@ 50,015  		SAY "Peso Bruto"
		@ 65,015   		SAY "Peso Liquido"    
		@ 80,015     	SAY "Transportadora"    
		@ 95,011     	SAY "_____________________________________________________________________"
		@ 107,012     	SAY "Dados Adicionais:" COLOR CLR_HBLUE, CLR_WHITE 
		@ 107,063      SAY "(M�ximo 700 Caracteres)"  COLOR CLR_HRED, CLR_WHITE   
		
		@ 20,60 GET nQuant  PICTURE "@E 99,999.99" 	size 60,150
		@ 35,60 GET cEspeci                        	size 60,150
		@ 50,60 GET nBruto  PICTURE "@E 999,999.99" 	size 60,150
		@ 65,60 GET nLiqui  PICTURE "@E 999,999.99" 	size 60,150    
		@ 80,60 GET pTransp F3 "SA4"				    	size 60,150       
		
		oMemo:= tMultiget():New(115,12,{|u|if(Pcount()>0,cMemo:=u,cMemo)},oDlg,205,60,,,,,,.T.) 
		
		@ 180 ,190 BMPBUTTON TYPE 01 ACTION VerLinhaMemo(cMemo)
		@ 195 ,190 BMPBUTTON TYPE 02 ACTION Close(oDlg)
		
		ACTIVATE DIALOG oDlg  CENTERED                       
   
   EndIf	   

EndIf
*/     
// comentado o prg que s� era utilizado pela Sumitomo, e agora os campos para dados adicionais encontram-se
// dentro do SD1. - FR 08/11/07

_cEMP := "B5/R3/V6/M1/70/H6/HV/HF/DW/I7"//I7/DW/EF/U6"
//R7/FF"   // Sefar/AVEBE - tratamento para solicitar pesos e volumes na hora da gravacao

// Fl�via Rocha -  25/07/07: inclu�do tb para a empresa McIntyre (H6)

IF INCLUI .OR. ALTERA   // EXECUTA SOMENTE SE FOR INCLUSAO OU ALTERACAO - EXCLUSAO NAO
	IF SM0->M0_CODIGO $ _cEMP
		
		@ 0,0 TO 260,460 DIALOG oDlg TITLE "Informa��es Complementares Nota de Entrada"
		@ 05,10 TO 130,220
		
		@ 20,015 		SAY "Quantidade"	COLOR CLR_HBLUE
		@ 35,015   		SAY "Esp�cie"		COLOR CLR_HBLUE
		@ 50,015  		SAY "Peso Bruto"	COLOR CLR_HBLUE
		@ 65,015   		SAY "Peso Liquido"	COLOR CLR_HBLUE
		IF SM0->M0_CODIGO $ "V6/U6/70/FF/HV/HF/I7/DW/"
			@ 80,015 	SAY "Transportadora"
		ENDIF
		
	    IF SM0->M0_CODIGO $ "R3"  // INICIALMENTE PARA A AVEBE
			@ 120,015 SAY "Local Entrega "		
		ENDIF  
		
		//IF SM0->M0_CODIGO $ "I7"  // INICIALMENTE PARA A AVEBE
		//	@ 095,015 SAY "Marca"  size 60,150
		//	@ 110,015 SAY "Placa "  size  60,150 		
		//ENDIF
		
		@ 20,60 GET nQuant  PICTURE "@E 99,999.99" 	size 60,150
		@ 35,60 GET cEspeci                        	size 60,150
		@ 50,60 GET nBruto  PICTURE "@E 999,999.99" 	size 60,150
		@ 65,60 GET nLiqui  PICTURE "@E 999,999.99" 	size 60,150
		
		IF SM0->M0_CODIGO $ "V6/U6/70/FF/HV/HF/I7/DW/" //RIEKE
			@ 80,60 GET pTransp F3 "SA4"					size 60,150
		ENDIF 
		
		//IF SM0->M0_CODIGO $ "I7"
		//   @ 095,60 GET cMarca	size 60,150
	    //   @ 110,60 GET cPlaca 	size 60,150
		//ENDIF
		
		IF SM0->M0_CODIGO $ "R3"  // INICIALMENTE PARA A AVEBE
			@ 117,50 GET cMENEND  picture "@S60"
		ENDIF 
		        
		
		@ 95 ,190 BMPBUTTON TYPE 01 ACTION U_MT100B5()
		@ 110,190 BMPBUTTON TYPE 02 ACTION Close(oDlg)
		
		ACTIVATE DIALOG oDlg  CENTERED            
		
	ENDIF  
	
ENDIF   

Return

*------------------------*
  USER FUNCTION MT100B5()
*------------------------*

IF SM0->M0_CODIGO $ "V6"
	reclock("SF1",.F.)
	Replace SF1->F1_PLIQUI  WITH nLiqui
	Replace SF1->F1_PBRUT   WITH nBruto
	Replace SF1->F1_PQUANT  WITH nQuant
	Replace SF1->F1_PESPECI WITH cEspeci
	Replace SF1->F1_PTRANSP WITH pTransp
/*ELSEIF SM0->M0_CODIGO $ "FF"
	reclock("SF1",.F.)
	Replace SF1->F1_PESOL    WITH nLiqui
	Replace SF1->F1_P_PESOB  WITH nBruto
	Replace SF1->F1_P_VOLUM  WITH nQuant
	Replace SF1->F1_P_ESPV   WITH cEspeci
	Replace SF1->F1_P_TRANS  WITH pTransp
	//Replace SF1->F1_DADOSA   WITH cMemo	*/
ELSEIF SM0->M0_CODIGO $ "70"
	reclock("SF1",.F.)
	Replace SF1->F1_PESOL    WITH nLiqui
    Replace SF1->F1_P_PESOB  WITH nBruto
	Replace SF1->F1_P_VOLUM  WITH nQuant
	Replace SF1->F1_P_ESPV   WITH cEspeci
    Replace SF1->F1_P_TRANS  WITH pTransp	 
ELSEIF SM0->M0_CODIGO $ "HV/HF/DW"
	reclock("SF1",.F.)
	Replace SF1->F1_P_PESOL  WITH nLiqui
	Replace SF1->F1_P_PESOB  WITH nBruto
	Replace SF1->F1_P_VOLUM  WITH nQuant
	Replace SF1->F1_P_ESPV   WITH cEspeci
	Replace SF1->F1_P_TRANS  WITH pTransp 	  
ELSEIF SM0->M0_CODIGO $ "I7"
	reclock("SF1",.F.)		
    Replace SF1->F1_PESOL      WITH nLiqui
	Replace SF1->F1_ZZTRANS    WITH pTransp
	Replace SF1->F1_ZZPBRUT    WITH nBruto
	Replace SF1->F1_ZZESPEC    WITH cEspeci
	Replace SF1->F1_ZZVOLUM    WITH nQuant
   // Replace SF1->F1_ZZMARCA    WITH cMarca
   // Replace SF1->F1_ZZPLACA    WITH cPlaca	 */
     		
ELSEIF SM0->M0_CODIGO $ "M1"	
   Reclock("SF1",.F.)
   Replace SF1->F1_P_VOLUM With nQuant
   Replace SF1->F1_P_ESPEC With cEspeci
   Replace SF1->F1_P_BRUTO With nBruto
   Replace SF1->F1_P_LIQUI With nLiqui
/*ELSEIF SM0->M0_CODIGO $ "U6"
	Reclock("SF1",.F.)
	Replace SF1->F1_PESOL  	 With nLiqui
	Replace SF1->F1_P_PESOB  With nBruto
	Replace SF1->F1_P_VOLUM  With nQuant
	Replace SF1->F1_P_ESPV   With cEspeci
	Replace SF1->F1_P_TRANS  With pTransp	*/
/*ELSEIF SM0->M0_CODIGO $ "EF"
	Reclock("SF1",.F.)
   Replace SF1->F1_P_VOLUM With nQuant
   Replace SF1->F1_P_ESPEC With cEspeci
   Replace SF1->F1_P_BRUTO With nBruto
   Replace SF1->F1_P_LIQUI With nLiqui*/
   
ELSEIF SM0->M0_CODIGO $ "H6"
	Reclock("SF1",.F.)
   Replace SF1->F1_P_VOLUM With nQuant
   Replace SF1->F1_P_ESPEC With cEspeci
   Replace SF1->F1_P_BRUTO With nBruto
   Replace SF1->F1_P_LIQUI With nLiqui    
   
/*ELSEIF SM0->M0_CODIGO $ "PR"
	Reclock("SF1",.F.)
   Replace SF1->F1_P_VOLUM  With nQuant
   Replace SF1->F1_P_ESPV   With cEspeci
   Replace SF1->F1_P_PESOB  With nBruto
   Replace SF1->F1_PESOL    With nLiqui  
   Replace SF1->F1_P_TRANS  With pTransp  */
   
/*ELSEIF SM0->M0_CODIGO $ "R7"
	Reclock("SF1",.F.)
   Replace SF1->F1_P_VOLUM With nQuant
   Replace SF1->F1_P_ESPEC With cEspeci
   Replace SF1->F1_P_BRUTO With nBruto
   Replace SF1->F1_P_LIQUI With nLiqui        */
ELSE
	Reclock("SF1",.F.)
	REPL SF1->F1_YLIQUI  WITH nLiqui
	REPL SF1->F1_YBRUT   WITH nBruto
	REPL SF1->F1_YQUANT  WITH nQuant
	REPL SF1->F1_YESPECI WITH cEspeci
ENDIF

IF SM0->M0_CODIGO $ "R3"  // INICIALMENTE PARA A AVEBE
	REPL SF1->F1_YMENEND WITH cMENEND
ENDIF
      

MSUNLOCK()

Close(oDlg) 

RETURN                      


//Fun��o que verifica o n�mero de linhas m�ximas que se pode gravar.
*------------------------------------*
 Static Function VerLinhaMemo(cMemo)
*------------------------------------*

Local lRet := .T.
Local nLines := 0 
Local lOk := .T.
                                 
   //nLines := MLCOUNT(cMemo,49,,,)                      
   nLines := Len(Alltrim(cMemo))                                         
   If nLines <= 700  
      lOk := APMSGYESNO( "O texto cont�m: " + Alltrim(Str(nlines)) + " caracteres, deseja confirmar grava��o?"  , "Confirma��o de Grava��o." )
         If lOk       
            U_MT100B5() 
         EndIf
   Else            
      Alert("� permitido no m�ximo 700 Caracteres para o texto de importa��o. Atualmente o texto cont�m: " + Alltrim(Str(nlines)) + " Caracteres")
      lRet := .F.    
   EndIf   
   
Return lRet