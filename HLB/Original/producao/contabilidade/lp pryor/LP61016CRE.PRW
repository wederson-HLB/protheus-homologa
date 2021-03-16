#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

User Function LP61016CRE()        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_CCREDITO,")

_CCREDITO := " "


IF SM0->M0_CODIGO $"48/49"         /// EMPRESAS DO GRUPO DISCOVERY
   IF Alltrim(SB1->B1_COD) == "DSC001" 
      _CCREDITO:="311106061"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC002" 
      _CCREDITO:="311106062"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC003" 	
      _CCREDITO:="311106064"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC004" 	
      _CCREDITO:="311106063"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC005" 	
	  _CCREDITO:="311106065"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC006" 	
	  _CCREDITO:="311106066"  
   ELSEIF Alltrim(SB1->B1_COD) == "DSC007" 	
	  _CCREDITO:="311106067"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC013" 	
	  _CCREDITO:="311106070"
   ELSEIF Alltrim(SB1->B1_COD) $ "DSC014"
      _CCREDITO:="311106069"
   ELSEIF Alltrim(SB1->B1_COD) $ "DSC0015/DSC016"//EBF - 10/05/2017 - Ajuste conta credito por produto
      _CCREDITO:="311106064"
   ELSEIF Alltrim(SB1->B1_COD) $ "DSC017"//EBF - 10/05/2017 - Ajuste conta credito por produto
      _CCREDITO:="311106073"
   ELSEIF Alltrim(SB1->B1_COD) $ "DSC008/DSC009/DSC010/DSC011/DSC012"
      _CCREDITO:="311106068"
   
   //CAS - 27-03-2018 - Altera豫o Conta Contabil-LP610-17(novos produtos), conforme e-mail da Lisandra Sanches.    	 
   ELSEIF Alltrim(SB1->B1_COD) == "DSC023" 
      _CCREDITO:="311107063"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC021" 	
      _CCREDITO:="311107066"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC020" 	
      _CCREDITO:="311107061"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC025" 	
      _CCREDITO:="311107073"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC026" 	
      _CCREDITO:="311107064"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC022" 	
      _CCREDITO:="311107062"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC024" 	
      _CCREDITO:="311107065"
   ELSEIF Alltrim(SB1->B1_COD) == "DSC019"
      _CCREDITO:="311108023"   
   ENDIF 
	
ENDIF
	
Return(_CCREDITO)        
