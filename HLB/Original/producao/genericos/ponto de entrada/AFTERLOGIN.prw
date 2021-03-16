#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "FWMVCDEF.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
       
/*
Funcao      : AFTERLOGIN
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. para Controle de acessos 
Autor     	: Tiago Luiz Mendon�a 
Data     	: 18/06/09
Obs         : 
TDN         : Ao acessar pelo SIGAMDI, este ponto de entrada � chamado ao entrar na rotina. Pelo modo SIGAADV, a abertura dos SXs � executado ap�s o login.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 22/03/2012
M�dulo      : Todos
Cliente     : Dondalson, Engecorps, Harris, Mind Lab, Sirona , Media Networks ,MFS , WAYRA , Godigital , Victaulic 
*/
*----------------------------*
User Function AFTERLOGIN()
*----------------------------*
Local nCount        := 0
Local nImpCount     := 0
Local cLogados      :="O numero m�ximo de licen�as foi utilizado, usu�rios logados :"+CHR(13)+CHR(10)  
Local cLogadosImp   :="O numero m�ximo de licen�as de Importa��o utilizado, usu�rios logados :"+CHR(13)+CHR(10)  
Local nLic , cUserComp ,nLicImp ,cUserComp1 
Local cTodos        :=""       
Local cSim          :="SIM"
Local lControle     :=.F.
Local lModImp       :=.F.                 

//Begin Sequence 

	//Testa para verificar se a chamada � por JOBS				                        
	If Select("SX3")<=0
    	Return
	EndIf			                  
	
	If ValidaEmerg()
 		ALERT("Acesso n�o Autorizado!")
 		KillApp( .T. )         
	EndIf

   If cEmpAnt $ "I7" .Or. cEmpAnt $ "I6"  .Or. cEmpAnt $ "07"   .Or. cEmpAnt $ "K2"   .Or. cEmpAnt $ "MN" .Or. cEmpAnt $ "SI"  .Or. cEmpAnt $ "UY"  .Or. cEmpAnt $ "4J" .Or. cEmpAnt $ "1V" .Or. cEmpAnt $ "6H" .Or. cEmpAnt $ "4Y".Or. cEmpAnt $ "1X" .Or. cEmpAnt $ "G6" .Or. cEmpAnt $ "4Z" .Or. cEmpAnt $ "TM" .Or. cEmpAnt $ "4L"
         
      cUserComp  := GETMV("MV_P_USERS")
      cUserComp1 := GETMV("MV_P_USER1")    
      nLic       := GETMV("MV_P_NRLIC")  
      lControle  := GETMV("MV_P_CONTR") 
      nLicImp    := 2   // Licen�as de importa��o        
      
      cTodos:=Alltrim(cUserComp)+Alltrim(cUserComp1)
      
      aUser:=GetUserInfoArray()  
   
      IF alltrim(cUserName) $ cTodos .And. lControle 
                                                   
         cLogados+=" "+CHR(13)+CHR(10) 
      
         SZX->(DbGoTop())
         SZX->(DbSetOrder(1))
         SZX->(DbSeek(xFilial()+cSim))                          
              
         While SZX->(!EOF()) .And. SZX->ZX_LOGADO==cSim  
            cLogados+="    User: "+UPPER(Alltrim(SZX->ZX_USER))+"   Modulo : "+Alltrim(SZX->ZX_MODULO)+CHR(13)+CHR(10) 
            If alltrim(cUserName) <> Alltrim(SZX->ZX_USER) 
               nCount++  
               If Alltrim(SZX->ZX_MODULO) == "Importacao" .And.  Alltrim(Modulo(CMODULO)) == "Importacao" 
                  cLogadosImp+="    User: "+UPPER(Alltrim(SZX->ZX_USER))+"   Modulo : "+Alltrim(SZX->ZX_MODULO)+CHR(13)+CHR(10)   
                  nImpCount++
               EndIf
            EndIf  
                
            SZX->(DbSkip())
         EndDo
         
         If nImpCount > nLicImp 
            MsgStop(cLogadosImp,"Aten��o")
            KillApp( .T. )         
         Else
            If nCount < nLic 
               SZX->(DbGoTop())
               SZX->(DbSetOrder(2))
               If SZX->(DbSeek(xFilial()+cUserName))
                  RecLock("SZX",.F.)  
                  SZX->ZX_MODULO :=Alltrim(Modulo(CMODULO))                                          
                  SZX->ZX_LOGADO:=cSIm
                  SZX->ZX_HORA:=Time()
                  SZX->ZX_DATA:=Date()  
                  SZX->ZX_OBS:="CONECTADO NO SISTEMA"
                  SZX->(MsUnlock())  
               Else
                  RecLock("SZX",.T.) 
                  SZX->ZX_FILIAL :=xFilial()
                  SZX->ZX_USER   :=Alltrim(cUserName) 
                  SZX->ZX_MODULO :=Alltrim(Modulo(CMODULO))                                          
                  SZX->ZX_LOGADO :=cSim
                  SZX->ZX_HORA   :=Time()
                  SZX->ZX_DATA   :=Date()  
                  SZX->ZX_OBS:="CONECTADO NO SISTEMA"
                  SZX->(MsUnlock())         
               EndIf
            Else  
               MsgStop(cLogados,"Aten��o")
               KillApp( .T. )
            EndIf
         EndIf
   
      EndIf
   EndIf
      
   
   /*
		* LDB - 22/06/2015 - Controle de acessos somente em dia �til ( exclui sabado,domingo e feriados )
		* Obs: Para o correto controle do feriado deve-se dar manuten��o anualmente na tabela 63 ( SX5 ),
			pois a rotina DataValida() busca o feriado a partir desta tabela .   	
   */
	If !FwIsAdmin()//JVR - 31/07/2015 - N�o executa para administradores.
		If ( cEmpAnt == '7W' ) /* PayPall */ 
			If ( DataValida( dDataBase ) <> dDataBase )
				MsgStop( 'N�o � poss�vel entrar no sistema em sabados, domingos ou feriados.' )
				KillApp( .T. )   
			EndIf
		EndIf
	EndIf
   /* */
   
//End Sequence

   //Wederson - 08/02/2021 - Espec�fico Marici - Financeiro - In�cio
   If cEmpAnt == "X2"
      MV_CRNEG += Alltrim(SuperGetMV("MV_XXTPFN", .F.,"|PCL"))
   EndIf
   //Wederson - 08/02/2021 - Espec�fico Marici - Financeiro  Fim
  
Return

//Indentifica o modulo
*------------------------------*
  Static Function Modulo(cMod)
*------------------------------*                            

Default cMod:=""

Do case
   Case cMod=="FAT"
      cMod:="Faturamento"   
   Case cMod=="FIN"     
      cMod:="Financeiro"     
   Case cMod=="CTB"     
      cMod:="Contabil" 
   Case cMod=="EST"     
      cMod:="Estoque"  
   Case cMod=="PCP"     
      cMod:="PCP"
   Case cMod=="ATF"     
      cMod:="Ativo Fixo"
   Case cMod=="COM"     
      cMod:="Compras"   
   Case cMod=="EIC"     
      cMod:="Importacao"      
   Case cMod=="QIE"
      cMod:="Inp. Ent."  
   Case cMod=="QDO"
      cMod:="Contr. Doc." 
   Case cMod=="QNC"
      cMod:="Ctr. N-Confor."                          
   Otherwise
      cMod:="N�o disp."
End Case   

Return (cMod)

*---------------------*
User Function MSFINAL() 
*---------------------*                            
Local cUserComp  := ""    
Local cUserComp1  := "" 
Local lControle  :=.F. 
Local cTodos

If TYPE("cEmpAnt") == "U"
	Return .T.
EndIf

Begin Sequence
   If cEmpAnt $ "I7" .Or. cEmpAnt $ "I6"
     cUserComp  := GETMV("MV_P_USERS") // Problema com MDI      
     cUserComp1  := GETMV("MV_P_USER1") 
     //cUserComp  :="AFRADE/DAVIDYEO/EGIMENES/FELIAS/GZAMARIOLI/MGOES/VSILVA/AGALVAO/ECONCEICAO/JTRUJILLO/LFIGUEIREDO/LPASSADOR/MSIMIONATO/RCASTILHO/VLIMA/TPRESTES/TESTE2"  
     lControle := GETMV("MV_P_CONTR")
       
     cTodos:= Alltrim(cUserComp)+Alltrim(cUserComp1)
     
      If alltrim(cUserName) $ cTodos .And. lControle 
         MsgStop("Para sair do sistema ser� necess�rio utilizar o menu FINALIZAR SESS�O, devido ao controle de licen�as.","Aten��o")
         Return .F. 
      EndIf   
   EndIf
End Sequence

Return .T.
 
*--------------------*
User Function DBLLOG()
*--------------------*      
Local  aCores:={}      
Private aRotina:={}

If !(cEmpAnt $ "I7" .Or. cEmpAnt $ "I6" .Or. cEmpAnt $ "07" .Or. cEmpAnt $ "K2"  .Or. cEmpAnt $ "MN"  .Or. cEmpAnt $ "SI" )  
   MsgStop("Especifico","A T E N C A O")  
   Return .F.
EndIf      

 aRotina := {{"Pesquisar", "AxPesqui"     ,	0, 1},;    
             {"Atualizar", "U_AtuUserDBL()",	0, 2},;
	         {"Legenda"  , "U_LegendDBL()",	0, 3}}
	         
  
 aCores  := {{ "ZX_LOGADO == 'SIM'",'BR_VERDE'   },;	//User logado
	         { "ZX_LOGADO == 'NAO'",'BR_VERMELHO'}}  	//User Nao logado

 mBrowse( 6, 1,22,75,"SZX",,,,,,aCores)
  
 Return .T.     

*-----------------------------* 
  User Function AtuUserDBL()
*-----------------------------*                    

 Local aUser:={}     
 
 MsgInfo("Rotina ainda n�o disponivel") 

 Return .F.

// Aguardando fun��o da Microsiga que retorna os usu�rios logados
// Fun��o abaixo retorna login de rede e maquina  
aUser:=GetUserInfoArray()
 
If cEmpAnt $ "I7" .Or. cEmpAnt $ "I6" .Or. cEmpAnt $ "07" .Or. cEmpAnt $ "K2"   .Or. cEmpAnt $ "MN" .Or. cEmpAnt $ "SI"

   SZX->(DbGoTop())
   SZX->(DbSetOrder(2))                        
              
   While SZX->(!EOF())
       
      If !(aScan(aUser,{|x| AllTrim(x[1])== alltrim(SZX->ZX_USER)} ) ==0)
         RecLock("SZX",.F.)                                    
         SZX->ZX_LOGADO :="SIM"
         SZX->ZX_OBS:="CONECTADO NO SISTEMA"
         SZX->(MsUnlock())  
      Else
         RecLock("SZX",.F.)                                    
         SZX->ZX_LOGADO :="NAO"
         SZX->ZX_OBS:="DISCONECTADO NO SISTEMA"
         SZX->(MsUnlock())            
      EndIf                 
      
      SZX->(DbSkip())
      
    EndDo  
    
    MsgInfo("Atualizado com suscesso","HLB")
     
EndIf       
                        
Return
 
*-----------------------------* 
  User Function LegendDBL()
*-----------------------------*

Local aCores := {}    
   
aCores := {{"BR_VERDE"   ,"CONECTADO"},;     
           {"BR_VERMELHO","DESCONECTADO"}} 

BrwLegenda("Status","Legenda",aCores)

Return .T.

//Controle antigo antes do ponto MsQuit - Utilizado pelo usu�rios da Donaldson.
*-----------------------------*
   User Function FINALUSE()
*-----------------------------*              

Local cUserComp   := ""   
Local cUserComp1  := "" 
Local cSim       :="SIM"  
Local lControle  :=.F.   
Local cTodos

If cEmpAnt $ "I7" .Or. cEmpAnt $ "I6"        
     
   cUserComp   := GETMV("MV_P_USERS")
   cUserComp1  := GETMV("MV_P_USER1")  
   lControle   := GETMV("MV_P_CONTR")
   cTodos      := Alltrim(cUserComp)+Alltrim(cUserComp1) 
     
   If alltrim(cUserName) $ cTodos
      
      If (MsgYesNo("Deseja sair do sistema ?","Controle de licen�as"))  
        
         SZX->(DbGoTop())
         SZX->(DbSetOrder(1))
         
         If SZX->(DbSeek(xFilial()+cSim+Alltrim(cUserName)))
            RecLock("SZX",.F.)                                            
            SZX->ZX_LOGADO:="NAO"
            SZX->ZX_HORA:=Time()
            SZX->ZX_DATA:=Date()
            SZX->ZX_OBS:="DESCONECTADO DO SISTEMA"
            SZX->(MsUnlock())  
         EndIf 
                      
         KillApp(.T.) 
      
      EndIf
   
   Else   
      
      MsgInfo("Rotina especifica para usu�rios que possuem controle de licen�as","HLB")               
      
   EndIf
                    
Else                                                                     
    MsgStop("Especifico","A T E N C A O")
Endif                  


Return .F. 

/*
Funcao      : MSQUIT
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. para Controle de acessos , ap�s o bot�o sair, e depois do bot�o finalizar. 
Autor     	: Tiago Luiz Mendon�a 
Data     	: 18/06/09
Obs         : 
TDN         : O Ponto de Entrada MSQUIT foi disponibilizado para auxiliar nos processos de controle de acessos do sistema e ser� executado ao selecionar a op��o Finalizar ou Logoff da Final e as op��es de Logoff do sistema ao utilizar a interface TEMAP10.
            : O ponto de entrada ir� receber como par�metro um vetor (PARAMIXB) com uma vari�vel l�gica que identificar� se o ponto de entrada est� sendo executado a partir da op��o de Logoff.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 22/03/2012
M�dulo      : Todos
Cliente     : Engecorps, Harris, Mind Lab, Sirona , Media Networks ,MFS , WAYRA , Godigital , Victaulic 
*/          
 
*--------------------------*
   User Function MSQUIT()
*--------------------------* 

Local cUserComp  := ""   
Local cUserComp1 := ""  
Local cTodos     := ""
Local cSim       :="SIM"  
Local lControle  :=.F.
   
   If select("SX6")<=0
	  Return
   endif   
   
   If cEmpAnt $ "07"  .Or. cEmpAnt $ "K2"   .Or. cEmpAnt $ "MN" .Or. cEmpAnt $ "SI"  .Or. cEmpAnt $ "UY"  .Or. cEmpAnt $ "4J" .Or. cEmpAnt $ "1V" .Or. cEmpAnt $ "6H" .Or. cEmpAnt $ "4Y" .Or. cEmpAnt $ "1X"  .Or. cEmpAnt $ "G6" .Or. cEmpAnt $ "4Z" .Or. cEmpAnt $ "TM" .Or. cEmpAnt $ "4L"

      cUserComp  := GETMV("MV_P_USERS") 
      cUserComp1 := GETMV("MV_P_USER1")   
      lControle  := GETMV("MV_P_CONTR")
      
      cTodos:=Alltrim(cUserComp)+Alltrim(cUserComp1)
     
      If alltrim(cUserName) $ cTodos .And. lControle 
      
         SZX->(DbGoTop())
         SZX->(DbSetOrder(1))
         
         If SZX->(DbSeek(xFilial()+cSim+Alltrim(cUserName)))
            RecLock("SZX",.F.)                                            
            SZX->ZX_LOGADO:="NAO"
            SZX->ZX_HORA:=Time()
            SZX->ZX_DATA:=Date()
            SZX->ZX_OBS:="DESCONECTADO DO SISTEMA"
            SZX->(MsUnlock())  
         EndIf 
   
      EndIf   
   
   EndIf

Return
           
/*
Funcao      : ValidaEmerg
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Controle de Acesso ao Repositorio Emergencial.
Autor     	: Jean Victor Rocha
Data     	: 14/01/2014
Obs         : 
*/
*----------------------------*
Static Function ValidaEmerg() 
*----------------------------*
Local lRet := .T.
Local nOpc := 0
     
Private cGet1 := Space(6)
//Se for Administrador n�o executa.
If FwIsAdmin()
	Return !lRet
EndIf

If UPPER(Right(GetEnvServer(),1)) $ "A|B|C|D|E"
	If UPPER(GetEnvServer()) $ "GTHD|P11_TESTE|EP11_TESTE|P11_DISC|EP11_DISC|P12_TESTE|EP12_TESTE|P12_DISC|EP12_DISC"//Valida em casos que n�o � para utilizar a senha.
		Return !lRet
	EndIf
    
	cMGetNew := "Acesso Restrito ao repositorio de Emergencia!"+CHR(10)+CHR(13)
	cMGetNew += "Cod. Acesso Temporaria Fornecida apenas "+CHR(10)+CHR(13)
	cMGetNew += "pela equipe de Sistemas quando for necessario."+CHR(10)+CHR(13)
	oDlg1      := MSDialog():New( 247,531,531,829,"Repositorio de Emergencia",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 008,004,{||"Repositorio de Emergencia: "+UPPER(Right(GetEnvServer(),1))},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
	oSay2      := TSay():New( 016,004,{||"Usuario: "+cUserName},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
	oSay3      := TSay():New( 024,004,{||"Data: "+DTOC(DATE())},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
	oSay4      := TSay():New( 032,004,{||"Ambiente: "+UPPER(GetEnvServer())},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
	oSay5      := TSay():New( 064,004,{||"Cod.Acesso"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oGet1      := TGet():New( 064,048,{|u| IF(PCount()>0,cGet1:=u,cGet1)},oDlg1,060,008,"@E 999999",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSBtn1     := SButton():New( 008,116,1,{|| IF(BTNOKEMRG(),( nOpc := 1 , oDlg1:END()),) },oDlg1,,"", )
	oMManGetNew := TMultiGet():New(080,004,{|u|if(Pcount()>0,cMGetNew:=u,cMGetNew)},oDlg1,140,054,,.F.,,,,.T.,,,,,,.T.)
	oMManGetNew:EnableVScroll(.T.)
	oDlg1:Activate(,,,.T.)
	
	If nOpc == 1
		lRet := .F.
	EndIf           
Else
	Return !lRet
EndIf

Return lRet                                                                               
           
/*
Funcao      : BTNOKEMRG
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Valida Bot�o Ok do Controle de Acesso ao Repositorio Emergencial.
Autor     	: Jean Victor Rocha
Data     	: 14/01/2014
Obs         : 
*/
*----------------------------*
Static Function BTNOKEMRG()    
*----------------------------*
lRet := .T.

If EMPTY(cGet1)
	Alert("Cod. Acesso em Branco!","HLB BRASIL.")
	Return .F.
EndIf   

aArea := GetArea()
		
nCon := TCLink("MSSQL7/GTHD","10.0.30.5",7894) //MSM - 06/05/2016 - Ajuste para o novo top com license server
If Select("QRY") <> 0
	QRY->(DbCloseArea())
EndIf

cAmbHD := ""
If UPPER(Left(GetEnvServer(),3)) == "GTC"
	cAmbHD := "2"
ElseIf UPPER(Left(GetEnvServer(),3)) == "P11"
	cAmbHD := "1"
ElseIf UPPER(Left(GetEnvServer(),3)) == "P12"
	cAmbHD := "3"
EndIf

cTab := "% Z14010 %"
cWhere := ""
cWhere += "% Z14_PASS = '"+AllTrim(cGet1)+"' 
cWhere += " AND Z14_AMB = '"+cAmbHD+"'
cWhere += " AND Z14_EMERG = '"+UPPER(Right(GetEnvServer(),1))+"'
cWhere += " AND Z14_DTINI <= '"+DTOS(DATE())+"'
cWhere += " AND Z14_DTFIM >= '"+DTOS(DATE())+"'
cWhere += " %"

BeginSql Alias 'QRY'
	SELECT TOP 1 Z14_CODIGO
	FROM %exp:cTab%
	WHERE 	%notDel% 
			AND %exp:cWhere%
EndSql

QRY->(DbGoTop())
If QRY->(BOF() .and. EOF())	
	Alert("Cod. Acesso Invalida ou Expirada! favor verificar.")
	lRet := .F.
EndIf                             
QRY->(DbCloseArea())

//Encerra a conex�o
TCunLink(nCon)

RestArea(aArea)

Return lRet
