//-------------------------------------------------------------------------------------------------------------------------------------------------//
//Wederson L. Santana - 15/03/2021                                                                                                                      //
//-------------------------------------------------------------------------------------------------------------------------------------------------//
//Compras - Ponto de entrada filtro solicitação de compras.                                                                                                                     //
//-------------------------------------------------------------------------------------------------------------------------------------------------//

#Include "Rwmake.ch"

User Function MT110FIL()
Local cFiltro 
Local cIdGestor := SuperGetMV("MV__GERCOM", .F.,"000898/000899/000900/000901")
Local aAlias    := GetArea()

If cEmpAnt $ "XF"   

    If! __cUserId $ AllTrim(cIdGestor)

        _cFiltro:="C1_USER ='"+__cUserId+"'"  
        
    EndIf    

EndIf

RestArea(aAlias)
Return(cFiltro)   
