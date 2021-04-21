unit uAmazonAPIS3;

interface

uses
 System.SysUtils, Data.Cloud.CloudAPI, Data.Cloud.AmazonAPI, System.Classes, IdSSLOpenSSLHeaders,
 System.JSON, System.NetEncoding;

type

TAmanzonAPIS3 = class
private
    fAmazonConnetion: TAmazonConnectionInfo;
    fStorageService: TAmazonStorageService;
    fResponseAmazon: TCloudResponseInfo;
    fsAmazonRegion: string;
    fteste: string;
    fBucket: string;
    fsStorageEndPoint: string;
    fsAccountKey: string;
    fsAccountName: string;
    fArqStream: TBytesStream;
    fCaminhoArq: string;
    fDestinoAmazon: string;
    fiStatus: integer;
    fResposta: TJSONValue;
    fbb: TBytes;
    fRespostaString: String;
    procedure SetsAmazonRegion(const Value: string);
    procedure SetBucket(const Value: string);
    procedure SetsAccountKey(const Value: string);
    procedure SetsAccountName(const Value: string);
    procedure SetsStorageEndPoint(const Value: string);
    procedure SetArqStream(const Value: TBytesStream);
    procedure SetCaminhoArq(const Value: string);

public
   Constructor Create; virtual;
   destructor  Destroy; override;
   function AmazonUpload: Boolean;
   function AmazonDownload: Boolean;

published
   property AmazonConnection: TAmazonConnectionInfo read fAmazonConnetion write fAmazonConnetion;
   property StorageService  : TAmazonStorageService read fStorageService write fStorageService;
   property ResponseAmazon  : TCloudResponseInfo read fResponseAmazon write fResponseAmazon;
   property sAmazonRegion   : string       read fsAmazonRegion write SetsAmazonRegion;
   property Bucket          : string       read fBucket write SetBucket;
   property sAccountKey     : string       read fsAccountKey write SetsAccountKey;
   property sAccountName    : string       read fsAccountName write SetsAccountName;
   property sStorageEndPoint: string       read fsStorageEndPoint write SetsStorageEndPoint;
   property ArqStream       : TBytesStream read fArqStream write SetArqStream;
   property CaminhoArq      : string       read fCaminhoArq write SetCaminhoArq;
   property DestinoAmazon   : string       read fDestinoAmazon write fDestinoAmazon;
   property iStatus         : integer      read fiStatus write fiStatus;
   property Resposta        : TJSONValue   read fResposta write fResposta;
   property RespostaString  : String       read fRespostaString write fRespostaString;
   property bb              : TBytes       read fbb write fbb;
end;
implementation


{ TAmanzonAPIS3 }

function TAmanzonAPIS3.AmazonUpload: Boolean;
//var
//   bytes: tbytes;
begin
   Result := False;
   try
      Self.ArqStream.LoadFromFile(CaminhoArq);
      Self.ArqStream.Position := 0;
      SetLength(fbb, Self.ArqStream.Size);
      Self.ArqStream.ReadBuffer(fbb, Self.ArqStream.Size);
      AmazonConnection.AccountKey          := sAccountKey;
      AmazonConnection.AccountName         := sAccountName;
      AmazonConnection.StorageEndpoint     := sStorageEndPoint;
      AmazonConnection.UseDefaultEndpoints := False;
      StorageService.UploadObject(Bucket, DestinoAmazon +  ExtractFileName(CaminhoArq),fbb,False,nil,nil,amzbaPrivate,ResponseAmazon);
      iStatus  := ResponseAmazon.StatusCode;
      Resposta       := TJSONObject.ParseJSONValue(ResponseAmazon.StatusMessage);
      RespostaString := ResponseAmazon.StatusMessage;
      if ResponseAmazon.StatusCode = 200 then Result := True;
   except
      on e: Exception do begin
         Result   := False;
         iStatus  := -1;
         Resposta := TJSONObject.ParseJSONValue('Erro ' + e.Message);
      end;
   end;
end;

function TAmanzonAPIS3.AmazonDownload: Boolean;
begin
   Result := False;
   try
      AmazonConnection.AccountKey          := sAccountKey;
      AmazonConnection.AccountName         := sAccountName;
      AmazonConnection.StorageEndpoint     := sStorageEndPoint;
      AmazonConnection.UseDefaultEndpoints := False;
      StorageService.GetObject(Bucket,  DestinoAmazon +  UpperCase(CaminhoArq),  ArqStream, ResponseAmazon);
      iStatus  := ResponseAmazon.StatusCode;
      Resposta := TJSONObject.ParseJSONValue(ResponseAmazon.StatusMessage);
      if ResponseAmazon.StatusCode = 200 then Result := True;
   except
      on e: Exception do begin
         Result   := False;
         iStatus  := -1;
         Resposta := TJSONObject.ParseJSONValue('Erro ' + e.Message);
      end;
   end;
end;

constructor TAmanzonAPIS3.Create;
begin
   AmazonConnection := TAmazonConnectionInfo.Create(nil);
   StorageService   := TAmazonStorageService.Create(AmazonConnection);
   ResponseAmazon   := TCloudResponseInfo.Create;
   ArqStream        := TBytesStream.Create;
end;

destructor TAmanzonAPIS3.Destroy;
begin
   FreeAndNil(AmazonConnection);
   FreeAndNil(StorageService);
   FreeAndNil(ResponseAmazon);
   ArqStream.Clear;
//   FreeAndNil(ArqStream);
   inherited;
end;


procedure TAmanzonAPIS3.SetArqStream(const Value: TBytesStream);
begin
  fArqStream := Value;
end;

procedure TAmanzonAPIS3.SetBucket(const Value: string);
begin
   if Value = '' then begin
      raise Exception.Create('Bucket não informado');
   end;
   fBucket := Value;
end;

procedure TAmanzonAPIS3.SetCaminhoArq(const Value: string);
begin
  fCaminhoArq := Value;
end;

procedure TAmanzonAPIS3.SetsAccountKey(const Value: string);
begin
   if Value = '' then begin
      raise Exception.Create('Accoun tKey não informado');
   end;
   fsAccountKey := Value;
end;

procedure TAmanzonAPIS3.SetsAccountName(const Value: string);
begin
   if Value = '' then begin
      raise Exception.Create('Account Name não informado');
   end;
   fsAccountName := Value;
end;

procedure TAmanzonAPIS3.SetsAmazonRegion(const Value: string);
begin
   if Value = '' then begin
      raise Exception.Create('Não foi informado a região.');
   end;
   fsAmazonRegion := Value;
end;

procedure TAmanzonAPIS3.SetsStorageEndPoint(const Value: string);
begin
   fsStorageEndPoint := Value;
end;

end.
