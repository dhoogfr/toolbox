create or replace package body utils

as
    
    g_bad_chars   varchar2(256);
    g_a_bad_char  varchar2(256);
    
    function strip_bad( p_string in varchar2 ) return varchar2

    is

    begin

       return replace( translate( p_string,
                                  g_bad_chars,
                                  g_a_bad_char
                                 ),
                       substr( g_a_bad_char,
                               1,
                               1
                             ),
                       ''
                     );
   end;
   
     
   begin
       for i in 0..255 loop
           if ( i not between ascii('a') and ascii('z') AND
                i not between ascii('A') and ascii('Z') AND
               i not between ascii('0') and ascii('9') )
          then
               g_bad_chars := g_bad_chars || chr(i);
           end if;
      end loop;
       g_a_bad_char := rpad(
                         substr(g_bad_chars,1,1),
                         length(g_bad_chars),
                         substr(g_bad_chars,1,1));
   end;
   /
