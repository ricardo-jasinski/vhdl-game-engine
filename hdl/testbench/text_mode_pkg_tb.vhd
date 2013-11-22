use work.text_mode_pkg.all;
use work.tbu_text_out_pkg.all;
use work.colors_pkg.all;

use work.resource_handles_helper_pkg.all;

entity text_mode_pkg_tb is
end;

architecture testbench of text_mode_pkg_tb is
   
       
    constant HELLO_WORLD_STRING: text_mode_string_type := (
        x => 0,
        y => 0,
        text => "Hello world!!!  ",
        visible => true
    );
    
    constant SCORE_STRING: text_mode_string_type := (
        x => 0,
        y => 10,
        text => "SCORE:     0    ",
        visible => true
    );
    
    constant STRINGS: text_mode_strings_type := (
        HELLO_WORLD_STRING,
        SCORE_STRING
    );
begin



    process begin
        for y in 0 to 11 loop
            for x in 0 to 79 loop
                --put( to_string(character_at_x_y(x,y)) );
                print( to_string(character_at_x_y(x, y, strings)), newline => false );
            end loop;
            print("");
        end loop;
        
        for y in 0 to 11 loop
            for x in 0 to 79 loop
                --put( to_string(character_at_x_y(x,y)) );
                if text_pixel_at_x_y(x, y, strings) then
                    print( "#", newline => false );
                else
                    print( " ", newline => false );
                end if;
            end loop;
            print("");
        end loop;
        
        put(to_string( game_strings_count ));

        
        std.env.finish;
    end process;

end;