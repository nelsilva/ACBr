{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2014 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/gpl-license.php                           }
{                                                                              }
{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }
{                                                                              }
{******************************************************************************}

{******************************************************************************
|* Historico
|*
|* 04/04/2013:  Andr� Ferreira de Moraes
|*   Inicio do desenvolvimento
******************************************************************************}
{$I ACBr.inc}

unit ACBrSATExtratoESCPOS;

interface

uses Classes, SysUtils,
     {$IFDEF FPC}
       LResources,
     {$ENDIF} 
     ACBrSATExtratoClass, ACBrPosPrinter,
     pcnCFe, pcnCFeCanc, pcnConversao;

type

   TACBrSATMarcaImpressora = (iEpson, iBematech);

  { TACBrSATExtratoESCPOS }
  TACBrSATExtratoESCPOS = class( TACBrSATExtratoClass )
  private
    FImprimeDescAcrescItem: Boolean;
    FImprimeEmUmaLinha: Boolean;
    FPosPrinter : TACBrPosPrinter ;
    FUsaCodigoEanImpressao: Boolean;

    procedure ImprimirCopias ;
    procedure SetPosPrinter(AValue: TACBrPosPrinter);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure AtivarPosPrinter;

    procedure GerarCabecalho(Cancelamento: Boolean = False);
    procedure GerarItens;
    procedure GerarTotais(Resumido : Boolean = False);
    procedure GerarPagamentos(Resumido : Boolean = False );
    procedure GerarObsFisco;
    procedure GerarDadosEntrega;
    procedure GerarObsContribuinte(Resumido : Boolean = False );
    procedure GerarRodape(CortaPapel: Boolean = True; Cancelamento: Boolean = False);
    procedure GerarDadosCancelamento;
  public
    constructor Create(AOwner: TComponent); override;

    procedure ImprimirExtrato(ACFe : TCFe = nil); override;
    procedure ImprimirExtratoResumido(ACFe : TCFe = nil); override;
    procedure ImprimirExtratoCancelamento(ACFe : TCFe = nil; ACFeCanc: TCFeCanc = nil); override;
  published
    property PosPrinter : TACBrPosPrinter read FPosPrinter write SetPosPrinter;

    property ImprimeEmUmaLinha: Boolean read FImprimeEmUmaLinha
      write FImprimeEmUmaLinha default True;
    property ImprimeDescAcrescItem: Boolean read FImprimeDescAcrescItem
      write FImprimeDescAcrescItem default True;
    property UsaCodigoEanImpressao: Boolean read FUsaCodigoEanImpressao
      write FUsaCodigoEanImpressao default False;
  end ;

procedure Register;

implementation

uses
  strutils, math,
  ACBrValidador, ACBrUtil, ACBrDFeUtil;

{$IFNDEF FPC}
   {$R ACBrSATExtratoESCPOS.dcr}
{$ENDIF}

procedure Register;
begin
  RegisterComponents('ACBrSAT',[TACBrSATExtratoESCPOS]);
end;

{ TACBrSATExtratoESCPOS }

constructor TACBrSATExtratoESCPOS.Create(AOwner: TComponent);
begin
  inherited create( AOwner );

  FPosPrinter := Nil;

  FImprimeEmUmaLinha := True;
  FImprimeDescAcrescItem := True;
  FUsaCodigoEanImpressao := False;
end;

procedure TACBrSATExtratoESCPOS.GerarCabecalho(Cancelamento: Boolean);
var        
  nCFe: String;
begin
  FPosPrinter.Buffer.Clear;
  FPosPrinter.Buffer.Add('</zera></ce></logo>');
  FPosPrinter.Buffer.Add('<n>'+CFe.Emit.xFant+'</n>');

  FPosPrinter.Buffer.Add('<c>'+CFe.Emit.xNome);
  FPosPrinter.Buffer.Add(Trim(CFe.Emit.EnderEmit.xLgr)+' '+
                         Trim(CFe.Emit.EnderEmit.nro)+' '+
                         Trim(CFe.Emit.EnderEmit.xCpl)+' '+
                         Trim(CFe.Emit.EnderEmit.xBairro)+'-'+
                         Trim(CFe.Emit.EnderEmit.xMun)+'-'+
                         FormatarCEP(IntToStr(CFe.Emit.EnderEmit.CEP)));

  FPosPrinter.Buffer.Add( '</ae><c>'+
                          'CNPJ:'+FormatarCNPJ(CFe.Emit.CNPJ)+
                           ' IE:'+Trim(CFe.Emit.IE)+
                           ' IM:'+Trim(CFe.Emit.IM));
  FPosPrinter.Buffer.Add('</linha_simples>');


  if CFe.ide.tpAmb = taHomologacao then
  begin
    FPosPrinter.Buffer.Add('</fn></ce><n>Extrato No. 000000');
    FPosPrinter.Buffer.Add(ACBrStr('CUPOM FISCAL ELETR�NICO - SAT</n>'));
    FPosPrinter.Buffer.Add(' ');
    FPosPrinter.Buffer.Add(' = T E S T E =');
    FPosPrinter.Buffer.Add(' ');
    FPosPrinter.Buffer.Add(StringOfChar('>',FPosPrinter.ColunasFonteNormal));
    FPosPrinter.Buffer.Add(StringOfChar('>',FPosPrinter.ColunasFonteNormal));
    FPosPrinter.Buffer.Add(StringOfChar('>',FPosPrinter.ColunasFonteNormal));
  end
  else
  begin
    if (Cancelamento) then
      nCFe := IntToStrZero( CFeCanc.ide.nCFe, 6)
    else
      nCFe := IntToStrZero( CFE.ide.nCFe, 6);
                                      
    FPosPrinter.Buffer.Add('</fn></ce><n>Extrato No. '+ nCFe );
    FPosPrinter.Buffer.Add( ACBrStr('CUPOM FISCAL ELETR�NICO - SAT</n>'));
  end;

  FPosPrinter.Buffer.Add('</linha_simples>');
  FPosPrinter.Buffer.Add('</ae><c>CPF/CNPJ do Consumidor: '+
                         FormatarCNPJouCPF(CFe.Dest.CNPJCPF));
end;

procedure TACBrSATExtratoESCPOS.GerarItens;
var
  i: Integer;
  nTamDescricao: Integer;
  fQuant, VlrLiquido: Double;
  sItem, sCodigo, sDescricao, sQuantidade, sUnidade, sVlrUnitario, sVlrProduto,
    sVlrImpostos, LinhaCmd: String;
begin
  FPosPrinter.Buffer.Add('</ae><c></linha_simples>');
  FPosPrinter.Buffer.Add(PadSpace('#|COD|DESC|QTD|UN|VL UN R$|(VLTR R$)*|VL ITEM R$',
                                  FPosPrinter.ColunasFonteCondensada, '|'));
  FPosPrinter.Buffer.Add('</linha_simples>');

  for i := 0 to CFe.Det.Count - 1 do
  begin
    sItem        := IntToStrZero(CFe.Det.Items[i].nItem, 3);
    sDescricao   := Trim(CFe.Det.Items[i].Prod.xProd);
    sUnidade     := Trim(CFe.Det.Items[i].Prod.uCom);
    sVlrProduto  := FormatFloat('#,###,##0.00', CFe.Det.Items[i].Prod.vProd);

    if (Length( Trim( CFe.Det.Items[i].Prod.cEAN ) ) > 0) and (UsaCodigoEanImpressao) then
      sCodigo := Trim(CFe.Det.Items[i].Prod.cEAN)
    else
      sCodigo := Trim(CFe.Det.Items[i].Prod.cProd);

    // formatar conforme configurado
    sVlrUnitario := FormatFloatBr(CFe.Det.Items[i].Prod.VUnCom, Mask_vUnCom );
    if CFe.Det.Items[i].Imposto.vItem12741 > 0 then
      sVlrImpostos := ' ('+FormatFloatBr(CFe.Det.Items[i].Imposto.vItem12741, '0.00')+') '
    else
      sVlrImpostos := ' ';

    // formatar conforme configurado somente quando houver decimais
    // caso contr�rio mostrar somente o n�mero inteiro
    fQuant := CFe.Det.Items[i].Prod.QCom;
    if Frac(fQuant) > 0 then
      sQuantidade := FormatFloatBr(fQuant, Mask_qCom )
    else
      sQuantidade := FloatToStr(fQuant);

    if ImprimeEmUmaLinha then
    begin
      LinhaCmd := sItem + ' ' + sCodigo + ' ' + '[DesProd] ' + sQuantidade + ' ' +
        sUnidade + ' X ' + sVlrUnitario + sVlrImpostos + sVlrProduto;

      // acerta tamanho da descri��o
      nTamDescricao := FPosPrinter.ColunasFonteCondensada - Length(LinhaCmd) + 9;
      sDescricao := PadRight(Copy(sDescricao, 1, nTamDescricao), nTamDescricao);

      LinhaCmd := StringReplace(LinhaCmd, '[DesProd]', sDescricao, [rfReplaceAll]);
      FPosPrinter.Buffer.Add('</ae><c>' + LinhaCmd);
    end
    else
    begin
      LinhaCmd := sItem + ' ' + sCodigo + ' ' + sDescricao;
      FPosPrinter.Buffer.Add('</ae><c>' + LinhaCmd);

      LinhaCmd :=
        PadRight(sQuantidade, 15) + ' ' + PadRight(sUnidade, 6) + ' X ' +
        PadRight(sVlrUnitario, 13) + '|' + sVlrImpostos + sVlrProduto;

      LinhaCmd := padSpace(LinhaCmd, FPosPrinter.ColunasFonteCondensada, '|');
      FPosPrinter.Buffer.Add('</ae><c>' + LinhaCmd);
    end;

    if ImprimeDescAcrescItem then
    begin
      // desconto
      if CFe.Det.Items[i].Prod.vDesc > 0 then
      begin
        VlrLiquido := CFe.Det.Items[i].Prod.vProd - CFe.Det.Items[i].Prod.vDesc;

        LinhaCmd := '</ae><c>' + padSpace(
            'desconto ' + padLeft(FormatFloatBr(CFe.Det.Items[i].Prod.vDesc, '-0.00'), 15, ' ')
            + '|' + FormatFloatBr(VlrLiquido, '0.00'),
            FPosPrinter.ColunasFonteCondensada, '|');
        FPosPrinter.Buffer.Add('</ae><c>' + LinhaCmd);
      end;

      // ascrescimo
      if CFe.Det.Items[i].Prod.vOutro > 0 then
      begin
        VlrLiquido := CFe.Det.Items[i].Prod.vProd + CFe.Det.Items[i].Prod.vOutro;

        LinhaCmd := '</ae><c>' + ACBrStr(padSpace(
            'acr�scimo ' + padLeft(FormatFloatBr(CFe.Det.Items[i].Prod.vOutro, '+0.00'), 15, ' ')
            + '|' + FormatFloatBr(VlrLiquido, '0.00'),
            FPosPrinter.ColunasFonteCondensada, '|'));
        FPosPrinter.Buffer.Add('</ae><c>' + LinhaCmd);
      end;
    end;

    if CFe.Det.Items[i].Imposto.ISSQN.vDeducISSQN > 0 then
    begin
      FPosPrinter.Buffer.Add(ACBrStr(PadSpace('Dedu��o para ISSQN|'+
         FormatFloatBr(CFe.Det.Items[i].Imposto.ISSQN.vDeducISSQN, '-#,###,##0.00'),
         FPosPrinter.ColunasFonteCondensada, '|')));
      FPosPrinter.Buffer.Add(ACBrStr(PadSpace('Base de c�lculo ISSQN|'+
         FormatFloatBr(CFe.Det.Items[i].Imposto.ISSQN.vBC, '#,###,##0.00'),
         FPosPrinter.ColunasFonteCondensada, '|')));
    end;

  end;
end;

procedure TACBrSATExtratoESCPOS.GerarTotais(Resumido: Boolean);
var
  Descontos, Acrescimos: Double;
begin
  if not Resumido then
   begin
     Descontos  := (CFe.Total.ICMSTot.vDesc  + CFe.Total.DescAcrEntr.vDescSubtot);
     Acrescimos := (CFe.Total.ICMSTot.vOutro + CFe.Total.DescAcrEntr.vAcresSubtot);

     if (Descontos > 0) or (Acrescimos > 0) then
        FPosPrinter.Buffer.Add('<c>'+PadSpace('Subtotal|'+
           FormatFloatBr(CFe.Total.ICMSTot.vProd, '#,###,##0.00'),
           FPosPrinter.ColunasFonteCondensada, '|'));

     if Descontos > 0 then
        FPosPrinter.Buffer.Add('<c>'+PadSpace('Descontos|'+
           FormatFloatBr(Descontos, '-#,###,##0.00'),
           FPosPrinter.ColunasFonteCondensada, '|'));

     if Acrescimos > 0 then
        FPosPrinter.Buffer.Add('<c>'+ACBrStr(PadSpace('Acr�scimos|'+
           FormatFloatBr(Acrescimos, '+#,###,##0.00'),
           FPosPrinter.ColunasFonteCondensada, '|')));
   end;

  FPosPrinter.Buffer.Add('</ae></fn><e>'+PadSpace('TOTAL R$|'+
     FormatFloatBr(CFe.Total.vCFe, '#,###,##0.00'),
     trunc(FPosPrinter.ColunasFonteExpandida), '|')+'</e>');
end;

procedure TACBrSATExtratoESCPOS.GerarPagamentos(Resumido : Boolean = False );
var
  i : integer;
begin
  if not Resumido then
    FPosPrinter.Buffer.Add('');

  for i:=0 to CFe.Pagto.Count - 1 do
  begin
    FPosPrinter.Buffer.Add('<c>'+ACBrStr(PadSpace(CodigoMPToDescricao(CFe.Pagto.Items[i].cMP)+'|'+
                FormatFloatBr(CFe.Pagto.Items[i].vMP, '#,###,##0.00'),
                FPosPrinter.ColunasFonteCondensada, '|')));
  end;

  if CFe.Pagto.vTroco > 0 then
    FPosPrinter.Buffer.Add('<c>'+PadSpace('Troco R$|'+
       FormatFloatBr(CFe.Pagto.vTroco, '#,###,##0.00'),
       FPosPrinter.ColunasFonteCondensada, '|'));
end;

procedure TACBrSATExtratoESCPOS.GerarObsFisco;
var
  i : integer;
begin
  if (CFe.InfAdic.obsFisco.Count > 0) or
     (CFe.Emit.cRegTrib = RTSimplesNacional) then
     FPosPrinter.Buffer.Add('');

  if CFe.Emit.cRegTrib = RTSimplesNacional then
     FPosPrinter.Buffer.Add('<c>' + Msg_ICMS_123_2006 );

  for i:=0 to CFe.InfAdic.obsFisco.Count - 1 do
     FPosPrinter.Buffer.Add('<c>'+CFe.InfAdic.obsFisco.Items[i].xCampo+'-'+
                                  CFe.InfAdic.obsFisco.Items[i].xTexto);
end;

procedure TACBrSATExtratoESCPOS.GerarDadosEntrega;
begin
  if Trim(CFe.Entrega.xLgr)+
     Trim(CFe.Entrega.nro)+
     Trim(CFe.Entrega.xCpl)+
     Trim(CFe.Entrega.xBairro)+
     Trim(CFe.Entrega.xMun)+
     Trim(CFe.Dest.xNome) <> '' then
   begin
     FPosPrinter.Buffer.Add('</fn></linha_simples>');
     FPosPrinter.Buffer.Add('DADOS PARA ENTREGA');
     FPosPrinter.Buffer.Add('<c>'+Trim(CFe.Entrega.xLgr)+' '+
                                  Trim(CFe.Entrega.nro)+' '+
                                  Trim(CFe.Entrega.xCpl)+' '+
                                  Trim(CFe.Entrega.xBairro)+' '+
                                  Trim(CFe.Entrega.xMun));
     FPosPrinter.Buffer.Add(CFe.Dest.xNome);
   end;
end;

procedure TACBrSATExtratoESCPOS.GerarObsContribuinte(Resumido : Boolean = False );
var
  CabecalhoGerado: Boolean;

  procedure GerarCabecalhoObsContribuinte;
  begin
    FPosPrinter.Buffer.Add('</fn></linha_simples>');
    FPosPrinter.Buffer.Add(ACBrStr('OBSERVA��ES DO CONTRIBUINTE'));
    CabecalhoGerado := True;
  end;

begin
  CabecalhoGerado := False;

  if Trim(CFe.InfAdic.infCpl) <> '' then
  begin
    GerarCabecalhoObsContribuinte;
    FPosPrinter.Buffer.Add('<c>'+StringReplace(Trim(CFe.InfAdic.infCpl),';',sLineBreak,[rfReplaceAll]));
  end;

  if CFe.Total.vCFeLei12741 > 0 then
  begin
    if not CabecalhoGerado then
      GerarCabecalhoObsContribuinte
    else
      FPosPrinter.Buffer.Add(' ');

    if not Resumido then
      FPosPrinter.Buffer.Add('<c>*Valor aproximado dos tributos do item');

    FPosPrinter.Buffer.Add('<c>'+PadSpace('Valor aproximado dos tributos deste cupom R$ |<n>'+
                FormatFloatBr(CFe.Total.vCFeLei12741, '#,###,##0.00'),
                FPosPrinter.ColunasFonteCondensada, '|'));
    FPosPrinter.Buffer.Add('</n>(conforme Lei Fed. 12.741/2012)');
  end;
end;

procedure TACBrSATExtratoESCPOS.GerarRodape(CortaPapel: Boolean = True; Cancelamento: Boolean = False);
var
  QRCode, Chave: String;
  ConfigQRCodeTipo, ConfigQRCodeErrorLevel: Integer;
begin
  FPosPrinter.Buffer.Add('</fn></linha_simples>');
  if Cancelamento then
     FPosPrinter.Buffer.Add(ACBrStr('<n>DADOS DO CUPOM FISCAL ELETR�NICO CANCELADO</n>'));

  Chave := FormatarChaveAcesso(CFe.infCFe.ID);
  if Length(Chave) > FPosPrinter.ColunasFonteCondensada then
    Chave := OnlyNumber(Chave);

  FPosPrinter.Buffer.Add('</ce>SAT No. <n>'+IntToStr(CFe.ide.nserieSAT)+'</n>');
  FPosPrinter.Buffer.Add(FormatDateTimeBr(CFe.ide.dEmi + CFe.ide.hEmi));
  FPosPrinter.Buffer.Add('<c>'+Chave+'</fn>');

  FPosPrinter.Buffer.Add('<code128>'+copy(CFe.infCFe.ID,1,22)+'</code128>');
  FPosPrinter.Buffer.Add('<code128>'+copy(CFe.infCFe.ID,23,22)+'</code128>');

  if ImprimeQRCode then
  begin
    ConfigQRCodeTipo := FPosPrinter.ConfigQRCode.Tipo;
    ConfigQRCodeErrorLevel := FPosPrinter.ConfigQRCode.ErrorLevel;

    QRCode := CalcularConteudoQRCode( CFe.infCFe.ID,
                                      CFe.ide.dEmi+CFe.ide.hEmi,
                                      CFe.Total.vCFe,
                                      Trim(CFe.Dest.CNPJCPF),
                                      CFe.ide.assinaturaQRCODE );

    FPosPrinter.Buffer.Add('<qrcode_tipo>2</qrcode_tipo>'+
                           '<qrcode_error>0</qrcode_error>'+
                           '<qrcode>'+QRCode+'</qrcode>'+
                           '<qrcode_tipo>'+IntToStr(ConfigQRCodeTipo)+'</qrcode_tipo>'+
                           '<qrcode_error>'+IntToStr(ConfigQRCodeErrorLevel)+'</qrcode_error>');
  end;

  if CortaPapel then
  begin
    if FPosPrinter.CortaPapel then
      FPosPrinter.Buffer.Add('</corte_total>')
    else
      FPosPrinter.Buffer.Add('</pular_linhas>');
  end;
end;

procedure TACBrSATExtratoESCPOS.GerarDadosCancelamento;
Var
  ConfigQRCodeTipo, ConfigQRCodeErrorLevel: Integer;
var
  QRCode: AnsiString;
begin
  FPosPrinter.Buffer.Add('</fn></linha_simples>');
  FPosPrinter.Buffer.Add(ACBrStr('<n>DADOS DO CUPOM FISCAL ELETR�NICO DE CANCELAMENTO</n>'));
  FPosPrinter.Buffer.Add('</ce>SAT No. <n>'+IntToStr(CFe.ide.nserieSAT)+'</n>');
  FPosPrinter.Buffer.Add(FormatDateTimeBr(CFeCanc.ide.dEmi + CFeCanc.ide.hEmi));
  FPosPrinter.Buffer.Add('<c>'+FormatarChaveAcesso((CFeCanc.infCFe.ID))+'</fn>');

  FPosPrinter.Buffer.Add('<code128>'+copy(CFeCanc.infCFe.ID,1,22)+'</code128>');
  FPosPrinter.Buffer.Add('<code128>'+copy(CFeCanc.infCFe.ID,23,22)+'</code128>');

  if ImprimeQRCode then
  begin
    ConfigQRCodeTipo := FPosPrinter.ConfigQRCode.Tipo;
    ConfigQRCodeErrorLevel := FPosPrinter.ConfigQRCode.ErrorLevel;

    QRCode := CalcularConteudoQRCode( CFeCanc.infCFe.ID,
                                      CFeCanc.ide.dEmi+CFeCanc.ide.hEmi,
                                      CFeCanc.Total.vCFe,
                                      Trim(CFeCanc.Dest.CNPJCPF),
                                      CFeCanc.ide.assinaturaQRCODE );

    FPosPrinter.Buffer.Add('<qrcode_tipo>2</qrcode_tipo>'+
                           '<qrcode_error>0</qrcode_error>'+
                           '<qrcode>'+QRCode+'</qrcode>'+
                           '<qrcode_tipo>'+IntToStr(ConfigQRCodeTipo)+'</qrcode_tipo>'+
                           '<qrcode_error>'+IntToStr(ConfigQRCodeErrorLevel)+'</qrcode_error>');
  end;

  if FPosPrinter.CortaPapel then
    FPosPrinter.Buffer.Add('</corte_total>')
  else
    FPosPrinter.Buffer.Add('</pular_linhas>');
end;

procedure TACBrSATExtratoESCPOS.ImprimirCopias;
begin
  FPosPrinter.Imprimir( '', False, True, True, NumCopias);   // Imprime o Buffer
end;

procedure TACBrSATExtratoESCPOS.SetPosPrinter(AValue: TACBrPosPrinter);
begin
  if AValue <> FPosPrinter then
  begin
     if Assigned(FPosPrinter) then
        FPosPrinter.RemoveFreeNotification(Self);

     FPosPrinter := AValue;

     if AValue <> nil then
        AValue.FreeNotification(self);
  end ;
end;

procedure TACBrSATExtratoESCPOS.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) then
  begin
    if (AComponent is TACBrPosPrinter) and (FPosPrinter <> nil) then
       FPosPrinter := nil ;
  end;
end;

procedure TACBrSATExtratoESCPOS.AtivarPosPrinter;
begin
  if not Assigned( FPosPrinter ) then
    raise Exception.Create('Componente PosPrinter n�o associado');

  FPosPrinter.Ativar;
end;

procedure TACBrSATExtratoESCPOS.ImprimirExtrato(ACFe: TCFe);
begin
  inherited;

  AtivarPosPrinter;

  GerarCabecalho;
  GerarItens;
  GerarTotais;
  GerarPagamentos;
  GerarObsFisco;
  GerarDadosEntrega;
  GerarObsContribuinte;
  GerarRodape;

  ImprimirCopias;
end;

procedure TACBrSATExtratoESCPOS.ImprimirExtratoCancelamento(ACFe: TCFe;
  ACFeCanc: TCFeCanc);
begin
  inherited;

  AtivarPosPrinter;

  GerarCabecalho(True);
  GerarTotais(True);
  GerarRodape(False, True);
  GerarDadosCancelamento;

  ImprimirCopias;
end;

procedure TACBrSATExtratoESCPOS.ImprimirExtratoResumido(ACFe: TCFe);
begin
  inherited;

  AtivarPosPrinter;

  GerarCabecalho;
  GerarTotais(True);
  GerarPagamentos(True);
  GerarObsFisco;
  GerarDadosEntrega;
  GerarObsContribuinte(True);
  GerarRodape;

  ImprimirCopias;
end;

{$IFDEF FPC}
{$IFNDEF NOGUI}
initialization
   {$I ACBrSATExtratoESCPOS.lrs}
{$ENDIF}
{$ENDIF}

end.
