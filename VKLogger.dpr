program VKLogger;

uses
  System.StartUpCopy,
  FMX.Forms,
  pVKLogger in 'pVKLogger.pas' {fVKLogger};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfVKLogger, fVKLogger);
  Application.Run;
end.
