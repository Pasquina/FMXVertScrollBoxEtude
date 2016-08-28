unit pVKLogger;

{
   Copyright © 2016 Milan Vydareny

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

	For more information contact:
	Milan Vydareny
	Milan@VyDevSoft.com

}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Layouts;

type
  TfVKLogger = class(TForm)
    mVKLog: TMemo;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    GPLEditBoxes: TGridPanelLayout;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    cbAlwaysShow: TCheckBox;
    btFinal: TButton;
    procedure cbAlwaysShowChange(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormCreate(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormFocusChanged(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fVKLogger: TfVKLogger;

implementation

{$R *.fmx}
{$R *.LgXhdpiTb.fmx ANDROID}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.XLgXhdpiTb.fmx ANDROID}

{ Set VK Auto Show Mode in response to user check box.  }

procedure TfVKLogger.cbAlwaysShowChange(Sender: TObject);
begin
  if cbAlwaysShow.IsChecked then                       // if auto show checked
    VKAutoShowMode := TVKAutoShowMode.Always           // always display the VK
  else
    VKAutoShowMode := TVKAutoShowMode.DefinedBySystem; // use system default
end;

{ Initialize the Boolean string equivalents. }

procedure TfVKLogger.FormCreate(Sender: TObject);
begin
  SetLength(TrueBoolStrs, 1);            // array size
  TrueBoolStrs[0] := 'True';             // first entry
  SetLength(FalseBoolStrs, 1);           // array size
  FalseBoolStrs[0] := 'False';           // first entry
end;

{ Log the focus change event parameters. }

procedure TfVKLogger.FormFocusChanged(Sender: TObject);
var
  LSender: String;                       // class name of sender
  LFocused: TFMXObject;                  // the focused object
  LFocusedClass: String;                 // the focused class
  LFocusedName: String;                  // the focused component name
begin
  if Assigned(Sender) then               // test for null sender
    LSender := Sender.ToString           // if assigned get class name
  else
    LSender := '<Null>';                 // unassigned are null

  if Assigned(Focused) then              // test for focused object located
  begin
    LFocused := Focused.GetObject;       // get focused object
    LFocusedClass := LFocused.ClassName; // get focused object class name
    LFocusedName := LFocused.Name;       // get focused object component name
  end
  else
  begin
    LFocusedClass := '<Unknown>';        // unknown class name
    LFocusedName := '<Unknown>';         // unknown component name
  end;

  mVKLog.Lines.Add(Format('Sender: %s; Focused: %s, %s', [LSender, LFocusedClass, LFocusedName]));
end;

{ Procedure to intercept navigation key to help user move from field to field.
  Note that it is always the return key, regardless of the key label. It is up
  to the designer to specify the label on the key (in the field properties) to
  say NEXT, DONE, SEND, etc. }

procedure TfVKLogger.FormKeyDown(
  Sender: TObject;
  var Key: Word;
  var KeyChar: Char;
  Shift: TShiftState);
begin
  if Key = vkReturn then                    // if Return pressed
  begin
    Key := vkTab;                           // change the key to a Tab (causes navigation)
    KeyDown(Key, KeyChar, Shift);           // execute the form's keydown to effect navigation
  end;
end;

{ Log a line when the Keyboard is hidden. }

procedure TfVKLogger.FormVirtualKeyboardHidden(
  Sender: TObject;
  KeyboardVisible: Boolean;
  const Bounds: TRect);
var
  LSender: String;
begin
  if Assigned(Sender) then                                   // test for null sender
    LSender := Sender.ToString                               // if assigned get class name
  else
    LSender := '<Null>';                                     // unassigned are null
  mVKLog.Lines.Add(Format(                                   // log the hidden event
    'Sender: %s; Hidden: V: %s; W: %d; H: %d; X: %d; Y: %d', // parameter format string
    [Sender.ToString, BoolToStr(KeyboardVisible, True), Bounds.Width, Bounds.Height, Bounds.Location.X,
    Bounds.Location.Y]))
end;

{ Log a line when the Keyboard is shown. }

procedure TfVKLogger.FormVirtualKeyboardShown(
  Sender: TObject;
  KeyboardVisible: Boolean;
  const Bounds: TRect);
var
  LSender: String;
begin
  if Assigned(Sender) then                                  // test for null sender
    LSender := Sender.ToString                              // if assigned get class name
  else
    LSender := '<Null>';                                    // unassigned are null
  mVKLog.Lines.Add(Format(                                  // log the shown event
    'Sender: %s; Shown: V: %s; W: %d; H: %d; X: %d; Y: %d', // parameter format string
    [Sender.ToString, BoolToStr(KeyboardVisible, True), Bounds.Width, Bounds.Height, Bounds.Location.X,
    Bounds.Location.Y]))
end;

end.
