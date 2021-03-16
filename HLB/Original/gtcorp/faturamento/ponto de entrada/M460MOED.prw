#include 'protheus.ch'
#include 'parmtype.ch'

/*/
�������������������������������������������������������������
�������������������������������������������������������������
���������������������������������������������������������¿��
��?Programa  * M460MOED.PRW *                            ��?
��?Autor     * Guilherme Fernandes Pilan - GFP *          ��?
��?Data      * 06/03/2017 - 11:07 *                       ��?
�������������������������������������������������������������
��?Descricao * Ponto de Entrada do fonte MATA461 *        ��?
���������������������������������������������������������Ĵ��
��?PE        * M460MOED * Executado durante a gera��o da  ��?
��?          *             NF para validar o tipo de moeda��?
                           na gera��o do Contas a Receber*��?
���������������������������������������������������������Ĵ��
��?Uso       * FATURAMENTO                                ��?
����������������������������������������������������������ٱ�
�������������������������������������������������������������
�������������������������������������������������������������
/*/
*-----------------------*
User Function M460MOED()
*-----------------------*
Local cMoedaTit := If(Type("ParamIxb") = "A",ParamIxb[1],If(Type("ParamIxb") = "C",ParamIxb,""))
Local aOrd := SaveOrd("SA1")

SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
	cMoedaTit := IF(SA1->A1_EST == "EX","S","N")
EndIf

RestOrd(aOrd,.T.)
Return cMoedaTit