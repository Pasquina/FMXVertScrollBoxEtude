program VKScrollDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  pVKScrollDemo in 'pVKScrollDemo.pas' {fVKLogger};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfVKLogger, fVKLogger);
  Application.Run;
end.
