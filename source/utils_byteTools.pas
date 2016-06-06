(*
 *	 Unit owner: d10.天地弦
 *	       blog: http://www.cnblogs.com/dksoft
 *     homePage: www.diocp.org
 *
 *   2015-02-22 08:29:43
 *     DIOCP-V5 发布
 *
 *)
 
unit utils_byteTools;

interface

uses
  SysUtils, Classes;

type
  {$IF RTLVersion<25}
  IntPtr=Integer;
  {$IFEND IntPtr}

  {$if CompilerVersion < 18} //before delphi 2007
  TBytes = array of Byte;
  {$ifend}

  TByteTools = class(TObject)
  public

     class function varToByteString(const v; len: Cardinal; Split: string = ' '):
         String;

     class function varToHexString(const v; len: Cardinal; Split: string = ' '):
         String;


     /// <summary>
     ///  16进制转 二进制
     /// </summary>
     class function HexToBin(pvHexStr:String; buf:Pointer):Integer;

     class function HexStrToBytes(pvHexStr:String): TBytes;

     /// <summary>
     ///  16进制字符到二进制
     /// </summary>
     class function HexValue(c: Char): Integer;

     /// <summary>
     ///   是否16进制字符
     /// </summary>
     class function IsHexChar(c: Char): Boolean;

     /// <summary>
     ///   高低位进行交换
     /// </summary>
     class function swap32(v:Integer):Integer;

     /// <summary>
     ///   高低位进行交换
     /// </summary>
     class function swap64(v:int64):Int64;

     /// <summary>
     ///   高低位进行交换
     /// </summary>
     class function swap16(const v):Word;


     class function SwapBuff(buf: Pointer; offset, len: Integer): Integer;

     /// <summary>
     ///   生成数据校验码
     /// </summary>
     class function verifyData(const buf; len:Cardinal): Cardinal;

     /// <summary>
     ///  生成数据校验码
     /// </summary>
     class function verifyStream(pvStream:TStream; len:Cardinal): Cardinal;

     /// <summary>
     ///   文件生成TBytes
     /// </summary>
     class function FileToBytes(pvFileName:string): TBytes;


     /// <summary>
     ///   
     /// </summary>
     class function GetBitUInt64(pvBuf:Pointer; pvStart, pvLen:Integer): UInt64;
  end;

implementation



class function TByteTools.FileToBytes(pvFileName:string): TBytes;
var
  lvStream:TFileStream;
begin
  lvStream := TFileStream.Create(pvFileName, fmOpenRead);
  try
    SetLength(Result, lvStream.Size);
    lvStream.Read(Result[0], lvStream.Size);
  finally
    lvStream.Free;
  end;
end;

class function TByteTools.GetBitUInt64(pvBuf:Pointer; pvStart, pvLen:Integer): UInt64;
var
  lvBytes:TBytes;
begin
  Assert(pvLen<=8);
  SetLength(lvBytes, pvLen);
  Move(Pointer(IntPtr(pvBuf) + pvStart)^, lvBytes[0], pvLen);

  Result := PInt64(@lvBytes[0])^;

end;

class function TByteTools.HexStrToBytes(pvHexStr:String): TBytes;
var
  lvStr:String;
  l, r:Integer;
begin
  lvStr := StringReplace(pvHexStr, ' ', '', [rfReplaceAll]);
  lvStr := StringReplace(lvStr, #13, '', [rfReplaceAll]);
  lvStr := StringReplace(lvStr, #10, '', [rfReplaceAll]);
  l := Length(lvStr);
  l := l shr 1;
  SetLength(Result, l);
  r := HexToBin(lvStr, @Result[0]);
  Assert(r = l, 'TByteTools.HexStrToBytes');
end;

class function TByteTools.HexToBin(pvHexStr: String;
  buf: Pointer): Integer;
var
  l: Integer;
  p, ps: PChar;
  pd: PByte;
begin
  l := Length(pvHexStr);
  p := PChar(pvHexStr);
  ps := p;
  pd := PByte(buf);
  Result := 0;
  while p - ps < l do
  begin
    if IsHexChar(p[0]) and IsHexChar(p[1]) then
    begin
      pd^ := (HexValue(p[0]) shl 4) + HexValue(p[1]);
      inc(Result);
      Inc(pd);
      Inc(p, 2);
      end
    else
    begin
      Exit;
    end;
  end;
end;

class function TByteTools.HexValue(c: Char): Integer;
begin
  if (c >= '0') and (c <= '9') then
    Result := Ord(c) - Ord('0')
  else if (c >= 'a') and (c <= 'f') then
    Result := 10 + Ord(c) - Ord('a')
  else
    Result := 10 + Ord(c) - Ord('A');
end;

class function TByteTools.IsHexChar(c: Char): Boolean;
begin
  Result := ((c >= '0') and (c <= '9')) or ((c >= 'a') and (c <= 'f')) or ((c >= 'A') and (c <= 'F'));
end;


class function TByteTools.swap16(const v): Word;
begin
  // FF, EE : EE->1, FF->2
  PByte(@result)^ := PByte(IntPtr(@v) + 1)^;
  PByte(IntPtr(@result) + 1)^ := PByte(@v)^;
end;

class function TByteTools.swap32(v: Integer): Integer;
var
  lvPByte : PByte;
begin
  result := v;
  lvPByte := PByte(@result);
  PByte(lvPByte)^ := byte(v shr 24);
  PByte(IntPtr(lvPByte) + 1)^ := byte(v shr 16);
  PByte(IntPtr(lvPByte) + 2)^ := byte(v shr 8);
  PByte(IntPtr(lvPByte) + 3)^ := byte(v);
end;

class function TByteTools.swap64(v: int64): Int64;
var
  lvPByte : PByte;
begin
  result := v;
  lvPByte := PByte(@result);
  PByte(lvPByte)^ := byte(v shr 56);  //8 * 7
  PByte(IntPtr(lvPByte) + 1)^ := byte(v shr 48); //6
  PByte(IntPtr(lvPByte) + 2)^ := byte(v shr 40); //5
  PByte(IntPtr(lvPByte) + 3)^ := byte(v shr 32); //4
  PByte(IntPtr(lvPByte) + 4)^ := byte(v shr 24); //3
  PByte(IntPtr(lvPByte) + 5)^ := byte(v shr 16); //2
  PByte(IntPtr(lvPByte) + 6)^ := byte(v shr 8); //2
  PByte(IntPtr(lvPByte) + 7)^ := byte(v); //1
end;

class function TByteTools.SwapBuff(buf: Pointer; offset, len: Integer): Integer;
var
  lvStart, lvEnd: PByte;
  lvByte: Byte;
begin
  lvStart := PByte(buf);
  Inc(lvStart, offset);
  
  lvEnd := lvStart;
  Inc(lvEnd, len - 1);

  while IntPtr(lvStart) < IntPtr(lvEnd) do
  begin
    lvByte := lvStart^;
    lvStart^ := lvEnd^;
    lvEnd^ := lvByte;
    Inc(lvStart);
    Dec(lvEnd);
  end;
end;

class function TByteTools.varToByteString(const v; len: Cardinal; Split: string
    = ' '): String;
var
  lvSource:PByte;
  i: Integer;
begin
  lvSource := PByte(@v);
  for i := 1 to len do
  begin
    Result := Result + IntToStr(lvSource^) + Split;
    Inc(lvSource);
  end;

end;

class function TByteTools.varToHexString(const v; len: Cardinal; Split: string
    = ' '): String;
var
  lvSource:PByte;
  i: Integer;
begin
  lvSource := PByte(@v);
  for i := 1 to len do
  begin
    Result := Result + IntToHex(lvSource^, 2) + Split;
    Inc(lvSource);
  end;   
end;

class function TByteTools.verifyData(const buf; len: Cardinal): Cardinal;
var
  i:Cardinal;
  p:PByte;
begin
  i := 0;
  Result := 0;
  p := PByte(@buf);
  while i < len do
  begin
    Result := Result + p^;
    Inc(p);
    Inc(i);
  end;
end;

class function TByteTools.verifyStream(pvStream:TStream; len:Cardinal):
    Cardinal;
var
  l, j:Cardinal;
  lvBytes:TBytes;
begin
  SetLength(lvBytes, 1024);

  if len = 0 then
  begin
    j := pvStream.Size - pvStream.Position;
  end else
  begin
    j := len;
  end;

  Result := 0;

  while j > 0 do
  begin
    if j <1024 then l := j else l := 1024;

    pvStream.ReadBuffer(lvBytes[0], l);

    Result := Result + verifyData(lvBytes[0], l);
    Dec(j, l);
  end;
end;

end.
