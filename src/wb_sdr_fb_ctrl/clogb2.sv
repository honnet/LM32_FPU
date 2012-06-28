function integer clogb2;
input [31:0]  value;
begin
  int i ;
  if ((value == 0) || (value == 1)) clogb2 = 0 ;
  else
    begin
    value = value-1 ;
    for (i = 0; i < 32; i++)
      if (value[i]) clogb2 = i+1 ;
  end
end
endfunction
