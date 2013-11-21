library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package tbu_text_out_pkg is
    procedure put(text: string);
    procedure print(text: string; newline: boolean := true);
    procedure put(value: real);
    procedure putv(value: std_logic_vector);
    procedure putv(value: unsigned);

end;

package body tbu_text_out_pkg is

    procedure put(text: string) is
        variable s: line;
    begin
        write(s, text);
        writeline(output,s);
    end;
    
    shared variable current_line: line;
    
    procedure print(text: string; newline: boolean := true) is
        --variable s: line;
    begin
        write(current_line, text);
        if (newline) then
            writeline(output, current_line);
        end if;
    end;

    procedure put(value: real) is begin
        -- synthesis translate_off
        put(to_string(value));
        -- synthesis translate_on
    end;

    procedure putv(value: std_logic_vector) is begin
        -- synthesis translate_off
        put(to_string(value));
        -- synthesis translate_on
    end;

    procedure putv(value: unsigned) is begin
        -- synthesis translate_off
        put(to_string(value));
        -- synthesis translate_on
    end;

end;
