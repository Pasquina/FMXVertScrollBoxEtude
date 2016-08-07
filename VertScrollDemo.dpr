program VertScrollDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  pVertScrollDemo in 'pVertScrollDemo.pas' {fVertScrollDemo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfVertScrollDemo, fVertScrollDemo);
  Application.Run;
end.
