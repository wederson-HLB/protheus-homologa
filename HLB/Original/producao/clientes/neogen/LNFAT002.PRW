//--------------------------------------------------------------------------------------------------------------------------------------------//
// Sandro Silva - HLB - 10/10/2020
//--------------------------------------------------------------------------------------------------------------------------------------------//
// Específico NEOGEN                                                                                                                          //
// Faturamento                                                                                                                                //
//--------------------------------------------------------------------------------------------------------------------------------------------//
// Envio de PDF DANFE E BOLETO  automatico por e-mail.                                                                                        //
//--------------------------------------------------------------------------------------------------------------------------------------------//
//Bibliotecas
#include 'totvs.ch'
#include 'apwebsrv.ch'
#include 'tbiconn.ch'
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

User Function LNFAT002()  

Local aNFeId   := aClone(PARAMIXB[1])
Local nProc
Local cTssNom  := SuperGetMV("MV_XXTSSNM", .F.,"MSSQL7/TSS_02" ) //"MSSQL7/TSS_HOM")
Local cTssLoc  := SuperGetMV("MV_XXTSSLC", .F.,"10.0.30.56"     )//"srvdchomapp01.zion.lan")
Local cTssPor  := SuperGetMV("MV_XXTSSPR", .F.,7892)             //7895)

Private cArquivo,cFileName,cArqXML
Private cHora   := Strtran(Time(), ":", "")
Private cPasta	:= "C:\LN\"
Private cPCopy	:= "\LN\"
Private cEmail	:= "Teste"

If !ExistDir(cPasta)
	MakeDir(cPasta) 
Endif	

If !ExistDir(cPCopy)
	MakeDir(cPCopy)
Endif	

Sleep( 6000 )

For nProc := 1 To Len(aNFeId)       
     
      If Select("TRB_TSS1") <> 0
        TRB_TSS1->(DbCloseArea())
      EndIf   
                
      If Select("TRB_TSS2") <> 0
         TRB_TSS2->(DbCloseArea())
      EndIf  

      lAutorizada := .F.   
      aArea       := GetArea()  
      nConTss     := TcLink( cTssNom,cTssLoc,cTssPor )
      XML_NFE     := "" 
       
      If nConTss # 0
           dbUseArea( .T., "TOPCONN", "SPED001", "TRB_TSS1", .T., .T. )
           dbSelectArea("TRB_TSS1")
           While !Eof()
              If AllTrim(TRB_TSS1->CNPJ) == AllTrim(SM0->M0_CGC)
                 cIdEnt:= TRB_TSS1->ID_ENT
              EndIf
              dbSkip()
           End

           dbUseArea( .T., "TOPCONN", "SPED050", "TRB_TSS2", .T., .F. )
           
           If !TCCanOpen( "SPED050", "SPED05001" )
               // dbCreateIndex("SPED050Z", "ID_ENT+NFE_ID+DOC_CHV"  , {|| ID_ENT+NFE_ID+DOC_CHV   })
           EndIf
           dbClearind()
	       dbSetIndex("SPED05001") 
            
           dbSelectArea("TRB_TSS2")
           If dbSeek(cIdEnt+aNFeId[nProc])
              If TRB_TSS2->STATUS = 6
                 XML_NFE := TRB_TSS2->XML_SIG
                 lAutorizada := .T.
              EndIf   
           EndIf

           TCunLink(nConTss)
           RestArea(aArea)

           If lAutorizada

              SF2->(dbSetOrder(1))
              If SF2->(dbSeek(xFilial("SF2")+SubStr(aNFeId[nProc],4,9)+SubStr(aNFeId[nProc],1,3)))
                                                  
                 SA1->(dbSetOrder(1))
                 SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA) )    

                 U_GerDanfe(Right(aNFeId[nProc],9),Left(aNFeId[nProc],3),cPasta,XML_NFE) //Gera a Danfe em PDF e o xml                      
                 If SA1->A1_BLEMAIL == '1'  // 1 = Sim, o Cliente receberá o boleto via email, ou, 2 = Não
                    U_LNFIN002(Left(aNFeId[nProc],3),Right(aNFeId[nProc],9),cPasta ) // Gera o boleto em pdf
                 EndIf                 

                 U_Email(cPasta)  // Envio de email para o cliente do boleto,danfe em pdf e o xml.
                
              Endif 

           EndIf

      EndIf

 Next nProc        

Return
