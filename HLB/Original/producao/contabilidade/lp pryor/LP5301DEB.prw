#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

User Function LP5301DEB()        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

//------------------//
// JOS� FERREIRA    //
//------------------//
//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_CDEBITO,")


_CDEBITO := " "


IF SM0->M0_CODIGO $ "71"         ///D A STUART

		    _CDEBITO:="211110001"
	
	ELSE
	
	   	 _CDEBITO:="211130001"
	

ENDIF
	
Return(_CDEBITO)        
