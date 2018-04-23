{******************************************************************************}
{ Projeto: Componente ACBreSocial                                              }
{  Biblioteca multiplataforma de componentes Delphi para envio dos eventos do  }
{ eSocial - http://www.esocial.gov.br/                                         }
{                                                                              }
{ Direitos Autorais Reservados (c) 2008 Wemerson Souto                         }
{                                       Daniel Simoes de Almeida               }
{                                       Andr� Ferreira de Moraes               }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do Projeto ACBr     }
{ Componentes localizado em http://www.sourceforge.net/projects/acbr           }
{                                                                              }
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
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }
{                                                                              }
{******************************************************************************}

{******************************************************************************
|* Historico
|*
|* 27/10/2015: Jean Carlo Cantu, Tiago Ravache
|*  - Doa��o do componente para o Projeto ACBr
|* 01/03/2016: Guilherme Costa
|*  - Altera��es para valida��o com o XSD
******************************************************************************}
{$I ACBr.inc}

unit pcesS2230;

interface

uses
  SysUtils, Classes,
  pcnConversao, pcnGerador, ACBrUtil,
  pcesCommon, pcesConversaoeSocial, pcesGerador;

type
  TS2230Collection = class;
  TS2230CollectionItem = class;
  TEvtAfastTemp = class;
  TinfoAfastamento = class;
  TiniAfastamento = class;
  TaltAfastamento = class;
  TAltEmpr = class;
  TfimAfastamento = class;
  TinfoAtestado = class;
  TinfoAtestadoItem = class;
  TinfoCessao = class;
  TinfoMandSind = class;
  TinfoRetif = class;

  TS2230Collection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TS2230CollectionItem;
    procedure SetItem(Index: Integer; Value: TS2230CollectionItem);
  public
    function Add: TS2230CollectionItem;
    property Items[Index: Integer]: TS2230CollectionItem read GetItem write SetItem; default;
  end;

  TS2230CollectionItem = class(TCollectionItem)
  private
    FTipoEvento: TTipoEvento;
    FEvtAfastTemp: TEvtAfastTemp;

    procedure setEvtAfastTemp(const Value: TEvtAfastTemp);
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;
  published
    property TipoEvento: TTipoEvento read FTipoEvento;
    property EvtAfastTemp: TEvtAfastTemp read FEvtAfastTemp write setEvtAfastTemp;
  end;

  TEvtAfastTemp = class(TeSocialEvento)
  private
    FIdeEvento : TIdeEvento2;
    FIdeEmpregador : TIdeEmpregador;
    FIdeVinculo : TIdeVinculo;
    FinfoAfastamento : TinfoAfastamento;
    FACBreSocial: TObject;

    procedure GerarInfoAfastamento(objInfoAfast: TinfoAfastamento);
    procedure GerarInfoAtestado(objInfoAtestado: TinfoAtestado);
    procedure GerarInfoCessao(objInfoCessao: TinfoCessao);
    procedure GerarInfoMandSind(objInfoMandSind: TInfoMandSind);
//    procedure GerarAltAfast(objAltAfast: TaltAfastamento);
//    procedure GerarAltEmpr(pAltEmpr: TAltEmpr);
    procedure GerarInfoRetif(objInfoRetif: TInfoRetif);
    procedure GerarFimAfast(objFimAfast: TfimAfastamento);
  public
    constructor Create(AACBreSocial: TObject);overload;
    destructor  Destroy; override;

    function GerarXML: boolean; override;
    function LerArqIni(const AIniString: String): Boolean;

    property IdeEvento: TIdeEvento2 read FIdeEvento write FIdeEvento;
    property IdeEmpregador: TIdeEmpregador read FIdeEmpregador write FIdeEmpregador;
    property IdeVinculo: TIdeVinculo read FIdeVinculo write FIdeVinculo;
    property infoAfastamento: TinfoAfastamento read FinfoAfastamento write FinfoAfastamento;
  end;

  TinfoAfastamento = class(TPersistent)
  private
    FiniAfastamento : TiniAfastamento;
    FaltAfastamento : TaltAfastamento;
    FinfoRetif: TinfoRetif;
    FfimAfastamento : TfimAfastamento;
  public
    constructor create;
    destructor  destroy; override;

    property iniAfastamento: TiniAfastamento read FiniAfastamento write FiniAfastamento;
    property altAfastamento: TaltAfastamento read FaltAfastamento write FaltAfastamento;
    property infoRetif: TinfoRetif read FinfoRetif write FinfoRetif;
    property fimAfastamento: TfimAfastamento read FfimAfastamento write FfimAfastamento;
  end;

  tiniAfastamento = class(TAfastamento)
  private
    FInfoMesmoMtv: tpSimNao;
    FtpAcidTransito: tpTpAcidTransito;
    FObservacao: String;
    FinfoAtestado: TinfoAtestado;
    FinfoCessao: TinfoCessao;
    FinfoMandSind: TinfoMandSind;

    function getInfoAtestado: TinfoAtestado;
  public
    constructor create;
    destructor  destroy; override;

    function infoAtestadoInst: boolean;

    property infoMesmoMtv: tpSimNao read FInfoMesmoMtv write FInfoMesmoMtv;
    property tpAcidTransito: tpTpAcidTransito read FtpAcidTransito write FtpAcidTransito;
    property Observacao: String read FObservacao write FObservacao;
    property infoAtestado: TinfoAtestado read getInfoAtestado write FinfoAtestado;
    property infoCessao: TinfoCessao read FinfoCessao write FinfoCessao;
    property infoMandSind : TinfoMandSind read FinfoMandSind write FinfoMandSind;
  end;

  TinfoAtestado = class(TCollection)
  private
    function GetItem(Index: Integer): TinfoAtestadoItem;
    procedure SetItem(Index: Integer; Value: TinfoAtestadoItem);
  public
    constructor create(); reintroduce;
    function Add: TinfoAtestadoItem;
    property Items[Index: Integer]: TinfoAtestadoItem read GetItem write SetItem; default;
  end;

  TinfoAtestadoItem = class(TCollectionItem)
  private
    FcodCID : String;
    FqtDiasAfast : Integer;
    FEmitente : TEmitente;

    function getEmitente: TEmitente;
  public
    constructor create; reintroduce;
    destructor  destroy; override;

    function emitenteInst: boolean;

    property codCID: String read FCodCId write FcodCID;
    property qtDiasAfast: Integer read FqtDiasAfast write FqtDiasAfast;
    property Emitente: TEmitente read getEmitente write FEmitente;
  end;

  TinfoCessao = class(TPersistent)
  private
    FcnpjCess : String;
    FinfOnus : tpInfOnus;
  public
    property cnpjCess: String read FcnpjCess write FcnpjCess;
    property infOnus: tpInfOnus read FinfOnus write FinfOnus;
  end;

  TinfoMandSind = class(TPersistent)
  private
    FcnpjSind : String;
    FinfOnusRemun: tpOnusRemun;
  public
    property cnpjSind: String read FcnpjSind write FcnpjSind;
    property infOnusRemun: tpOnusRemun read FinfOnusRemun write FinfOnusRemun;
  end;

  TAltEmpr = class(TPersistent)
  private
    FCodCID: string;
    FQtdDiasAfast: Integer;
    FNmEmit: string;
    FIdeOC: tpIdeOC;
    FNrOc: string;
    FUfOc: tpuf;
  public
    property codCID: String read FCodCID write FCodCID;
    property qtdDiasAfast: integer read FQtdDiasAfast write FQtdDiasAfast;
    property nmEmit: string read FNmEmit write FNmEmit;
    property ideOC: tpIdeOC read FIdeOC write FIdeOC;
    property nrOc: String read FNrOc write FNrOc;
    property ufOC: tpuf read FUfOc write FUfOc;
  end;

  TaltAfastamento = class(TPersistent) //altera��o do motivo do afastamento
  private
    FdtAltMot: TDateTime;
    FcodMotAnt : String;
    FcodMotAfast: String;
    FInfoMesmoMtv: tpSimNao;
    FindEfRetroativo: tpSimNao;
    FOrigAlt: tpOrigemAltAfast;
    FNrProcJud: string;
    FAltEmpr: TAltEmpr;

    function getAltEmpr: TAltEmpr;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    function altEmprInst: boolean;

    property dtAltMot: TDateTime read FdtAltMot write FdtAltMot;
    property codMotAnt: String read FcodMotAnt write FcodMotAnt;
    property codMotAfast: String read FcodMotAfast write FcodMotAfast;
    property infoMesmoMtv: tpSimNao read FInfoMesmoMtv write FInfoMesmoMtv;
    property indEfRetroativo: tpSimNao read FindEfRetroativo write FindEfRetroativo;
    property origAlt: tpOrigemAltAfast read FOrigAlt write FOrigAlt;
    property nrProcJud: string read FNrProcJud write FNrProcJud;
    property altEmpr: TAltEmpr read getAltEmpr write FAltEmpr;
  end;

  TfimAfastamento = class(TPersistent)
  private
    FdtTermAfast : TDateTime;
  public
    property dtTermAfast: TDateTime read FdtTermAfast write FdtTermAfast;
  end;

  TinfoRetif = class(TPersistent)
  private
    ForigRetif: Integer;
    FTpProc: tpTpProc;
    FnrProc: String;
  public
    property origRetif: Integer read ForigRetif write ForigRetif;
    property tpProc: tpTpProc read FTpProc write FTpProc;
    property nrProc: String read FnrProc write FnrProc;
  end;

implementation

uses
  IniFiles,
  ACBreSocial, ACBrDFeUtil;

{ TS2230Collection }

function TS2230Collection.Add: TS2230CollectionItem;
begin
  Result := TS2230CollectionItem(inherited Add);
  Result.Create(TComponent(Self.Owner));
end;

function TS2230Collection.GetItem(Index: Integer): TS2230CollectionItem;
begin
  Result := TS2230CollectionItem(inherited GetItem(Index));
end;

procedure TS2230Collection.SetItem(Index: Integer; Value: TS2230CollectionItem);
begin
  inherited SetItem(Index, Value);
end;

{ TS2230CollectionItem }

constructor TS2230CollectionItem.Create(AOwner: TComponent);
begin
  FTipoEvento := teS2230;
  FEvtAfastTemp := TEvtAfastTemp.Create(AOwner);
end;

destructor TS2230CollectionItem.Destroy;
begin
  FEvtAfastTemp.Free;

  inherited;
end;

procedure TS2230CollectionItem.setEvtAfastTemp(const Value: TEvtAfastTemp);
begin
  FEvtAfastTemp.Assign(Value);
end;

{ TinfoAfastamento }

constructor TinfoAfastamento.create;
begin
  inherited;

  FiniAfastamento := TiniAfastamento.Create;
  FaltAfastamento := TaltAfastamento.Create;
  FinfoRetif := TinfoRetif.Create;
  FfimAfastamento := TfimAfastamento.Create;
end;

destructor TinfoAfastamento.destroy;
begin
  FiniAfastamento.Free;
  FaltAfastamento.Free;
  FinfoRetif.Free;
  FfimAfastamento.Free;

  inherited;
end;

{ tiniAfastamento }

constructor tiniAfastamento.create;
begin
  inherited;

  FinfoAtestado := nil;
  FinfoCessao := TinfoCessao.Create;
  FinfoMandSind := TinfoMandSind.Create;
end;

destructor tiniAfastamento.destroy;
begin
  FreeAndNil(FInfoAtestado);
  FinfoCessao.Free;
  FinfoMandSind.Free;

  inherited;
end;

function tiniAfastamento.getInfoAtestado: TinfoAtestado;
begin
  if not Assigned(FinfoAtestado) then
    FinfoAtestado := TinfoAtestado.create;
  Result := FinfoAtestado;
end;

function tiniAfastamento.infoAtestadoInst: boolean;
begin
  result := Assigned(FinfoAtestado);
end;

{ TinfoAtestado }

function TinfoAtestado.Add: TinfoAtestadoItem;
begin
  Result := TinfoAtestadoItem(inherited add());
  Result.Create;
end;

constructor TinfoAtestado.create;
begin
  Inherited create(TinfoAtestadoItem);
end;

function TinfoAtestado.GetItem(
  Index: Integer): TinfoAtestadoItem;
begin
  Result := TinfoAtestadoItem(inherited GetItem(Index));
end;

procedure TinfoAtestado.SetItem(Index: Integer;
  Value: TinfoAtestadoItem);
begin
  inherited SetItem(Index, Value);
end;

{ TinfoAtestadoItem }

constructor TinfoAtestadoItem.create;
begin
  FEmitente := nil;
end;

destructor TinfoAtestadoItem.destroy;
begin
  FreeAndNil(FEmitente);

  inherited;
end;

function TinfoAtestadoItem.getEmitente: TEmitente;
begin
  if not assigned(FEmitente) then
    FEmitente := TEmitente.Create;
  Result := FEmitente;
end;

function TinfoAtestadoItem.emitenteInst: boolean;
begin
  result := Assigned(FEmitente);
end;

{ TaltAfastamento }

constructor TaltAfastamento.Create;
begin
  inherited;

  FAltEmpr := nil;
end;

destructor TaltAfastamento.Destroy;
begin
  FreeAndNil(FAltEmpr);

  inherited;
end;

function TaltAfastamento.getAltEmpr: TAltEmpr;
begin
  if not Assigned(FAltEmpr) then
    FAltEmpr := TAltEmpr.Create;
  Result := FAltEmpr;
end;

function TaltAfastamento.altEmprInst: boolean;
begin
  result := Assigned(FAltEmpr);
end;

{ TEvtAfastTemp }

constructor TEvtAfastTemp.Create(AACBreSocial: TObject);
begin
  inherited;

  FACBreSocial := AACBreSocial;
  FIdeEvento := TIdeEvento2.Create;
  FIdeEmpregador := TIdeEmpregador.Create;
  FIdeVinculo := TIdeVinculo.Create;
  FinfoAfastamento := TinfoAfastamento.Create;
end;

destructor TEvtAfastTemp.Destroy;
begin
  FIdeEvento.Free;
  FIdeEmpregador.Free;
  FideVinculo.Free;
  FinfoAfastamento.Free;

  inherited;
end;

procedure TEvtAfastTemp.GerarInfoAfastamento(objInfoAfast: TinfoAfastamento);
begin
  Gerador.wGrupo('infoAfastamento');

  if (DateToStr(objInfoAfast.iniAfastamento.DtIniAfast) <> dDataBrancoNula) then
  begin
    Gerador.wGrupo('iniAfastamento');

    Gerador.wCampo(tcDat, '', 'dtIniAfast',  10,  10, 1, objInfoAfast.iniAfastamento.DtIniAfast);
    Gerador.wCampo(tcStr, '', 'codMotAfast',  1,   2, 1, eStpMotivosAfastamentoToStr(objInfoAfast.iniAfastamento.codMotAfast));

    if (objInfoAfast.iniAfastamento.codMotAfast in [mtvAcidenteDoencaTrabalho, mtvAcidenteDoencaNaoTrabalho]) then
    begin
      Gerador.wCampo(tcStr, '', 'infoMesmoMtv',   1, 1, 0, eSSimNaoToStr(objInfoAfast.iniAfastamento.infoMesmoMtv));
      if ( objInfoAfast.iniAfastamento.tpAcidTransito <> tpatNao ) then
        Gerador.wCampo(tcStr, '', 'tpAcidTransito', 1, 1, 0, eStpTpAcidTransitoToStr(objInfoAfast.iniAfastamento.tpAcidTransito));
    end;

    Gerador.wCampo(tcStr, '', 'observacao', 1, 255, 0, objInfoAfast.iniAfastamento.Observacao);

    if objInfoAfast.iniAfastamento.infoAtestadoInst then
      GerarInfoAtestado(objInfoAfast.iniAfastamento.infoAtestado);

    if Assigned(objInfoAfast.iniAfastamento.infoCessao) then
      GerarInfoCessao(objInfoAfast.iniAfastamento.infoCessao);

    if Assigned(objInfoAfast.iniAfastamento.infoMandSind) then
      GerarInfoMandSind(objInfoAfast.iniAfastamento.infoMandSind);

    Gerador.wGrupo('/iniAfastamento');
  end;

  //    GerarAltAfast(objInfoAfast.altAfastamento);
  GerarInfoRetif(objInfoAfast.FinfoRetif);

  if (DateToStr(objInfoAfast.fimAfastamento.dtTermAfast) <> dDataBrancoNula) then
    GerarFimAfast(objInfoAfast.fimAfastamento);

  Gerador.wGrupo('/infoAfastamento');
end;

procedure TEvtAfastTemp.GerarInfoAtestado(objInfoAtestado: TinfoAtestado);
var
  i: Integer;
begin
  for i := 0 to objInfoAtestado.Count - 1 do
  begin
    Gerador.wGrupo('infoAtestado');

    Gerador.wCampo(tcStr, '', 'codCID',       1, 4, 0, objInfoAtestado[i].codCID);
    Gerador.wCampo(tcInt, '', 'qtdDiasAfast', 1, 3, 1, objInfoAtestado[i].qtDiasAfast);

    if objInfoAtestado[i].emitenteInst then
      GerarEmitente(objInfoAtestado[i].Emitente);

    Gerador.wGrupo('/infoAtestado');
  end;

  if objInfoAtestado.Count > 9 then
    Gerador.wAlerta('', 'infoAtestado', 'Lista de Informa��es de Atestados', ERR_MSG_MAIOR_MAXIMO + '9');
end;

procedure TEvtAfastTemp.GerarInfoCessao(objInfoCessao: TinfoCessao);
begin
  if objInfoCessao.cnpjCess <> EmptyStr then
  begin
    Gerador.wGrupo('infoCessao');

    Gerador.wCampo(tcStr, '', 'cnpjCess', 14, 14, 1, objInfoCessao.cnpjCess);
    Gerador.wCampo(tcStr, '', 'infOnus',   1,  1, 1, tpInfOnusToStr(objInfoCessao.infOnus));

    Gerador.wGrupo('/infoCessao');
  end;
end;

procedure TEvtAfastTemp.GerarInfoMandSind(objInfoMandSind: TInfoMandSind);
begin
  if objInfoMandSind.cnpjSind <> '' then
  begin
    Gerador.wGrupo('infoMandSind');

    Gerador.wCampo(tcStr, '', 'cnpjSind',     14, 14, 1, objInfoMandSind.cnpjSind);
    Gerador.wCampo(tcStr, '', 'infOnusRemun',  1,  1, 1, tpOnusRemunToStr(objInfoMandSind.infOnusRemun));

    Gerador.wGrupo('/infoMandSind');
  end;
end;

function TEvtAfastTemp.GerarXML: boolean;
begin
  try
    Self.VersaoDF := TACBreSocial(FACBreSocial).Configuracoes.Geral.VersaoDF;
     
    Self.Id := GerarChaveEsocial(now, self.ideEmpregador.NrInsc, self.Sequencial);

    GerarCabecalho('evtAfastTemp');
    Gerador.wGrupo('evtAfastTemp Id="' + Self.Id + '"');

    GerarIdeEvento2(self.IdeEvento);
    GerarIdeEmpregador(self.IdeEmpregador);
    GerarIdeVinculo(self.IdeVinculo);
    GerarInfoAfastamento(FinfoAfastamento);

    Gerador.wGrupo('/evtAfastTemp');

    GerarRodape;

    XML := Assinar(Gerador.ArquivoFormatoXML, 'evtAfastTemp');

    Validar(schevtAfastTemp);
  except on e:exception do
    raise Exception.Create(e.Message);
  end;

  Result := (Gerador.ArquivoFormatoXML <> '')
end;
(*
procedure TEvtAfastTemp.GerarAltEmpr(pAltEmpr: TAltEmpr);
begin
  //  N�o � mais gerado na vers�o 2.4.01
  Gerador.wGrupo('altEmpr');
    Gerador.wCampo(tcStr, '', 'codCID', 0,0,0, pAltEmpr.codCID);
    Gerador.wCampo(tcInt, '', 'qtdDiasAfast', 0,0,0, pAltEmpr.qtdDiasAfast);
    Gerador.wCampo(tcStr, '', 'nmEmit', 0,0,0, pAltEmpr.nmEmit);
    Gerador.wCampo(tcInt, '', 'ideOC', 0,0,0, eSIdeOCToStr(pAltEmpr.ideOC));
    Gerador.wCampo(tcStr, '', 'nrOc', 0,0,0, pAltEmpr.nrOc);
    Gerador.wCampo(tcStr, '', 'ufOC', 0,0,0, eSufToStr(pAltEmpr.ufOC));
  Gerador.wGrupo('/altEmpr');
end;
*)

(*
procedure TEvtAfastTemp.GerarAltAfast(objAltAfast: TaltAfastamento);
begin
  // N�o � mais gerado na vers�o 2.4.01
  if (Assigned(objAltAfast)) then
  begin
    if objAltAfast.dtAltMot > 0 then
    begin
      Gerador.wGrupo('altAfastamento');
        Gerador.wCampo(tcDat, '', 'dtAltMot', 0,0,0, objAltAfast.dtAltMot);
        Gerador.wCampo(tcStr, '', 'codMotAnt', 0,0,0, objAltAfast.codMotAnt);
        Gerador.wCampo(tcStr, '', 'codMotAfast', 0,0,0, objAltAfast.codMotAfast);
        Gerador.wCampo(tcStr, '', 'infoMesmoMtv', 0,0,0, eSSimNaoToStr(objAltAfast.infoMesmoMtv));
        Gerador.wCampo(tcStr, '', 'indEfRetroativo', 0,0,0, eSSimNaoToStr(objAltAfast.indEfRetroativo));
        Gerador.wCampo(tcInt, '', 'origAlt', 0,0,0, eSTpOrigemAltAfastToStr(objAltAfast.origAlt));
        Gerador.wCampo(tcStr, '', 'nrProcJud', 0,0,0, objAltAfast.nrProcJud);
        if objAltAfast.altEmprInst then
          GerarAltEmpr(objAltAfast.altEmpr);
      Gerador.wGrupo('/altAfastamento');
    end;
  end;
end;
 *)

procedure TEvtAfastTemp.GerarFimAfast(objFimAfast: TfimAfastamento);
begin
  if (Assigned(objFimAfast)) then
  begin
    if objFimAfast.dtTermAfast > 0 then
    begin
      Gerador.wGrupo('fimAfastamento');

      Gerador.wCampo(tcDat, '', 'dtTermAfast', 10, 10, 1, objFimAfast.dtTermAfast);

      Gerador.wGrupo('/fimAfastamento');
    end;
  end;
end;

procedure TEvtAfastTemp.GerarInfoRetif(objInfoRetif: TInfoRetif);
begin
  if (Assigned(objInfoRetif)) then
  begin
    if objInfoRetif.origRetif > 0 then
    begin
      Gerador.wGrupo('infoRetif');

      Gerador.wCampo(tcInt, '', 'origRetif', 1,  1, 1, objInfoRetif.origRetif);
      Gerador.wCampo(tcStr, '', 'tpProc',    1,  1, 0, eSTpProcessoToStr(objInfoRetif.tpProc));
      Gerador.wCampo(tcStr, '', 'nrProc',    1, 20, 0, objInfoRetif.nrProc);

      Gerador.wGrupo('/infoRetif');
    end;
  end;
end;

function TEvtAfastTemp.LerArqIni(const AIniString: String): Boolean;
var
  INIRec: TMemIniFile;
  Ok: Boolean;
  sSecao, sFim: String;
  I: Integer;
begin
  Result := False;

  INIRec := TMemIniFile.Create('');
  try
    LerIniArquivoOuString(AIniString, INIRec);

    with Self do
    begin
      sSecao := 'evtAfastTemp';
      Sequencial := INIRec.ReadInteger(sSecao, 'Sequencial', 0);

      sSecao := 'ideEvento';
      ideEvento.indRetif    := eSStrToIndRetificacao(Ok, INIRec.ReadString(sSecao, 'indRetif', '1'));
      ideEvento.NrRecibo    := INIRec.ReadString(sSecao, 'nrRecibo', EmptyStr);
      ideEvento.TpAmb       := eSStrTotpAmb(Ok, INIRec.ReadString(sSecao, 'tpAmb', '1'));
      ideEvento.ProcEmi     := eSStrToProcEmi(Ok, INIRec.ReadString(sSecao, 'procEmi', '1'));
      ideEvento.VerProc     := INIRec.ReadString(sSecao, 'verProc', EmptyStr);

      sSecao := 'ideEmpregador';
      ideEmpregador.OrgaoPublico := (TACBreSocial(FACBreSocial).Configuracoes.Geral.TipoEmpregador = teOrgaoPublico);
      ideEmpregador.TpInsc       := eSStrToTpInscricao(Ok, INIRec.ReadString(sSecao, 'tpInsc', '1'));
      ideEmpregador.NrInsc       := INIRec.ReadString(sSecao, 'nrInsc', EmptyStr);

      sSecao := 'ideVinculo';
      ideVinculo.CpfTrab   := INIRec.ReadString(sSecao, 'cpfTrab', EmptyStr);
      ideVinculo.NisTrab   := INIRec.ReadString(sSecao, 'nisTrab', EmptyStr);
      ideVinculo.Matricula := INIRec.ReadString(sSecao, 'matricula', EmptyStr);
      ideVinculo.codCateg  := INIRec.ReadInteger(sSecao, 'codCateg', 0);

      sSecao := 'iniAfastamento';
      infoAfastamento.iniAfastamento.DtIniAfast     := StringToDateTime(INIRec.ReadString(sSecao, 'dtIniAfast', '0'));
      infoAfastamento.iniAfastamento.codMotAfast    := eSStrTotpMotivosAfastamento(Ok, INIRec.ReadString(sSecao, 'codMotAfast', '00'));
      infoAfastamento.iniAfastamento.infoMesmoMtv   := eSStrToSimNao(Ok, INIRec.ReadString(sSecao, 'infoMesmoMtv', 'S'));
      infoAfastamento.iniAfastamento.tpAcidTransito := eSStrTotpTpAcidTransito(Ok, INIRec.ReadString(sSecao, 'tpAcidTransito', '1'));
      infoAfastamento.iniAfastamento.Observacao     := INIRec.ReadString(sSecao, 'observacao', '');

      I := 1;
      while true do
      begin
        // de 0 at� 9
        sSecao := 'infoAtestado' + IntToStrZero(I, 1);
        sFim   := INIRec.ReadString(sSecao, 'codCID', 'FIM');

        if (sFim = 'FIM') or (Length(sFim) <= 0) then
          break;

        with infoAfastamento.iniAfastamento.infoAtestado.Add do
        begin
          codCID      := sFim;
          qtDiasAfast := INIRec.ReadInteger(sSecao, 'qtDiasAfast', 0);

          sSecao := 'emitente' + IntToStrZero(I, 1);
          emitente.nmEmit := INIRec.ReadString(sSecao, 'nmEmit', EmptyStr);
          emitente.ideOC  := eSStrToIdeOC(Ok, INIRec.ReadString(sSecao, 'ideOC', '1'));
          emitente.nrOc   := INIRec.ReadString(sSecao, 'nrOc', EmptyStr);
          emitente.ufOC   := eSStrTouf(Ok, INIRec.ReadString(sSecao, 'ufOC', 'SP'));
        end;

        Inc(I);
      end;

      sSecao := 'infoCessao';
      infoAfastamento.iniAfastamento.infoCessao.cnpjCess := INIRec.ReadString(sSecao, 'cnpjCess', EmptyStr);
      infoAfastamento.iniAfastamento.infoCessao.infOnus  := StrTotpInfOnus(Ok, INIRec.ReadString(sSecao, 'infOnus', '1'));

      sSecao := 'infoMandSind';
      infoAfastamento.iniAfastamento.infoMandSind.cnpjSind     := INIRec.ReadString(sSecao, 'cnpjSind', EmptyStr);
      infoAfastamento.iniAfastamento.infoMandSind.infOnusRemun := StrTotpOnusRemun(Ok, INIRec.ReadString(sSecao, 'infOnusRemun', '1'));

      sSecao := 'infoRetif';
      infoAfastamento.infoRetif.origRetif := INIRec.ReadInteger(sSecao, 'origRetif', 1);
      infoAfastamento.infoRetif.tpProc    := eSStrToTpProcesso(Ok, INIRec.ReadString(sSecao, 'tpProc', '1'));
      infoAfastamento.infoRetif.nrProc    :=  INIRec.ReadString(sSecao, 'nrProc', EmptyStr);

      sSecao := 'fimAfastamento';
      infoAfastamento.fimAfastamento.dtTermAfast := StringToDateTime(INIRec.ReadString(sSecao, 'dtTermAfast', '0'));
    end;

    GerarXML;

    Result := True;
  finally
     INIRec.Free;
  end;
end;

end.
