#include "protheus.ch"    
#Include "rwmake.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

/*
Funcao      : ATUCT2_48
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Atualizar Campos personalizados da Discovery após Off-Line.  
Autor     	: Tiago Luiz Mendonça
Data     	: 30/03/2010
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Faturamento.
*/
   
*---------------------------*
  User Function ATUCT2_48() 
*---------------------------* 

Local oDlg,oMain   
Local nUsado:=0
Local aStruct:={} 
Local n:=1  

Private Indice:=Cc:=cTp:=""
Private oGetDB ,lRet:=.F.

Private aHeader	:={} 
Private aCols  	:={}
Private aRotina	:={}

Private cData := ""
//Local cEmpAnt:="50"

If cEmpAnt $ ("49")  .Or. cEmpAnt $ ("48") .Or. cEmpAnt $ ("50")

  If Select("Work")>0
     Work->(DbCloseArea()) 
  EndIf

  aRotina := {{ "Pesquisa"             ,"AxPesqui"   , 0 , 1},;
	          { "Visualizar"           ,"AxVisual"  , 0  , 2},; 
	          { "Incluir"              ,"AxVisual"  , 0  ,3},; 
	          { "Alterar"              ,"AxVisual"  , 0 , 4}}  


   DbSelectArea("SX3") 
   DbSetOrder(1)
   DbSeek("ZX1") 
   
   Aadd(aStruct,{"Seq"      ,"N",3   ,0})
       
   While !Eof() .And. (SX3->X3_ARQUIVO=="ZX1")

      If X3USO(x3_usado) .And. cNivel>=x3_nivel 
              
         nUsado++
         Aadd(aHeader,{ Substr(Alltrim(X3_TITULO),1,10),X3_CAMPO ,X3_PICTURE,X3_TAMANHO, X3_DECIMAL,"","", X3_TIPO   ,""   ,""} )   
    	 Aadd(aStruct,{ SX3->X3_CAMPO,SX3->X3_TIPO , SX3->X3_TAMANHO, SX3->X3_DECIMAL})                          

      EndIf
     
      SX3->(DbSkip())
     
   EndDo 
  
  Aadd(aStruct,{"FLAG","L",1,0})
         
  cNome:=CriaTrab(aStruct,.T.)                     
  DbUseArea(.T.,"DBFCDX",cNome,'Work',.F.,.F.)
        
  Indice:=E_Create(,.F.)
  IndRegua("Work",Indice+OrdBagExt(),"Work->ZX1_CC")  
  
  DbSelectArea("WORK")
  
  ZX1->(DbGoTop())  
  
  While ZX1->(!EOF()) 
  
     If ZX1->ZX1_P_EMP == cEmpAnt 
              
        RecLock("Work",.T.) 
        Work->Seq         :=n
        Work->ZX1_CC      :=ZX1->ZX1_CC  
        Work->ZX1_BRAND   :=ZX1->ZX1_BRAND
        Work->ZX1_PLATAF  :=ZX1->ZX1_PLATAF 
        Work->ZX1_P_GEOG  :=ZX1->ZX1_P_GEOG
        Work->ZX1_P_CODE  :=ZX1->ZX1_P_CODE  
	    Work->ZX1_CONTAS  :=ZX1->ZX1_CONTAS
        n++
        
     EndIf   

     Work->(MsUnlock()) 
     ZX1->(DbSkip()) 
           
  EndDo

	//JVR - 04/04/2012 - Tratamento para permitir escolha de data
	AjustaSX1()
	If !Pergunte("ATUCT2",.T.)
		cData := "25/02/2012"
	Else
		dInicial:= mv_par01
		cData	:= DtoC(dInicial)
	EndIf
  
  Work->(DbGoTop())  
  Work->(DbSetOrder(1))  


   DEFINE MSDIALOG oDlg TITLE "Atualização de lançamentos" From 1,1 To 36,96
          
   @ 06, 30 Say  " Todos os registros de Item Contabil (Brand), Classe de Valor (Plataforma), Região e Company Code à partir de " + cData  OF oDlg  PIXEL 
   @ 12, 100 Say  "  serão atualizados de acordo com as regras abaixo: "  OF oDlg  PIXEL 
    
   @ 22, 51    Say  'BRAND 9910 : PARA TODAS AS CONTAS DO ATIVO E PASSIVO ( CONTAS QUE INICIAM COM "1" e "2" )'  COLOR CLR_HRED, CLR_WHITE OF oDlg  PIXEL   
   @ 32, 45    Say  'PLATAFORMA 120 : PARA TODAS AS CONTAS DO ATIVO E PASSIVO ( CONTAS QUE INICIAM COM "1" e "2" )' COLOR CLR_HRED, CLR_WHITE OF oDlg PIXEL   
   
    
   //Discover Publicidade
   If cEmpAnt $ ("48")
      @ 42, 20    Say  'COMPANY CODE COM CÓDIGO "306", CASO O BRAND SEJA 4100 COMPANY COM "314", CASO O BRAND SEJA 1000 COMPANY COM "324"   ' COLOR CLR_HRED, CLR_WHITE OF oDlg  PIXEL 
      @ 52, 162   Say  'REGIAO COM "BR" ' COLOR CLR_HRED, CLR_WHITE  OF oDlg  PIXEL 
   Else
      @ 42, 20    Say  'COMPANY CODE COM CÓDIGO "307", CASO O BRAND SEJA 4100 COMPANY COM "313", CASO O BRAND SEJA 1000 COMPANY COM "323"   ' COLOR CLR_HRED, CLR_WHITE OF oDlg  PIXEL   
      @ 52, 65    Say  'REGIAO COM "BR" , CASO O CENTRO DE CUSTO SEJA 63031001 REGIAO COM "US"  ' COLOR CLR_HRED, CLR_WHITE  OF oDlg  PIXEL 
      @ 62, 100   Say  'CASO REGIAO SEJA "US" , PLATAFORMA COM "210"  ' COLOR CLR_HRED, CLR_WHITE  OF oDlg  PIXEL      
   EndIf        
   
     @ 75, 80   Say  'Caso exista centro de custo a atualização será de acordo com a tabela abaixo : ' OF oDlg PIXEL
                    oGetDB:= MsGetDB():New(85,;//1
                                        25,;//2
                                      220,;//3
                                      350,;//4
                                        2,;//5
	                                     ,;//06
                                         ,;//07
                                         ,;//08
                                      .F.,;//09 - Habilita exclusão
                                         ,;//10 - Vetor cps Alteração
                                        1,;//11
                                      .T.,;//12
                                         ,;//13
                                   "Work",;//14
                                         ,;//15
                                      .F.,;//16
                                         ,;//17
                                     oDlg,;//18
                                      .T.,;//19
                                      .F.,;//20
                                        ,;//21
                                        ) //22      
               
   
   
   /*
   @ 26 ,10 TO 130,380 LABEL "" OF oDlg  PIXEL
   @ 33, 155   Say  "DISCOVERY PUBLICIDADE"   COLOR CLR_HBLUE, CLR_WHITE  OF oDlg  PIXEL  
   @ 43, 60    Say  'BRAND 9910 : PARA TODAS AS CONTAS DO ATIVO E PASSIVO ( CONTAS QUE INICIAM COM "1" e "2" )'  COLOR CLR_HRED, CLR_WHITE OF oDlg  PIXEL   
   @ 53, 53    Say  'PLATAFORMA 120 : PARA TODAS AS CONTAS DO ATIVO E PASSIVO ( CONTAS QUE INICIAM COM "1" e "2" )' COLOR CLR_HRED, CLR_WHITE OF oDlg PIXEL  
   @ 63, 20    Say  'COMPANY CODE COM CÓDIGO "306", CASO O BRAND SEJA 4100 COMPANY COM "314", CASO O BRAND SEJA 1000 COMPANY COM "324"   ' COLOR CLR_HRED, CLR_WHITE OF oDlg  PIXEL  
   @ 73, 162   Say  'REGIAO COM "BR" ' COLOR CLR_HRED, CLR_WHITE  OF oDlg  PIXEL 
   
   @ 135,10 TO 225,380 LABEL "" OF oDlg  PIXEL
   @ 142,155    Say  "DISCOVERY COMUNICAÇÃO"   COLOR CLR_HBLUE, CLR_WHITE  OF oDlg  PIXEL    
   @ 152, 60    Say  'BRAND 9910 : PARA TODAS AS CONTAS DO ATIVO E PASSIVO ( CONTAS QUE INICIAM COM "1" e "2" )'  COLOR CLR_HRED, CLR_WHITE OF oDlg  PIXEL   
   @ 162, 53    Say  'PLATAFORMA 120 : PARA TODAS AS CONTAS DO ATIVO E PASSIVO ( CONTAS QUE INICIAM COM "1" e "2" )' COLOR CLR_HRED, CLR_WHITE OF oDlg PIXEL  
   @ 172, 20    Say  'COMPANY CODE COM CÓDIGO "307", CASO O BRAND SEJA 4100 COMPANY COM "313", CASO O BRAND SEJA 1000 COMPANY COM "323"   ' COLOR CLR_HRED, CLR_WHITE OF oDlg  PIXEL  
   @ 182, 65    Say  'REGIAO COM "BR" , CASO O CENTRO DE CUSTO SEJA 63031001 REGIAO COM "US"  ' COLOR CLR_HRED, CLR_WHITE  OF oDlg  PIXEL 
   @ 192, 120   Say  'CASO REGIAO SEJA "US" , PLATAFORMA COM "210"  ' COLOR CLR_HRED, CLR_WHITE  OF oDlg  PIXEL   
   */

   
   @ 233,085 TO 258,260 LABEL "" OF oDlg  PIXEL
   @ 238,120 BUTTON "Cancel" size 40,15 ACTION Processa({||  lRet:=.F.,oDlg:End()}) of oDlg Pixel  
   @ 238,160 BUTTON "Parametros" size 40,15 ACTION Processa({|| U_Paramet(),oGetDB:Refresh()}) of oDlg Pixel
   @ 238,200 BUTTON "Atualiza"   size 40,15 ACTION Processa({|| lRet:=.T.,oDlg:End()}) of oDlg Pixel  
   
   ACTIVATE DIALOG oDlg CENTERED ON INIT(oDlg:Refresh())

   If lRet 
   
      If !(MsgYesNo("Deseja realmente atualizar ?","Discovery"))    
         Work->(DbCloseArea()) 
         Return .F.                                                               
      EndIf
      
      Processa({|| AtuCT2()})

 
   EndIf
Else 
   MsgStop("Rotina não disponivel para essa empresa","Pryor")
EndIf
 
Return 
     

*------------------------------*
    Static Function AtuCT2()
*------------------------------*

    
Local lTurnOn:=GetMv("MV_P_ATU_L")
Local n:=0                        

      
   If lTurnOn       
         
      CT2->(DbSetOrder(1))      	
	  //If CT2->(DbSeek(xFilial("CT2")+"20120224"))  .Or.  CT2->(DbSeek(xFilial("CT2")+"20120225")) .Or.  CT2->(DbSeek(xFilial("CT2")+"20120226"))           	               
      If CT2->(DbSeek(xFilial("CT2")+DTOS(dInicial)))//JVR - 04/04/2012 - Tratamento para possibilitar user escolher a data.
        
         lRet:=.F.
         
         While CT2->(!EOF())
         
            IncProc("Aguarde, lendo registros ..." +Alltrim(str(N))) 
            
            RecLock("CT2",.F.)  
            
            //Centro de Custo
            cTp:=CT2->CT2_DC
            
            //Lançamento Debito
            If  cTp=="1"              
               
               If SubStr(CT2->CT2_DEBITO,1,1) $ "12"
                  
                  If Empty(CT2->CT2_ITEMD)
                     CT2->CT2_ITEMD:="9910"      
                  EndIf  
                  
                  If Empty(CT2->CT2_CLVLDB)
                     CT2->CT2_CLVLDB:="120"      
                  EndIf 
                  
                  //If !Empty(CT2->CT2_CCD)
                  //   CT2->CT2_CCD:=""      
                  //EndIf  
                  
                  //If !Empty(CT2->CT2_P_PROJ)
                  //   CT2->CT2_P_PROJ:=0      
                  //EndIf  
                                         
               EndIf             
               
               Cc:=CT2->CT2_CCD  
                                   
               //Discovery Comunicação
               If cEmpAnt $ ("49") 
                  CT2->CT2_P_GEOG:="BR"   // REGIAO
                  CT2->CT2_P_CODE:="307"  // COMPANY CODE    
               Else 
                  CT2->CT2_P_GEOG:="BR"   // REGIAO
                  CT2->CT2_P_CODE:="306"  // COMPANY CODE  
               EndIf     
               
            
            ElseIf cTp=="2"
            
               If SubStr(CT2->CT2_CREDIT,1,1) $ "12"
                  
                  If Empty(CT2->CT2_ITEMC)
                     CT2->CT2_ITEMC:="9910"      
                  EndIf 
                  
                  If Empty(CT2->CT2_CLVLCR)
                     CT2->CT2_CLVLCR:="120"      
                  EndIf   
                   
               EndIf  
               
               Cc:=CT2->CT2_CCC  
              
               //Discovery Comunicação
               If cEmpAnt $ ("49") 
                  CT2->CT2_P_GEOG:="BR"   // REGIAO
                  CT2->CT2_P_CODE:="307"  // COMPANY CODE    
               Else 
                  CT2->CT2_P_GEOG:="BR"   // REGIAO
                  CT2->CT2_P_CODE:="306"  // COMPANY CODE  
               EndIf     
            	
            
            ElseIf cTp=="3"    
            
               If SubStr(CT2->CT2_DEBITO,1,1) $ "12"  .Or. SubStr(CT2->CT2_CREDIT,1,1) $ "12"
                  
                  If Empty(CT2->CT2_ITEMD)
                     CT2->CT2_ITEMD:="9910"      
                  EndIf 
                  
                  If Empty(CT2->CT2_CLVLDB)
                     CT2->CT2_CLVLDB:="120"      
                  EndIf              
            
                
                  If Empty(CT2->CT2_ITEMC)
                     CT2->CT2_ITEMC:="9910"      
                  EndIf 
                  
                  If Empty(CT2->CT2_CLVLCR)
                     CT2->CT2_CLVLCR:="120"      
                  EndIf 
                  
                  
                                 
               EndIf    
               
               If !Empty(CT2->CT2_CCD)      
                  Cc:=CT2->CT2_CCD
               Else
                  If Empty(Cc)
                     Cc:=CT2->CT2_CCC  
                  EndIf   
               EndIf     
               
               //Discovery Comunicação
               If cEmpAnt $ ("49") 
                  CT2->CT2_P_GEOG:="BR"   // REGIAO
                  CT2->CT2_P_CODE:="307"  // COMPANY CODE    
               Else 
                  CT2->CT2_P_GEOG:="BR"   // REGIAO
                  CT2->CT2_P_CODE:="306"  // COMPANY CODE  
               EndIf     
    
            
            
            EndIf
            
            If !Empty(Cc) // .And. cTp<>"3"
            
               ZX1->(DbSetOrder(1))
               
               If ZX1->(DbSeek(xFilial("ZX1")+Cc))   
               
                  If cTp=="1"        
                     
                     //Valida se o centro de custo Debito está apontado para a empresa correta. 
                     If cEmpAnt == ZX1->ZX1_P_EMP
						
						if cEmpAnt $ ("49") 
							if SUBSTR(CT2->CT2_DEBITO,1,1) $ ZX1->ZX1_CONTAS
		                        CT2->CT2_ITEMD :=ZX1->ZX1_BRAND   // BRAND   
		                        CT2->CT2_CLVLDB:=ZX1->ZX1_PLATAF  // PLATAFORMA
		                        CT2->CT2_P_GEOG:=ZX1->ZX1_P_GEOG  // REGIAO
		                        CT2->CT2_P_CODE:=ZX1->ZX1_P_CODE  // COMPANY CODE  
	                        endif
						else
	                        CT2->CT2_ITEMD :=ZX1->ZX1_BRAND   // BRAND   
	                        CT2->CT2_CLVLDB:=ZX1->ZX1_PLATAF  // PLATAFORMA
	                        CT2->CT2_P_GEOG:=ZX1->ZX1_P_GEOG  // REGIAO
	                        CT2->CT2_P_CODE:=ZX1->ZX1_P_CODE  // COMPANY CODE
						endif                        
                     EndIf
                     
                  
                  ElseIf cTp=="2"   
                     
                      //Valida se o centro de custo Credito está apontado para a empresa correta.  
                     If cEmpAnt == ZX1->ZX1_P_EMP 
						if cEmpAnt $ ("49") 
		               		if SUBSTR(CT2->CT2_CREDIT,1,1) $ ZX1->ZX1_CONTAS
		                        CT2->CT2_ITEMC :=ZX1->ZX1_BRAND   // BRAND
		                        CT2->CT2_CLVLCR:=ZX1->ZX1_PLATAF  // PLATAFORMA
		                        CT2->CT2_P_GEOG:=ZX1->ZX1_P_GEOG  // REGIAO
		                        CT2->CT2_P_CODE:=ZX1->ZX1_P_CODE  // COMPANY CODE  
	                    	endif
						else
	                        CT2->CT2_ITEMC :=ZX1->ZX1_BRAND   // BRAND
	                        CT2->CT2_CLVLCR:=ZX1->ZX1_PLATAF  // PLATAFORMA
	                        CT2->CT2_P_GEOG:=ZX1->ZX1_P_GEOG  // REGIAO
	                        CT2->CT2_P_CODE:=ZX1->ZX1_P_CODE  // COMPANY CODE  
						endif
                    EndIf 
                    
                  ElseIf cTp=="3"   
                     
                      //Valida se o centro de custo Credito está apontado para a empresa correta.  

                     If cEmpAnt == ZX1->ZX1_P_EMP   
						if cEmpAnt $ ("49") 
							if SUBSTR(CT2->CT2_DEBITO,1,1) $ ZX1->ZX1_CONTAS
		                        CT2->CT2_ITEMD :=ZX1->ZX1_BRAND   // BRAND   
		                        CT2->CT2_CLVLDB:=ZX1->ZX1_PLATAF  // PLATAFORMA
		                        CT2->CT2_P_GEOG:=ZX1->ZX1_P_GEOG  // REGIAO
		                        CT2->CT2_P_CODE:=ZX1->ZX1_P_CODE  // COMPANY CODE  	                        
							endif
	
							if SUBSTR(CT2->CT2_CREDIT,1,1) $ ZX1->ZX1_CONTAS
		                        CT2->CT2_ITEMC :=ZX1->ZX1_BRAND   // BRAND   
		        				CT2->CT2_CLVLCR:=ZX1->ZX1_PLATAF  // PLATAFORMA
		                        CT2->CT2_P_GEOG:=ZX1->ZX1_P_GEOG  // REGIAO
		                        CT2->CT2_P_CODE:=ZX1->ZX1_P_CODE  // COMPANY CODE  
							endif
						else
	                        CT2->CT2_ITEMD :=ZX1->ZX1_BRAND   // BRAND   
	                        CT2->CT2_CLVLDB:=ZX1->ZX1_PLATAF  // PLATAFORMA
	                        CT2->CT2_ITEMC :=ZX1->ZX1_BRAND   // BRAND   
	        				CT2->CT2_CLVLCR:=ZX1->ZX1_PLATAF  // PLATAFORMA
	                        CT2->CT2_P_GEOG:=ZX1->ZX1_P_GEOG  // REGIAO
	                        CT2->CT2_P_CODE:=ZX1->ZX1_P_CODE  // COMPANY CODE  
						endif
					 EndIf

                  EndIf 
                  
               EndIf
            
            EndIf
                             
            n++
            
            CT2->(MsUnlock())        
            CT2->(DbSkip())
            
            Cc:=""
                 
         EndDo   
      Else
         MsgInfo("Não foi encontrado nenhum registro relacionado a data " + cData,"Discovery")
         Work->(DbCloseArea())
         Return .t.
      EndIf   
      
      If !(lRet)
         MsgInfo("Atualizado com sucesso todos os registros com data a partir de "+cData,"Discovery")  
         MsgAlert("NECESSARIO REPROCESSAR A EMPRESA","Discovery")    
      Else
         MsgInfo("Nenhum registro atualizado","Discovery")
      EndIf  

                                                           	
      Work->(DbCloseArea())    

   EndIf   


Return

*-------------------------*
Static Function AjustaSX1()
*-------------------------*

U_PUTSX1("ATUCT2"  ,"01" ,"Data ?"		,"" ,"" ,"mv_ch1","D"	,08, 0 , ,"G",""		,"","","","mv_par01","","","" 							,"25/02/2012"	,"","",""			  			   		,"","",""	,"","","","","","",{"Inserir a data Inicial"},{},{})

Return .t.

/*
Funcao      : Paramet
Parametros  : 
Retorno     : 
Objetivos   : Carrega a tela com os dados da ZX1 para alterações
Autor       : Matheus Massarotto
Data/Hora   : 29/01/2012
*/
*---------------------*
User Function Paramet()
*---------------------*
Local nUsado := 0
Local aButtons :={}

Private oDlg1
Private oGetDados
Private lRefresh := .T.
Private aHeaderX1 := {}
Private aColsX1 := {}
Private aAlter:={}
Private lCtrl:=.F.
Private nOpc1:= GD_INSERT+GD_DELETE+GD_UPDATE
Private oGet1
Private cGet1	 := Space(25)

ProcRegua(0)

/*++++++++Carrego ZX1 no aHeader+++++++++*/

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("ZX1")

While !Eof().And.(x3_arquivo=="ZX1")
	If !alltrim(SX3->X3_CAMPO) $ "ZX1_FILIAL/ZX1_P_EMP"
		nUsado:=nUsado+1
		AADD(aHeaderX1,{ TRIM(SX3->X3_TITULO),;
							 SX3->X3_CAMPO,;
							 SX3->X3_PICTURE,;
							 SX3->X3_TAMANHO,;
		 					 SX3->X3_DECIMAL,;
		 					 "ALLWAYSTRUE()",;
		 					 SX3->X3_USADO,;
		 					 SX3->X3_TIPO,;
		 					 SX3->X3_F3,;
		 					 SX3->X3_CONTEXT } )
        

	aadd(aAlter,SX3->X3_CAMPO)

	Endif
	dbSkip()
Enddo

	/*++++++++ Montagem do aCols +++++++++*/

	aColsX1:={}
	dbSelectArea("ZX1")
	dbSetOrder(1)
	ZX1->(DbGoTop())
	While !EOF() .AND. ZX1_FILIAL==xFilial("ZX1")
		AADD(aColsX1,Array(nUsado+1))
			For nX:=1 to nUsado
				aColsX1[Len(aColsX1),nX]:=FieldGet(FieldPos(aHeaderX1[nX,2]))
			Next
		aColsX1[Len(aColsX1),nUsado+1]:=.F.
		ZX1->(dbSkip())
	End

	/*++++++++ Definição da tela +++++++++*/

oDlg1 := MSDIALOG():New(000,000,500,800, "Contabilidade",,,,,,,,,.T.)


// Cria Componentes Padroes do Sistema
@ 015,257 Button "Buscar" Size 037,011 action(BuscaCC(cGet1)) PIXEL OF oDlg1
@ 016,035 MsGet oGet1 Var cGet1 Size 217,009 COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg1
@ 018,005 Say "Pesquisar" Size 025,008 COLOR CLR_BLACK PIXEL OF oDlg1

oGetDados:= MsNewGetDados():New(30, 05, 250, 395,;
nOpc1,"AllwaysTrue()","AllwaysTrue()", "", aAlter, 000, 999,"U_V_ATUCT2()",;
"AllwaysTrue()","AllwaysTrue()", oDlg1, aHeaderX1, aColsX1)

oDlg1:bInit := {|| EnchoiceBar(oDlg1, {|| iif(ValidaInfo(aColsX1,aHeaderX1),Processa({|| AtuaZX1(),oDlg1:End(),"Processando..."}),"")    },{||oDlg1:End()},,aButtons)}
oDlg1:lCentered := .T.
oDlg1:Activate()


Return


/*
Funcao      : V_ATUCT2
Parametros  : 
Retorno     : .T. or .F.
Objetivos   : Validar campos do aCols
Autor       : Matheus Massarotto
Data/Hora   : 28/01/2012
*/
*---------------------------*
User Function V_ATUCT2(nTipo)
*---------------------------*
DEFAULT nTipo:=1

if nTipo==1
	if alltrim(aHeaderX1[oGetDados:oBrowse:ColPos][2])=="ZX1_CC"

		DbSelectArea("ZX1")
		ZX1->(DbSetOrder(1))
		if DbSeek(xFilial("ZX1")+M->ZX1_CC)
			Alert("Centro de custo escolhido já foi definido!!")
			Return(.F.)
	    endif

	endif
else

endif

Return(.T.)

/*
Funcao      : ValidaInfo
Parametros  : 
Retorno     : lRet
Objetivos   : Validar Informações
Autor       : Matheus Massarotto
Data/Hora   : 29/01/2012
*/
*-------------------------*
Static Function ValidaInfo
*-------------------------*
Local lRet:=.F.
Local aDados:=oGetDados:aCols

lRet:= MsgYesNo("Deseja realmente atualizar parametros?","Atenção")

if lRet

	if aScan(aDados,{|x|AllTrim(x[2])==""})>0
		Msginfo("Por favor, preencha todos os campos!")
		Return(.F.) 
	elseif aScan(aDados,{|x|AllTrim(x[3])==""})>0
		Msginfo("Por favor, preencha todos os campos!")
		Return(.F.) 
	elseif aScan(aDados,{|x|AllTrim(x[4])==""})>0
		Msginfo("Por favor, preencha todos os campos!")
		Return(.F.) 
	elseif aScan(aDados,{|x|AllTrim(x[5])==""})>0
		Msginfo("Por favor, preencha todos os campos!")
		Return(.F.) 
	elseif aScan(aDados,{|x|AllTrim(x[6])==""})>0
		Msginfo("Por favor, preencha todos os campos!")
		Return(.F.) 
	endif

endif

Return(lRet)

/*
Funcao      : AtuaZX1
Parametros  : 
Retorno     : 
Objetivos   : Grava dados na tabela ZX1 e Work
Autor       : Matheus Massarotto
Data/Hora   : 29/01/2012
*/

*-----------------------*
Static Function AtuaZX1()
*-----------------------*
Local aDados:=oGetDados:aCols

DbSelectArea("ZX1")
DbSelectArea("Work")
   
For i:=1 to len(aDados)
	ZX1->(DbGotop())
	Work->(DbGotop())
	
	if !empty(aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CC"})])
		if aDados[i][len(aDados[i])]
			if ZX1->(DbSeek(xFilial("ZX1")+aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CC"})]))
				RecLock("ZX1",.F.)
					ZX1->(DbDelete())
				ZX1->(MsUnlock())
			endif
			if Work->(DbSeek(aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CC"})]))
				RecLock("Work",.F.)
					Work->(DbDelete())
				MsUnlock()
			endif
        else
			if ZX1->(DbSeek(xFilial("ZX1")+aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CC"})]))
				RecLock("ZX1",.F.)
					ZX1->ZX1_BRAND	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_BRAND"})]
					ZX1->ZX1_PLATAF	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_PLATAF"})]
					ZX1->ZX1_P_GEOG	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_P_GEOG"})]
					ZX1->ZX1_P_CODE	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_P_CODE"})]
					ZX1->ZX1_CONTAS	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CONTAS"})]
				ZX1->(MsUnlock())
	
				if Work->(DbSeek(aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CC"})]))
					RecLock("Work",.F.)
						Work->ZX1_BRAND	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_BRAND"})]
						Work->ZX1_PLATAF	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_PLATAF"})]
						Work->ZX1_P_GEOG	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_P_GEOG"})]
						Work->ZX1_P_CODE	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_P_CODE"})]
						Work->ZX1_CONTAS	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CONTAS"})]						
					Work->(MsUnlock())
				endif

			else
				RecLock("ZX1",.T.)
					ZX1->ZX1_FILIAL	:=xFilial("ZX1")
					ZX1->ZX1_CC		:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CC"})]
					ZX1->ZX1_BRAND	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_BRAND"})]
					ZX1->ZX1_PLATAF	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_PLATAF"})]
					ZX1->ZX1_P_GEOG	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_P_GEOG"})]
					ZX1->ZX1_P_CODE	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_P_CODE"})]
					ZX1->ZX1_CONTAS	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CONTAS"})]
					ZX1->ZX1_P_EMP	:=cEmpAnt
				ZX1->(MsUnlock())

				RecLock("Work",.T.)
					Work->ZX1_CC		:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CC"})]
					Work->ZX1_BRAND		:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_BRAND"})]
					Work->ZX1_PLATAF	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_PLATAF"})]
					Work->ZX1_P_GEOG	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_P_GEOG"})]
					Work->ZX1_P_CODE	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_P_CODE"})]
					Work->ZX1_CONTAS	:=aDados[i][aScan(aHeaderX1,{|x|AllTrim(x[2])=="ZX1_CONTAS"})]
					Work->ZX1_P_EMP		:=cEmpAnt
				Work->(MsUnlock())

			endif
		endif
	endif
	
Next

Work->(DbGotop())

Return

/*
Funcao      : BuscaCC()
Parametros  : 
Retorno     : 
Objetivos   : Função para buscar o centro de custo no aCols, posicionando caso encontre
Autor       : Matheus Massarotto
Data/Hora   : 28/01/2012
*/
*-------------------------------*
Static Function BuscaCC(cBusca)
*-------------------------------*
Local nGo		:= 0
Local nTamBusca	:= len(alltrim(cBusca))

nGo:= aScan( aColsX1, { |x|   UPPER(alltrim(cBusca)) $  SUBSTR(UPPER(x[1]),1,nTamBusca)  } )

oGetDados:GoTo(nGo)

Return()
